# Development checks

Normal builds require only the dependencies in `README.md`. Quality checks are
opt-in locally and mandatory in GitHub CI. Use CMake's Makefiles or Ninja generator
so `compile_commands.json` is available to static analysis.

## Tools and commands

Use **clang-format 18.1.8** and **clang-tidy 18.1.8** on both developer machines and
CI. Exact versions avoid formatting drift and unexpected new diagnostics. Python
3.8+ runs the lint driver; Python 3 with venv/pip can install the pinned tools:

```sh
python3 -m venv .venv-quality
.venv-quality/bin/python -m pip install clang-format==18.1.8 clang-tidy==18.1.8
cmake -S . -B build-quality -DBUILD_TESTING=ON -DAMB_ENABLE_QUALITY_CHECKS=ON \
  -DAMB_CLANG_FORMAT="$PWD/.venv-quality/bin/clang-format" \
  -DAMB_CLANG_TIDY="$PWD/.venv-quality/bin/clang-tidy"
cmake --build build-quality --target format-check
cmake --build build-quality --parallel
cmake --build build-quality --target lint
ctest --test-dir build-quality --output-on-failure --no-tests=error
```

To apply formatting, run `cmake --build build-quality --target format`, then review
the diff and rerun `format-check`. Check targets never rewrite files. Paths can be
overridden with the two CMake variables; missing/wrong-version tools fail configure
only when quality checks are enabled. Normal builds do not download tools.

## Rules and coverage

- C source/header formatting: four spaces, no tabs, 100 columns, Linux-style braces
  (function brace on its own line), deterministic include sorting. `.clang-format`
  is authoritative; its `Cpp` language setting is clang-format's C-family mode.
- `.editorconfig`: UTF-8, LF, final newline and no trailing whitespace; four-space
  default, two-space Markdown/YAML indentation. Markdown/CMake/Python/YAML formatting
  is reviewed manually; clang-format is applied only to C sources and headers.
- clang-tidy enables static-analyzer, bug-prone and portability checks and treats
  their warnings as errors. It does not apply fixes. The lint driver uses the
  compilation database, not guessed compiler flags, and fails if there are no C
  translation units. Headers are analyzed through the units that include them.
- `src/`, `include/` and `tests/` C files/headers are included in format checks;
  new production source directories must be added to this list when introduced.
- Keep explicit source lists for build targets. Generated build files, dependencies
  and local virtual environments are outside formatting coverage.
- The scaffold compiles as strict C11 with `-Wall -Wextra -Wpedantic -Werror` on
  GCC/Clang. Future production targets must retain equivalent warning coverage.

Suppress a diagnostic only with a narrow, documented reason, preferably at the
specific line; do not disable whole check families to hide a defect. Tool-version
or check-policy changes require an explicit configuration and CI update together.
Static analysis does not replace signal tests, sanitizers or hardware validation.
