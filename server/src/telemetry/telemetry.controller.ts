import { Body, Controller, Get, HttpCode, Post, UseGuards } from '@nestjs/common';
import { SkipThrottle } from '@nestjs/throttler';
import { IngestDto } from './dto/ingest.dto';
import { TelemetryService } from './telemetry.service';
import { TokenGuard } from './token.guard';

@Controller()
export class TelemetryController {
	constructor(private readonly service: TelemetryService) {}

	/**
	 * ⚠️ **2xx 를 돌려줘야 앱이 큐를 비운다.** 5xx 로 답하면 다음 실행 때 그대로 다시
	 *    올라온다(중복이 아니라 재시도다). 저장에 실패했으면 반드시 5xx 로 답할 것 —
	 *    200 을 주고 버리면 그 판은 영영 사라진다.
	 */
	@Post('collect')
	@UseGuards(TokenGuard)
	@HttpCode(200)
	async collect(@Body() dto: IngestDto): Promise<{ ok: true; stored: number }> {
		const stored = await this.service.store(dto.install_id, dto.runs);
		return { ok: true, stored };
	}

	@Get('health')
	@SkipThrottle()
	health(): { ok: true } {
		return { ok: true };
	}
}
