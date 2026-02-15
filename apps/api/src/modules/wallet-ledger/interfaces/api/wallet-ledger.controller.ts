import { Body, Controller, Get, Post, Req, UseGuards, UsePipes } from '@nestjs/common';
import { UserRole } from '@/common/enums';
import { z } from 'zod';
import { JwtAuthGuard } from '@/common/guards/jwt-auth.guard';
import { RolesGuard } from '@/common/guards/roles.guard';
import { ZodValidationPipe } from '@/common/validation/zod-validation.pipe';
import { WalletLedgerService } from '../../application/wallet-ledger.service';

const topUpSchema = z.object({ amount: z.number().positive() });
const holdSchema = z.object({
  amount: z.number().positive(),
  reason: z.string().min(3),
  referenceId: z.string()
});
const releaseSchema = z.object({ holdId: z.string().uuid() });
const settleSchema = z.object({ holdId: z.string().uuid(), ownerUserId: z.string().uuid() });

@Controller('wallet')
@UseGuards(JwtAuthGuard)
export class WalletLedgerController {
  constructor(private readonly walletLedgerService: WalletLedgerService) {}

  @Post('top-up')
  @UseGuards(new RolesGuard([UserRole.ADMIN]))
  @UsePipes(new ZodValidationPipe(topUpSchema))
  topUp(@Req() req: Express.Request, @Body() body: z.infer<typeof topUpSchema>) {
    return this.walletLedgerService.topUp(req.user!.sub, body.amount);
  }

  @Get('balance')
  balance(@Req() req: Express.Request) {
    return this.walletLedgerService.getBalance(req.user!.sub);
  }

  @Post('holds')
  @UsePipes(new ZodValidationPipe(holdSchema))
  hold(@Req() req: Express.Request, @Body() body: z.infer<typeof holdSchema>) {
    return this.walletLedgerService.createHold(
      req.user!.sub,
      body.amount,
      body.reason,
      body.referenceId
    );
  }

  @Post('holds/release')
  @UsePipes(new ZodValidationPipe(releaseSchema))
  release(@Body() body: z.infer<typeof releaseSchema>) {
    return this.walletLedgerService.releaseHold(body.holdId);
  }

  @Post('holds/settle')
  @UsePipes(new ZodValidationPipe(settleSchema))
  settle(@Body() body: z.infer<typeof settleSchema>) {
    return this.walletLedgerService.settleHold(body.holdId, body.ownerUserId);
  }
}
