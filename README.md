# 🎮 NeonBlaster

> **네온 스페이스 슈팅 + 영어 단어 학습 게임** — Godot 4로 제작된 모바일 안드로이드 타겟 아케이드 에듀테인먼트 슈터

![Godot 4.7](https://img.shields.io/badge/Godot-4.7-blue)
![Platform](https://img.shields.io/badge/Platform-Android-green)
![Language](https://img.shields.io/badge/Language-GDScript-yellow)

## 📖 소개

**NeonBlaster**는 네온 감성의 탑다운 스페이스 슈팅 게임입니다. 적 함선을 격추하고 웨이브를 클리어하며 최고 기록에 도전하세요! 적마다 알파벳 글자가 적혀 있고, 스펠링해야 할 단어의 **타겟 글자**를 가진 적을 처치하면 단어가 완성됩니다. 완성된 단어는 TTS로 발음까지 들려주어 **게임을 하면서 자연스럽게 영어 단어를 학습**할 수 있습니다.

### ✨ 주요 특징

| 기능 | 설명 |
|------|------|
| 🎯 **터치 조종** | 동적 가상 조이스틱 (드래그 위치에 생성) |
| 🔫 **자동 발사** | 조종에 집중, 발사는 자동! |
| 👾 **7종 적 유닛** | Chaser, Shooter, Tank, Dasher, Bomber, Splitter, Shielder |
| 💎 **7종 파워업** | Rapid, Spread, Shield, Bomb, Laser, Time Slow, Lightning |
| 🔤 **단어 학습 모드** | 알파벳 적을 처치해 영어 단어 스펠링 완성 (Easy/Normal/Hard) |
| 🔊 **TTS 발음** | 완성된 단어를 네이티브 영어 발음으로 들려줌 |
| 📖 **단어 사전** | 70+ 단어, 카테고리별 분류 + 한국어/영어 설명 |
| ✦ **스토리 모드** | 루미노스 은하 세계관, 세력·파워업·적 도감 |
| 🤖 **오토 플레이** | AI가 알아서 타겟 적을 찾아 플레이 (데모용) |
| 🌊 **웨이브 시스템** | 점진적 난이도 상승 |
| 💥 **이펙트** | 파티클 폭발, 화면 흔들림, 플래시, 네온 글로우 |
| 🎵 **절차적 사운드** | 외부 음원 없이 실시간 SFX 합성 |
| 📺 **AdMob 광고** | 배너, 전면, 리워드(부활) 광고 |
| 💾 **최고기록 저장** | 로컬 저장소 |
| ⏸️ **일시정지/재개** | 언제든 일시정지 가능 |
| 📊 **벤치마크 씬** | 성능 측정용 씬 (`scenes/Benchmark.tscn`) |

## 🎮 조작법

| 조작 | 모바일 | 키보드 (테스트) |
|------|--------|-----------------|
| 이동 | 화면 왼쪽 드래그 | 방향키 / WASD |
| 발사 | 자동 | 자동 |
| 일시정지 | ⏸ 버튼 | — |

## 🔤 단어 학습 게임플레이

1. **난이도 선택**: 메인 메뉴에서 Easy(3글자) / Normal(4-5글자) / Hard(6글자+) 선택
2. **타겟 글자 확인**: HUD 상단에 진행 중인 단어가 표시됨 (예: `C _ T`)
3. **적 처치**: 각 적에게 알파벳이 적혀 있음. **녹색으로 하이라이트된 글자**가 현재 타겟 글자
4. **단어 완성**: 타겟 글자를 가진 적을 처치하면 슬롯이 채워짐
5. **보상**: 단어 완성 시 보너스 점수 + 아이콘/이모지/발음(TTS) 표시
6. **사전 확인**: 메인 메뉴 → 📖 DICTIONARY 에서 모든 단어와 설명 탐색

## 👾 적 유닛 7종

| 타입 | 특징 | 공격 패턴 |
|------|------|-----------|
| 🔺 **Chaser** | 빠르고 약함 (HP 1) | 플레이어 추적 돌진 |
| 🔶 **Shooter** | 중간 체력, 원거리 | 거리 유지 + 직사 탄환 |
| ⬡ **Tank** | 높은 체력, 느림 | 전진 + 3방 확산탄 |
| ⭐ **Dasher** | 매우 빠름, 지그재그 | 지그재그 돌진 |
| ⚫ **Bomber** | 자폭형 | 접근 후 12방향 폭발 탄막 |
| ⬢ **Splitter** | 분열형 | 사망 시 3마리 Chaser로 분열 |
| ⬛ **Shielder** | 체력 재생, 원형 탄막 | 8방향 원형 탄막 + HP 회복 |

## 💎 파워업 7종

| 아이템 | 효과 | 등급 |
|--------|------|------|
| ⚡ **Rapid** | 발사 속도 2배 (6초) | Common |
| 🔱 **Spread** | 무기 레벨 업 (최대 4단계) | Common |
| 🛡️ **Shield** | 무적 보호막 (6초) | Uncommon |
| 💣 **Bomb** | 화면 정리 (모든 적/탄환 제거) | Uncommon |
| ⚡ **Lightning** | 연쇄 번개 (최대 8체) | Rare |
| 🔆 **Laser** | 수직 레이저 (5초 지속 데미지) | Rare |
| 🕐 **Time Slow** | 시간 감속 (4초) | Legendary |

## 📂 프로젝트 구조

```
NeonBlaster/
├── project.godot              # 프로젝트 설정
├── export_presets.cfg         # 안드로이드 익스포트 설정
│
├── scripts/                   # GDScript
│   ├── GameManager.gd         # 게임 상태, 점수, 생명, 콤보 (Autoload)
│   ├── SceneManager.gd        # 씬 전환 + 페이드 (Autoload)
│   ├── AdsManager.gd          # AdMob 광고 관리 (Autoload)
│   ├── AudioManager.gd        # 절차적 SFX 합성 + TTS (Autoload)
│   ├── EffectsManager.gd      # 화면 흔들림/이펙트 (Autoload)
│   ├── WordManager.gd         # 단어 진행/타겟 글자 관리 (Autoload)
│   │
│   ├── Game.gd                # 게임플레이 컨트롤러
│   ├── Player.gd              # 플레이어 함선 (+ AI 오토플레이)
│   ├── Enemy.gd               # 적 (7종, class_name)
│   ├── EnemySpawner.gd        # 웨이브 스폰 시스템
│   ├── Bullet.gd              # 총알 (플레이어/적)
│   ├── Explosion.gd           # 폭발 이펙트
│   ├── StarField.gd           # 배경 별
│   ├── PowerUp.gd             # 파워업 아이템
│   ├── ScorePopup.gd          # 점수 팝업
│   │
│   ├── HUD.gd                 # 게임 중 HUD (단어 진행 표시)
│   ├── MainMenu.gd            # 메인 메뉴 (난이도/오토플레이/사전/스토리)
│   ├── GameOverPanel.gd       # 게임오버 패널
│   ├── PausePanel.gd          # 일시정지 패널
│   ├── Joystick.gd            # 가상 조이스틱
│   │
│   ├── WordDictionary.gd      # 단어 설명 DB (class_name, 카테고리/이모지/한영설명)
│   ├── WordReveal.gd          # 단어 완성 시 오버레이 (아이콘 + TTS)
│   ├── DictionaryPage.gd      # 단어 사전 페이지
│   ├── IconRenderer.gd        # 이모지/아이콘 렌더링 헬퍼
│   │
│   ├── StoryData.gd           # 세계관 DB (프롤로그/챕터/세력/도감)
│   ├── StoryPage.gd           # 스토리 페이지 뷰어
│   ├── StoryArt.gd            # 스토리 일러스트 렌더링
│   │
│   └── Benchmark.gd           # 성능 벤치마크
│
├── scenes/                    # 씬 파일
│   ├── Menu.tscn              # 메인 메뉴 씬
│   ├── Game.tscn              # 게임 씬
│   ├── Dictionary.tscn        # 단어 사전 씬
│   ├── Story.tscn             # 스토리 씬
│   ├── Benchmark.tscn         # 벤치마크 씬
│   ├── Player.tscn            # 플레이어 프리팹
│   ├── Enemy.tscn             # 적 프리팹
│   ├── Bullet.tscn            # 총알 프리팹
│   ├── Explosion.tscn         # 폭발 프리팹
│   └── PowerUp.tscn           # 파워업 프리팹
│
├── website/                   # 단어/이모지 매핑 웹 도구
│   ├── index.html
│   ├── script.js
│   ├── style.css
│   ├── words.js
│   └── audio/                 # 오디오 생성 스크립트
│
└── assets/
    ├── shaders/
    │   └── neon_glow.gdshader # 네온 글로우 셰이더
    ├── icons/                 # 앱 아이콘
    └── sounds/                # (예약)
```

## 🚀 실행 방법 (처음이라면 여기부터!)

### 방법 1: Godot 에디터로 열기 (가장 쉬운 방법)

1. **Godot 에디터 실행**
   ```bash
   # 터미널에서 실행하거나 Launchpad에서 Godot 클릭
   godot
   ```

2. **프로젝트 임포트**
   - Godot 시작 화면에서 **Import** 버튼 클릭
   - 다음 파일 선택:
     ```
     /Users/swyoon/workspace/AndroidStudioProjects/NeonBlaster/project.godot
     ```
   - **Import & Edit** 클릭

3. **게임 실행**
   - 에디터 우상단의 ▶ **재생 버튼** 클릭
   - 또는 단축키 **F5** 누름
   - 게임 창이 열리면서 메인 메뉴가 표시됨

### 방법 2: 터미널에서 바로 실행 (에디터 없이)

```bash
# 게임 바로 실행
godot /Users/swyoon/workspace/AndroidStudioProjects/NeonBlaster/project.godot

# 또는 디렉토리로 이동 후 실행
cd /Users/swyoon/workspace/AndroidStudioProjects/NeonBlaster
godot
```

### 방법 3: 터미널에서 에디터 열기

```bash
# Godot 에디터로 프로젝트 열기
godot --editor /Users/swyoon/workspace/AndroidStudioProjects/NeonBlaster/project.godot

# 또는
cd /Users/swyoon/workspace/AndroidStudioProjects/NeonBlaster
godot -e
```

### 데스크톱 조작법 (테스트용)
- **이동**: 방향키 또는 WASD
- **발사**: 자동 (아무것도 안 눌러도 발사됨)
- **일시정지**: 화면 우상단 ⏸ 버튼

### 안드로이드 APK 빌드

#### 사전 준비
1. **Godot 4.x** 설치 (https://godotengine.org)
2. **Android SDK** 설치 (Android Studio 통해)
3. **Java JDK 17** 설치
4. **Godot Android Export Template** 다운로드 (에디터 → Editor → Manage Export Templates)

#### 디버그 빌드
1. Godot 에디터 → Project → Export
2. "Android (Debug)" 프리셋 선택
3. keystore 파일 설정 (또는 debug keystore 사용)
4. "Export Project" 클릭 → `.apk` 생성

#### 커맨드라인 빌드
```bash
# Godot CLI로 APK 빌드
/Applications/Godot.app/Contents/MacOS/Godot --export-debug "Android (Debug)" NeonBlaster-debug.apk

# 디바이스 설치
adb install NeonBlaster-debug.apk
```

## 📺 AdMob 광고 설정

### 광고 단위 ID 교체

`scripts/AdsManager.gd`에서 테스트 ID를 실제 ID로 변경하세요:

```gdscript
const ADMOB_APP_ID := "ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX"
const BANNER_ID := "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX"
const INTERSTITIAL_ID := "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX"
const REWARDED_ID := "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX"
```

> ⚠️ **플러그인 미설치 시**: 자동으로 stub 모드로 동작합니다. 콘솔에 `[AdsManager] AdMob plugin not found. Running in stub mode` 로그가 표시되며 더미 광고 오버레이가 표시됩니다.

### AdMob 플러그인 설치

1. Godot Asset Library에서 **Poing Studios AdMob** 플러그인 설치
2. 또는 [GitHub](https://github.com/Poing-Studios/godot-admob-android)에서 다운로드
3. `addons/admob/` 폴더에 배치
4. Project Settings → Plugins → AdMob 활성화

### 광고 배치 전략

| 광고 유형 | 시점 | 빈도 |
|-----------|------|------|
| **배너** | 게임 중 하단 | 상시 |
| **전면** | 게임오버 시 | 최소 120초 간격 |
| **리워드** | 부활 선택 시 | 게임당 1회 |

## 🎨 커스터마이징

### 색상 테마

`scripts/Player.gd`, `scripts/Enemy.gd`에서 색상 변경:

```gdscript
# 플레이어 네온 색상
_sprite.color = Color(0.3, 0.9, 1.0)  # 시안
```

### 난이도 조정

`scripts/EnemySpawner.gd`:

```gdscript
@export var initial_spawn_interval: float = 2.0   # 초기 스폰 간격
@export var min_spawn_interval: float = 0.4        # 최소 스폰 간격
@export var difficulty_scale: float = 0.97         # 웨이브당 간격 감소율
@export var wave_duration: float = 20.0            # 웨이브 지속시간(초)
```

### 생명 수

`scripts/GameManager.gd`:

```gdscript
const MAX_LIVES := 3  # 변경 가능
```

### 단어 추가/수정

`scripts/WordManager.gd` (게임용 단어 목록) + `scripts/WordDictionary.gd` (설명/이모지/카테고리)를 편집:

```gdscript
# WordManager.gd - 게임에 등장할 단어
const WORDS_EASY := ["SUN", "CAT", "DOG", ...]

# WordDictionary.gd - 각 단어의 설명
"SUN": {"category": "SPACE", "emoji": "☀️", "ko": "태양...", "en": "The bright star..."}
```

## 🔊 오디오 시스템

| 기능 | 토글 버튼 | 비고 |
|------|-----------|------|
| **SFX** | 메인 메뉴 우상단 `SFX ON/OFF` | 절차적 합성 사운드 |
| **BGM** | 메인 메뉴 우상단 `BGM ON/OFF` | 배경 음악 |
| **TTS** | 메인 메뉴 우상단 `TTS ON/OFF` | 단어 완성 시 영어 발음 |

> TTS는 `DisplayServer.tts_speak()`를 사용하며 플랫폼 지원이 필요합니다 (데스크톱/macOS, Android 지원).

## 🛠️ 기술 스택

- **엔진**: Godot Engine 4.x (GDScript)
- **렌더링**: gl_compatibility (모바일 최적화)
- **광고**: Poing Studios Godot AdMob Plugin
- **해상도**: 720×1280 (Portrait)
- **타겟**: Android API 21+ (Android 5.0+)

## 📝 라이선스

MIT License - 자유롭게 사용, 수정, 배포 가능합니다.