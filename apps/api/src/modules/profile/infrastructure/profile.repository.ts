import { Injectable } from '@nestjs/common';
import { PrismaService } from '@/infrastructure/prisma/prisma.service';

@Injectable()
export class ProfileRepository {
  constructor(private readonly prisma: PrismaService) {}

  getProfile(userId: string) {
    return this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        fullName: true,
        avatarUrl: true,
        bio: true,
        preferredPositions: true,
        teamMemberships: {
          where: { status: 'ACTIVE' },
          take: 1,
          select: {
            role: true,
            team: {
              select: {
                id: true,
                name: true,
                maxPlayers: true,
                isRecruiting: true,
                footballType: true,
                formation: true,
                shieldUrl: true
              }
            }
          }
        },
        posts: { orderBy: { createdAt: 'desc' }, take: 30 },
        stories: { orderBy: { createdAt: 'desc' }, take: 20 }
      }
    });
  }

  getLegacyProfile(userId: string) {
    return this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        fullName: true
      }
    });
  }

  async ensureProfileSchemaReady() {
    await this.prisma.$executeRawUnsafe(
      'ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "avatarUrl" TEXT'
    );
    await this.prisma.$executeRawUnsafe('ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "bio" TEXT');
    await this.prisma.$executeRawUnsafe(
      'ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "preferredPositions" TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[]'
    );

    await this.prisma.$executeRawUnsafe(`
      CREATE TABLE IF NOT EXISTS "Post" (
        "id" TEXT NOT NULL,
        "userId" TEXT NOT NULL,
        "content" TEXT NOT NULL,
        "imageUrl" TEXT,
        "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT "Post_pkey" PRIMARY KEY ("id"),
        CONSTRAINT "Post_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE
      )
    `);

    await this.prisma.$executeRawUnsafe(`
      CREATE TABLE IF NOT EXISTS "Story" (
        "id" TEXT NOT NULL,
        "userId" TEXT NOT NULL,
        "mediaUrl" TEXT NOT NULL,
        "caption" TEXT,
        "isHighlighted" BOOLEAN NOT NULL DEFAULT false,
        "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT "Story_pkey" PRIMARY KEY ("id"),
        CONSTRAINT "Story_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE
      )
    `);

    await this.prisma.$executeRawUnsafe(
      'CREATE INDEX IF NOT EXISTS "Post_createdAt_idx" ON "Post"("createdAt" DESC)'
    );
    await this.prisma.$executeRawUnsafe(
      'CREATE INDEX IF NOT EXISTS "Story_createdAt_idx" ON "Story"("createdAt" DESC)'
    );
  }

  getCommunityFeed() {
    return this.prisma.post.findMany({
      orderBy: { createdAt: 'desc' },
      take: 50,
      include: {
        user: {
          select: {
            id: true,
            fullName: true,
            avatarUrl: true
          }
        }
      }
    });
  }

  updateProfile(
    userId: string,
    data: { fullName?: string; bio?: string; avatarUrl?: string; preferredPositions?: string[] }
  ) {
    return this.prisma.user.update({
      where: { id: userId },
      data,
      select: {
        id: true,
        email: true,
        fullName: true,
        avatarUrl: true,
        bio: true,
        preferredPositions: true
      }
    });
  }

  createStory(
    userId: string,
    data: { mediaUrl: string; caption?: string; isHighlighted?: boolean }
  ) {
    return this.prisma.story.create({
      data: {
        userId,
        mediaUrl: data.mediaUrl,
        caption: data.caption,
        isHighlighted: data.isHighlighted ?? false
      }
    });
  }

  setStoryHighlighted(userId: string, storyId: string, isHighlighted: boolean) {
    return this.prisma.story.updateMany({
      where: { id: storyId, userId },
      data: { isHighlighted }
    });
  }

  createPost(userId: string, data: { content: string; imageUrl?: string }) {
    return this.prisma.post.create({
      data: { userId, content: data.content, imageUrl: data.imageUrl }
    });
  }
}
