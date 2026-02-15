import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { UserRole } from '@/common/enums';
import * as bcrypt from 'bcrypt';
import { AppError } from '@/common/errors/app-error';
import { IdentityAccessRepository } from '../infrastructure/identity-access.repository';

type DbRoleAssignment = { id: string; createdAt: Date; userId: string; role: string };

@Injectable()
export class IdentityAccessService {
  constructor(
    private readonly repository: IdentityAccessRepository,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService
  ) {}

  async register(input: { email: string; fullName: string; password: string; roles?: UserRole[] }) {
    const existing = await this.repository.findByEmail(input.email);
    if (existing) {
      throw new AppError('EMAIL_ALREADY_EXISTS', 'Email already registered', 409);
    }

    const passwordHash = await bcrypt.hash(input.password, 10);
    const user = await this.repository.createUser({
      email: input.email,
      fullName: input.fullName,
      passwordHash,
      roles: input.roles?.length ? input.roles : [UserRole.PLAYER]
    });

    return this.issueTokens(
      user.id,
      user.email,
      user.roleAssignments.map((assignment: DbRoleAssignment) => assignment.role as UserRole)
    );
  }

  async login(input: { email: string; password: string }) {
    const user = await this.repository.findByEmail(input.email);
    if (!user || !(await bcrypt.compare(input.password, user.passwordHash))) {
      throw new AppError('INVALID_CREDENTIALS', 'Invalid credentials', 401);
    }

    return this.issueTokens(
      user.id,
      user.email,
      user.roleAssignments.map((assignment: DbRoleAssignment) => assignment.role as UserRole)
    );
  }

  async refresh(refreshToken: string) {
    const storedToken = await this.repository.findRefreshToken(refreshToken);
    if (!storedToken || storedToken.expiresAt < new Date()) {
      throw new AppError('INVALID_REFRESH_TOKEN', 'Refresh token invalid or expired', 401);
    }

    await this.repository.deleteRefreshToken(refreshToken);
    const roles = storedToken.user.roleAssignments.map(
      (assignment: DbRoleAssignment) => assignment.role as UserRole
    );

    return this.issueTokens(storedToken.user.id, storedToken.user.email, roles);
  }

  private async issueTokens(userId: string, email: string, roles: UserRole[]) {
    const accessToken = this.jwtService.sign(
      { sub: userId, email, roles },
      {
        secret: this.configService.get<string>('auth.accessSecret'),
        expiresIn: this.configService.get<string>('auth.accessExpiresIn')
      }
    );

    const refreshToken = this.jwtService.sign(
      { sub: userId },
      {
        secret: this.configService.get<string>('auth.refreshSecret'),
        expiresIn: this.configService.get<string>('auth.refreshExpiresIn')
      }
    );

    const decoded = this.jwtService.decode(refreshToken) as { exp: number };
    await this.repository.createRefreshToken(userId, refreshToken, new Date(decoded.exp * 1000));

    return { accessToken, refreshToken };
  }
}
