#!/usr/bin/env bash
# PostToolUse hook: after editing a lib/**/*.ex file, run its matching test file.
set -euo pipefail

file=$(jq -r '.tool_input.file_path // empty')

case "$file" in
  *lib/*.ex)
    project_root="${file%%/lib/*}"
    rel="${file#*/lib/}"
    test_file="$project_root/test/${rel%.ex}_test.exs"
    if [ -f "$test_file" ]; then
      (cd "$project_root" && mix test "${test_file#"$project_root"/}")
    fi
    ;;
esac
