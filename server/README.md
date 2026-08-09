# 텔레메트리 수신 서버 (NestJS)

알파 테스터의 판 기록을 받아 날짜별 JSONL 로 쌓는다. Node 20+ 면 된다(개발은 24.18 에서 확인).

```
POST /collect   X-NB-Token: <토큰>   →  {"ok":true,"stored":N}
GET  /health                        →  {"ok":true}
```

## 로컬 실행

```bash
cd server
npm install
cp .env.example .env      # NB_TOKEN 을 실제 값으로 바꾼다
npm run build
npm run start:prod
```

## 테스트

```bash
npm run build && npm run test:e2e
```

실제로 서버를 띄워 HTTP 요청을 보낸다. 확인 항목:
정상 저장 / 토큰 오류 403 / 토큰 없음 403 / `install_id` 형식 400 /
**모르는 지표도 그대로 저장** / 동시 40건에서 줄 안 깨짐 / 1MB 초과 413.

## 배포 (won-solution.com)

### 1. 앱과 토큰 맞추기

`.env` 의 `NB_TOKEN` 과 [`scripts/Telemetry.gd`](../scripts/Telemetry.gd) 의 `TOKEN` 이
같아야 한다. 둘 다 초기값이 `CHANGE_ME_BEFORE_DEPLOY` 다.

### 2. systemd

```ini
# /etc/systemd/system/nb-telemetry.service
[Unit]
Description=NeonBlaster telemetry
After=network.target

[Service]
Type=simple
User=nbtel
WorkingDirectory=/opt/nb-telemetry
Environment=NODE_ENV=production
EnvironmentFile=/opt/nb-telemetry/.env
ExecStart=/usr/bin/node dist/main.js
Restart=always
# 수집 파일 말고는 아무 데도 못 쓰게 막는다.
ProtectSystem=strict
ReadWritePaths=/var/lib/nb-telemetry
PrivateTmp=true
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
```

`.env` 에 `NB_DATA_DIR=/var/lib/nb-telemetry` 를 넣는다.

> ⚠️ **워커를 여러 개로 늘리지 마라**(pm2 cluster 금지). 동시 쓰기 직렬화가
> 프로세스 하나를 전제로 한다. 늘리는 순간 JSONL 이 섞일 수 있다.
> 테스터 수십 명 규모에서 늘릴 이유도 없다.

### 3. nginx

```nginx
location /api/nb/ {
    proxy_pass http://127.0.0.1:3000/;
    proxy_set_header Host $host;
    client_max_body_size 2m;
    # ⚠️ 접근 로그에 IP 가 남는다. 앱에서 "수집하지 않는다" 고 고지했으므로 끄거나
    #    보존 기간을 짧게 둘 것.
    access_log off;
}
```

이러면 앱이 보내는 `https://won-solution.com/api/nb/collect` 가 Nest 의 `/collect` 로 간다.

### 4. 확인

```bash
curl -sS -X POST https://won-solution.com/api/nb/collect \
  -H 'Content-Type: application/json' -H 'X-NB-Token: <토큰>' \
  -d '{"schema":1,"install_id":"0123456789abcdef","runs":[{"end_reason":"died","survival_time":123.4}]}'
# → {"ok":true,"stored":1}
```

## 수집 결과 집계

```bash
scp <호스트>:/var/lib/nb-telemetry/runs-*.jsonl export/telemetry/
python3 tools/telemetry_report.py export/telemetry/*.jsonl
```

## 원칙

- **IP 를 저장하지 않는다.** 앱에서 "계정·연락처·광고ID 를 수집하지 않는다" 고 고지했으므로
  서버가 IP 를 남기면 그 고지가 거짓이 된다. 그래서 요청 로그 미들웨어를 일부러 붙이지 않았고,
  nginx `access_log` 도 꺼야 한다. 유량 제한은 IP 를 **판단에만** 쓰고 메모리에만 센다.
- **판 안쪽을 DTO 로 검증하지 않는다.** `ValidationPipe({whitelist:true})` 는 중첩 DTO 에
  선언되지 않은 항목을 말없이 버린다 — 실제로 `survival_time` 이 통째로 사라졌다(e2e 가 잡았다).
  앱에 지표를 추가할 때마다 서버를 먼저 올려야 하는 구조가 되는 것도 위험하다.
- **2xx 를 돌려줘야 앱이 큐를 비운다.** 저장에 실패하면 반드시 5xx 로 답할 것.
  200 을 주고 버리면 그 판은 영영 사라진다. 5xx 면 다음 실행 때 다시 올라온다(재시도지 중복이 아니다).
- 테스트가 끝나면 수집 파일을 지운다. 남길 이유가 없는 자료를 오래 들고 있지 않는다.
