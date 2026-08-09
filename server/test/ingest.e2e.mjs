// 수신 서버 동작 확인.
//   cd server && npm run build && npm run test:e2e
// 임시 폴더에 서버를 띄우고 실제 HTTP 요청을 보낸다.
import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { spawn } from 'node:child_process';
import { mkdtemp, readFile, readdir } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

const TOKEN = 'test-token';
const PORT = 34561;
const BASE = `http://127.0.0.1:${PORT}`;
let proc;
let dataDir;

const post = (body, headers = {}) =>
	fetch(`${BASE}/collect`, {
		method: 'POST',
		headers: { 'Content-Type': 'application/json', 'X-NB-Token': TOKEN, ...headers },
		body: typeof body === 'string' ? body : JSON.stringify(body),
	});

const validRun = (extra = {}) => ({
	schema: 1,
	install_id: '0123456789abcdef',
	runs: [{ end_reason: 'died', survival_time: 512.5, alive_avg: 4.2, ...extra }],
});

before(async () => {
	dataDir = await mkdtemp(join(tmpdir(), 'nb-telemetry-'));
	proc = spawn(process.execPath, ['dist/main.js'], {
		env: { ...process.env, NB_TOKEN: TOKEN, NB_DATA_DIR: dataDir, PORT: String(PORT) },
		stdio: ['ignore', 'pipe', 'pipe'],
	});
	for (let i = 0; i < 100; i++) {
		try {
			const r = await fetch(`${BASE}/health`);
			if (r.ok) return;
		} catch {}
		await new Promise((r) => setTimeout(r, 100));
	}
	throw new Error('서버가 뜨지 않았다');
});

after(() => proc?.kill());

test('정상 요청은 저장된다', async () => {
	const res = await post(validRun());
	assert.equal(res.status, 200);
	assert.deepEqual(await res.json(), { ok: true, stored: 1 });

	const files = (await readdir(dataDir)).filter((f) => f.endsWith('.jsonl'));
	assert.equal(files.length, 1, '하루 한 파일이어야 한다');
	const line = (await readFile(join(dataDir, files[0]), 'utf8')).trim().split('\n').at(-1);
	const rec = JSON.parse(line);
	assert.equal(rec.install_id, '0123456789abcdef');
	assert.equal(rec.end_reason, 'died');
	// ⚠️ 여기가 핵심이다. whitelist 가 중첩 항목을 버리면 빈 껍데기만 저장된다.
	assert.equal(rec.survival_time, 512.5, '지표가 버려졌다');
	assert.equal(rec.alive_avg, 4.2, '지표가 버려졌다');
	assert.ok(rec._received_at, '수신 시각이 붙어야 한다');
});

test('토큰이 틀리면 403', async () => {
	const res = await post(validRun(), { 'X-NB-Token': 'wrong' });
	assert.equal(res.status, 403);
});

test('토큰이 없으면 403', async () => {
	const res = await fetch(`${BASE}/collect`, {
		method: 'POST',
		headers: { 'Content-Type': 'application/json' },
		body: JSON.stringify(validRun()),
	});
	assert.equal(res.status, 403);
});

test('install_id 형식이 다르면 400', async () => {
	const res = await post({ ...validRun(), install_id: 'nope' });
	assert.equal(res.status, 400);
});

test('모르는 지표가 있어도 받아 적는다 (앱이 먼저 올라가도 자료를 잃지 않는다)', async () => {
	const res = await post(validRun({ brand_new_metric: 42 }));
	assert.equal(res.status, 200);
	const files = (await readdir(dataDir)).filter((f) => f.endsWith('.jsonl'));
	const lines = (await readFile(join(dataDir, files[0]), 'utf8')).trim().split('\n');
	const rec = JSON.parse(lines.at(-1));
	assert.equal(rec.brand_new_metric, 42, '모르는 항목이 버려졌다');
});

test('동시에 들어와도 줄이 섞이지 않는다', async () => {
	const N = 40;
	await Promise.all(
		Array.from({ length: N }, (_, i) =>
			post({ schema: 1, install_id: 'abcdef0123456789', runs: [{ end_reason: 'quit', seq: i }] }),
		),
	);
	const files = (await readdir(dataDir)).filter((f) => f.endsWith('.jsonl'));
	const lines = (await readFile(join(dataDir, files[0]), 'utf8')).trim().split('\n');
	for (const l of lines) JSON.parse(l); // 깨진 줄이 있으면 여기서 던진다
	const seqs = lines.map((l) => JSON.parse(l).seq).filter((s) => s !== undefined);
	assert.equal(new Set(seqs).size, N, '유실되거나 겹친 줄이 있다');
});

test('본문이 1MB 를 넘으면 413', async () => {
	const big = 'x'.repeat(1_200_000);
	const res = await post(`{"schema":1,"install_id":"0123456789abcdef","runs":[{"pad":"${big}"}]}`);
	assert.equal(res.status, 413);
});
