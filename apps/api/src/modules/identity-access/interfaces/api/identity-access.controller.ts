import { Body, Controller, Post, UsePipes } from '@nestjs/common';
import { UserRole } from '@/common/enums';
import { z } from 'zod';
import { ZodValidationPipe } from '@/common/validation/zod-validation.pipe';
import { IdentityAccessService } from '../../application/identity-access.service';

const registerSchema = z.object({
  email: z.string().email(),
  fullName: z.string().min(3),
  password: z.string().min(8),
  role: z.nativeEnum(UserRole).optional(),
  roles: z.array(z.nativeEnum(UserRole)).optional()
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

  @Post('register')
  @UsePipes(new ZodValidationPipe(registerSchema))
  register(@Body() body: z.infer<typeof registerSchema>) {
    const normalizedRoles = body.roles?.length
      ? body.roles
      : body.role
        ? [body.role]
        : undefined;

    return this.identityAccessService.register({
      email: body.email,
      fullName: body.fullName,
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
