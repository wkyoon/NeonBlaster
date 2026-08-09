# 텔레메트리 수신 서버

알파 테스터의 판 기록을 받는 최소 구성. PHP 7.4+ 만 있으면 된다.

## 배포

1. `collect.php` 를 `https://won-solution.com/api/nb/collect.php` 로 올린다.
2. 같은 폴더에 `data/` 를 만들고 쓰기 권한을 준다(0750).
3. `.htaccess.data` 를 `data/.htaccess` 로 올린다 — **이걸 빠뜨리면 수집 파일이 웹으로 열린다.**
4. `collect.php` 의 `TOKEN` 과 `scripts/Telemetry.gd` 의 `TOKEN` 을 같은 값으로 바꾼다.

## 확인

```bash
curl -sS -X POST https://won-solution.com/api/nb/collect.php \
  -H 'Content-Type: application/json' -H 'X-NB-Token: <토큰>' \
  -d '{"schema":1,"install_id":"0123456789abcdef","runs":[{"end_reason":"died","survival_time":123.4}]}'
# → {"ok":true,"stored":1}
```

## 수집 결과 내려받아 집계

```bash
scp <호스트>:/.../api/nb/data/runs-*.jsonl export/telemetry/
python3 tools/telemetry_report.py export/telemetry/*.jsonl
```

## 원칙

- **IP 를 저장하지 않는다.** 앱에서 "계정·연락처·광고ID 를 수집하지 않는다" 고 고지했으므로
  서버가 IP 를 남기면 그 고지가 거짓이 된다. 웹서버 access log 보존 기간도 짧게 둘 것.
- 2xx 를 돌려줘야 앱이 큐를 비운다. 5xx 로 답하면 다음 실행 때 그대로 다시 올라온다.
- 테스트가 끝나면 `data/` 를 지운다. 남길 이유가 없는 자료를 오래 들고 있지 않는다.
