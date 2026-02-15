import { Inject, Injectable } from '@nestjs/common';
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
      return await this.getProfileWithHighlights(userId);
    } catch (error) {
      if (!this.isSchemaDriftError(error)) {
        throw error;
      }

      await this.profileRepository.ensureProfileSchemaReady();

      try {
        return await this.getProfileWithHighlights(userId);
      } catch (retryError) {
        if (!this.isSchemaDriftError(retryError)) {
          throw retryError;
        }

        const legacyProfile = await this.profileRepository.getLegacyProfile(userId);
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
  }

  async getFeed() {
    try {
      return await this.profileRepository.getCommunityFeed();
    } catch (error) {
      if (!this.isSchemaDriftError(error)) {
        throw error;
      }

      await this.profileRepository.ensureProfileSchemaReady();
      return this.profileRepository.getCommunityFeed();
    }
  }

  async updateMe(
    userId: string,
    body: { fullName?: string; bio?: string; avatarUrl?: string; preferredPositions?: string[] }
  ) {
    return this.withSchemaRecovery(() => this.profileRepository.updateProfile(userId, body));
  }

  async createStory(
    userId: string,
    body: { mediaUrl: string; caption?: string; isHighlighted?: boolean }
  ) {
    return this.withSchemaRecovery(() => this.profileRepository.createStory(userId, body));
  }

  async setStoryHighlighted(userId: string, storyId: string, isHighlighted: boolean) {
    const result = await this.withSchemaRecovery<{ count: number }>(() =>
      this.profileRepository.setStoryHighlighted(userId, storyId, isHighlighted)
    );

    if (result.count === 0) throw new AppError('STORY_NOT_FOUND', 'Story not found', 404);
    return { ok: true };
  }

  async createPost(userId: string, body: { content: string; imageUrl?: string }) {
    return this.withSchemaRecovery(() => this.profileRepository.createPost(userId, body));
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

  private async getProfileWithHighlights(userId: string) {
    const profile = await this.profileRepository.getProfile(userId);
    if (!profile) throw new AppError('PROFILE_NOT_FOUND', 'Profile not found', 404);

    return {
      ...profile,
      highlightedStories: profile.stories.filter(
        (story: { isHighlighted: boolean }) => story.isHighlighted
      )
    };
  }

  private async withSchemaRecovery<T>(operation: () => Promise<T>): Promise<T> {
    try {
      return await operation();
    } catch (error) {
      if (!this.isSchemaDriftError(error)) {
        throw error;
      }

      try {
        await this.profileRepository.ensureProfileSchemaReady();
        return await operation();
      } catch (retryError) {
        this.throwSchemaNotReady(retryError);
        throw retryError;
      }
    }
  }

  private throwSchemaNotReady(error: unknown): void {
    if (this.isSchemaDriftError(error)) {
      throw new AppError(
        'PROFILE_SCHEMA_NOT_READY',
        'Perfil temporalmente no disponible. Ejecuta las migraciones pendientes con: npm run prisma:migrate',
        503
      );
    }
  }

  private isSchemaDriftError(error: unknown): boolean {
    if (typeof error !== 'object' || error === null || !('code' in error)) {
      return false;
    }

    const code = String((error as { code?: unknown }).code ?? '');
    return code === 'P2021' || code === 'P2022';
  }
}
