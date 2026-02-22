import { Body, Controller, Get, Post, Req, UseGuards, UsePipes } from '@nestjs/common';
import { z } from 'zod';
import { JwtAuthGuard } from '@/common/guards/jwt-auth.guard';
import { ZodValidationPipe } from '@/common/validation/zod-validation.pipe';
import { MatchesService } from '../../application/matches.service';

const queueSchema = z.object({
  mode: z.enum(['CASUAL', 'COMPETITIVE'])
});

@Controller('matches')
@UseGuards(JwtAuthGuard)
export class MatchesController {
  constructor(private readonly matchesService: MatchesService) {}

  @Post('search')
  @UsePipes(new ZodValidationPipe(queueSchema))
  search(@Req() req: Express.Request, @Body() body: z.infer<typeof queueSchema>) {
    return this.matchesService.searchMatch(req.user!.sub, body.mode);
  }

  @Post('cancel-search')
  @UsePipes(new ZodValidationPipe(queueSchema))
  cancelSearch(@Req() req: Express.Request, @Body() body: z.infer<typeof queueSchema>) {
    return this.matchesService.cancelSearch(req.user!.sub, body.mode);
  }

  @Get('search-status')
  searchStatus(@Req() req: Express.Request) {
    return this.matchesService.mySearchStatus(req.user!.sub);
  }
}
