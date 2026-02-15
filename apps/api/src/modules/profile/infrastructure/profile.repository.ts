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
        posts: { orderBy: { createdAt: 'desc' }, take: 30 },
        stories: { orderBy: { createdAt: 'desc' }, take: 20 }
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
