import { Injectable } from '@nestjs/common';
import { PrismaService } from '@/infrastructure/prisma/prisma.service';

@Injectable()
export class TeamsRepository {
  constructor(private readonly prisma: PrismaService) {}

  createTeam(
    ownerId: string,
    input: {
      name: string;
      description?: string;
      maxPlayers: number;
      footballType: number;
      formation: string;
      shieldUrl: string;
    }
  ) {
    return this.prisma.team.create({
      data: {
        name: input.name,
        ownerId,
        maxPlayers: input.maxPlayers,
        footballType: input.footballType,
        formation: input.formation,
        shieldUrl: input.shieldUrl,
        description: input.description,
        members: { create: { userId: ownerId, status: 'ACTIVE', role: 'LEADER' } }
      }
    });
  }

  createInvitation(teamId: string, invitedUserId: string) {
    return this.prisma.teamInvitation.upsert({
      where: { teamId_invitedUserId: { teamId, invitedUserId } },
      update: { status: 'PENDING' },
      create: { teamId, invitedUserId, status: 'PENDING' }
    });
  }

  getOpenTeams() {
    return this.prisma.team.findMany({
      where: { isRecruiting: true },
      include: {
        owner: { select: { id: true, fullName: true } },
        members: { where: { status: 'ACTIVE' }, select: { id: true } },
        _count: { select: { applications: true } }
      },
      orderBy: { createdAt: 'desc' }
    });
  }

  getTeamProfile(teamId: string) {
    return this.prisma.team.findUnique({
      where: { id: teamId },
      include: {
        owner: { select: { id: true, fullName: true, avatarUrl: true } },
        members: {
          where: { status: 'ACTIVE' },
          orderBy: [{ role: 'asc' }, { user: { fullName: 'asc' } }],
          select: {
            role: true,
            matchesPlayed: true,
            goals: true,
            assists: true,
            yellowCards: true,
            redCards: true,
            cleanSheets: true,
            user: {
              select: { id: true, fullName: true, avatarUrl: true, preferredPositions: true }
            }
          }
        },
        _count: {
          select: {
            applications: { where: { status: 'PENDING' } }
          }
        }
      }
    });
  }

  updateTeam(
    teamId: string,
    data: {
      name?: string;
      description?: string;
      formation?: string;
      footballType?: number;
      maxPlayers?: number;
      shieldUrl?: string;
      isRecruiting?: boolean;
    }
  ) {
    return this.prisma.team.update({
      where: { id: teamId },
      data
    });
  }

  async applyToTeam(teamId: string, userId: string, message?: string) {
    return this.prisma.teamApplication.upsert({
      where: { teamId_userId: { teamId, userId } },
      update: { status: 'PENDING', message, reviewedAt: null },
      create: { teamId, userId, message, status: 'PENDING' }
    });
  }

  listApplications(teamId: string) {
    return this.prisma.teamApplication.findMany({
      where: { teamId, status: 'PENDING' },
      orderBy: { createdAt: 'asc' },
      include: {
        user: {
          select: {
            id: true,
            fullName: true,
            avatarUrl: true,
            bio: true,
            preferredPositions: true,
            posts: { orderBy: { createdAt: 'desc' }, take: 3 },
            stories: { orderBy: { createdAt: 'desc' }, take: 3 }
          }
        }
      }
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
      create: { teamId, userId, status: 'ACTIVE', role: 'MEMBER' }
    });
  }

  async reviewApplication(teamId: string, applicantUserId: string, approve: boolean) {
    await this.prisma.teamApplication.update({
      where: { teamId_userId: { teamId, userId: applicantUserId } },
      data: {
        status: approve ? 'ACCEPTED' : 'REJECTED',
        reviewedAt: new Date()
      }
    });

    if (!approve) return { ok: true };

    await this.prisma.teamMember.upsert({
      where: { teamId_userId: { teamId, userId: applicantUserId } },
      update: { status: 'ACTIVE', role: 'MEMBER' },
      create: { teamId, userId: applicantUserId, status: 'ACTIVE', role: 'MEMBER' }
    });

    return { ok: true };
  }

  getUserActiveMembership(userId: string) {
    return this.prisma.teamMember.findFirst({
      where: { userId, status: 'ACTIVE' },
      include: { team: true }
    });
  }

  getActiveMembersCount(teamId: string) {
    return this.prisma.teamMember.count({ where: { teamId, status: 'ACTIVE' } });
  }

  getTeamById(teamId: string) {
    return this.prisma.team.findUnique({ where: { id: teamId } });
  }

  getActiveMember(teamId: string, userId: string) {
    return this.prisma.teamMember.findFirst({ where: { teamId, userId, status: 'ACTIVE' } });
  }

  updateMemberRole(teamId: string, userId: string, role: string) {
    return this.prisma.teamMember.update({
      where: { teamId_userId: { teamId, userId } },
      data: { role }
    });
  }

  removeMember(teamId: string, userId: string) {
    return this.prisma.teamMember.update({
      where: { teamId_userId: { teamId, userId } },
      data: { status: 'REMOVED' }
    });
  }
}
