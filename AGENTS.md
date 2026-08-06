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

> 🎯 **타겟 유저**: 속도감을 즐기는 층. "너무 쉬우면 이탈한다"가 설계 전제다.
> EASY 도 방심하면 죽어야 한다(목표 사망률 25~45%). 사망률 0%는 정상이 아니라 결함이다.

노브는 난이도 배수 [`EnemySpawner._get_diff_mult()`](scripts/EnemySpawner.gd) 에 모여 있다:
`spawn_interval`(작을수록 촘촘) / `enemy_hp` / `enemy_speed` / `wave_duration` / `bullet_speed`.

⚠️ **전역 노브 3개(`initial_spawn_interval`·`difficulty_scale`·`wave_duration`)는 `@export` 라서
[Game.tscn](scenes/Game.tscn) 의 EnemySpawner 노드가 덮어쓴다. 스크립트만 고치면 게임에 반영되지 않는다 — 양쪽을 함께 수정할 것.**

#### ⚠️⚠️ 측정 함정 두 개 — 이걸 모르면 측정 자체가 무의미하다

1. **`--fixed-fps` 없이는 시드를 고정해도 재현되지 않는다.**
   delta 기반 실시간 시뮬이라 CPU 부하로 프레임 간격이 흔들리면 상태가 발산한다.
   실측: 동일 시드·동일 코드 2회에 생존 **37.05s vs 28.59s**, 킬 **35 vs 24**.
   `--fixed-fps 60` 을 주면 3회 실행이 소수점 3자리까지 일치한다.
   → `tools/run_balance.sh` / `tools/balance_sweep.sh` 에 이미 적용됨(`BENCH_FPS` 로 변경 가능).
   → **절대 수치가 실시간 런과 다르다**(프레임이 고른 만큼 AI 회피가 정확해짐). 옛 측정치와 섞어 비교하지 말 것.

2. **난이도는 반드시 별도 프로세스로 측정한다.**
   한 프로세스에서 easy→normal→hard 를 순차 실행하면 `WordManager`(오토로드)의 학습 통계·테마 상태와
   난수 소비량이 난이도 간에 이어져 앞 난이도가 뒤 난이도를 오염시킨다.
   실측: EASY 배수만 바꿨는데 NORMAL 사망률 **60%→80%**, HARD 생존 **54.3s→33.9s** 로 함께 움직였다.
   → `balance_sweep.sh` 가 이제 난이도별로 프로세스를 분리한다. 단일 난이도만 볼 때는 `SWEEP_DIFFICULTY=easy` 로 빠르게 확인.

1. **베이스라인 먼저 측정** — `./tools/balance_sweep.sh`. 비교 대상 없이 배수를 바꾸면 개선 증명이 불가능하다.
   측정 결과는 `export/balance_*/` 로 복사해 보존할 것(다음 스윕이 `export/balance/` 를 지운다).
2. **목표치 확인** — `Benchmark.gd` 의 `DIFFICULTY_TARGETS` (피격/사망률/생존율 구간). 목표는 **`BENCH_AI_ERROR=0.15`**(평균적인 인간 근사) 기준으로 정의되어 있고, 다른 오차값으로 측정하면 진단이 경고를 낸다.
3. **한 번에 배수 하나만** 바꾸고 동일 시드셋으로 재측정. 5개를 같이 만지면 원인 분리가 안 된다.
4. **스킬 민감도 확인** — 리포트가 오차 0.0/0.15/0.3 에서 피격 기울기를 계산한다. 기울기가 0에 가까우면 난이도가 플레이어 실력에 반응하지 않는다는 뜻이므로, 절대 난이도보다 이걸 먼저 고쳐야 한다.

**지표 해석 시 함정:**
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
- 한 테마의 단어를 `WORDS_PER_STAGE`(5)개 완성하면 **다음 테마 스테이지**로 넘어가고,
  `WordManager.stage_changed` 신호로 **배경 팔레트·파티클 모티프도 함께 전환**된다.
- 그래서 한 테마 안에 `RED`(3글자)와 `YELLOW`(6글자)가 같이 들어간다 — 주제가 1순위다.
- ⚠️ **`Difficulty`(EASY/NORMAL/HARD)는 단어와 무관하다.** 적 밀도·속도·체력만 담당한다.
- 테마 안에서의 순서는 간격 반복 학습(`REPETITION_BONUS`, `REPETITION_GAP_MIN`)과 새 단어 우대로 정하고,
  이번 스테이지에서 이미 완성한 단어는 후보에서 빠진다(스테이지 내 중복 없음).

**새 테마·단어 추가 시:**
1. 단어를 [WordDictionary](scripts/WordDictionary.gd) 에 먼저 등록한다(카테고리·이모지·한/영 설명 — TTS·도감이 쓴다).
2. 테마의 `words` 는 `WORDS_PER_STAGE` 개 이상이어야 스테이지를 완주할 수 있다.
3. `motif` 는 [StarField](scripts/StarField.gd) 가 그릴 수 있는 `ThemeStages.Motif` 값이어야 한다.
   모티프별 그리기 호출 수가 다르므로 `StarField.MOTIF_DENSITY` 에 입자 수 배율을 함께 넣는다(모바일 draw call).

### 콤보

- 콤보는 **처치 연쇄**이고, 글자 정확도는 단어 진행·정답 보너스(+50점)로 보상한다. 이 분리가 중요하다.
- ⚠️ **오답 글자에 콤보 페널티를 걸면 안 된다.** 적의 약 70%가 오답 글자(`get_random_letter(0.3)`)이고
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

