from __future__ import annotations

import math
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SKIP_DIRS = {
    ".git",
    ".build",
    ".swiftpm",
    "DerivedData",
    "__pycache__",
}
SKIP_SUFFIXES = {
    ".png",
    ".jpg",
    ".jpeg",
    ".gif",
    ".pdf",
    ".xcuserstate",
    ".mobileprovision",
    ".cer",
    ".p12",
}

PATTERNS = {
    "OpenAI API key": re.compile(r"\bsk-(?:proj-)?[A-Za-z0-9_-]{20,}\b"),
    "GitHub token": re.compile(r"\b(?:ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9_]{20,}\b|\bgithub_pat_[A-Za-z0-9_]{30,}\b"),
    "Google API key": re.compile(r"\bAIza[0-9A-Za-z_-]{35}\b"),
    "Slack token": re.compile(r"\bxox[baprs]-[A-Za-z0-9-]{20,}\b"),
    "JWT": re.compile(r"\beyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\b"),
    "Private key block": re.compile(r"-----BEGIN (?:RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----"),
    "AWS access key": re.compile(r"\bAKIA[0-9A-Z]{16}\b"),
    "Assignment to secret-like name": re.compile(
        r"(?i)\b(?:api[_-]?key|secret|access[_-]?token|auth[_-]?token|password)\b\s*[:=]\s*[\"'][^\"']{12,}[\"']"
    ),
}

ALLOWLIST = [
    "https://YOUR_BACKEND_URL.com/posturepilot-ai",
    "https://apps.apple.com/app/id0000000000",
    "OPENAI_API_KEY",
    "YOUR_DOMAIN.com",
    "Marketing/AppStoreConnect/",
]


def entropy(value: str) -> float:
    if not value:
        return 0.0
    frequencies = {char: value.count(char) for char in set(value)}
    return -sum((count / len(value)) * math.log2(count / len(value)) for count in frequencies.values())


def should_scan(path: Path) -> bool:
    if any(part in SKIP_DIRS for part in path.parts):
        return False
    return path.suffix.lower() not in SKIP_SUFFIXES


def redact(line: str) -> str:
    output = line.strip()
    for pattern in PATTERNS.values():
        output = pattern.sub("[REDACTED]", output)
    return output[:220]


def main() -> None:
    findings: list[str] = []

    for path in ROOT.rglob("*"):
        if not path.is_file() or not should_scan(path.relative_to(ROOT)):
            continue

        try:
            text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue

        for line_number, line in enumerate(text.splitlines(), start=1):
            if any(allowed in line for allowed in ALLOWLIST):
                continue

            for label, pattern in PATTERNS.items():
                if pattern.search(line):
                    rel = path.relative_to(ROOT).as_posix()
                    findings.append(f"{rel}:{line_number}: {label}: {redact(line)}")

            for candidate in re.findall(r"\b[A-Za-z0-9_/-]{32,}\b", line):
                if (
                    entropy(candidate) >= 4.4
                    and any(char.isdigit() for char in candidate)
                    and not candidate.isupper()
                    and not candidate.startswith(("PosturePilotAI", "ASSETCATALOG", "INFOPLIST_KEY"))
                ):
                    rel = path.relative_to(ROOT).as_posix()
                    findings.append(f"{rel}:{line_number}: high-entropy token-like string: [REDACTED]")

    if findings:
        print("Potential secrets found:")
        for finding in sorted(set(findings)):
            print(f"- {finding}")
        raise SystemExit(1)

    print("No API secrets or token-like values found.")


if __name__ == "__main__":
    main()
