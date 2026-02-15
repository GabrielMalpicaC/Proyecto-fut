import { Body, Controller, Param, Post, Req, UseGuards, UsePipes } from '@nestjs/common';
import { z } from 'zod';
import { JwtAuthGuard } from '@/common/guards/jwt-auth.guard';
import { ZodValidationPipe } from '@/common/validation/zod-validation.pipe';
import { TeamsService } from '../../application/teams.service';

const createTeamSchema = z.object({ name: z.string().min(3) });
const inviteSchema = z.object({ invitedUserId: z.string().uuid() });

@Controller('teams')
@UseGuards(JwtAuthGuard)
export class TeamsController {
  constructor(private readonly teamsService: TeamsService) {}

  @Post()
  @UsePipes(new ZodValidationPipe(createTeamSchema))
  create(@Req() req: Express.Request, @Body() body: z.infer<typeof createTeamSchema>) {
    return this.teamsService.createTeam(req.user!.sub, body);
  }

  @Post(':teamId/invite')
  @UsePipes(new ZodValidationPipe(inviteSchema))
  invite(@Param('teamId') teamId: string, @Body() body: z.infer<typeof inviteSchema>) {
    return this.teamsService.inviteMember(teamId, body);
  }

  @Post(':teamId/accept')
  accept(@Req() req: Express.Request, @Param('teamId') teamId: string) {
    return this.teamsService.acceptInvite(teamId, req.user!.sub);
  }
}
