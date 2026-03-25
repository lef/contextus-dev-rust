#!/bin/sh
# SessionStart hook: cs-lint health check
# Warn only (don't block session start)
# Output goes to agent context

set -eu

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
LINT="$PROJECT_DIR/.contextus/contextus/tools/cs-lint.sh"

# Run lint if tool exists
if [ -x "$LINT" ] 2>/dev/null || [ -f "$LINT" ]; then
    _result="$(sh "$LINT" "$PROJECT_DIR/.spec" 2>&1 || true)"
    _must="$(echo "$_result" | grep "^MUST" | wc -l | tr -d ' ')"
    _should="$(echo "$_result" | grep "^SHOULD" | wc -l | tr -d ' ')"

    if [ "$_must" -gt 0 ] || [ "$_should" -gt 0 ]; then
        echo "[session:cs-lint]"
        # MUST: full details (must fix)
        if [ "$_must" -gt 0 ]; then
            echo ":: cs-lint: ${_must} MUST errors:"
            echo "$_result" | grep "^MUST"
        fi
        # SHOULD: file names only (1 line, minimal tokens)
        if [ "$_should" -gt 0 ]; then
            _files="$(echo "$_result" | grep "^SHOULD" | sed 's/^SHOULD  *\([^ :]*\).*/\1/' | sort -u | tr '\n' ', ' | sed 's/,$//')"
            echo ":: cs-lint: ${_should} SHOULD in: ${_files}"
        fi
        echo "[/session:cs-lint]"
    fi
fi
