import { INestApplication, Injectable, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit {
  constructor(private readonly config: ConfigService) {
    const url = process.env.DATABASE_URL || '';

    // Si por alguna razón sigue vacío, que falle con mensaje claro
    if (!url) {
      throw new Error(
        'DATABASE_URL is missing. Check apps/api/.env or root .env and ConfigModule envFilePath.'
      );
    }

    super({
      datasources: {
        db: { url }
      }
    });
  }

  async onModuleInit(): Promise<void> {
    await this.$connect();
  }

  async enableShutdownHooks(app: INestApplication): Promise<void> {
    (this as unknown as { $on: (event: string, cb: () => Promise<void>) => void }).$on(
      'beforeExit',
      async () => {
        await app.close();
      }
    );
  }
}
