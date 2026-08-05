# CLAUDE.md

이 프로젝트의 모든 작업 컨텍스트·컨벤션·명령·함정은 **AGENTS.md**에 정리되어 있습니다.
아래 import를 통해 Claude Code가 동일한 가이드를 따릅니다.

@AGENTS.md

## Claude Code 전용 추가 참고

- **검증 자동화**: GDScript 수정 후에는 항상 `godot --headless --quit --path .` 로 Parse Error 를 잡아낸 뒤 작업을 마무리할 것. (hang 대비 백그라운드 실행 + 타임아웃)
- **Android 반영**: 코드/설정 변경이 폰에 적용되려면 Godot 에디터 GUI export 가 필요하다(AGENTS.md 함정 1·2). 이 단계는 사용자가 직접 수행해야 하므로, 변경 완료 시 명확한 단계를 안내로 전달할 것.
- **들여쓰기**: 반드시 **탭**. 에디터 교체 시 스페이스로 변환되지 않도록 주의.
