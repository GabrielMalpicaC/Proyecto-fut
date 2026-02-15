import { UserRole } from '@/common/enums';

declare global {
  namespace Express {
    interface Request {
      traceId?: string;
      user?: {
        sub: string;
        email: string;
        roles: UserRole[];
      };
    }
  }
}

export {};
