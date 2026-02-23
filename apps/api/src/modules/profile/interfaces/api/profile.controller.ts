import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Req,
  UploadedFile,
  UseGuards,
  UseInterceptors,
  UsePipes
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { JwtAuthGuard } from '@/common/guards/jwt-auth.guard';
import { z } from 'zod';
import { ZodValidationPipe } from '@/common/validation/zod-validation.pipe';
import { ProfileService } from '../../application/profile.service';

const updateProfileSchema = z.object({
  fullName: z.string().min(3).optional(),
  bio: z.string().max(180).optional(),
  avatarUrl: z.string().url().optional(),
  preferredPositions: z.array(z.string().min(2)).max(5).optional()
});

const createStorySchema = z.object({
  mediaUrl: z.string().url(),
  caption: z.string().max(100).optional(),
  isHighlighted: z.boolean().optional()
});

const setHighlightedSchema = z.object({
  isHighlighted: z.boolean()
});

const createPostSchema = z.object({
  content: z.string().min(1).max(500),
  imageUrl: z.string().url().optional()
});


const upsertVenueOwnerProfileSchema = z.object({
  venueName: z.string().min(3),
  venuePhotoUrl: z.string().url().optional(),
  bio: z.string().max(300).optional(),
  address: z.string().min(5),
  contactPhone: z.string().min(6),
  openingHours: z.string().min(3),
  fields: z.array(
    z.object({
      name: z.string().min(2),
      rates: z.array(
        z.object({
          dayOfWeek: z.number().int().min(0).max(6),
          startHour: z.number().int().min(0).max(23),
          endHour: z.number().int().min(1).max(24),
          price: z.number().positive()
        })
      ).min(1)
    })
  ).min(1)
});

const refereeVerificationSchema = z.object({
  documentUrl: z.string().url()
});

@Controller('profile')
@UseGuards(JwtAuthGuard)
export class ProfileController {
  constructor(private readonly profileService: ProfileService) {}

  @Get('users/:userId')
  userProfile(@Param('userId') userId: string) {
    return this.profileService.getUserProfile(userId);
  }

  @Get('me')
  me(@Req() req: Express.Request) {
    return this.profileService.getMe(req.user!.sub);
  }

  @Get('feed')
  feed() {
    return this.profileService.getFeed();
  }


  @Get('venue-owner/me')
  venueOwnerProfile(@Req() req: Express.Request) {
    return this.profileService.getVenueOwnerProfile(req.user!.sub);
  }

  @Patch('venue-owner/me')
  @UsePipes(new ZodValidationPipe(upsertVenueOwnerProfileSchema))
  upsertVenueOwnerProfile(
    @Req() req: Express.Request,
    @Body() body: z.infer<typeof upsertVenueOwnerProfileSchema>
  ) {
    return this.profileService.upsertVenueOwnerProfile(req.user!.sub, body);
  }

  @Get('referee/assignments')
  refereeAssignments(@Req() req: Express.Request) {
    return this.profileService.getRefereeAssignments(req.user!.sub);
  }

  @Post('referee/verification')
  @UsePipes(new ZodValidationPipe(refereeVerificationSchema))
  submitRefereeVerification(
    @Req() req: Express.Request,
    @Body() body: z.infer<typeof refereeVerificationSchema>
  ) {
    return this.profileService.submitRefereeVerification(req.user!.sub, body);
  }


  @Patch('me')
  @UsePipes(new ZodValidationPipe(updateProfileSchema))
  updateMe(@Req() req: Express.Request, @Body() body: z.infer<typeof updateProfileSchema>) {
    return this.profileService.updateMe(req.user!.sub, body);
  }

  @Post('upload')
  @UseInterceptors(FileInterceptor('file'))
  upload(
    @Req() req: Express.Request,
    @UploadedFile() file: { buffer: Buffer; originalname: string; mimetype: string }
  ) {
    return this.profileService.uploadMedia(req.user!.sub, file);
  }

  @Post('stories')
  @UsePipes(new ZodValidationPipe(createStorySchema))
  createStory(@Req() req: Express.Request, @Body() body: z.infer<typeof createStorySchema>) {
    return this.profileService.createStory(req.user!.sub, body);
  }

  @Patch('stories/:storyId/highlight')
  @UsePipes(new ZodValidationPipe(setHighlightedSchema))
  setStoryHighlight(
    @Req() req: Express.Request,
    @Param('storyId') storyId: string,
    @Body() body: z.infer<typeof setHighlightedSchema>
  ) {
    return this.profileService.setStoryHighlighted(req.user!.sub, storyId, body.isHighlighted);
  }

  @Post('posts')
  @UsePipes(new ZodValidationPipe(createPostSchema))
  createPost(@Req() req: Express.Request, @Body() body: z.infer<typeof createPostSchema>) {
    return this.profileService.createPost(req.user!.sub, body);
  }
}
