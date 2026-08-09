import { Injectable, InternalServerErrorException, Logger } from '@nestjs/common';
import { appendFile, mkdir } from 'node:fs/promises';
import { join, resolve } from 'node:path';
import type { RunDto } from './dto/ingest.dto';

@Injectable()
export class TelemetryService {
	private readonly logger = new Logger(TelemetryService.name);

	/**
	 * 쓰기 직렬화용 체인.
	 *
	 * ⚠️ 여러 테스터가 동시에 올린다. `appendFile` 여러 개를 동시에 걸면 한 줄이
	 *    다른 줄 중간에 끼어들어 JSONL 이 깨진다(PHP 판에서 flock 으로 막던 것과 같은 문제).
	 *    Node 는 프로세스가 하나이므로 프라미스 체인으로 순서를 강제하면 충분하다.
	 * ⚠️ 그래서 **여러 인스턴스로 띄우면 안 된다**(pm2 cluster / 다중 워커 금지).
	 *    늘려야 할 만큼 트래픽이 나올 규모가 아니고, 늘리는 순간 이 보장이 깨진다.
	 */
	private writeChain: Promise<void> = Promise.resolve();

	private get dataDir(): string {
		return resolve(process.env.NB_DATA_DIR ?? './data');
	}

	async store(installId: string, runs: RunDto[]): Promise<number> {
		if (runs.length === 0) {
			return 0;
		}

		// 하루 한 파일. 집계 스크립트가 날짜별로 읽기 쉽고 파일 하나가 커지지 않는다.
		const day = new Date().toISOString().slice(0, 10);
		const path = join(this.dataDir, `runs-${day}.jsonl`);

		const lines: string[] = [];
		for (const run of runs) {
			// ⚠️ IP 는 담지 않는다. 담을 수 있는 자리라고 담으면 고지가 거짓이 된다.
			const record = {
				...run,
				install_id: installId,
				// 기기 시계가 틀어져 있어도 순서를 알 수 있어야 한다.
				_received_at: new Date().toISOString(),
			};
			lines.push(JSON.stringify(record));
		}
		const payload = lines.join('\n') + '\n';

		const task = this.writeChain.then(async () => {
			await mkdir(this.dataDir, { recursive: true, mode: 0o750 });
			await appendFile(path, payload, { encoding: 'utf8', mode: 0o640 });
		});
		// 실패가 체인을 끊어 이후 요청까지 전부 죽는 일이 없게 한다.
		this.writeChain = task.catch(() => undefined);

		try {
			await task;
		} catch (err) {
			this.logger.error(`저장 실패: ${String(err)}`);
			// ⚠️ 반드시 5xx 로 답해야 앱이 큐를 유지해 다음에 다시 보낸다.
			throw new InternalServerErrorException('storage failure');
		}
		return lines.length;
	}
}
