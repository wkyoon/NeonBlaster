import { ValidationPipe, Logger } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import type { NestExpressApplication } from '@nestjs/platform-express';
import { AppModule } from './app.module';

/**
 * NeonBlaster 알파 텔레메트리 수신 서버.
 *
 * ⚠️ **IP 를 저장하거나 로그로 남기지 않는다.** 앱에서 "계정·연락처·광고ID 를 수집하지 않는다"
 *    라고 고지했으므로 서버가 IP 를 남기면 그 고지가 거짓이 되고, Play 데이터 보안 양식과도
 *    어긋난다. 그래서 access log 미들웨어(morgan 등)를 **일부러 붙이지 않았다**.
 *    앞단 nginx 의 access_log 도 꺼거나 보존 기간을 짧게 둘 것.
 */
async function bootstrap(): Promise<void> {
	const app = await NestFactory.create<NestExpressApplication>(AppModule, {
		// 요청 로그를 남기지 않는다(위 참조). 기동/오류 로그만 본다.
		logger: ['error', 'warn', 'log'],
	});

	// 서버 종류를 굳이 알릴 이유가 없다.
	app.disable('x-powered-by');

	// 판 300개 배치도 1MB 안에 들어온다. 그 이상은 우리 앱이 보낸 것이 아니다.
	app.useBodyParser('json', { limit: '1mb' });

	app.useGlobalPipes(
		new ValidationPipe({
			whitelist: true,
			// ⚠️ forbidNonWhitelisted 는 쓰지 않는다. 앱이 새 지표를 추가하면
			//    구버전 서버가 전부 400 으로 거절해 테스터 자료가 통째로 날아간다.
			//    모르는 항목은 조용히 무시하는 편이 안전하다.
			transform: true,
		}),
	);

	const port = Number(process.env.PORT ?? 3000);
	await app.listen(port);
	Logger.log(`텔레메트리 수신 대기: :${port}`, 'Bootstrap');
}

void bootstrap();
