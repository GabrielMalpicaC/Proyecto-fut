import { BookingStatus } from '@/common/enums';
import { Injectable } from '@nestjs/common';
import { PrismaService } from '@/infrastructure/prisma/prisma.service';

@Injectable()
export class BookingsRepository {
  constructor(private readonly prisma: PrismaService) {}

  create(input: {
    venueId: string;
    userId: string;
    ownerId: string;
    startsAt: Date;
    endsAt: Date;
    totalAmount: number;
    commissionAmount: number;
    holdId: string;
  }) {
    return this.prisma.booking.create({
      data: {
        ...input,
        status: BookingStatus.PENDING
      }
    });
  }

  getById(id: string) {
    return this.prisma.booking.findUnique({ where: { id } });
  }

  confirm(id: string) {
    return this.prisma.booking.update({ where: { id }, data: { status: BookingStatus.CONFIRMED } });
  }

  complete(id: string) {
    return this.prisma.booking.update({ where: { id }, data: { status: BookingStatus.COMPLETED } });
  }
}
