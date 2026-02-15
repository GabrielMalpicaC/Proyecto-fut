import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { PrismaModule } from '@/infrastructure/prisma/prisma.module';
import { IdentityAccessController } from './interfaces/api/identity-access.controller';
import { IdentityAccessService } from './application/identity-access.service';
import { IdentityAccessRepository } from './infrastructure/identity-access.repository';

@Module({
  imports: [
    PrismaModule,
    JwtModule.registerAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        secret: config.get<string>('auth.accessSecret')
      })
    })
  ],
  controllers: [IdentityAccessController],
  providers: [IdentityAccessService, IdentityAccessRepository],
  exports: [IdentityAccessService, IdentityAccessRepository]
})
export class IdentityAccessModule {}
