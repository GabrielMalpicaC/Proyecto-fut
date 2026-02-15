import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import appConfig from './config/app.config';
import authConfig from './config/auth.config';
import redisConfig from './config/redis.config';
import storageConfig from './config/storage.config';
import { InfrastructureModule } from './infrastructure/infrastructure.module';
import { IdentityAccessModule } from './modules/identity-access/identity-access.module';
import { TeamsModule } from './modules/teams/teams.module';
import { VenuesModule } from './modules/venues/venues.module';
import { BookingsModule } from './modules/bookings/bookings.module';
import { WalletLedgerModule } from './modules/wallet-ledger/wallet-ledger.module';
import { MatchesModule } from './modules/matches/matches.module';
import { SocialModule } from './modules/social';
import { RefereeingModule } from './modules/refereeing';
import { CompetitiveRankingModule } from './modules/competitive-ranking';
import { TournamentsModule } from './modules/tournaments';
import { AdsModule } from './modules/ads';
import { AdminModerationModule } from './modules/admin-moderation';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [appConfig, authConfig, redisConfig, storageConfig],
      envFilePath: ['apps/api/.env', '.env']
    }),
    InfrastructureModule,
    IdentityAccessModule,
    TeamsModule,
    VenuesModule,
    BookingsModule,
    WalletLedgerModule,
    MatchesModule,
    SocialModule,
    RefereeingModule,
    CompetitiveRankingModule,
    TournamentsModule,
    AdsModule,
    AdminModerationModule
  ]
})
export class AppModule {}
