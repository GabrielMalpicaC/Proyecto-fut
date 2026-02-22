import { Body, Controller, Get, Param, Patch, Post, Req, UseGuards, UsePipes } from '@nestjs/common';
import { z } from 'zod';
import { JwtAuthGuard } from '@/common/guards/jwt-auth.guard';
import { ZodValidationPipe } from '@/common/validation/zod-validation.pipe';
import { TeamsService } from '../../application/teams.service';

const createTeamSchema = z.object({
  name: z.string().min(3),
  footballType: z.number().int().min(5).max(11),
  formation: z.string().min(3).max(20).optional(),
  description: z.string().max(500).optional(),
  shieldUrl: z.string().url().optional()
});

const updateTeamSchema = z.object({
  name: z.string().min(3).optional(),
  footballType: z.number().int().min(5).max(11).optional(),
  formation: z.string().min(3).max(20).optional(),
  description: z.string().max(500).optional(),
  shieldUrl: z.string().url().optional(),
  isRecruiting: z.boolean().optional()
});

const inviteSchema = z.object({ invitedUserId: z.string().uuid() });
const applySchema = z.object({ message: z.string().max(300).optional() });
const reviewApplicationSchema = z.object({ approve: z.boolean() });
const updateMemberRoleSchema = z.object({ role: z.enum(['MEMBER', 'CAPTAIN', 'CO_LEADER']) });

@Controller('teams')
@UseGuards(JwtAuthGuard)
export class TeamsController {
  constructor(private readonly teamsService: TeamsService) {}

  @Get('open')
  listOpenTeams() {
    return this.teamsService.listOpenTeams();
  }

  @Get('me')
  myTeam(@Req() req: Express.Request) {
    return this.teamsService.getMyTeam(req.user!.sub);
  }

  @Get(':teamId')
  getTeam(@Param('teamId') teamId: string) {
    return this.teamsService.getTeamProfile(teamId);
  }

  @Post()
  @UsePipes(new ZodValidationPipe(createTeamSchema))
  create(@Req() req: Express.Request, @Body() body: z.infer<typeof createTeamSchema>) {
    return this.teamsService.createTeam(req.user!.sub, body);
  }

  @Patch(':teamId')
  @UsePipes(new ZodValidationPipe(updateTeamSchema))
  update(
    @Req() req: Express.Request,
    @Param('teamId') teamId: string,
    @Body() body: z.infer<typeof updateTeamSchema>
  ) {
    return this.teamsService.updateTeam(teamId, req.user!.sub, body);
  }

  @Post(':teamId/invite')
  @UsePipes(new ZodValidationPipe(inviteSchema))
  invite(
    @Req() req: Express.Request,
    @Param('teamId') teamId: string,
    @Body() body: z.infer<typeof inviteSchema>
  ) {
    return this.teamsService.inviteMember(teamId, req.user!.sub, body);
  }

  @Post(':teamId/accept')
  accept(@Req() req: Express.Request, @Param('teamId') teamId: string) {
    return this.teamsService.acceptInvite(teamId, req.user!.sub);
  }

  @Post(':teamId/apply')
  @UsePipes(new ZodValidationPipe(applySchema))
  apply(
    @Req() req: Express.Request,
    @Param('teamId') teamId: string,
    @Body() body: z.infer<typeof applySchema>
  ) {
    return this.teamsService.applyToTeam(teamId, req.user!.sub, body.message);
  }

  @Get(':teamId/applications')
  applications(@Req() req: Express.Request, @Param('teamId') teamId: string) {
    return this.teamsService.listApplications(teamId, req.user!.sub);
  }


  @Patch(':teamId/members/:memberUserId/role')
  @UsePipes(new ZodValidationPipe(updateMemberRoleSchema))
  setMemberRole(
    @Req() req: Express.Request,
    @Param('teamId') teamId: string,
    @Param('memberUserId') memberUserId: string,
    @Body() body: z.infer<typeof updateMemberRoleSchema>
  ) {
    return this.teamsService.assignMemberRole(teamId, req.user!.sub, memberUserId, body.role);
  }

  @Patch(':teamId/members/:memberUserId/remove')
  removeMember(
    @Req() req: Express.Request,
    @Param('teamId') teamId: string,
    @Param('memberUserId') memberUserId: string
  ) {
    return this.teamsService.removeMember(teamId, req.user!.sub, memberUserId);
  }

  @Patch(':teamId/applications/:applicantUserId')
  @UsePipes(new ZodValidationPipe(reviewApplicationSchema))
  reviewApplication(
    @Req() req: Express.Request,
    @Param('teamId') teamId: string,
    @Param('applicantUserId') applicantUserId: string,
    @Body() body: z.infer<typeof reviewApplicationSchema>
  ) {
    return this.teamsService.reviewApplication(teamId, req.user!.sub, applicantUserId, body.approve);
  }
}
