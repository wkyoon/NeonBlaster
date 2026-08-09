# AGENTS.md — NeonBlaster AI 에이전트 가이드

> 이 파일은 **Codex(OpenAI), Claude Code, Cursor, Gemini CLI** 등 모든 AI 코딩 에이전트가
> 프로젝트에 진입할 때 먼저 읽는 컨텍스트입니다. 작업 전 반드시 이 파일의 내용을 따르세요.
> (Claude Code는 `CLAUDE.md`를 통해 이 파일을 임포트합니다.)

## 1. 프로젝트 개요

**NeonBlaster** — 네온 감성 탑다운 스페이스 슈팅 + 영어 단어 학습 게임.
- **엔진**: Godot 4.7 (GDScript, .NET 미사용)
- **타겟**: Android (Portrait 세로 모드) — 데스크톱에서도 실행 가능(테스트용)
- **레포지토리**: https://github.com/wkyoon/NeonBlaster.git (브랜치 `main`)
- **설계 해상도**: 720×1280 (9:16) — 단, 화면 맞춤은 `expand` 모드라 기기 비율에 동적 적응

## 2. 핵심 작업 규칙 (변경 전 반드시 읽기)

### ⚠️ 함정 1 — Android Studio는 "게임 리소스"를 갱신하지 않는다
이 프로젝트의 Android 빌드(`android/build`)는 Godot가 생성한 Gradle 프로젝트다.
- Android Studio의 Gradle 빌드 / Run 은 **네이티브 코드 + AndroidManifest + APK 조립**만 수행한다.
- **게임 리소스(`.pck` / `project.binary` / 씬·스크립트)는 오직 Godot가 export할 때만 갱신**된다.
- 따라서 `project.godot` 설정이나 `.gd` / `.tscn` / 에셋을 바꿨으면 **반드시 Godot로 Android export를 다시 돌려야** 폰에 반영된다.
- **`android/build/src/` 안의 AndroidManifest.xml 등 네이티브 소스를 직접 편집하지 마라** — 다음 Godot export 때 덮어씌워진다.

### ⚠️ 함정 2 — Godot CLI export는 Gradle 단계에서 hang할 수 있다
- `godot --export-debug` 가 APK가 클 때(현재 ~160MB) Gradle 빌드 단계에서 멈출 수 있다.
- **가장 안정적인 export 방법 = Godot 에디터 GUI** (`Project → Export... → Android (Debug) → Export Project...`).
- CLI export를 쓸 땐 반드시 백그라운드(`&`) + 타임아웃 + 로그 확인(`tail`)로 진행 상황을 감시하라.

### ⚠️ 함정 3 — 화면 크기를 하드코딩하지 마라
- 절대 `720`/`1280` 상수로 스폰·이동·UI 범위를 정하지 마라.
- 항상 `get_viewport_rect().size` 로 동적 획득 (`Player.gd`, `EnemySpawner.gd`, `Joystick.gd` 가 이 규칙을 따름).
- `expand` 모드라 기기마다 가로세로가 달라도 정상 동작해야 한다.

## 3. 프로젝트 구조

```
NeonBlaster/
├── project.godot        # 엔진 설정 (display/audio/physics/layer_names)
├── export_presets.cfg   # Android 익스포트 프리셋
├── scripts/             # GDScript (58개) — 아키텍처 섹션 참조
├── scenes/              # .tscn 씬 파일
├── assets/              # icons/ shaders/ particles/ + neon_env.tres
│                        #   (외부 오디오 파일 없음 — 절차적 합성)
│                        #   particles/ = Kenney Particle Pack(CC0) 발췌 3장
├── tools/               # run_balance.sh, word_sim.sh (밸런스/단어 자동 테스트)
├── website/             # 홍보 웹사이트 (게임과 별개 — 무시해도 OK)
└── android/build/       # Godot 생성 Gradle 프로젝트 (.gitignore 됨, 재생성 가능)
```

## 4. 아키텍처 (Autoload 싱글톤)

`project.godot`의 `[autoload]`에 등록된 6개 전역 매니저. 어디서든 이름으로 접근:

| 싱글톤 | 역할 |
|--------|------|
| `GameManager` | 게임 상태머신(`GameState`), 점수/생명/콤보, `auto_play` 플래그, `ai_dodge_error` |
| `SceneManager` | 씬 전환 + 페이드 |
| `AdsManager` | AdMob 광고 (플러그인 미설치 시 stub 모드 자동 동작) |
| `AudioManager` | 절차적 SFX 합성 + 절차적 BGM(`_generate_bgm`) + TTS |
| `EffectsManager` | 화면 흔들림/플래시 이펙트 |
| `WordManager` | 단어 진행, 타겟 글자, 난이도(`Difficulty` enum) |

> 중요: 오토로드 스크립트를 수정하면 **전역**이므로 모든 씬에 영향. 시그널 연결 해제 누수 주의.
## 5. 코드 컨벤션 (반드시 준수)

