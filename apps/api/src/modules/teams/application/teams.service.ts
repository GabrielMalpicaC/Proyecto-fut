import { Injectable } from '@nestjs/common';
import { AppError } from '@/common/errors/app-error';
import { TeamsRepository } from '../infrastructure/teams.repository';

@Injectable()
export class TeamsService {
  constructor(private readonly teamsRepository: TeamsRepository) {}

  async createTeam(ownerId: string, input: { name: string; maxPlayers: number; description?: string }) {
    const existingMembership = await this.teamsRepository.getUserActiveMembership(ownerId);
    if (existingMembership) {
      throw new AppError('USER_ALREADY_IN_TEAM', 'Ya perteneces a un equipo activo', 409);
    }

    return this.teamsRepository.createTeam(ownerId, input);
  }

  inviteMember(teamId: string, input: { invitedUserId: string }) {
    return this.teamsRepository.createInvitation(teamId, input.invitedUserId);
  }

  acceptInvite(teamId: string, userId: string) {
    return this.teamsRepository.acceptInvitation(teamId, userId);
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
