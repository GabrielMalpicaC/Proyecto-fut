import { Module } from '@nestjs/common';
import { TeamsController } from './interfaces/api/teams.controller';
import { TeamsService } from './application/teams.service';
import { TeamsRepository } from './infrastructure/teams.repository';

@Module({
  controllers: [TeamsController],
  providers: [TeamsService, TeamsRepository]
})
export class TeamsModule {}
