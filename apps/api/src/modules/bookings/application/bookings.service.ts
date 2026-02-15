import { Injectable } from '@nestjs/common';

import { AppError } from '@/common/errors/app-error';
import { VenuesService } from '@/modules/venues/application/venues.service';
import { WalletLedgerService } from '@/modules/wallet-ledger/application/wallet-ledger.service';
import { BookingsRepository } from '../infrastructure/bookings.repository';

@Injectable()
export class BookingsService {
  constructor(
    private readonly bookingsRepository: BookingsRepository,
    private readonly venuesService: VenuesService,
    private readonly walletLedgerService: WalletLedgerService
  ) {}

  async createBooking(userId: string, input: { venueId: string; startsAt: Date; endsAt: Date }) {
    const venue = await this.venuesService.getVenue(input.venueId);
    const durationHours = Math.max(
      1,
      (input.endsAt.getTime() - input.startsAt.getTime()) / 3600000
    );
    const totalAmount = Number(venue.pricePerHour) * durationHours;
    const commissionAmount = totalAmount * 0.05;

    const hold = await this.walletLedgerService.createHold(
      userId,
      totalAmount,
      'Booking hold',
      `booking:${input.venueId}:${input.startsAt.toISOString()}`
    );

    return this.bookingsRepository.create({
      venueId: input.venueId,
      userId,
      ownerId: venue.ownerId,
      startsAt: input.startsAt,
      endsAt: input.endsAt,
      totalAmount: Number(totalAmount.toFixed(2)),
      commissionAmount: Number(commissionAmount.toFixed(2)),
      holdId: hold.id
    });
  }

  async finalizeBooking(bookingId: string) {
    const booking = await this.bookingsRepository.getById(bookingId);
    if (!booking) {
      throw new AppError('BOOKING_NOT_FOUND', 'Booking not found', 404);
    }
    if (!booking.holdId) {
      throw new AppError('HOLD_NOT_FOUND', 'Booking hold not found', 404);
    }

    await this.walletLedgerService.settleHold(booking.holdId, booking.ownerId);
    await this.bookingsRepository.confirm(bookingId);
    return this.bookingsRepository.complete(bookingId);
  }
}
