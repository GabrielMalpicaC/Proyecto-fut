import { Body, Controller, Get, Post, Query, Req, UseGuards, UsePipes } from '@nestjs/common';
import { UserRole } from '@/common/enums';
import { z } from 'zod';
import { JwtAuthGuard } from '@/common/guards/jwt-auth.guard';
import { RolesGuard } from '@/common/guards/roles.guard';
import { ZodValidationPipe } from '@/common/validation/zod-validation.pipe';
import { VenuesService } from '../../application/venues.service';

const createVenueSchema = z.object({
  name: z.string().min(3),
  location: z.string().min(3),
  pricePerHour: z.number().positive()
});

@Controller('venues')
export class VenuesController {
  constructor(private readonly venuesService: VenuesService) {}

  @Post()
  @UseGuards(JwtAuthGuard, new RolesGuard([UserRole.VENUE_OWNER, UserRole.ADMIN]))
  @UsePipes(new ZodValidationPipe(createVenueSchema))
  create(@Req() req: Express.Request, @Body() body: z.infer<typeof createVenueSchema>) {
    return this.venuesService.createVenue(req.user!.sub, body);
  }

  @Get()
  list(@Query('q') query?: string) {
    return this.venuesService.listVenues(query);
  }
}
