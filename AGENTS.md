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
├── assets/              # sounds/ icons/ shaders/ (외부 오디오 파일 없음 — 절차적 합성)
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
./tools/run_balance.sh          # 난이도별 밸런스 시뮬레이션 → benchmark_log.txt
```

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

