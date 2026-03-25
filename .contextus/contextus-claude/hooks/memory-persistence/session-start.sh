#!/bin/bash
# SessionStart Hook — inject previous session context into Claude's context window
#
# Outputs HANDOFF.md to stdout, which Claude Code injects into the context.
# User-visible messages are handled by session-banner.sh (systemMessage JSON).

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
HANDOFF_FILE="${PROJECT_DIR}/HANDOFF.md"
SPEC_DIR="${PROJECT_DIR}/.spec"
SESSIONS_DIR="${HOME}/.claude/sessions"

# Inject enforcement rules (always, before any other context)
cat << 'ENFORCE'
[session:enforcement]
MANDATORY — 以下は全セッションで遵守する義務:
1. 非自明なタスクでは必ず extended thinking (megathink) を使用すること
2. 実装コードを書く前に必ずテストを先に書くこと（TDD: RED → GREEN → REFACTOR）
3. 非自明な機能実装の前に .spec/TODO.md を確認し、人間の承認を得ること（SDD）
4. ユーザーが次の作業を求めたら理由付きで推薦すること（/clarify-todo-gtd-like 参照）
5. 議論・決定が発生したら MINUTES.md に議題（### 議題N:）を記録すること（rules/minutes.md 参照）
   タイミング: 話題が切り替わったとき（議題単位）。毎ターンではない。セッション末のまとめ書きも避ける
   # ↑ 試行中。運用が重すぎればタイミングを見直す
違反はユーザーの時間を浪費する。
[/session:enforcement]
ENFORCE

# Inject HANDOFF.md into context (stdout)
if [ -f "$HANDOFF_FILE" ]; then
    echo "[session:handoff]"
    cat "$HANDOFF_FILE"
    echo ""
    echo "[/session:handoff]"
fi

# Inject CONSTITUTION.md into context (stdout) — project constraints
CONSTITUTION_FILE="${SPEC_DIR}/CONSTITUTION.md"
if [ -f "$CONSTITUTION_FILE" ]; then
    echo "[session:constitution]"
    cat "$CONSTITUTION_FILE"
    echo ""
    echo "[/session:constitution]"
fi

# Inject SDD files into context (stdout) — just-in-time strategy
# KNOWLEDGE: headings + Decisions table only (body is Read on demand)
# TODO: ## headers + top-level pending items only (子項目は Read on demand)
# PLAN: not injected (Read on demand when needed)
_knowledge="${SPEC_DIR}/KNOWLEDGE.md"
if [ -f "$_knowledge" ]; then
    echo "[session:knowledge]"
    # YAML frontmatter + title + ## headings + Decisions table
    awk '
        # Skip YAML frontmatter (--- to ---)
        NR == 1 && /^---$/ { in_fm = 1; next }
        in_fm && /^---$/ { in_fm = 0; next }
        in_fm { next }
        # Title line
        /^# / { print; next }
        # Description lines before first ##
        !seen_h2 && /^[A-Za-z]/ { print; next }
        !seen_h2 && /^$/ { print; next }
        # ## headings
        /^## / { seen_h2 = 1; in_decisions = ($0 ~ /Decisions/); print; next }
        # Decisions table content (蒸留ルール: 永続)
        in_decisions && /^[>|]/ { print; next }
        in_decisions && /^$/ { print; next }
        in_decisions && /^[^>|]/ && !/^$/ { in_decisions = 0; next }
    ' "$_knowledge"
    echo ""
    echo "[/session:knowledge]"
fi

_todo="${SPEC_DIR}/TODO.md"
if [ -f "$_todo" ]; then
    echo "[session:todo]"
    # YAML frontmatter + title + ## headers with pending count
    # Sections with 0 pending items are omitted (completed)
    awk '
        # Skip YAML frontmatter (--- to ---)
        NR == 1 && /^---$/ { in_fm = 1; next }
        in_fm && /^---$/ { in_fm = 0; next }
        in_fm { next }
        # Title (H1 only, not code comments)
        /^# [A-Z]/ { print; next }
        # ## section headers — buffer and count pending items
        /^## / {
            if (section && pending > 0) {
                printf "%s (%d pending)\n", section, pending
                for (i = 0; i < desc_count; i++) print desc[i]
            }
            section = $0; pending = 0; desc_count = 0; in_desc = 1; next
        }
        # Skip code blocks
        /^```/ { in_code = !in_code; next }
        in_code { next }
        # Description lines: between ## heading and first checkbox
        in_desc && /^- \[/ { in_desc = 0 }
        in_desc && !/^$/ && !/^- / && !/^#/ && !/^>/ && !/^\|/ { desc[desc_count++] = $0; next }
        in_desc { next }
        # Count top-level pending tasks
        /^- \[ \]/ { pending++; next }
    END {
        if (section && pending > 0) {
            printf "%s (%d pending)\n", section, pending
            for (i = 0; i < desc_count; i++) print desc[i]
        }
    }
    ' "$_todo"
    echo ""
    echo "[/session:todo]"
fi
# PLAN.md: not injected (just-in-time — Read on demand)

# Append meeting header to MINUTES.md and inject into context
MINUTES_FILE="${SPEC_DIR}/MINUTES.md"
if [ -d "$SPEC_DIR" ]; then
    TODAY=$(date '+%Y-%m-%d')
    NOW=$(date '+%H:%M')
    {
        echo ""
        echo "## 会議: ${TODAY} ${NOW}"
        echo "**出席者**: $(whoami)（人間）、Claude（AI）"
        echo ""
        echo "---"
        echo ""
    } >> "$MINUTES_FILE" || true

    # Inject only recent 5 sessions (file retains full history)
    echo "[session:minutes]"
    _total=$(grep -c '^## 会議:' "$MINUTES_FILE" 2>/dev/null || echo 0)
    _skip=$(( _total > 5 ? _total - 5 : 0 ))
    if [ "$_skip" -eq 0 ]; then
        cat "$MINUTES_FILE"
    else
        awk -v skip="$_skip" '
            /^## 会議:/ { count++ }
            count > skip { print }
        ' "$MINUTES_FILE"
    fi
    echo ""
    echo "[/session:minutes]"
fi

# Record [SessionStart] to trace.log
TODAY=$(date '+%Y-%m-%d')
TRACE_FILE="${SESSIONS_DIR}/${TODAY}-trace.log"
mkdir -p "$SESSIONS_DIR"
echo "$(date -Iseconds) [SessionStart] project=${PROJECT_DIR}" >> "$TRACE_FILE" || true