| 항목 | 규칙 |
|------|------|
| **들여쓰기** | **탭(Tab)** 1개 per 레벨. 스페이스 사용 금지. |
| **타입** | typed GDScript 사용. 함수 반환형 `-> void`/`-> Vector2`, 변수 `var x := ...` 또는 명시 `var x: int`. |
| **배열 타입** | typed 배열 필수 `Array[PackedFloat64Array]`. untyped `[[1,2],[3,4]]` 는 Parse Error 발생(강타입 추론 실패). |
| **주석 언어** | 한국어 허용/권장 (기존 코드가 한국어 주석). `## ` 는 문서화 주석(`@export` 설명용). |
| **class_name** | 재사용 타입은 `class_name` 선언 (`Enemy`, `WordDictionary`, `StoryData`, `StoryArt`, `IconRenderer`). |
| **화면 좌표** | `get_viewport_rect().size` 동적 사용 (하드코딩 720/1280 금지). |
| **Godot 버전 API** | Godot 4.x API만 (`move_and_slide()`, `AudioServer`, `DisplayServer`). Godot 3 API 금지. |

## 6. 실행 / 검증 / 빌드 명령

> Godot CLI 경로: `/Applications/Godot.app/Contents/MacOS/Godot` 또는 (Homebrew) `godot`.

### 데스크톱에서 게임 실행 (빠른 확인)
```bash
cd /Users/swyoon/workspace/AndroidStudioProjects/NeonBlaster
godot   # 에디터 없이 게임 바로 실행. 또는 에디터에서 F5.
```

### 오토로드 참조 검증 (오토로드의 이름을 바꿨다면 필수)
```bash
python3 tools/check_autoload_refs.py     # 문제 없으면 종료코드 0
```
⚠️ **GDScript 는 오토로드 접근(`GameManager.foo`)을 컴파일 시점에 검사하지 않는다.**
오토로드의 변수/함수 이름을 바꾸면 옛 호출부가 남아도 파스는 통과하고, **그 줄이 실행될 때만** 터진다.
실제로 겪은 예: `DifficultyDirector.intensity`(변수) → `get_intensity()`(함수) 로 바뀌었는데
[Enemy.gd](scripts/Enemy.gd) 의 파워업 드롭 분기 하나가 옛 이름을 참조했다.
**6% 확률(TIME_SLOW 드롭) 경로**라 짧은 플레이 테스트로는 안 걸리고 파스 검사도 통과했다.

### 스크립트 컴파일 에러 검증 (코드 수정 후 필수)
이 명령은 프로젝트를 로드하고 즉시 종료하며, **Parse/Script Error**를 잡아낸다.
```bash
cd /Users/swyoon/workspace/AndroidStudioProjects/NeonBlaster
godot --headless --quit --path . 2>&1 | grep -iE 'SCRIPT ERROR|Parse Error|Invalid|expected'
# (출력이 없으면 에러 없음)
```
> 주의: 가끔 오토로드 초기화 중 hang할 수 있으니 백그라운드(`&`) + 타임아웃(`timeout 50`) 권장.

### 밸런스 자동 테스트 (게임 로직 변경 시)
```bash
./tools/run_balance.sh          # 단일 측정 → benchmark_log.txt (빠른 확인용)
./tools/balance_sweep.sh        # 시드 × AI오차 격자 스윕 → export/balance/ + 리포트
python3 tools/balance_report.py # 기존 스윕 결과만 다시 집계
```

> ⚠️ **단일 측정으로 노브를 만지지 말 것.** 관측된 분산이 매우 크다(HARD 동일 조건
> 2게임에서 생존 26.2s vs 6.7s, 4배). 난이도당 5게임 이상 + 다중 시드로 풀링해야
> 중앙값이 의미를 갖는다. `run_balance.sh` 는 회귀 확인용이고, 튜닝 판단은 스윕으로 한다.

### Android APK 빌드 (Godot 에디터 GUI 권장)
1. Godot 에디터 → `Project → Export...` → `Android (Debug)` → `Export Project...`
2. (선택) Android Studio → `android/build` 열기 → Sync → Run(⌃R)

### 환경 의존성
- Godot 4.7.x — `/Applications/Godot.app`
- Android SDK — `~/Library/Android/sdk` (env: `ANDROID_HOME`)
- Java JDK 17
- Android Studio — `/Applications/Android Studio.app`

## 7. 자주 묻는 작업 — 레시피

### 화면 방향/맞춤 설정 변경
`project.godot`의 `[display]`:
- `window/handheld/orientation` = `0`(가로) / `1`(세로) / ...
- `window/stretch/mode` = `"canvas_items"`, `window/stretch/aspect` = `"expand"` (여백·왜곡 없이 꽉 채움)
- 변경 후 Godot export 필수(함정 1).

### 사운드/SFX/BGM
- 외부 오디오 파일 없음. SFX와 BGM 모두 `AudioManager.gd`에서 절차적 합성(`_create_wav`, `_generate_sfx_*`, `_generate_bgm`).
- BGM 볼륨: `AudioManager`의 `_music_volume`(기본 0.7). SFX 레벨: 각 `_gen_sfx_*` 함수 내 진폭.

