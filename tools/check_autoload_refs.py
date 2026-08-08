#!/usr/bin/env python3
"""오토로드의 **존재하지 않는 멤버**를 참조하는 곳을 찾는다.

왜 필요한가:
    GDScript 는 오토로드 접근(`GameManager.foo`)을 컴파일 시점에 검사하지 않는다.
    그래서 오토로드의 변수/함수 이름을 바꾸면 호출부가 남아 있어도 파스는 통과하고,
    **그 줄이 실제로 실행될 때만** 터진다.

    실제로 겪은 예:
        DifficultyDirector 를 성능 기반에서 시간 목표 기반으로 다시 쓰면서
        `var intensity` 가 `func get_intensity()` 로 바뀌었는데
        Enemy.gd 의 파워업 드롭 분기 하나가 옛 이름을 계속 참조했다.
        그 분기는 6% 확률(TIME_SLOW 드롭)이라 짧은 플레이 테스트에서는 걸리지 않았고,
        `godot --headless --quit` 파스 검사도 통과했다.

사용법:
    python3 tools/check_autoload_refs.py        # 프로젝트 루트에서
    → 문제가 없으면 종료 코드 0, 있으면 1

한계:
    정적 텍스트 검사다. 동적 접근(`get(name)`, `call(name)`)은 못 잡는다.
    내장 Node 멤버(name, queue_free 등)는 화이트리스트로 걸러낸다.
"""

import pathlib
import re
import sys

# 모든 Node 가 갖는 멤버. 오토로드 스크립트에 선언돼 있지 않아도 정상이다.
NODE_BUILTINS = {
    "name", "get_node", "get_node_or_null", "queue_free", "add_child", "get_children",
    "get_child", "get_child_count", "get_tree", "get_parent", "connect", "disconnect",
    "is_connected", "call_deferred", "set_process", "set_physics_process", "free",
    "has_method", "has_signal", "get", "set", "call", "emit_signal", "is_inside_tree",
    "process_mode", "owner", "visible", "get_class", "new", "duplicate", "remove_child",
    "move_child", "find_child", "propagate_call", "set_deferred", "get_instance_id",
}

DECL_PATTERNS = [
    r"^(?:func|static func)\s+(\w+)",
    r"^(?:var|const)\s+(\w+)",
    r"^signal\s+(\w+)",
    r"^enum\s+(\w+)",
]


def main() -> int:
    root = pathlib.Path(".")
    proj = root / "project.godot"
    if not proj.exists():
        print("project.godot 을 찾을 수 없습니다. 프로젝트 루트에서 실행하세요.")
        return 2

    autoloads = {
        m.group(1): m.group(2)
        for m in re.finditer(r'^(\w+)="\*res://(scripts/\w+\.gd)"', proj.read_text(), re.M)
    }
    if not autoloads:
        print("오토로드를 찾지 못했습니다.")
        return 2

    members: dict[str, set[str]] = {}
    for name, rel in autoloads.items():
        src = (root / rel).read_text()
        found: set[str] = set(NODE_BUILTINS)
        for pat in DECL_PATTERNS:
            found |= {m.group(1) for m in re.finditer(pat, src, re.M)}
        members[name] = found

    problems = []
    for path in sorted(root.glob("scripts/*.gd")):
        own = {n for n, rel in autoloads.items() if pathlib.Path(rel).name == path.name}
        for lineno, line in enumerate(path.read_text().splitlines(), 1):
            if line.lstrip().startswith("#"):
                continue
            for name in autoloads:
                if name in own:
                    continue  # 자기 자신은 지역 스코프로 접근하므로 검사 대상이 아니다
                for m in re.finditer(re.escape(name) + r"\.(\w+)", line):
                    if m.group(1) not in members[name]:
                        problems.append((path, lineno, name, m.group(1), line.strip()))

    print("오토로드 %d개 검사: %s" % (len(autoloads), ", ".join(sorted(autoloads))))
    if not problems:
        print("존재하지 않는 멤버 참조: 없음")
        return 0

    print("\n존재하지 않는 멤버 참조 %d건:" % len(problems))
    for path, lineno, name, attr, text in problems:
        print("  %s:%d  %s.%s" % (path, lineno, name, attr))
        print("      %s" % text[:100])
    return 1


if __name__ == "__main__":
    sys.exit(main())
