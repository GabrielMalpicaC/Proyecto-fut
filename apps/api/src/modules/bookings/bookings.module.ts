import { Module } from '@nestjs/common';
import { BookingsController } from './interfaces/api/bookings.controller';
import { BookingsService } from './application/bookings.service';
import { BookingsRepository } from './infrastructure/bookings.repository';
import { VenuesModule } from '@/modules/venues/venues.module';
import { WalletLedgerModule } from '@/modules/wallet-ledger/wallet-ledger.module';

@Module({
  imports: [VenuesModule, WalletLedgerModule],
  controllers: [BookingsController],
  providers: [BookingsService, BookingsRepository]
})
export class BookingsModule {}