### SFX 후보 비교 (SFX Lab)
새 효과음을 고를 때는 `AudioManager` 를 바로 고치지 말고 **후보를 `SfxLibrary.gd` 에 추가해 A/B 비교**한다.
- `scripts/SfxLibrary.gd` — 카테고리별 후보 변형(현재 8개 이벤트 × 4후보). `_cur` 로 끝나는 id 는 실제 게임에 들어간 기준음.
- `scenes/SfxLab.tscn` + `scripts/SfxLab.gd` — 눌러서 듣는 비교 화면. 메뉴 우측 상단 `🔊 SFX` 버튼으로도 진입.
- 명령:
  ```bash
  ./tools/sfx_lab.sh            # 비교 화면 실행
  ./tools/sfx_lab.sh dump       # export/sfx_preview/*.wav 로 덤프 (헤드리스)
  ./tools/sfx_lab.sh play hit   # 덤프 후 afplay 로 카테고리 순차 재생
  ```
- 후보 추가 시 **레벨을 기준음 RMS 에 맞출 것** (큰 소리가 좋게 들리는 편향 방지). 목표: 기준음 대비 0.55~1.9x, 클리핑 0.
- 확정된 후보는 해당 `_gen_*` 본문을 `AudioManager._gen_sfx_*` 로 옮기고 `_generate_sfx_cache()` 에서 연결한다.
- ⚠️ `class_name` 을 새로 만든 직후 헤드리스 실행은 "Identifier not declared" 로 실패한다 → `godot --headless --import --path .` 로 클래스 캐시를 먼저 갱신.
- ⚠️ GDScript 에서 `round()` 는 Variant 를 반환해 `var x := round(...)` 가 Parse Error 다. `roundf()` 사용.

### 밸런스 튜닝 절차

> 🎯 **이 게임은 지하철·버스 대기 같은 틈새 시간용이다.** 밸런스의 목표는
> "얼마나 어려운가"가 아니라 **"한 판이 목표 시간쯤에 끝나는가"** 다.

**난이도 선택은 없다.** [`DifficultyDirector`](scripts/DifficultyDirector.gd) 가 경과 시간으로 맞춘다.
- 처음 시작 → 약 **10분**(`BASE_TARGET`)에 죽는다.
- 하루 플레이할 때마다 목표가 **1분**씩 늘어난다(`MINUTE_PER_DAY`, 최대 +20분).
- 하루 거르면 **거른 날수만큼만** 줄어든다(`RewardManager.day_advanced`).
  ⚠️ `streak_days` 와 다르다 — streak 은 하루만 걸러도 1로 초기화되지만
  여기 `bonus_minutes` 는 조금씩 되돌아간다. 며칠 못 했다고 통째로 잃으면 돌아올 이유가 사라진다.

⚠️ **판에는 반드시 끝이 있어야 한다.** 예전 EASY 는 사망률 0% 라 영영 안 끝났다 —
플레이어가 스스로 끊어야 했고 그러면 성취 없이 종료된다. 사망률 목표가 이제 **90~100%** 인 이유다.

⚠️ **밀도를 낮춰서 시간을 벌면 안 된다 — 게임이 밋밋해진다.**
목표 시간을 10분으로 늘리면서 밀도를 낮췄더니 실측 **동시 적 2.2(첫날) / 1.6(20일차)** 로
화면에 적이 한두 마리뿐인 상태가 됐다. 30분 판 내내 클라이맥스가 없었다.
시간은 **치사율**(적 속도·탄속)과 러시 사이의 **골짜기**로 벌 것. 밀도는 재미의 최저선이다.
(`Benchmark.DIFFICULTY_TARGETS` 의 `alive` 하한 3.5 가 이 규칙을 지킨다.)

⚠️ **러시 리듬이 없으면 평탄해서 지루하다**(`RUSH_PERIOD` 30초 / `RUSH_STRENGTH` 0.55).
슈팅 게임의 기본 재미는 "밀려온다 → 쓸어낸다 → 숨 돌린다"의 반복이다.
예전에는 웨이브마다 조여드는 계단이 그 역할을 했는데, 웨이브 램프를 없애며 리듬까지 사라졌다.
러시는 **밀도에만** 얹는다 — 치사율까지 흔들면 죽는 타이밍이 운에 좌우된다.

⚠️ **밀도와 치사율은 다른 곡선으로 오른다**(`DENSITY_SHAPE` 0.5 / `LETHAL_SHAPE` 2.2).
둘을 같이 올리면 긴 판에서 중반이 길어진 만큼 피격이 누적돼 목표 전에 죽고(실측 30분 목표에서 74%),
반대로 통째로 늦추면 화면이 한산해 지루하다(동시 적 1.4). 화려함과 위험은 붙어 있을 이유가 없다.

⚠️ **난이도 곡선의 주인은 Director 하나뿐이다.** 예전 `EnemySpawner` 는 웨이브마다
`_spawn_interval *= difficulty_scale`(0.91) 로 누적했는데, 그 램프는 90초 판 기준이라
목표가 10분이 된 지금은 폭주한다(0.91^54 ≈ 0.006). 제거했고 적 체력 가산도 `MAX_STAT_WAVE`(8)로 막았다.

