import { Inject, Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { AppError } from '@/common/errors/app-error';
import { IMediaStorage, MEDIA_STORAGE } from '@/infrastructure/storage/media-storage.interface';
import { ProfileRepository } from '../infrastructure/profile.repository';

@Injectable()
export class ProfileService {
  constructor(
    private readonly profileRepository: ProfileRepository,
    @Inject(MEDIA_STORAGE) private readonly mediaStorage: IMediaStorage
  ) {}

  async getMe(userId: string) {
    try {
      const profile = await this.profileRepository.getProfile(userId);
      if (!profile) throw new AppError('PROFILE_NOT_FOUND', 'Profile not found', 404);

      return {
        ...profile,
        highlightedStories: profile.stories.filter((story) => story.isHighlighted)
      };
    } catch (error) {
      if (!this.isSchemaDriftError(error)) {
        throw error;
      }

      const legacyProfile = await this.profileRepository.getProfile(userId);
      if (!legacyProfile) throw new AppError('PROFILE_NOT_FOUND', 'Profile not found', 404);

      return {
        ...legacyProfile,
        avatarUrl: null,
        bio: null,
        preferredPositions: [],
        stories: [],
        highlightedStories: [],
        posts: []
      };
    }
  }

  async getFeed() {
    try {
      return await this.profileRepository.getCommunityFeed();
    } catch (error) {
      if (this.isSchemaDriftError(error)) {
        return [];
      }
      throw error;
    }
  }

  updateMe(
    userId: string,
    body: { fullName?: string; bio?: string; avatarUrl?: string; preferredPositions?: string[] }
  ) {
    return this.profileRepository.updateProfile(userId, body);
  }

  createStory(
    userId: string,
    body: { mediaUrl: string; caption?: string; isHighlighted?: boolean }
  ) {
    return this.profileRepository.createStory(userId, body);
  }

  async setStoryHighlighted(userId: string, storyId: string, isHighlighted: boolean) {
    const result = await this.profileRepository.setStoryHighlighted(userId, storyId, isHighlighted);
    if (result.count === 0) throw new AppError('STORY_NOT_FOUND', 'Story not found', 404);
    return { ok: true };
  }

  createPost(userId: string, body: { content: string; imageUrl?: string }) {
    return this.profileRepository.createPost(userId, body);
  }

  async uploadMedia(
    userId: string,
    file: { buffer: Buffer; originalname: string; mimetype: string }
  ) {
    if (!file) throw new AppError('FILE_REQUIRED', 'File is required', 400);
    const key = `profiles/${userId}/${Date.now()}-${file.originalname}`;
    const url = await this.mediaStorage.upload({
      key,
      body: file.buffer,
      contentType: file.mimetype
    });
    return { url };
  }

  private isSchemaDriftError(error: unknown): boolean {
    if (!(error instanceof Prisma.PrismaClientKnownRequestError)) {
      return false;
    }

    return error.code === 'P2021' || error.code === 'P2022';
  }
}
