#!/usr/bin/env python3
"""Static M1 acceptance checks (no Godot runtime required)."""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GAME = ROOT / "game"

RES_MAP = {
    "treasury", "popular", "people", "frontier", "border_army",
    "court", "court_order", "resolve", "emperor_heart", "mandate_decay",
    "rebel_pressure",
}

REQUIRED_SCENES = [
    "scenes/main/Main.tscn",
    "scenes/world/Meishan.tscn",
    "assets/models/props/plot_01.tscn",
]

REQUIRED_DIALOGUES = [
    "DLG_A1_AEN_SEED",
    "DLG_A1_BROTHER_VISIT",
]

errors: list[str] = []
warnings: list[str] = []


def err(msg: str) -> None:
    errors.append(msg)


def warn(msg: str) -> None:
    warnings.append(msg)


def check_issues() -> None:
    issues_dir = GAME / "data" / "issues"
    a1_files = sorted(issues_dir.glob("ISSUE_A1_*.json"))
    if len(a1_files) != 15:
        err(f"A1 议题应为 15 条，实际 {len(a1_files)}")
    ids: set[str] = set()
    for path in a1_files:
        data = json.loads(path.read_text(encoding="utf-8"))
        iid = data.get("id", "")
        if iid in ids:
            err(f"重复议题 id: {iid}")
        ids.add(iid)
        for choice in data.get("choices", []):
            for k in choice.get("deltas", {}):
                if k not in RES_MAP:
                    err(f"{path.name} choice {choice.get('id')} 未知 delta 键: {k}")


def check_dialogues() -> None:
    dlg_dir = GAME / "data" / "dialogues"
    for dlg_id in REQUIRED_DIALOGUES:
        path = dlg_dir / f"{dlg_id}.json"
        if not path.exists():
            err(f"缺少对话 JSON: {dlg_id}")


def check_scenes_and_scripts() -> None:
    for rel in REQUIRED_SCENES:
        if not (GAME / rel).exists():
            err(f"缺少资源: game/{rel}")
    scripts = [
        "scripts/world/Act1Director.gd",
        "scripts/world/CourtPlot.gd",
        "scripts/managers/ResourceManager.gd",
        "scripts/managers/IssueManager.gd",
        "scripts/ui/Act1Closure.gd",
        "scripts/world/BrotherStoryline.gd",
    ]
    for rel in scripts:
        if not (GAME / rel).exists():
            err(f"缺少脚本: game/{rel}")


def check_act1_director_priority() -> None:
    text = (GAME / "scripts/world/Act1Director.gd").read_text(encoding="utf-8")
    if "_try_story_beat" not in text:
        err("Act1Director 缺少 _try_story_beat（剧情日可能被夜召抢走）")
    if "if _try_story_beat():" not in text:
        err("Act1Director 未在夜召前调用 _try_story_beat")
    if "ResourceManager.day % 7 == 0" not in text:
        err("Act1Director 缺少周夜召触发")


def check_reset_on_replay() -> None:
    main = (GAME / "scripts/main/Main.gd").read_text(encoding="utf-8")
    for fn in ("reset_for_new_act1",):
        if fn not in main:
            err(f"Main.gd 未调用 {fn}，重玩第一幕可能残留 autoload 状态")


def main() -> int:
    check_issues()
    check_dialogues()
    check_scenes_and_scripts()
    check_act1_director_priority()
    check_reset_on_replay()

    print("=== M1 静态验收 ===")
    if warnings:
        print("\n警告:")
        for w in warnings:
            print(f"  ! {w}")
    if errors:
        print("\n失败:")
        for e in errors:
            print(f"  x {e}")
        print(f"\n共 {len(errors)} 项失败")
        return 1
    print("全部通过（静态检查；实机 F5 仍建议人工跑 day1→150）")
    return 0


if __name__ == "__main__":
    sys.exit(main())
