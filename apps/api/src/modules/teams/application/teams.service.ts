import { Injectable } from '@nestjs/common';
import { TeamsRepository } from '../infrastructure/teams.repository';

@Injectable()
export class TeamsService {
  constructor(private readonly teamsRepository: TeamsRepository) {}

  createTeam(ownerId: string, input: { name: string }) {
    return this.teamsRepository.createTeam(ownerId, input.name);
  }

  inviteMember(teamId: string, input: { invitedUserId: string }) {
    return this.teamsRepository.createInvitation(teamId, input.invitedUserId);
  }

  acceptInvite(teamId: string, userId: string) {
    return this.teamsRepository.acceptInvitation(teamId, userId);
  }
}
