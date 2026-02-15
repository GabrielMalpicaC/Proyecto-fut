import { Global, Module } from '@nestjs/common';
import { PrismaModule } from './prisma/prisma.module';
import { RedisService } from './redis/redis.service';
import { MEDIA_STORAGE } from './storage/media-storage.interface';
import { S3MediaStorageStub } from './storage/s3-media-storage.stub';

@Global()
@Module({
  imports: [PrismaModule],
  providers: [
    RedisService,
    S3MediaStorageStub,
    { provide: MEDIA_STORAGE, useExisting: S3MediaStorageStub }
  ],
  exports: [PrismaModule, RedisService, MEDIA_STORAGE]
})
export class InfrastructureModule {}
