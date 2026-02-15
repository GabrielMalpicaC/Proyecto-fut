import { Injectable } from '@nestjs/common';
import { PrismaService } from '@/infrastructure/prisma/prisma.service';

@Injectable()
export class VenuesRepository {
  constructor(private readonly prisma: PrismaService) {}

  create(input: { ownerId: string; name: string; location: string; pricePerHour: number }) {
    return this.prisma.venue.create({
      data: {
        ownerId: input.ownerId,
        name: input.name,
        location: input.location,
        pricePerHour: input.pricePerHour
      }
    });
  }

  search(query?: string) {
    return this.prisma.venue.findMany({
      where: query
        ? {
            OR: [
              { name: { contains: query, mode: 'insensitive' } },
              { location: { contains: query, mode: 'insensitive' } }
            ]
          }
        : undefined,
      orderBy: { createdAt: 'desc' }
    });
  }

  findById(id: string) {
    return this.prisma.venue.findUnique({ where: { id } });
  }
}
