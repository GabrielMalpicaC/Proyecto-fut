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
      const profile = await this.profileRepository.getProfile(userId);
      if (!profile) throw new AppError('PROFILE_NOT_FOUND', 'Profile not found', 404);

      return {
        ...profile,
        highlightedStories: profile.stories.filter(
          (story: { isHighlighted: boolean }) => story.isHighlighted
        )
      };
    } catch (error) {
      if (!this.isSchemaDriftError(error)) {
        this.throwSchemaNotReady(error);
        throw error;
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

  async getFeed() {
    try {
      return await this.profileRepository.getCommunityFeed();
    } catch (error) {
      if (this.isSchemaDriftError(error)) {
        return [];
      }
      this.throwSchemaNotReady(error);
      throw error;
    }
  }

  async updateMe(
    userId: string,
    body: { fullName?: string; bio?: string; avatarUrl?: string; preferredPositions?: string[] }
  ) {
    try {
      return await this.profileRepository.updateProfile(userId, body);
    } catch (error) {
      this.throwSchemaNotReady(error);
      throw error;
    }
  }

  async createStory(
    userId: string,
    body: { mediaUrl: string; caption?: string; isHighlighted?: boolean }
  ) {
    try {
      return await this.profileRepository.createStory(userId, body);
    } catch (error) {
      this.throwSchemaNotReady(error);
      throw error;
    }
  }

  async setStoryHighlighted(userId: string, storyId: string, isHighlighted: boolean) {
    try {
      const result = await this.profileRepository.setStoryHighlighted(
        userId,
        storyId,
        isHighlighted
      );
      if (result.count === 0) throw new AppError('STORY_NOT_FOUND', 'Story not found', 404);
      return { ok: true };
    } catch (error) {
      this.throwSchemaNotReady(error);
      throw error;
    }
  }

  async createPost(userId: string, body: { content: string; imageUrl?: string }) {
    try {
      return await this.profileRepository.createPost(userId, body);
    } catch (error) {
      this.throwSchemaNotReady(error);
      throw error;
    }
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

  private throwSchemaNotReady(error: unknown): void {
    if (this.isSchemaDriftError(error)) {
      throw new AppError(
        'PROFILE_SCHEMA_NOT_READY',
        'Perfil temporalmente no disponible. Ejecuta las migraciones pendientes con: npm run prisma:migrate',
        503
      );
    }

    if (this.isDatabaseUnavailableError(error)) {
      throw new AppError(
        'PROFILE_DB_UNAVAILABLE',
        'No se pudo conectar a la base de datos. Verifica que el backend y Postgres estén levantados.',
        503
      );
    }
  }

  private isSchemaDriftError(error: unknown): boolean {
    const code = this.errorCode(error);
    return code === 'P2021' || code === 'P2022';
  }

  private isDatabaseUnavailableError(error: unknown): boolean {
    const code = this.errorCode(error);
    return code === 'P1001' || code === 'P1008' || code === 'P1017';
  }

  private errorCode(error: unknown): string | null {
    if (typeof error !== 'object' || error === null || !('code' in error)) {
      return null;
    }

    const code = (error as { code?: unknown }).code;
    if (typeof code === 'string' && code.length > 0) {
      return code;
    }

    return null;
  }
}
