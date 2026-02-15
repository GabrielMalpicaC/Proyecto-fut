export interface IMediaStorage {
  upload(_params: { key: string; body: Buffer; contentType: string }): Promise<string>;
}

export const MEDIA_STORAGE = Symbol('MEDIA_STORAGE');
