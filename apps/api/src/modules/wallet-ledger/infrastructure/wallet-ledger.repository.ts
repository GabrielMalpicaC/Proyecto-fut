import { HoldStatus, LedgerEntryType } from '@/common/enums';
import { Injectable } from '@nestjs/common';
import { PrismaService } from '@/infrastructure/prisma/prisma.service';

const PLATFORM_USER_ID = '00000000-0000-0000-0000-000000000001';

@Injectable()
export class WalletLedgerRepository {
  constructor(private readonly prisma: PrismaService) {}

  ensureWallet(userId: string) {
    return this.prisma.wallet.upsert({ where: { userId }, update: {}, create: { userId } });
  }

  async topUp(userId: string, amount: number) {
    const wallet = await this.ensureWallet(userId);
    await this.prisma.wallet.update({
      where: { id: wallet.id },
      data: { balance: { increment: amount } }
    });
    return this.prisma.ledgerEntry.create({
      data: {
        walletId: wallet.id,
        type: LedgerEntryType.CREDIT,
        amount,
        description: 'Wallet top up'
      }
    });
  }

  async createHold(userId: string, amount: number, reason: string, referenceId: string) {
    const wallet = await this.ensureWallet(userId);
    return this.prisma.$transaction(async (tx: any) => {
      const freshWallet = await tx.wallet.findUniqueOrThrow({ where: { id: wallet.id } });
      if (Number(freshWallet.balance) < amount) throw new Error('INSUFFICIENT_BALANCE');

      await tx.wallet.update({
        where: { id: wallet.id },
        data: { balance: { decrement: amount } }
      });
      await tx.ledgerEntry.create({
        data: {
          walletId: wallet.id,
          type: LedgerEntryType.DEBIT,
          amount,
          description: 'Funds held',
          referenceId
        }
      });

      return tx.hold.create({ data: { walletId: wallet.id, amount, reason, referenceId } });
    });
  }

  getHold(holdId: string) {
    return this.prisma.hold.findUnique({ where: { id: holdId }, include: { wallet: true } });
  }

  async releaseHold(holdId: string) {
    return this.prisma.$transaction(async (tx: any) => {
      const hold = await tx.hold.findUniqueOrThrow({ where: { id: holdId } });
      if (hold.status !== HoldStatus.ACTIVE) throw new Error('INVALID_HOLD_STATUS');

      await tx.wallet.update({
        where: { id: hold.walletId },
        data: { balance: { increment: hold.amount } }
      });
      await tx.ledgerEntry.create({
        data: {
          walletId: hold.walletId,
          type: LedgerEntryType.CREDIT,
          amount: hold.amount,
          description: 'Hold released',
          referenceId: hold.referenceId
        }
      });

      return tx.hold.update({ where: { id: holdId }, data: { status: HoldStatus.RELEASED } });
    });
  }

  async settleHold(params: { holdId: string; ownerUserId: string; commissionAmount: number }) {
    return this.prisma.$transaction(async (tx: any) => {
      const hold = await tx.hold.findUniqueOrThrow({ where: { id: params.holdId } });
      if (hold.status !== HoldStatus.ACTIVE) throw new Error('INVALID_HOLD_STATUS');

      const ownerWallet = await tx.wallet.upsert({
        where: { userId: params.ownerUserId },
        update: {},
        create: { userId: params.ownerUserId }
      });

      await tx.user.upsert({
        where: { id: PLATFORM_USER_ID },
        update: {},
        create: {
          id: PLATFORM_USER_ID,
          email: 'platform@internal.local',
          fullName: 'Platform',
          passwordHash: 'internal'
        }
      });
      const platformWallet = await tx.wallet.upsert({
        where: { userId: PLATFORM_USER_ID },
        update: {},
        create: { userId: PLATFORM_USER_ID }
      });

      const payoutAmount = Number(hold.amount) - params.commissionAmount;
      await tx.wallet.update({
        where: { id: ownerWallet.id },
        data: { balance: { increment: payoutAmount } }
      });
      await tx.wallet.update({
        where: { id: platformWallet.id },
        data: { balance: { increment: params.commissionAmount } }
      });

      await tx.ledgerEntry.createMany({
        data: [
          {
            walletId: ownerWallet.id,
            type: LedgerEntryType.CREDIT,
            amount: payoutAmount,
            description: 'Booking settlement payout',
            referenceId: hold.referenceId
          },
          {
            walletId: platformWallet.id,
            type: LedgerEntryType.CREDIT,
            amount: params.commissionAmount,
            description: 'Booking commission',
            referenceId: hold.referenceId
          }
        ]
      });

      return tx.hold.update({ where: { id: params.holdId }, data: { status: HoldStatus.SETTLED } });
    });
  }
}
