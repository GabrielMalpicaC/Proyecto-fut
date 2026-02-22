import { Injectable } from '@nestjs/common';
import { PrismaService } from '@/infrastructure/prisma/prisma.service';

@Injectable()
export class MatchesRepository {
  constructor(private readonly prisma: PrismaService) {}

  getActiveMembership(userId: string) {
    return this.prisma.teamMember.findFirst({
      where: { userId, status: 'ACTIVE' },
      include: { team: true }
    });
  }

  async createQueueAndTryMatch(teamId: string, mode: 'CASUAL' | 'COMPETITIVE') {
    return this.prisma.$transaction(async (tx) => {
      const alreadySearching = await tx.matchQueue.findFirst({
        where: { teamId, mode, status: 'SEARCHING' }
      });
      if (alreadySearching) {
        return { type: 'already_searching' as const, queue: alreadySearching };
      }

      const rivalQueue = await tx.matchQueue.findFirst({
        where: {
          mode,
          status: 'SEARCHING',
          teamId: { not: teamId }
        },
        orderBy: { createdAt: 'asc' }
      });

      const myQueue = await tx.matchQueue.create({
        data: { teamId, mode, status: 'SEARCHING' }
      });

      if (!rivalQueue) {
        return { type: 'queued' as const, queue: myQueue };
      }

      const now = new Date();

      const match = await tx.match.create({
        data: {
          mode,
          status: 'SCHEDULED',
          homeTeamId: rivalQueue.teamId,
          awayTeamId: teamId,
          matchedAt: now
        },
        include: {
          homeTeam: { select: { id: true, name: true, shieldUrl: true } },
          awayTeam: { select: { id: true, name: true, shieldUrl: true } }
        }
      });

      await tx.matchQueue.update({
        where: { id: rivalQueue.id },
        data: { status: 'MATCHED', matchId: match.id, matchedAt: now }
      });

      await tx.matchQueue.update({
        where: { id: myQueue.id },
        data: { status: 'MATCHED', matchId: match.id, matchedAt: now }
      });

      return { type: 'matched' as const, match };
    });
  }

  cancelQueue(teamId: string, mode: 'CASUAL' | 'COMPETITIVE') {
    return this.prisma.matchQueue.updateMany({
      where: { teamId, mode, status: 'SEARCHING' },
      data: { status: 'CANCELED' }
    });
  }

  getMyQueue(teamId: string) {
    return this.prisma.matchQueue.findFirst({
      where: { teamId, status: 'SEARCHING' },
      orderBy: { createdAt: 'desc' }
    });
  }
}