#### 현재 기준선 (2026-08-09, 5게임·`BENCH_AI_ERROR=0.15`·프로세스 분리)

벤치마크의 EASY/NORMAL/HARD 는 이제 난이도가 아니라 **플레이 이력의 세 지점**이다.

| 벤치 이름 | 상황 | 목표 | 실측 평균 | 동시 적 | 사망률 |
|---|---|---|---|---|---|
| EASY | 첫날 | 10분 | **8.7분** (87%) | 6.6 | 100% |
| NORMAL | 5일차 | 15분 | **17.2분** (115%) | 5.2 | 100% |
| HARD | 20일차(상한) | 30분 | **26.8분** (89%) | 4.4 | 100% |

밀도는 러시 주기로 오르내리며 목표 시간 근처에서 최고조에 달한다
(첫날 실측: 30초 2.2 → 180초 5.8 → 480초 6.0 → 600초 11.0).

⚠️ `BENCH_TIME` 을 목표보다 크게 줄 것(10분 목표 → 900, 30분 목표 → 2600).
작으면 제한시간에 걸려 측정이 무의미해진다(진단이 경고한다).

#### ⚠️⚠️ 측정 함정 **네** 개 — 이걸 모르면 측정 자체가 무의미하다

0. **도감 수집 상태가 user:// 에 쌓여 측정을 오염시킨다.**
   벤치마크도 게임이라 단어를 수집하고 저장한다. 그대로 두면 실행할수록 단어 풀이 달라지고
   (테마 완주 → 심화 단어 해금) 같은 배수·같은 시드인데 결과가 달라진다.
   실측: NORMAL 사망률이 두 실행에서 **20% vs 50%**.
   → `Benchmark._reset_learning_state()` 가 난이도마다 수집을 비우고
     `WordManager.persist_enabled = false` 로 저장을 막는다. 이제 두 실행이 소수점까지 일치한다.

0-1. **난이도는 그 난이도를 여는 최소 랭크에서 재야 한다.**
   NORMAL 은 랭크1(+6%), HARD 는 랭크2(+12%) 가 있어야 열린다
   (`RewardManager.DIFFICULTY_RANK`). 랭크 0 으로 HARD 를 재면 아무도 겪지 않는 조건을
   측정하는 것이다. `Benchmark` 가 자동으로 맞추고, `BENCH_RANK` 로 강제할 수 있다.

1. **`--fixed-fps` 없이는 시드를 고정해도 재현되지 않는다.**
   delta 기반 실시간 시뮬이라 CPU 부하로 프레임 간격이 흔들리면 상태가 발산한다.
   실측: 동일 시드·동일 코드 2회에 생존 **37.05s vs 28.59s**, 킬 **35 vs 24**.
   `--fixed-fps 60` 을 주면 3회 실행이 소수점 3자리까지 일치한다.
   → `tools/run_balance.sh` / `tools/balance_sweep.sh` 에 이미 적용됨(`BENCH_FPS` 로 변경 가능).
   → **절대 수치가 실시간 런과 다르다**(프레임이 고른 만큼 AI 회피가 정확해짐). 옛 측정치와 섞어 비교하지 말 것.

2. **난이도는 반드시 별도 프로세스로 측정한다.** (`run_balance.sh` 도 이제 분리한다)
   한 프로세스에서 easy→normal→hard 를 순차 실행하면 `WordManager`(오토로드)의 학습 통계·테마 상태와
   난수 소비량이 난이도 간에 이어져 앞 난이도가 뒤 난이도를 오염시킨다.
   실측: EASY 배수만 바꿨는데 NORMAL 사망률 **60%→80%**, HARD 생존 **54.3s→33.9s** 로 함께 움직였다.
   실측: NORMAL 의 `spawn_interval` 만 바꿨는데 손대지 않은 HARD 사망률이 60%→80% 로 움직였다.
   → `balance_sweep.sh` 와 `run_balance.sh` 모두 난이도별로 프로세스를 분리한다. 단일 난이도만 볼 때는 `SWEEP_DIFFICULTY=easy` 로 빠르게 확인.

1. **베이스라인 먼저 측정** — `./tools/balance_sweep.sh`. 비교 대상 없이 배수를 바꾸면 개선 증명이 불가능하다.
   측정 결과는 `export/balance_*/` 로 복사해 보존할 것(다음 스윕이 `export/balance/` 를 지운다).
2. **목표치 확인** — `Benchmark.gd` 의 `DIFFICULTY_TARGETS` (피격/사망률/생존율 구간). 목표는 **`BENCH_AI_ERROR=0.15`**(평균적인 인간 근사) 기준으로 정의되어 있고, 다른 오차값으로 측정하면 진단이 경고를 낸다.
3. **한 번에 배수 하나만** 바꾸고 동일 시드셋으로 재측정. 5개를 같이 만지면 원인 분리가 안 된다.
4. **스킬 민감도 확인** — 리포트가 오차 0.0/0.15/0.3 에서 피격 기울기를 계산한다. 기울기가 0에 가까우면 난이도가 플레이어 실력에 반응하지 않는다는 뜻이므로, 절대 난이도보다 이걸 먼저 고쳐야 한다.

