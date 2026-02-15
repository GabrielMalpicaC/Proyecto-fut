import { ArgumentsHost, Catch, ExceptionFilter, HttpException, HttpStatus } from '@nestjs/common';
import { Request, Response } from 'express';
import { AppError } from '../errors/app-error';

@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    if (exception instanceof AppError) {
      response.status(exception.status).json({
        code: exception.code,
        message: exception.message,
        details: exception.details,
        traceId: request.traceId
      });
      return;
    }

    if (exception instanceof HttpException) {
      const status = exception.getStatus();
      const payload = exception.getResponse();
      response.status(status).json({
        code: `HTTP_${status}`,
        message:
          typeof payload === 'string' ? payload : ((payload as any).message ?? 'Request failed'),
        details: typeof payload === 'string' ? undefined : payload,
        traceId: request.traceId
      });
      return;
    }

    response.status(HttpStatus.INTERNAL_SERVER_ERROR).json({
      code: 'INTERNAL_SERVER_ERROR',
      message: 'Unexpected error',
      traceId: request.traceId
    });
  }
}
