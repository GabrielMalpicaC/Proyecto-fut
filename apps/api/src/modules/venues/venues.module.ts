import { Module } from '@nestjs/common';
import { VenuesController } from './interfaces/api/venues.controller';
import { VenuesService } from './application/venues.service';
import { VenuesRepository } from './infrastructure/venues.repository';

@Module({
  controllers: [VenuesController],
  providers: [VenuesService, VenuesRepository],
  exports: [VenuesService, VenuesRepository]
})
export class VenuesModule {}
