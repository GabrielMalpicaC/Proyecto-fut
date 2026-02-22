import { Injectable } from '@nestjs/common';
import { AppError } from '@/common/errors/app-error';
import { MatchesRepository } from '../infrastructure/matches.repository';

@Injectable()
export class MatchesService {
  constructor(private readonly matchesRepository: MatchesRepository) {}

  async searchMatch(userId: string, mode: 'CASUAL' | 'COMPETITIVE') {
    const membership = await this.matchesRepository.getActiveMembership(userId);
    if (!membership) {
      throw new AppError('TEAM_REQUIRED', 'Debes pertenecer a un equipo para buscar partido', 409);
    }

    const result = await this.matchesRepository.createQueueAndTryMatch(membership.teamId, mode);

    if (result.type === 'matched') {
      return {
        status: 'MATCH_FOUND',
        mode,
        match: result.match
      };
    }

    return {
      status: 'SEARCHING',
      mode,
      queue: result.queue
    };
  }

  async cancelSearch(userId: string, mode: 'CASUAL' | 'COMPETITIVE') {
    const membership = await this.matchesRepository.getActiveMembership(userId);
    if (!membership) {
      throw new AppError('TEAM_REQUIRED', 'Debes pertenecer a un equipo para cancelar búsqueda', 409);
    }

    const result = await this.matchesRepository.cancelQueue(membership.teamId, mode);
    return { ok: true, canceled: result.count };
  }

  async mySearchStatus(userId: string) {
    const membership = await this.matchesRepository.getActiveMembership(userId);
    if (!membership) {
      return { searching: false };
    }

    const queue = await this.matchesRepository.getMyQueue(membership.teamId);
    if (!queue) return { searching: false };

    return { searching: true, queue };
  }
}
