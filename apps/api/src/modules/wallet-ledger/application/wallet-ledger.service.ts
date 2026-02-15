import { Injectable } from '@nestjs/common';
import { AppError } from '@/common/errors/app-error';
import { WalletLedgerRepository } from '../infrastructure/wallet-ledger.repository';

@Injectable()
export class WalletLedgerService {
  constructor(private readonly walletLedgerRepository: WalletLedgerRepository) {}

  async getBalance(userId: string) {
    const wallet = await this.walletLedgerRepository.ensureWallet(userId);
    return { balance: Number(wallet.balance) };
  }

  async topUp(userId: string, amount: number) {
    await this.walletLedgerRepository.topUp(userId, Number(amount.toFixed(2)));
    return this.getBalance(userId);
  }

  async createHold(userId: string, amount: number, reason: string, referenceId: string) {
    try {
      return await this.walletLedgerRepository.createHold(
        userId,
        Number(amount.toFixed(2)),
        reason,
        referenceId
      );
    } catch (error) {
      if ((error as Error).message === 'INSUFFICIENT_BALANCE') {
        throw new AppError('INSUFFICIENT_BALANCE', 'Insufficient wallet balance', 400);
      }
      throw error;
    }
  }

  async releaseHold(holdId: string) {
    try {
      return await this.walletLedgerRepository.releaseHold(holdId);
    } catch (error) {
      if ((error as Error).message === 'INVALID_HOLD_STATUS') {
        throw new AppError('INVALID_HOLD_STATUS', 'Hold cannot be released', 400);
      }
      throw error;
    }
  }

  async settleHold(holdId: string, ownerUserId: string, commissionRate = 0.05) {
    const hold = await this.walletLedgerRepository.getHold(holdId);
    if (!hold) {
      throw new AppError('HOLD_NOT_FOUND', 'Hold not found', 404);
    }

    const commission = Number(hold.amount) * commissionRate;

    try {
      return await this.walletLedgerRepository.settleHold({
        holdId,
        ownerUserId,
        commissionAmount: Number(commission.toFixed(2))
      });
    } catch (error) {
      if ((error as Error).message === 'INVALID_HOLD_STATUS') {
        throw new AppError('INVALID_HOLD_STATUS', 'Hold cannot be settled', 400);
      }
      throw error;
    }
  }
}
