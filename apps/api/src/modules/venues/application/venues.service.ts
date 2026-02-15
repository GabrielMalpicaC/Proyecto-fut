import { Injectable } from '@nestjs/common';
import { AppError } from '@/common/errors/app-error';
import { VenuesRepository } from '../infrastructure/venues.repository';

@Injectable()
export class VenuesService {
  constructor(private readonly venuesRepository: VenuesRepository) {}

  createVenue(ownerId: string, input: { name: string; location: string; pricePerHour: number }) {
    return this.venuesRepository.create({ ...input, ownerId });
  }

  listVenues(query?: string) {
    return this.venuesRepository.search(query);
  }

  async getVenue(id: string) {
    const venue = await this.venuesRepository.findById(id);
    if (!venue) {
      throw new AppError('VENUE_NOT_FOUND', 'Venue not found', 404);
    }
    return venue;
  }
}
