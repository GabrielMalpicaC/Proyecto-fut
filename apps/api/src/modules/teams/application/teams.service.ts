import { Injectable } from '@nestjs/common';
import { AppError } from '@/common/errors/app-error';
import { TeamsRepository } from '../infrastructure/teams.repository';

@Injectable()
export class TeamsService {
  private readonly defaultShield =
    'https://ui-avatars.com/api/?name=Team&background=1f2a44&color=ffffff&rounded=true';

  constructor(private readonly teamsRepository: TeamsRepository) {}

  async createTeam(
    ownerId: string,
    input: {
      name: string;
      footballType: number;
      formation?: string;
      description?: string;
      shieldUrl?: string;
    }
  ) {
    return this.withSchemaGuard(async () => {
      const existingMembership = await this.teamsRepository.getUserActiveMembership(ownerId);
      if (existingMembership) {
        throw new AppError('USER_ALREADY_IN_TEAM', 'Ya perteneces a un equipo activo', 409);
      }

      const maxPlayers = input.footballType * 2;

      return this.teamsRepository.createTeam(ownerId, {
        ...input,
        maxPlayers,
        formation: input.formation?.trim() || '4-4-2',
        shieldUrl: input.shieldUrl?.trim() || this.defaultShield
      });
    });
  }

  inviteMember(teamId: string, input: { invitedUserId: string }) {
    return this.withSchemaGuard(() => this.teamsRepository.createInvitation(teamId, input.invitedUserId));
  }

  acceptInvite(teamId: string, userId: string) {
    return this.withSchemaGuard(() => this.teamsRepository.acceptInvitation(teamId, userId));
  }

  listOpenTeams() {
    return this.withSchemaGuard(() => this.teamsRepository.getOpenTeams());
  }

  async getTeamProfile(teamId: string) {
    return this.withSchemaGuard(async () => {
      const team = await this.teamsRepository.getTeamProfile(teamId);
      if (!team) throw new AppError('TEAM_NOT_FOUND', 'Equipo no encontrado', 404);
      return team;
    });
  }

  async applyToTeam(teamId: string, userId: string, message?: string) {
    return this.withSchemaGuard(async () => {
      const membership = await this.teamsRepository.getUserActiveMembership(userId);
      if (membership) {
        throw new AppError('USER_ALREADY_IN_TEAM', 'Ya perteneces a un equipo activo', 409);
      }

      const team = await this.teamsRepository.getTeamById(teamId);
      if (!team) throw new AppError('TEAM_NOT_FOUND', 'Equipo no encontrado', 404);
      if (!team.isRecruiting) {
        throw new AppError('TEAM_NOT_RECRUITING', 'Este equipo no está reclutando', 409);
      }

      const activeMembers = await this.teamsRepository.getActiveMembersCount(teamId);
      if (activeMembers >= team.maxPlayers) {
        throw new AppError('TEAM_FULL', 'El equipo ya está completo', 409);
      }

      return this.teamsRepository.applyToTeam(teamId, userId, message);
    });
  }

  async listApplications(teamId: string, requesterId: string) {
    return this.withSchemaGuard(async () => {
      const team = await this.teamsRepository.getTeamById(teamId);
      if (!team) throw new AppError('TEAM_NOT_FOUND', 'Equipo no encontrado', 404);
      if (team.ownerId !== requesterId) {
        throw new AppError('FORBIDDEN', 'Solo el líder puede ver postulaciones', 403);
      }
      return this.teamsRepository.listApplications(teamId);
    });
  }

  async reviewApplication(teamId: string, requesterId: string, applicantUserId: string, approve: boolean) {
    return this.withSchemaGuard(async () => {
      const team = await this.teamsRepository.getTeamById(teamId);
      if (!team) throw new AppError('TEAM_NOT_FOUND', 'Equipo no encontrado', 404);
      if (team.ownerId !== requesterId) {
        throw new AppError('FORBIDDEN', 'Solo el líder puede revisar postulaciones', 403);
      }

      if (approve) {
        const activeMembers = await this.teamsRepository.getActiveMembersCount(teamId);
        if (activeMembers >= team.maxPlayers) {
          throw new AppError('TEAM_FULL', 'El equipo ya está completo', 409);
        }
      }

      return this.teamsRepository.reviewApplication(teamId, applicantUserId, approve);
    });
  }

  private async withSchemaGuard<T>(operation: () => Promise<T>): Promise<T> {
    try {
      return await operation();
    } catch (error) {
      if (this.isSchemaDriftError(error)) {
        throw new AppError(
          'TEAM_SCHEMA_NOT_READY',
          'Equipos temporalmente no disponible. Ejecuta migraciones pendientes con: npm run prisma:deploy',
          503
        );
      }

      throw error;
    }
  }

  private isSchemaDriftError(error: unknown): boolean {
    if (typeof error !== 'object' || error === null || !('code' in error)) {
      return false;
    }

    const code = String((error as { code?: unknown }).code ?? '');
    return code === 'P2021' || code === 'P2022';
  }

  listOpenTeams() {
    return this.teamsRepository.getOpenTeams();
  }

  async getTeamProfile(teamId: string) {
    const team = await this.teamsRepository.getTeamProfile(teamId);
    if (!team) throw new AppError('TEAM_NOT_FOUND', 'Equipo no encontrado', 404);
    return team;
  }

  async applyToTeam(teamId: string, userId: string, message?: string) {
    const membership = await this.teamsRepository.getUserActiveMembership(userId);
    if (membership) {
      throw new AppError('USER_ALREADY_IN_TEAM', 'Ya perteneces a un equipo activo', 409);
    }

    const team = await this.teamsRepository.getTeamById(teamId);
    if (!team) throw new AppError('TEAM_NOT_FOUND', 'Equipo no encontrado', 404);
    if (!team.isRecruiting) {
      throw new AppError('TEAM_NOT_RECRUITING', 'Este equipo no está reclutando', 409);
    }

    const activeMembers = await this.teamsRepository.getActiveMembersCount(teamId);
    if (activeMembers >= team.maxPlayers) {
      throw new AppError('TEAM_FULL', 'El equipo ya está completo', 409);
    }

    return this.teamsRepository.applyToTeam(teamId, userId, message);
  }

  async listApplications(teamId: string, requesterId: string) {
    const team = await this.teamsRepository.getTeamById(teamId);
    if (!team) throw new AppError('TEAM_NOT_FOUND', 'Equipo no encontrado', 404);
    if (team.ownerId !== requesterId) {
      throw new AppError('FORBIDDEN', 'Solo el líder puede ver postulaciones', 403);
    }
    return this.teamsRepository.listApplications(teamId);
  }

  async reviewApplication(teamId: string, requesterId: string, applicantUserId: string, approve: boolean) {
    const team = await this.teamsRepository.getTeamById(teamId);
    if (!team) throw new AppError('TEAM_NOT_FOUND', 'Equipo no encontrado', 404);
    if (team.ownerId !== requesterId) {
      throw new AppError('FORBIDDEN', 'Solo el líder puede revisar postulaciones', 403);
    }

    if (approve) {
      const activeMembers = await this.teamsRepository.getActiveMembersCount(teamId);
      if (activeMembers >= team.maxPlayers) {
        throw new AppError('TEAM_FULL', 'El equipo ya está completo', 409);
      }
    }

    return this.teamsRepository.reviewApplication(teamId, applicantUserId, approve);
  }
}
