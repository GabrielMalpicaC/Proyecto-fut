import { Body, Controller, Get, Post, UsePipes } from '@nestjs/common';
import { UserRole } from '@/common/enums';
import { z } from 'zod';
import { ZodValidationPipe } from '@/common/validation/zod-validation.pipe';
import { IdentityAccessService } from '../../application/identity-access.service';

const roleAliasMap: Record<string, UserRole> = {
  PLAYER: UserRole.PLAYER,
  JUGADOR: UserRole.PLAYER,
  VENUE_OWNER: UserRole.VENUE_OWNER,
  OWNER: UserRole.VENUE_OWNER,
  PROPIETARIO: UserRole.VENUE_OWNER,
  PROPIETARIO_CANCHA: UserRole.VENUE_OWNER,
  REFEREE: UserRole.REFEREE,
  ARBITRO: UserRole.REFEREE,
  ÁRBITRO: UserRole.REFEREE,
  ADMIN: UserRole.ADMIN
};

const roleValueSchema = z
  .string()
  .transform((value) => value.trim().toUpperCase())
  .transform((value) => roleAliasMap[value] ?? value)
  .pipe(z.nativeEnum(UserRole));

const registerSchema = z.object({
  email: z.string().email(),
  fullName: z.string().min(1).optional(),
  password: z.string().min(4),
  role: roleValueSchema.optional(),
  roles: z.array(roleValueSchema).optional()
});

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8)
});

const refreshSchema = z.object({
  refreshToken: z.string().min(10)
});

@Controller('auth')
export class IdentityAccessController {
  constructor(private readonly identityAccessService: IdentityAccessService) {}

  @Get('register')
  registerInfo() {
    return {
      ok: true,
      message: 'Usa POST /auth/register para crear cuenta'
    };
  }

  @Post('register')
  @UsePipes(new ZodValidationPipe(registerSchema))
  register(@Body() body: z.infer<typeof registerSchema>) {
    const normalizedRoles = body.roles?.length
      ? body.roles
      : body.role
        ? [body.role]
        : undefined;

    const fallbackName = body.email.split('@')[0] ?? 'Usuario';
    const normalizedFullName = body.fullName?.trim() || fallbackName;

    return this.identityAccessService.register({
      email: body.email,
      fullName: normalizedFullName,
      password: body.password,
      roles: normalizedRoles
    });
  }

  @Post('login')
  @UsePipes(new ZodValidationPipe(loginSchema))
  login(@Body() body: z.infer<typeof loginSchema>) {
    return this.identityAccessService.login(body);
  }

  @Post('refresh')
  @UsePipes(new ZodValidationPipe(refreshSchema))
  refresh(@Body() body: z.infer<typeof refreshSchema>) {
    return this.identityAccessService.refresh(body.refreshToken);
  }
}
