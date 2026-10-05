#!/usr/bin/env python3
"""Run pinned clang-tidy against each C unit in a CMake compilation database."""
import json
from pathlib import Path
import subprocess
import sys


def main():
    tool, database_name = sys.argv[1:]
    database = Path(database_name).resolve()
    entries = json.loads(database.read_text(encoding="utf-8"))
    sources = set()
    for entry in entries:
        source = Path(entry["file"])
        if not source.is_absolute():
            source = Path(entry["directory"]) / source
        if source.suffix == ".c":
            sources.add(source.resolve())
    if not sources:
        print("No C translation units to lint; enable BUILD_TESTING or add a C target.",
              file=sys.stderr)
        return 1
    failed = False
    for source in sorted(sources):
        result = subprocess.run([tool, "-p", str(database.parent), str(source)], check=False)
        failed = failed or result.returncode != 0
    return int(failed)


if __name__ == "__main__":
    sys.exit(main())
