import { Module } from '@nestjs/common';
import { MatchesService } from './application/matches.service';
import { MatchesRepository } from './infrastructure/matches.repository';
import { MatchesController } from './interfaces/api/matches.controller';

@Module({
  controllers: [MatchesController],
  providers: [MatchesService, MatchesRepository]
})
export class MatchesModule {}
