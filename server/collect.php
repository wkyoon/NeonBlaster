<?php
/**
 * NeonBlaster 알파 텔레메트리 수신부.
 *
 * 배포: won-solution.com 의 /api/nb/collect.php 로 올린다(PHP 7.4+ 면 된다).
 *       같은 폴더에 쓰기 권한이 필요하고, 저장 폴더는 **웹으로 열리면 안 된다**.
 *
 * ⚠️ **IP 를 저장하지 않는다.** IP 는 개인정보다. 앱에 "계정·연락처·광고ID 를 수집하지 않는다"
 *    라고 고지해 놓고 서버가 IP 를 남기면 그 고지가 거짓이 되고 Play 데이터 보안 양식과도 어긋난다.
 *    (웹서버 access log 에는 남으므로 호스팅 설정에서 보존 기간을 짧게 둘 것.)
 *
 * ⚠️ TOKEN 은 APK 안에 들어가므로 뜯어보면 나온다. 인증이 아니라 **잡음 차단**용이다.
 *    민감한 것을 여기에 걸지 말 것.
 */

declare(strict_types=1);

const TOKEN       = 'CHANGE_ME_BEFORE_DEPLOY';
const DATA_DIR    = __DIR__ . '/data';   // ⚠️ 웹 접근 차단 필요(.htaccess 동봉)
const MAX_BODY    = 1048576;             // 1MB — 판 300개 배치도 이 안에 들어온다
const MAX_RUNS    = 400;

header('Content-Type: application/json; charset=utf-8');

function fail(int $code, string $msg): void {
	http_response_code($code);
	echo json_encode(['ok' => false, 'error' => $msg]);
	exit;
}

if (($_SERVER['REQUEST_METHOD'] ?? '') !== 'POST') {
	fail(405, 'POST only');
}

$raw = file_get_contents('php://input');
if ($raw === false || strlen($raw) === 0) {
	fail(400, 'empty body');
}
if (strlen($raw) > MAX_BODY) {
	fail(413, 'too large');
}

$payload = json_decode($raw, true);
if (!is_array($payload) || !isset($payload['runs']) || !is_array($payload['runs'])) {
	fail(400, 'bad payload');
}
if (count($payload['runs']) > MAX_RUNS) {
	fail(413, 'too many runs');
}

// install_id 는 앱이 만든 난수 16자리 hex 다. 형식이 다르면 우리 앱이 아니다.
$install = (string)($payload['install_id'] ?? '');
if (!preg_match('/^[0-9a-f]{16}$/', $install)) {
	fail(400, 'bad install_id');
}

// 토큰은 헤더로 받는다(쿼리스트링에 두면 로그에 남는다).
$token = $_SERVER['HTTP_X_NB_TOKEN'] ?? '';
if (!hash_equals(TOKEN, (string)$token)) {
	fail(403, 'forbidden');
}

if (!is_dir(DATA_DIR) && !mkdir(DATA_DIR, 0750, true) && !is_dir(DATA_DIR)) {
	fail(500, 'storage unavailable');
}

// 하루 한 파일. 분석 스크립트가 날짜별로 집계하기 쉽고, 파일 하나가 커지지 않는다.
$path = DATA_DIR . '/runs-' . gmdate('Y-m-d') . '.jsonl';
$fh = fopen($path, 'ab');
if ($fh === false) {
	fail(500, 'cannot open store');
}
// ⚠️ 여러 테스터가 동시에 올린다. 잠그지 않으면 줄이 섞여 JSON 이 깨진다.
if (!flock($fh, LOCK_EX)) {
	fclose($fh);
	fail(500, 'cannot lock');
}

$written = 0;
foreach ($payload['runs'] as $run) {
	if (!is_array($run)) {
		continue;
	}
	// 서버가 받은 시각. 기기 시계가 틀어져 있어도 순서를 알 수 있어야 한다.
	$run['_received_at'] = gmdate('c');
	$run['install_id']   = $install;
	$line = json_encode($run, JSON_UNESCAPED_UNICODE);
	if ($line === false) {
		continue;
	}
	fwrite($fh, $line . "\n");
	$written++;
}

flock($fh, LOCK_UN);
fclose($fh);

// ⚠️ 2xx 를 돌려줘야 앱이 큐를 비운다. 실패로 답하면 다음 실행 때 다시 올라온다(중복 아님).
echo json_encode(['ok' => true, 'stored' => $written]);
