import { ArrayMaxSize, IsArray, IsInt, IsObject, Matches } from 'class-validator';

/** 판 하나. 지표 이름은 `scripts/RunTelemetry.gd` / `scripts/Benchmark.gd` 와 같다. */
export type RunDto = Record<string, unknown>;

export class IngestDto {
	@IsInt()
	schema: number;

	/** 앱이 설치 시 만든 난수 16자리 hex. 형식이 다르면 우리 앱이 아니다. */
	@Matches(/^[0-9a-f]{16}$/)
	install_id: string;

	/**
	 * ⚠️ **판 안쪽을 DTO 로 검증하지 마라.** `ValidationPipe({whitelist:true})` 는
	 *    중첩 DTO 에 선언되지 않은 항목을 **말없이 버린다**. 실제로 `@ValidateNested` +
	 *    `@Type(() => RunDto)` 를 걸었더니 `survival_time`·`alive_avg` 가 통째로 사라져
	 *    빈 껍데기만 저장됐다(e2e 가 잡았다).
	 *    앱에 지표를 추가할 때마다 서버를 먼저 올려야 하는 구조도 위험하다 —
	 *    순서가 뒤집히면 그 사이 자료를 전부 잃는다.
	 *    형식(배열·객체·개수)만 보고 내용은 그대로 받아 적는다.
	 */
	@IsArray()
	@ArrayMaxSize(400)
	@IsObject({ each: true })
	runs: RunDto[];
}
