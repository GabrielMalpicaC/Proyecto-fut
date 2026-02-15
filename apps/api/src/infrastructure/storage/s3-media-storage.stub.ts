import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { IMediaStorage } from './media-storage.interface';

@Injectable()
export class S3MediaStorageStub implements IMediaStorage {
  constructor(private readonly configService: ConfigService) {}

  async upload(params: { key: string; body: Buffer; contentType: string }): Promise<string> {
    const endpoint = this.configService.get<string>('storage.endpoint');
    const bucket = this.configService.get<string>('storage.bucket');
    void params.body;
    void params.contentType;
    return `${endpoint}/${bucket}/${params.key}`;
  }
}
