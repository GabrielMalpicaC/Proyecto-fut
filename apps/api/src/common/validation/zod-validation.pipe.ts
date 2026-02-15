import { ArgumentMetadata, Injectable, PipeTransform } from '@nestjs/common';
import { ZodSchema } from 'zod';
import { AppError } from '../errors/app-error';

@Injectable()
export class ZodValidationPipe implements PipeTransform {
  constructor(private readonly schema: ZodSchema) {}

  transform(value: unknown, metadata: ArgumentMetadata): unknown {
    void metadata;
    const parsed = this.schema.safeParse(value);

    if (!parsed.success) {
      throw new AppError(
        'VALIDATION_ERROR',
        'Invalid request payload',
        400,
        parsed.error.flatten()
      );
    }

    return parsed.data;
  }
}
