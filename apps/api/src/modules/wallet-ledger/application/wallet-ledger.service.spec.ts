import { Test } from '@nestjs/testing';
import { HoldStatus } from '@/common/enums';
import { WalletLedgerService } from './wallet-ledger.service';
import { WalletLedgerRepository } from '../infrastructure/wallet-ledger.repository';

describe('WalletLedgerService', () => {
  let service: WalletLedgerService;
  const repository = {
    ensureWallet: jest.fn(),
    topUp: jest.fn(),
    createHold: jest.fn(),
    releaseHold: jest.fn(),
    getHold: jest.fn(),
    settleHold: jest.fn()
  };

  beforeEach(async () => {
    jest.clearAllMocks();
    const module = await Test.createTestingModule({
      providers: [WalletLedgerService, { provide: WalletLedgerRepository, useValue: repository }]
    }).compile();

    service = module.get(WalletLedgerService);
  });

  it('creates hold when wallet has balance', async () => {
    repository.createHold.mockResolvedValue({ id: 'hold-1' });

    const hold = await service.createHold('user-1', 100, 'Booking hold', 'booking-1');

    expect(hold.id).toBe('hold-1');
    expect(repository.createHold).toHaveBeenCalledWith('user-1', 100, 'Booking hold', 'booking-1');
  });

  it('releases hold', async () => {
    repository.releaseHold.mockResolvedValue({ id: 'hold-1', status: HoldStatus.RELEASED });

    const hold = await service.releaseHold('hold-1');

    expect(hold.status).toBe(HoldStatus.RELEASED);
  });

  it('settles hold with 5% commission', async () => {
    repository.getHold.mockResolvedValue({ amount: 200 });
    repository.settleHold.mockResolvedValue({ id: 'hold-1', status: HoldStatus.SETTLED });

    const result = await service.settleHold('hold-1', 'owner-1');

    expect(result.status).toBe(HoldStatus.SETTLED);
    expect(repository.settleHold).toHaveBeenCalledWith({
      holdId: 'hold-1',
      ownerUserId: 'owner-1',
      commissionAmount: 10
    });
  });
});
