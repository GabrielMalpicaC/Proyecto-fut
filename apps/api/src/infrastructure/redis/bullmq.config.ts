import { ConfigService } from '@nestjs/config';

export const createBullMqConnection = (configService: ConfigService) => ({
  connection: {
    host: configService.get<string>('redis.host'),
    port: configService.get<number>('redis.port')
  }
});
