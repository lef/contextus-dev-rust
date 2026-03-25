#!/bin/bash
# PreCompact Hook — save state before context compression

SESSIONS_DIR="${HOME}/.claude/sessions"
COMPACTION_LOG="${SESSIONS_DIR}/compaction-log.txt"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"

mkdir -p "$SESSIONS_DIR"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Context compaction triggered (project: $PROJECT_DIR)" >> "$COMPACTION_LOG"

ACTIVE_SESSION=$(ls -t "$SESSIONS_DIR"/*.md 2>/dev/null | head -1)
if [ -n "$ACTIVE_SESSION" ] && [ -f "$ACTIVE_SESSION" ]; then
    echo "" >> "$ACTIVE_SESSION"
    echo "---" >> "$ACTIVE_SESSION"
    echo "**[Compaction at $(date '+%H:%M')]** — Context compressed. Above content may be summarized." >> "$ACTIVE_SESSION"
fi

# Plan A: Auto-generate HANDOFF snapshot from git log + pending TODOs
# Runs mechanically without Claude intelligence — safety net if /dumpmem was missed.
# Replaces old snapshot (if any) to prevent HANDOFF from growing unboundedly.
HANDOFF_FILE="${PROJECT_DIR}/HANDOFF.md"
SPEC_DIR="${PROJECT_DIR}/.spec"
if git -C "$PROJECT_DIR" rev-parse --git-dir > /dev/null 2>&1 && [ -f "$HANDOFF_FILE" ]; then
    # 古い snapshot を削除（marker 行 + 直前の --- から EOF まで）
    if grep -qn '<!-- pre-compact-snapshot -->' "$HANDOFF_FILE"; then
        _marker_line=$(grep -n '<!-- pre-compact-snapshot -->' "$HANDOFF_FILE" | head -1 | cut -d: -f1)
        if [ "$_marker_line" -gt 1 ]; then
            _prev_line=$((_marker_line - 1))
            _prev_content=$(sed -n "${_prev_line}p" "$HANDOFF_FILE")
            [ "$_prev_content" = "---" ] && _marker_line=$_prev_line
        fi
        head -n $((_marker_line - 1)) "$HANDOFF_FILE" > "$HANDOFF_FILE.tmp"
        mv "$HANDOFF_FILE.tmp" "$HANDOFF_FILE"
    fi
    # 新しい snapshot を追記
    {
        echo ""
        echo "---"
        echo "<!-- pre-compact-snapshot -->"
        echo "## Pre-Compaction Snapshot (auto-generated $(date '+%Y-%m-%d %H:%M'))"
        echo ""
        echo "### Recent Commits"
        git -C "$PROJECT_DIR" --no-pager log --oneline -10 2>/dev/null | sed 's/^/- /' || true
        echo ""
        if [ -f "${SPEC_DIR}/TODO.md" ]; then
            echo "### Pending TODOs"
            grep '^\- \[ \]' "${SPEC_DIR}/TODO.md" | head -20 | sed 's/^/  /' || true
            echo ""
        fi
        echo "**Note**: Run /dumpmem to replace this with Claude-authored context."
    } >> "$HANDOFF_FILE" || true
fi

# REPOS 内の dirty repos もコミット（sandbox で REPOS= 指定時のみ）
if [ -n "${SANDBOX_REPOS_DIR:-}" ] && [ -d "$SANDBOX_REPOS_DIR" ]; then
    for repo in "$SANDBOX_REPOS_DIR"/*/; do
        [ -d "$repo/.git" ] || continue
        cd "$repo"
        git add -u  # 追跡済みファイルのみ（新規ファイルは skill 経由で Claude がレビューして commit）
        git diff --cached --quiet || git commit -m "checkpoint: pre-compact auto-commit" || true
    done
fi

# Re-inject enforcement rules (survives compaction)
cat << 'ENFORCE'
[session:enforcement]
MANDATORY — 以下は全セッションで遵守する義務:
1. 非自明なタスクでは必ず extended thinking (megathink) を使用すること
2. 実装コードを書く前に必ずテストを先に書くこと（TDD: RED → GREEN → REFACTOR）
3. 非自明な機能実装の前に .spec/TODO.md を確認し、人間の承認を得ること（SDD）
違反はユーザーの時間を浪費する。
[/session:enforcement]
ENFORCE

echo "[PreCompact] git commit + HANDOFF snapshot + enforcement re-injection done."
echo ""
echo "================================================================"
echo "STOP. Run /dumpmem NOW before compaction erases this context."
echo "================================================================"
