import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { UserRole } from '@/common/enums';
import { AppError } from '../errors/app-error';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private readonly allowedRoles: UserRole[]) {}

  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest<Express.Request>();
    const userRoles = request.user?.roles ?? [];
    const allowed = this.allowedRoles.some((role) => userRoles.includes(role));

    if (!allowed) {
      throw new AppError('FORBIDDEN', 'Insufficient permissions', 403);
    }

    return true;
  }
}
