import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import * as request from 'supertest';
import { BookingsController } from './bookings.controller';
import { BookingsService } from '../../application/bookings.service';
import { JwtAuthGuard } from '@/common/guards/jwt-auth.guard';

describe('BookingsController integration', () => {
  let app: INestApplication;
  const bookingsService = {
    createBooking: jest.fn()
  };

  beforeAll(async () => {
    const moduleBuilder = Test.createTestingModule({
      controllers: [BookingsController],
      providers: [{ provide: BookingsService, useValue: bookingsService }]
    });

    moduleBuilder.overrideGuard(JwtAuthGuard).useValue({
      canActivate: (context: any) => {
        const req = context.switchToHttp().getRequest();
        req.user = { sub: 'user-1', email: 'test@test.com', roles: ['PLAYER'] };
        return true;
      }
    });

    const moduleRef = await moduleBuilder.compile();
    app = moduleRef.createNestApplication();
    await app.init();
  });

  afterAll(async () => {
    if (app) await app.close();
  });

  it('creates booking endpoint happy path', async () => {
    bookingsService.createBooking.mockResolvedValue({ id: 'booking-1', status: 'PENDING' });

    await request(app.getHttpServer())
      .post('/bookings')
      .set('Authorization', 'Bearer fake')
      .send({
        venueId: '0fbd98a8-74ad-460f-8ecb-f9dc8cc9f211',
        startsAt: '2026-01-10T12:00:00.000Z',
        endsAt: '2026-01-10T13:00:00.000Z'
      })
      .expect(201);

    expect(bookingsService.createBooking).toHaveBeenCalledWith(
      'user-1',
      expect.objectContaining({ venueId: '0fbd98a8-74ad-460f-8ecb-f9dc8cc9f211' })
    );
  });
});
