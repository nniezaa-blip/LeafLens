#!/usr/bin/env bash
set -euo pipefail

# Lightweight comment-density guard for Dart files in staged or changed lib/test paths.
# It flags files with high comment-to-code ratio, ignoring generated files.

files=$(git diff --name-only --cached -- '*.dart' || true)
if [[ -z "${files}" ]]; then
  exit 0
fi

status=0
while IFS= read -r file; do
  [[ -z "$file" ]] && continue
  [[ ! -f "$file" ]] && continue
  [[ "$file" == *.g.dart || "$file" == *.freezed.dart ]] && continue
  code_lines=$(grep -Ev '^\s*(//|/\*|\*|\*/|$)' "$file" | wc -l | tr -d ' ')
  comment_lines=$(grep -E '^\s*(//|/\*|\*|\*/)' "$file" | wc -l | tr -d ' ')
  if [[ "$code_lines" -gt 40 && "$comment_lines" -gt $((code_lines / 3)) ]]; then
    echo "comment-density: $file has $comment_lines comment lines for $code_lines code lines" >&2
    status=1
  fi
done <<< "$files"

exit $status
