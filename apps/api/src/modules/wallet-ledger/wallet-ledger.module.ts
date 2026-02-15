import { Module } from '@nestjs/common';
import { WalletLedgerController } from './interfaces/api/wallet-ledger.controller';
import { WalletLedgerService } from './application/wallet-ledger.service';
import { WalletLedgerRepository } from './infrastructure/wallet-ledger.repository';

@Module({
  controllers: [WalletLedgerController],
  providers: [WalletLedgerService, WalletLedgerRepository],
  exports: [WalletLedgerService]
})
export class WalletLedgerModule {}
