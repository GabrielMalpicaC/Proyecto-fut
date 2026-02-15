import { Body, Controller, Param, Post, Req, UseGuards, UsePipes } from '@nestjs/common';
import { UserRole } from '@/common/enums';
import { z } from 'zod';
import { JwtAuthGuard } from '@/common/guards/jwt-auth.guard';
import { RolesGuard } from '@/common/guards/roles.guard';
import { ZodValidationPipe } from '@/common/validation/zod-validation.pipe';
import { BookingsService } from '../../application/bookings.service';

const createBookingSchema = z.object({
  venueId: z.string().uuid(),
  startsAt: z.string().datetime(),
  endsAt: z.string().datetime()
});

@Controller('bookings')
@UseGuards(JwtAuthGuard)
export class BookingsController {
  constructor(private readonly bookingsService: BookingsService) {}

  @Post()
  @UsePipes(new ZodValidationPipe(createBookingSchema))
  create(@Req() req: Express.Request, @Body() body: z.infer<typeof createBookingSchema>) {
    return this.bookingsService.createBooking(req.user!.sub, {
      venueId: body.venueId,
      startsAt: new Date(body.startsAt),
      endsAt: new Date(body.endsAt)
    });
  }

  @Post(':bookingId/finalize')
  @UseGuards(new RolesGuard([UserRole.ADMIN, UserRole.VENUE_OWNER]))
  finalize(@Param('bookingId') bookingId: string) {
    return this.bookingsService.finalizeBooking(bookingId);
  }
}
