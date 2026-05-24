from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
METADATA_DIR = ROOT / "AppStore" / "Metadata"


LIMITS = {
    "name": 30,
    "subtitle": 30,
    "promotionalText": 170,
    "keywords": 100,
    "description": 4000,
    "whatsNew": 4000,
}


def main() -> None:
    files = sorted(METADATA_DIR.glob("*.json"))
    if not files:
        raise SystemExit("No metadata files found")

    for path in files:
        data = json.loads(path.read_text(encoding="utf-8"))
        for field, limit in LIMITS.items():
            value = data.get(field, "")
            length = len(value)
            if length > limit:
                raise SystemExit(f"{path.name}: {field} is {length} chars, over {limit}")

        keywords = data.get("keywords", "")
        if "posturepilot" in keywords.lower():
            raise SystemExit(f"{path.name}: keywords should not duplicate the app name")

        description = data.get("description", "").lower()
        blocked = ["diagnose ", "treat ", "cure ", "prevent injury", "guarantee"]
        for phrase in blocked:
            if phrase in description and "does not" not in description:
                raise SystemExit(f"{path.name}: risky medical claim phrase found: {phrase}")

        for screenshot in data.get("screenshotOrder", []):
            screenshot_path = ROOT / screenshot["file"]
            if not screenshot_path.exists():
                raise SystemExit(f"{path.name}: missing screenshot {screenshot_path}")

        print(f"{path.name}: metadata passes length and safety checks")


if __name__ == "__main__":
    main()
