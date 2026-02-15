import { Injectable } from '@nestjs/common';
import { UserRole } from '@/common/enums';
import { PrismaService } from '@/infrastructure/prisma/prisma.service';

@Injectable()
export class IdentityAccessRepository {
  constructor(private readonly prisma: PrismaService) {}

  async createUser(data: {
    email: string;
    fullName: string;
    passwordHash: string;
    roles: UserRole[];
  }) {
    return this.prisma.user.create({
      data: {
        email: data.email,
        fullName: data.fullName,
        passwordHash: data.passwordHash,
        roleAssignments: {
          create: data.roles.map((role) => ({ role }))
        },
        wallet: { create: {} }
      },
      include: { roleAssignments: true }
    });
  }

  async findByEmail(email: string) {
    return this.prisma.user.findUnique({ where: { email }, include: { roleAssignments: true } });
  }

  async createRefreshToken(userId: string, token: string, expiresAt: Date) {
    return this.prisma.refreshToken.create({ data: { userId, token, expiresAt } });
  }

  async findRefreshToken(token: string) {
    return this.prisma.refreshToken.findUnique({
      where: { token },
      include: { user: { include: { roleAssignments: true } } }
    });
  }

  async deleteRefreshToken(token: string) {
    return this.prisma.refreshToken.deleteMany({ where: { token } });
  }

  async assignRole(userId: string, role: UserRole): Promise<void> {
    await this.prisma.roleAssignment.upsert({
      where: { userId_role: { userId, role } },
      create: { userId, role },
      update: {}
    });
  }
}
