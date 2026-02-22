-- AlterTable
ALTER TABLE "Team"
  ADD COLUMN IF NOT EXISTS "description" TEXT,
  ADD COLUMN IF NOT EXISTS "maxPlayers" INTEGER NOT NULL DEFAULT 11,
  ADD COLUMN IF NOT EXISTS "isRecruiting" BOOLEAN NOT NULL DEFAULT true;

-- AlterTable
ALTER TABLE "TeamMember"
  ADD COLUMN IF NOT EXISTS "role" TEXT NOT NULL DEFAULT 'MEMBER';

-- CreateTable
CREATE TABLE IF NOT EXISTS "TeamApplication" (
  "id" TEXT NOT NULL,
  "teamId" TEXT NOT NULL,
  "userId" TEXT NOT NULL,
  "message" TEXT,
  "status" TEXT NOT NULL DEFAULT 'PENDING',
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "reviewedAt" TIMESTAMP(3),
  CONSTRAINT "TeamApplication_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX IF NOT EXISTS "TeamApplication_teamId_userId_key" ON "TeamApplication"("teamId", "userId");
CREATE INDEX IF NOT EXISTS "TeamApplication_teamId_status_idx" ON "TeamApplication"("teamId", "status");

-- AddForeignKey
DO $$ BEGIN
  ALTER TABLE "TeamApplication" ADD CONSTRAINT "TeamApplication_teamId_fkey"
    FOREIGN KEY ("teamId") REFERENCES "Team"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  ALTER TABLE "TeamApplication" ADD CONSTRAINT "TeamApplication_userId_fkey"
    FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
