import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';
import { APP_GUARD } from '@nestjs/core';
import { TelemetryModule } from './telemetry/telemetry.module';

@Module({
	imports: [
		ConfigModule.forRoot({ isGlobal: true }),
		// 토큰이 APK 안에 있어 뜯으면 나온다. 인증이 아니라 잡음 차단이므로
		// 유량 제한을 함께 둔다. 정상 앱은 실행당 한 번만 올린다.
		// ⚠️ 한도를 낮게 잡지 마라. 테스터 수십 명이 같은 사무실 WiFi(단일 NAT IP)에
		//    있으면 정상 트래픽이 막힌다. 실제로 30/분에서 e2e 동시 요청 40건 중 15건이
		//    429 로 떨어졌다.
		// ⚠️ 막혀도 자료를 잃지는 않는다 — 앱은 2xx 가 아니면 큐를 그대로 두고 다음 실행 때
		//    다시 보낸다. 그래도 회수가 늦어지므로 넉넉히 둔다.
		// ⚠️ 유량 제한은 IP 를 **판단에만** 쓰고 저장하지 않는다(메모리 카운터).
		ThrottlerModule.forRoot([{ ttl: 60_000, limit: 300 }]),
		TelemetryModule,
	],
	providers: [{ provide: APP_GUARD, useClass: ThrottlerGuard }],
})
export class AppModule {}
