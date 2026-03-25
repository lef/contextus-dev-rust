#!/bin/sh
# PostToolUse hook: cs-lint on .md file writes
# Minimal output — MUST errors only, 1 line per error
# Exit 0 always (don't block the tool, just inform)

set -eu

TOOL_NAME="${CLAUDE_TOOL_NAME:-}"
FILE_PATH="${CLAUDE_FILE_PATH:-}"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
LINT="$PROJECT_DIR/.contextus/contextus/tools/cs-lint.sh"

# Only run on Write/Edit of .md files in .spec/
case "$TOOL_NAME" in
    Write|Edit) ;;
    *) exit 0 ;;
esac

case "$FILE_PATH" in
    *.md) ;;
    *) exit 0 ;;
esac

case "$FILE_PATH" in
    */.spec/*|*/HANDOFF.md|*/CLAUDE.md) ;;
    *) exit 0 ;;
esac

# Run lint — edited file only. MUST detail + SHOULD count (1 line each max)
if [ -x "$LINT" ] 2>/dev/null || [ -f "$LINT" ]; then
    _bn="$(basename "$FILE_PATH")"
    _all="$(sh "$LINT" "$PROJECT_DIR/.spec" 2>&1 | grep "$_bn" || true)"
    _must="$(echo "$_all" | grep "^MUST" || true)"
    _should_n="$(echo "$_all" | grep -c "^SHOULD" || true)"

    if [ -n "$_must" ]; then
        echo ":: cs-lint: $(echo "$_must" | wc -l | tr -d ' ') MUST error(s) in $_bn" >&2
    fi
    if [ "$_should_n" -gt 0 ] 2>/dev/null; then
        echo ":: cs-lint: (${_should_n} SHOULD in $_bn)" >&2
    fi
fi

exit 0
