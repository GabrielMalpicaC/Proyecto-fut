import { Injectable } from '@nestjs/common';
import { PrismaService } from '@/infrastructure/prisma/prisma.service';

@Injectable()
export class TeamsRepository {
  constructor(private readonly prisma: PrismaService) {}

  createTeam(ownerId: string, name: string) {
    return this.prisma.team.create({
      data: { name, ownerId, members: { create: { userId: ownerId, status: 'ACTIVE' } } }
    });
  }

  createInvitation(teamId: string, invitedUserId: string) {
    return this.prisma.teamInvitation.upsert({
      where: { teamId_invitedUserId: { teamId, invitedUserId } },
      update: { status: 'PENDING' },
      create: { teamId, invitedUserId, status: 'PENDING' }
    });
  }

  async acceptInvitation(teamId: string, userId: string) {
    await this.prisma.teamInvitation.update({
      where: { teamId_invitedUserId: { teamId, invitedUserId: userId } },
      data: { status: 'ACCEPTED' }
    });

    return this.prisma.teamMember.upsert({
      where: { teamId_userId: { teamId, userId } },
      update: { status: 'ACTIVE' },
      create: { teamId, userId, status: 'ACTIVE' }
    });
  }
}
