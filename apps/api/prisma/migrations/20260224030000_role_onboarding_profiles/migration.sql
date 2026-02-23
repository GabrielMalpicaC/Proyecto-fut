CREATE TABLE IF NOT EXISTS "VenueOwnerProfile" (
  "id" TEXT NOT NULL,
  "userId" TEXT NOT NULL,
  "venueName" TEXT NOT NULL,
  "venuePhotoUrl" TEXT,
  "bio" TEXT,
  "address" TEXT NOT NULL,
  "contactPhone" TEXT NOT NULL,
  "openingHours" TEXT NOT NULL,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "VenueOwnerProfile_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "VenueOwnerProfile_userId_key" ON "VenueOwnerProfile"("userId");

CREATE TABLE IF NOT EXISTS "VenueField" (
  "id" TEXT NOT NULL,
  "profileId" TEXT NOT NULL,
  "name" TEXT NOT NULL,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "VenueField_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "VenueFieldRate" (
  "id" TEXT NOT NULL,
  "fieldId" TEXT NOT NULL,
  "dayOfWeek" INTEGER NOT NULL,
  "startHour" INTEGER NOT NULL,
  "endHour" INTEGER NOT NULL,
  "price" DECIMAL(10,2) NOT NULL,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "VenueFieldRate_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "RefereeVerification" (
  "id" TEXT NOT NULL,
  "userId" TEXT NOT NULL,
  "documentUrl" TEXT NOT NULL,
  "verificationStatus" TEXT NOT NULL DEFAULT 'PENDING',
  "notes" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "RefereeVerification_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "RefereeVerification_userId_key" ON "RefereeVerification"("userId");

CREATE TABLE IF NOT EXISTS "MatchRefereeAssignment" (
  "id" TEXT NOT NULL,
  "matchId" TEXT NOT NULL,
  "refereeId" TEXT NOT NULL,
  "venueName" TEXT,
  "scheduledAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "status" TEXT NOT NULL DEFAULT 'PENDING',
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "MatchRefereeAssignment_pkey" PRIMARY KEY ("id")
);

CREATE INDEX IF NOT EXISTS "MatchRefereeAssignment_refereeId_status_idx" ON "MatchRefereeAssignment"("refereeId", "status");

DO $$ BEGIN
  ALTER TABLE "VenueOwnerProfile" ADD CONSTRAINT "VenueOwnerProfile_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE "VenueField" ADD CONSTRAINT "VenueField_profileId_fkey" FOREIGN KEY ("profileId") REFERENCES "VenueOwnerProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE "VenueFieldRate" ADD CONSTRAINT "VenueFieldRate_fieldId_fkey" FOREIGN KEY ("fieldId") REFERENCES "VenueField"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE "RefereeVerification" ADD CONSTRAINT "RefereeVerification_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE "MatchRefereeAssignment" ADD CONSTRAINT "MatchRefereeAssignment_matchId_fkey" FOREIGN KEY ("matchId") REFERENCES "Match"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE "MatchRefereeAssignment" ADD CONSTRAINT "MatchRefereeAssignment_refereeId_fkey" FOREIGN KEY ("refereeId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN null;
END $$;
