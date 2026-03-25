#!/bin/sh
# PreToolUse hook: cs-lint before git commit
# Blocks commit if MUST errors exist in staged .md files
# Exit 1 to block, exit 0 to allow

set -eu

TOOL_NAME="${CLAUDE_TOOL_NAME:-}"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
LINT="$PROJECT_DIR/.contextus/contextus/tools/cs-lint.sh"

# Only run on Bash commands that look like git commit
case "$TOOL_NAME" in
    Bash) ;;
    *) exit 0 ;;
esac

# Check if this is a git commit command
COMMAND="${CLAUDE_BASH_COMMAND:-}"
case "$COMMAND" in
    *"git commit"*|*"git add"*"commit"*) ;;
    *) exit 0 ;;
esac

# Run lint if tool exists
if [ -x "$LINT" ] 2>/dev/null || [ -f "$LINT" ]; then
    _must="$(sh "$LINT" "$PROJECT_DIR/.spec" 2>&1 | grep "^MUST" || true)"
    if [ -n "$_must" ]; then
        _count="$(echo "$_must" | wc -l | tr -d ' ')"
        echo ":: cs-lint: ${_count} MUST error(s) — fix before commit:" >&2
        echo "$_must" >&2
        exit 1
    fi
fi

exit 0
