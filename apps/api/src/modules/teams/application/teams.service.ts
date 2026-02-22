import { Injectable } from '@nestjs/common';
import { AppError } from '@/common/errors/app-error';
import { TeamsRepository } from '../infrastructure/teams.repository';

@Injectable()
export class TeamsService {
  private readonly defaultShield =
    'https://ui-avatars.com/api/?name=Team&background=1f2a44&color=ffffff&rounded=true';

  constructor(private readonly teamsRepository: TeamsRepository) {}

  private canManageTeam(role: string) {
    return role === 'LEADER' || role === 'CO_LEADER';
  }

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

  async inviteMember(teamId: string, requesterId: string, input: { invitedUserId: string }) {
    return this.withSchemaGuard(async () => {
      const requesterMembership = await this.teamsRepository.getActiveMember(teamId, requesterId);
      if (!requesterMembership || !this.canManageTeam(requesterMembership.role)) {
        throw new AppError('FORBIDDEN', 'Solo líder/colíder pueden invitar jugadores', 403);
      }
      return this.teamsRepository.createInvitation(teamId, input.invitedUserId);
    });
  }

  acceptInvite(teamId: string, userId: string) {
    return this.withSchemaGuard(() => this.teamsRepository.acceptInvitation(teamId, userId));
  }

  listOpenTeams() {
    return this.withSchemaGuard(() => this.teamsRepository.getOpenTeams());
  }

  async getMyTeam(userId: string) {
    return this.withSchemaGuard(async () => {
      const membership = await this.teamsRepository.getUserActiveMembership(userId);
      if (!membership) throw new AppError('TEAM_NOT_FOUND', 'No perteneces a ningún equipo', 404);
      return this.getTeamProfile(membership.teamId);
    });
  }

  async getTeamProfile(teamId: string) {
    return this.withSchemaGuard(async () => {
      const team = await this.teamsRepository.getTeamProfile(teamId);
      if (!team) throw new AppError('TEAM_NOT_FOUND', 'Equipo no encontrado', 404);
      return team;
    });
  }

  async updateTeam(
    teamId: string,
    requesterId: string,
    input: {
      name?: string;
      description?: string;
      formation?: string;
      footballType?: number;
      shieldUrl?: string;
      isRecruiting?: boolean;
    }
  ) {
    return this.withSchemaGuard(async () => {
      const team = await this.teamsRepository.getTeamById(teamId);
      if (!team) throw new AppError('TEAM_NOT_FOUND', 'Equipo no encontrado', 404);
      if (team.ownerId !== requesterId) {
        throw new AppError('FORBIDDEN', 'Solo el líder puede editar el equipo', 403);
      }

      const footballType = input.footballType ?? team.footballType;

      return this.teamsRepository.updateTeam(teamId, {
        name: input.name,
        description: input.description,
        formation: input.formation,
        footballType,
        maxPlayers: footballType * 2,
        shieldUrl: input.shieldUrl,
        isRecruiting: input.isRecruiting
      });
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
      const requesterMembership = await this.teamsRepository.getActiveMember(teamId, requesterId);
      if (!requesterMembership || !this.canManageTeam(requesterMembership.role)) {
        throw new AppError('FORBIDDEN', 'Solo líder/colíder pueden ver postulaciones', 403);
      }
      return this.teamsRepository.listApplications(teamId);
    });
  }

  async reviewApplication(
    teamId: string,
    requesterId: string,
    applicantUserId: string,
    approve: boolean
  ) {
    return this.withSchemaGuard(async () => {
      const team = await this.teamsRepository.getTeamById(teamId);
      if (!team) throw new AppError('TEAM_NOT_FOUND', 'Equipo no encontrado', 404);
      const requesterMembership = await this.teamsRepository.getActiveMember(teamId, requesterId);
      if (!requesterMembership || !this.canManageTeam(requesterMembership.role)) {
        throw new AppError('FORBIDDEN', 'Solo líder/colíder pueden revisar postulaciones', 403);
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


  async assignMemberRole(
    teamId: string,
    requesterId: string,
    targetUserId: string,
    role: 'CAPTAIN' | 'CO_LEADER' | 'MEMBER'
  ) {
    return this.withSchemaGuard(async () => {
      const requesterMembership = await this.teamsRepository.getActiveMember(teamId, requesterId);
      if (!requesterMembership) throw new AppError('FORBIDDEN', 'No perteneces a este equipo', 403);
      if (requesterMembership.role !== 'LEADER') {
        throw new AppError('FORBIDDEN', 'Solo el líder puede asignar roles', 403);
      }

      const targetMembership = await this.teamsRepository.getActiveMember(teamId, targetUserId);
      if (!targetMembership) {
        throw new AppError('TEAM_MEMBER_NOT_FOUND', 'Jugador no pertenece al equipo', 404);
      }
      if (targetMembership.role === 'LEADER') {
        throw new AppError('INVALID_ROLE_CHANGE', 'No puedes cambiar el rol del líder', 409);
      }

      return this.teamsRepository.updateMemberRole(teamId, targetUserId, role);
    });
  }

  async removeMember(teamId: string, requesterId: string, targetUserId: string) {
    return this.withSchemaGuard(async () => {
      const requesterMembership = await this.teamsRepository.getActiveMember(teamId, requesterId);
      if (!requesterMembership) throw new AppError('FORBIDDEN', 'No perteneces a este equipo', 403);
      if (!this.canManageTeam(requesterMembership.role)) {
        throw new AppError('FORBIDDEN', 'Solo líder/colíder pueden expulsar jugadores', 403);
      }

      const targetMembership = await this.teamsRepository.getActiveMember(teamId, targetUserId);
      if (!targetMembership) {
        throw new AppError('TEAM_MEMBER_NOT_FOUND', 'Jugador no pertenece al equipo', 404);
      }
      if (targetMembership.role === 'LEADER') {
        throw new AppError('FORBIDDEN', 'No puedes expulsar al líder', 403);
      }
      if (targetUserId === requesterId) {
        throw new AppError('FORBIDDEN', 'No puedes expulsarte a ti mismo', 403);
      }

      return this.teamsRepository.removeMember(teamId, targetUserId);
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
}
