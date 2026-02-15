import { UserRole } from '@/common/enums';

export interface AuthUser {
  id: string;
  email: string;
  fullName: string;
  roles: UserRole[];
}