**지표 해석 시 함정:**
- ✅ **판정의 주축은 사망률과 생존 비율이다. 압박은 `alive_avg`(동시 적 수)로 본다.**
  `Benchmark.DIFFICULTY_TARGETS` 의 압박 지표를 `hits` 에서 `alive` 로 바꿨다 —
  아래 포화 문제 때문에 `hits` 로는 어떤 조정에도 반응하지 않았다(HARD 에서 5.7 고정).
- ⚠️ **`hits_taken` 은 `GameManager.MAX_LIVES`(현재 5)에서 포화된다.** 피격 1회 = 목숨 1개라
  5번 맞으면 게임이 끝나 그 이상 기록되지 않는다(부활로 +1). 그래서
  **사망이 확실한 난이도에서 `hits` 는 난이도 판별력이 없고, 스킬 민감도 기울기도 의미를 잃는다.**
  실력 반영을 보려면 포화되지 않는 지표(`survival_time`, `words_per_min`, `alive_avg`)를 봐야 한다.
  (2026-08-06 현재 세 난이도 모두 `⚠ 실력 반영 약함` 으로 나오는 이유가 이것이다. `Benchmark.gd` 의
  진단 로직을 피격 기반에서 생존/단어 기반으로 바꾸는 작업이 남아 있다.)
- 목숨 수를 바꾸면 `Benchmark.DIFFICULTY_TARGETS` 의 `hits` 구간도 **반드시** 함께 조정할 것.
  (과거 HARD 목표 `hits 5~12` 는 목숨 3개 시절 설정이라 구조적으로 도달 불가능한 상태로 방치돼 있었다.)
- `max_wave` 는 **독립 지표가 아니다.** 웨이브는 [EnemySpawner.gd](scripts/EnemySpawner.gd) 에서 타이머만으로 넘어가므로 `⌈생존시간/웨이브길이⌉` 와 정확히 일치한다(4개 런 검산 완료). 압박 지표로는 `alive_avg`(동시 적 수)를 쓸 것.
- `survival_time` 은 `BENCH_TIME` 에서 포화된다. 제한시간에 자주 닿으면 생존율 대신 **사망률**이 실질 신호다.
- `hit` SFX 카운트는 적이 피해를 입는 소리이고, 플레이어 피격은 `hits_taken` 이다. 둘은 무관하다.

### 단어 구성 = 주제(테마) 스테이지

**단어는 글자 수가 아니라 주제로 묶인다.** 글자 수 기준 3분할(EASY 3글자 / NORMAL 4-5 / HARD 6+)은 폐기했다.

- 정의는 [`ThemeStages.STAGES`](scripts/ThemeStages.gd) 한 곳에 모여 있다:
  `색깔 → 동물 → 몸 → 자연 → 우주 → 기계` (마지막 뒤에는 처음으로 순환).
- 한 테마의 단어를 `WORDS_PER_STAGE`(3)개 완성하면 **다음 테마 스테이지**로 넘어가고,
  `WordManager.stage_changed` 신호로 **배경 팔레트·파티클 모티프도 함께 전환**된다.
- 그래서 한 테마 안에 `RED`(3글자)와 `YELLOW`(6글자)가 같이 들어간다 — 주제가 1순위다.
- ⚠️ **`Difficulty`(EASY/NORMAL/HARD)는 단어와 무관하다.** 적 밀도·속도·체력만 담당한다.
- **테마 안에서는 배열 순서 그대로, 쉬운 것 → 어려운 것으로 나온다.**
  이미 수집한 단어는 건너뛰므로 그 테마에 다시 오면 다음 난이도부터 이어진다.
  ⚠️ **복습은 스테이지의 첫 단어**로 넣는다. 끝에 붙이면 오름차순이 깨진다
  (실측 "EAR(3) NOSE(4) EYE(3)").
  ⚠️ **기본의 마지막 단어가 심화의 첫 단어보다 길면 안 된다** — 층 경계에서 난이도가 거꾸로 간다
  (실측 SPACE 기본 GALAXY(6) → 심화 ORBIT(5)).
  ⚠️ 검사는 두 가지를 다 돌릴 것:
  `python3 tools/check_word_order.py`(배열 정렬) + `godot --headless --path . scenes/WordOrderCheck.tscn`
  (**실제 출현 순서**). 배열이 정렬돼 있어도 선택 로직이 순서를 깨뜨릴 수 있다.
  ⚠️ 예전에는 가중치 룰렛(무작위)이라 **배열을 쉬운 순으로 정렬해 둔 것이 게임에 반영되지 않았다** —
  첫 판에 어려운 단어가 나왔다. `tools/check_word_order.py` 로 정렬을 확인할 것.
- `REVIEW_EVERY`(3)번째마다 **가장 오래 안 본 수집 완료 단어**를 복습으로 끼워 넣는다.
  한 번 보고 끝이면 눈으로 익히는 게임이 성립하지 않는다.

