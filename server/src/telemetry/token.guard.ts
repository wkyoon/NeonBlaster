import { CanActivate, ExecutionContext, Injectable, ForbiddenException } from '@nestjs/common';
import { timingSafeEqual } from 'node:crypto';
import type { Request } from 'express';

/**
 * `X-NB-Token` 헤더 확인.
 *
 * ⚠️ 인증이 아니라 **잡음 차단**이다. 토큰은 APK 안에 들어가므로 뜯어보면 나온다.
 *    민감한 것을 이 뒤에 두지 말 것.
 * ⚠️ 쿼리스트링이 아니라 헤더로 받는다 — 쿼리스트링은 앞단 웹서버 로그에 남는다.
 */
@Injectable()
export class TokenGuard implements CanActivate {
	canActivate(context: ExecutionContext): boolean {
		const expected = process.env.NB_TOKEN ?? '';
		if (expected === '') {
			// 토큰을 안 정하고 띄우면 누구나 쓸 수 있는 열린 수집기가 된다.
			throw new ForbiddenException('NB_TOKEN 이 설정되지 않았다');
		}
		const req = context.switchToHttp().getRequest<Request>();
		const got = String(req.headers['x-nb-token'] ?? '');
		if (!TokenGuard.equals(got, expected)) {
			throw new ForbiddenException();
		}
		return true;
	}

	/** 길이가 달라도 timingSafeEqual 이 던지지 않도록 감싼다. */
	private static equals(a: string, b: string): boolean {
		const ba = Buffer.from(a);
		const bb = Buffer.from(b);
		if (ba.length !== bb.length) {
			return false;
		}
		return timingSafeEqual(ba, bb);
	}
}
