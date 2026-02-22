DO $$ BEGIN
  CREATE TYPE "MatchMode" AS ENUM ('CASUAL', 'COMPETITIVE');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE "MatchStatus" AS ENUM ('SCHEDULED', 'IN_PROGRESS', 'FINISHED', 'CANCELED');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE "MatchQueueStatus" AS ENUM ('SEARCHING', 'MATCHED', 'CANCELED');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

CREATE TABLE IF NOT EXISTS "Match" (
  "id" TEXT NOT NULL,
  "mode" "MatchMode" NOT NULL,
  "status" "MatchStatus" NOT NULL DEFAULT 'SCHEDULED',
  "homeTeamId" TEXT NOT NULL,
  "awayTeamId" TEXT NOT NULL,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "matchedAt" TIMESTAMP(3),
  CONSTRAINT "Match_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "MatchQueue" (
  "id" TEXT NOT NULL,
  "teamId" TEXT NOT NULL,
  "mode" "MatchMode" NOT NULL,
  "status" "MatchQueueStatus" NOT NULL DEFAULT 'SEARCHING',
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "matchedAt" TIMESTAMP(3),
  "matchId" TEXT,
  CONSTRAINT "MatchQueue_pkey" PRIMARY KEY ("id")
);

CREATE INDEX IF NOT EXISTS "Match_mode_status_createdAt_idx" ON "Match"("mode", "status", "createdAt");
CREATE INDEX IF NOT EXISTS "MatchQueue_mode_status_createdAt_idx" ON "MatchQueue"("mode", "status", "createdAt");
CREATE UNIQUE INDEX IF NOT EXISTS "MatchQueue_teamId_mode_status_key" ON "MatchQueue"("teamId", "mode", "status");

DO $$ BEGIN
  ALTER TABLE "Match" ADD CONSTRAINT "Match_homeTeamId_fkey" FOREIGN KEY ("homeTeamId") REFERENCES "Team"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE "Match" ADD CONSTRAINT "Match_awayTeamId_fkey" FOREIGN KEY ("awayTeamId") REFERENCES "Team"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE "MatchQueue" ADD CONSTRAINT "MatchQueue_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES "Team"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE "MatchQueue" ADD CONSTRAINT "MatchQueue_matchId_fkey" FOREIGN KEY ("matchId") REFERENCES "Match"("id") ON DELETE SET NULL ON UPDATE CASCADE;
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;