**단어는 두 층이다 — 기본 → 심화**
- `words`(기본 8개): 그 테마에서 먼저 익힌다. 다 모으면 **테마 완주**(보너스 점수 + 목숨).
- `advanced`(심화 4개): 기본 8개를 **모두 수집한 뒤부터** 후보에 합류한다.
  ⚠️ **한 번에 하나만.** `WordManager.get_pending_advanced()` 가 미수집 심화 중 맨 앞 하나만 돌려주고,
  그것을 수집해야 다음 하나가 풀린다. 어려운 단어를 한꺼번에 풀면 전부 반쯤 익힌 채 흩어진다.
- 완주(mastery)와 `ThemeStages.get_all_words()` 는 **기본 8개 기준**을 유지한다.
  심화까지 세면 완주가 12개가 되어 "자주 오는 성취"라는 설계가 깨진다.
  도감 총수(`get_collection_progress`)에만 심화를 더해 48 → 72 로 센다.

**새 테마·단어 추가 시:**
1. 단어를 [WordDictionary](scripts/WordDictionary.gd) 에 먼저 등록한다(카테고리·이모지·한/영 설명 — TTS·도감이 쓴다).
2. 테마의 `words` 는 `WORDS_PER_STAGE` 개 이상이어야 스테이지를 완주할 수 있다.
3. `motif` 는 [StarField](scripts/StarField.gd) 가 그릴 수 있는 `ThemeStages.Motif` 값이어야 한다.
   모티프별 그리기 호출 수가 다르므로 `StarField.MOTIF_DENSITY` 에 입자 수 배율을 함께 넣는다(모바일 draw call).

### 출석 / 플레이시간 보상

정의는 [`RewardManager`](scripts/RewardManager.gd) 한 곳에 있다(오토로드).
- **하루 10분**(`DAILY_GOAL_SECONDS`) 플레이 → 보상 1회. 시간은 `GameState.PLAYING` 일 때만 센다.
- **연속 접속**(`STREAK_MILESTONES` = 3/7/15/30일) → 마일스톤마다 1회.
- 수령은 메뉴에서만 한다(`MainMenu` 하단 보상 띠 → `🎁 DAILY REWARDS` 패널 → `🚀 SHIPS` 기체 선택).
  판 중간에 목숨이 늘면 밸런스가 흔들리므로, 게임 중 10분 달성은 **배너로 알리기만** 한다.

**랭크 = 난이도 도전 자격**
연속 접속 마일스톤을 받을 때마다 랭크가 1 오른다(0~4, `RewardManager.get_rank()`).
랭크는 `_claimed` 의 `"streak:*"` 개수에서 **파생**된다 — 따로 저장하면 어긋난다.
- 영구 화력 `RANK_POWER_STEP`(0.06) × 랭크 → 0 / 6 / 12 / 18 / 24%
- 난이도 해금 `DIFFICULTY_RANK = [0, 1, 2]` → NORMAL 은 연속 3일, HARD 는 연속 7일
- ⚠️ **해금은 한 번 받으면 영구다.** 연속이 끊겼다고 난이도를 다시 잠그면
  하루 빠뜨린 사람이 하던 난이도를 못 하게 되어 복귀를 막는다.
- ⚠️ 메뉴에서 보상을 받으면 `_rebuild_difficulty_selector()` 로 잠금을 **즉시** 푼다.
  이때 `queue_free()` 만 하면 이전 노드가 그 프레임 동안 이름을 붙잡아
  새 컨테이너가 다른 이름을 받는다 — `remove_child()` 를 먼저 할 것(실측으로 확인).
- ⚠️ NORMAL/HARD 밸런스는 **그 난이도를 여는 시점의 랭크 화력을 포함해** 측정해야 한다
  (해금 시점: NORMAL +6%, HARD +12%). 랭크 0 기준으로 잰 수치는 실제 플레이와 다르다.

**보상은 두 종류다.**
1. **기체 스킨**([`ShipSkins`](scripts/ShipSkins.gd)) — 영구 해금, 순수 코스메틱. 랭크와 함께 올라간다.
   마일스톤마다 하나씩 해금되고 즉시 장착된다(AURORA 기본 → SOLAR 3일 → PLASMA 7일 → PRISM 15일 → NOVA 30일).
   색은 기체·글로우·분사 파티클·**탄**·타이틀 엠블럼에 모두 반영된다.
   ⚠️ 탄까지 안 물들이면 스킨이 겉돈다 — 화면 면적의 대부분은 탄이다.
   ⚠️ 스킨 색이 1.0 을 넘는 건 의도적이다(glow_hdr_threshold=1.0 초과분만 번진다).
2. **일일 화력 버프**(오늘 10분) — **다음 판에만** 적용되는 +5%.
   `GameManager.start_game()` 이 `reward_power = 랭크 영구 화력 + consume_pending()` 으로 합치고,
   `Player.revive()` 가 실제로 입힌다.
   ⚠️ **무기 레벨(정수)을 올리면 안 된다.** 2(2줄기) → 3(3방향) → 4(5방향) 로 탄이 두 배 이상 뛰어
      판이 통째로 달라진다. 보상은 `reward_power`(0.05~0.30) 한 값으로만 올린다 —
      연사 `×(1+power)`, 탄 크기 `×(1+power*0.6)`. 최대치라도 +30% 다.

⚠️ **목숨은 보상에서 뺐다.** 숫자만 늘고 화면에 드러나지 않아 보상으로 느껴지지 않았다.
   보이는 보상은 탄 개수(무기 레벨 4 = 5방향)·연사·기체 외형이 담당한다.

⚠️ **보상 버프를 `Player._ready` 에서 읽으면 안 된다.** 자식(Player)의 `_ready` 는 부모(Game)의
   `_ready` 보다 **먼저** 실행되므로 그 시점의 `GameManager.reward_*` 는 아직 이전 판 값이다.
   `Game._ready` 가 `start_game()` 직후 호출하는 `Player.revive()` 에서 적용한다
   (실측: 연사 배수만 걸리고 무기 레벨은 안 걸렸다).
- 여러 보상을 몰아서 수령하면 버프가 누적된다 → `MAX_PENDING_POWER`(0.30)/`MAX_PENDING_SCORE_MULT`(1.2) 로 막는다.
- 성능 보상을 영구로 주면 맞춰 놓은 난이도가 무너진다. 영구인 것은 코스메틱뿐이다.

⚠️ **날짜는 로컬 날짜 문자열(YYYY-MM-DD)로 비교한다.** 유닉스 시간으로 24시간을 재면
자정을 넘겨도 같은 날로 잡히거나 그 반대가 되어 출석 판정이 어긋난다.

### 콤보

- 콤보는 **처치 연쇄**이고, 글자 정확도는 단어 진행·정답 보너스(+50점)로 보상한다. 이 분리가 중요하다.
- ⚠️ **오답 글자에 콤보 페널티를 걸면 안 된다.** 적의 절반 이상이 오답 글자(`get_random_letter(0.45)`)이고
  처치는 콤보 +1 뿐이라, 페널티가 1보다 크면 콤보가 항상 0으로 끌려간다.
  과거 "오답 시 콤보 리셋"이 이 상태였다 — 실측 20초 자동 플레이에서 **17킬·평균 처치 간격 1.09초인데도 콤보 0**.
  제거 후 같은 조건에서 **콤보 32 / 배수 x4.0** 까지 올라간다.
- `COMBO_WINDOW`(4.5초)는 평균 처치 간격의 약 2배로 잡는다. 2.5초는 간격보다 짧아 연쇄가 성립하지 않았다.
- 단어 완성은 `register_word_bonus()` 로 콤보를 `WORD_COMBO_BONUS`(4) 밀어주고 창도 늘린다(학습 → 액션 연결).
- 연출은 `combo_level_up` 신호(단계 **돌파 시에만** 발생)로 터뜨린다. `combo_changed` 에 걸면 매 처치마다 터진다.

**⚠️ 콤보는 화면에 표시하지 않는다 (이 게임의 핵심 규칙)**

이 게임은 단어 학습 게임이다. 콤보를 크게 띄웠더니 *"콤보가 터지니까 단어가 눈에 들어오지 않는다"* 는
문제가 생겼고, 작게 줄이는 것으로도 부족해서 **콤보 UI 자체를 없앴다.**
- 콤보 로직과 점수 배수는 살아 있다. **HUD 라벨만 없다** — 다시 추가하지 마라.
- 플레이어는 콤보를 **단어가 화려해지는 것으로만** 감지한다 —
  `HUD._refresh_word_style()` 이 콤보 단계에 따라 단어의 색·외곽 글로우·크기를 올린다.
  `HUD._on_combo_changed()` 의 유일한 역할은 콤보 단계를 추적해 이 함수에 넘기는 것이다.
- ⚠️ 남아 있는 설계 부채: 콤보는 **처치 연쇄**라서 "아무거나 빨리 많이 쏘기"를 보상하고,
  학습은 "맞는 글자만 골라 쏘기"를 요구한다 — 두 인센티브가 반대 방향이다.
  근본 해결은 콤보의 축을 처치 연쇄에서 **정답 글자·단어 연속**으로 바꾸는 것이다(미적용).
- `COMBO_COLORS` 는 단어 기본색(시안)에서 **멀어지는 상승 배열**이어야 한다.
  배열 끝을 시안 계열로 두면 최고 콤보에서 단어가 기본색으로 돌아와 보상 신호가 사라진다(실제로 그랬다).
- **화면 전체 플래시와 카메라 셰이크는 글자 가독성을 직접 해친다.** 단어 완성·콤보 돌파에는 쓰지 말고
  (단어 완성 시 플래시는 alpha 0.12 까지 낮췄다) 단어 라벨 자체의 스케일 펀치로 대체한다.
- ⚠️ HUD 콤보/단어 라벨은 **`PRESET_TOP_WIDE`(화면 전체 폭) + 중앙 정렬**이어야 한다.
  `CENTER_TOP` 프리셋은 폰트가 커지면 라벨이 화면 밖으로 나가 텍스트가 잘린다(실제로 겪었음).

### 네온 발광 / 파티클 / 화면 흔들림

- **발광의 실제 출처는 `assets/neon_env.tres`** (Game.tscn·Menu.tscn 의 `WorldEnvironment` 가 공유).
  `project.godot` 의 `rendering/viewport/hdr_2d=true` 와 세트로만 동작한다. 둘 중 하나만 켜면 안 번진다.
- `glow_hdr_threshold = 1.0` → **1.0 을 초과하는 픽셀만** 번진다. HUD 라벨(전부 1.0 이하)은 안 번져서 텍스트가 선명하다.
  더 화려하게 하려면 threshold 를 내리지 말고 **해당 오브젝트 색을 1.0 초과로 올릴 것**
  (threshold 를 내리면 HUD 텍스트까지 뿌옇게 된다). 예: `Player.tscn` 의 Sprite 색 `Color(0.36, 1.15, 1.3)`.
- **각 오브젝트의 halo 는 `PointLight2D`("Glow") + 라이트 쿠키 텍스처**다.
  Player/Bullet/Enemy/PowerUp 네 씬 모두에 있다. ⚠️ **텍스처(`texture`)를 비우면 PointLight2D 는 아무것도 렌더하지 않는다**
  (과거 이 상태로 방치돼 glow 가 전부 죽어 있었음). `texture_scale ≈ 2 × range_radius / 256` 로 맞춘다.
- 프로젝트 전역 필터가 Nearest(`default_texture_filter=0`)이므로, 그라디언트 텍스처를 쓰는 노드는
  **개별적으로 `texture_filter = 2`(Linear)** 를 지정해야 계단이 안 생긴다.
- 파티클은 `CPUParticles2D` 유지 — GPUParticles2D 는 Compatibility 렌더러/모바일 GL 지원이 버전마다 달라서 의도적으로 안 쓴다.
  `scale_amount_*` 는 **텍스처 크기(256px)의 배수**라 0.05~0.3 같은 작은 값이 정상이다.
- 화면 흔들림은 `EffectsManager` 의 **trauma 누적 방식**. `shake(amount, duration)` 은 하위호환 래퍼이고,
  신규 코드는 `add_trauma(0..1)` 을 쓰면 타격이 겹칠 때 자연스럽게 누적된다.
- ⚠️ 글로우는 모바일에서 fill-rate 비용이 있다. 시각 변경 후에는 **실기기 프레임 확인**이 필요하다
  (헤드리스 벤치는 렌더를 안 하므로 fps 검증이 안 된다).

### 플레이어 컨트롤
- 현재 **drag-to-follow(직접 추적)** 방식. `Player._unhandled_input` + `Player._apply_movement`.
- 속도 튜닝: `Player.gd`의 `@export var max_speed`(기본 700), `acceleration`, `friction`.
- 가상 조이스틱(`Joystick.gd`)은 비활성화됨(`set_process_input(false)`) — 노드는 호환성 유지.

### AdMob
- `scripts/AdsManager.gd`의 `ADMOB_APP_ID`/`BANNER_ID` 등을 실제 ID로 교체.
- 플러그인 미설치 시 자동 stub 모드(더미 오버레이). 데스크톱 테스트에 방해 안 됨.

## 8. 금지 / 주의 사항

- ❌ `android/build/src/` 하위 네이티브 파일(AndroidManifest.xml, Java/Kotlin) 직접 편집 → Godot가 덮어씀.
- ❌ `720`/`1280` 하드코딩 → `expand` 모드에서 기기별로 깨짐.
- ❌ untyped 다차원 배열 리터럴 `[[...],[...]]` → GDScript 강타입 추론 Parse Error.
- ❌ Godot 3.x API 사용.
- ⚠️ `.godot/`, `android/`, `export/` 는 `.gitignore` 됨 — 커밋하지 말 것.
- ⚠️ `website/` 는 게임과 무관한 홍보 페이지 — 게임 로직 작업 시 무시.
- ⚠️ keystore 비밀번호 등 시크릿이 README/설정에 노출될 수 있음 — 커밋 전 확인.

## 9. 작업 흐름 권장 (AI 에이전트용)

1. **변경 전**: 관련 파일을 먼저 읽고 컨벤션(탭, typed, 한국어 주석)을 파악한다.
2. **코드 수정**: 작은 단위로. typed GDScript 준수. 화면 크기는 동적.
3. **컴파일 검증**: `godot --headless --quit --path .` 로 Parse Error 확인 (반드시).
4. **런타임 검증**: 가능하면 `godot` 으로 데스크톱 실행 또는 `./tools/run_balance.sh`.
5. **Android 반영 필요 시**: Godot 에디터 GUI로 export 안내 (함정 1·2). 에이전트가 직접 GUI export는 못 하므로 사용자에게 단계를 안내.
6. **커밋**: `.godot/`·`android/`·`export/` 제외. 한국어 커밋 메시지 OK.

