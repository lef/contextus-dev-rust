---
name: save-laius-session
description: End-of-session workflow — archive JSONL, close MINUTES, update HANDOFF, sync repos. Use when the user says "おわり", "session close", "セッション終了", or before exiting.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

Complete session close procedure. **dumpmem のスーパーセット** — dumpmem の全ステップ + JSONL archive。

## Steps

### 1. git add -A && commit（作業ファイルをまず保存）

```bash
cd "$CLAUDE_PROJECT_DIR"
git add -A
git diff --cached --quiet || git commit -m "checkpoint: session-close auto-commit"
```

REPOS 内の dirty repos もコミット（sandbox で REPOS= 指定時のみ）:

```bash
if [ -n "${SANDBOX_REPOS_DIR:-}" ] && [ -d "$SANDBOX_REPOS_DIR" ]; then
    for repo in "$SANDBOX_REPOS_DIR"/*/; do
        [ -d "$repo/.git" ] || continue
        cd "$repo"
        git status --short
    done
fi
```

各 dirty repo について変更内容をレビューし、意味のあるメッセージで commit。
`.claude/settings.local.json` 等のセンシティブなファイルは commit しない。

### 2. JSONL Archive（会話ログ保全）

JSONL 会話ログを sessions-archive repo にコピーする。
フォーマット変更や Claude Code の GC で消える前に保全する。

```bash
ARCHIVE_DIR="$HOME/repos/sessions-archive"
if [ -d "$ARCHIVE_DIR/.git" ]; then
    _new=0 _updated=0
    while IFS= read -r f; do
        slug=$(echo "$f" | sed "s|$HOME/.claude/projects/||")
        dst="$ARCHIVE_DIR/$slug"
        if [ ! -f "$dst" ]; then
            mkdir -p "$(dirname "$dst")"
            cp "$f" "$dst"
            _new=$((_new + 1))
        elif [ "$f" -nt "$dst" ]; then
            cp "$f" "$dst"
            _updated=$((_updated + 1))
        fi
    done < <(find "$HOME/.claude/projects/" -name "*.jsonl" 2>/dev/null)
    echo "JSONL archive: new=$_new updated=$_updated"

    cd "$ARCHIVE_DIR"
    git add -A
    git diff --cached --quiet || \
        git commit -m "chore: archive JSONL sessions ($(date '+%Y-%m-%d'))"
else
    echo "warning: sessions-archive repo not found at $ARCHIVE_DIR" >&2
    echo "  JSONL archive skipped. Create the repo or adjust ARCHIVE_DIR." >&2
fi
```

### 3. KNOWLEDGE.md 更新

今セッションで発見した技術的事実・設計判断を `.spec/KNOWLEDGE.md` に追記する。
- 新しく分かったこと（ライブラリの挙動、制約、etc.）
- 却下したアプローチとその理由
- 非自明な決定の根拠

**追記する前に、同じトピックの既存エントリを確認し、矛盾・古い記述があれば修正する。**

### 4. MINUTES.md 締め（議事録の閉じ）

`.spec/MINUTES.md` の今日のセッションを閉じる:
- 開いている議題に「継続中」または結論を記録
- 議題がなければ、このセッションの主要な話題を 1-3 行で追記
- セッションの終了時刻を記録

### 5. TODO.md 更新

`.spec/TODO.md` を更新する:
- 今セッションで完了したタスクに `[x]` をつける
- 今セッションで**発見した新しい将来タスク**を追記する

### 6. memory/ 更新（必要があれば）

`~/.claude/projects/$(pwd | sed 's|/|-|g')/memory/` に記録すべきものがあれば書く:
- **user**: ユーザーの役割・好み・知識レベルに関する発見
- **feedback**: 行動修正につながる指摘
- **project**: プロジェクトの状況・目標・制約の変化
- **reference**: 外部システムへのポインタ

### 7. DESIGN / PLAN 更新チェック

- [ ] **DESIGN-*.md**: アーキテクチャに影響する変更があったか？ → 更新
- [ ] **PLAN.md**: Phase の進捗に変化があったか？ → 更新

### 8. HANDOFF.md 更新 + commit

`/handoff` スキルと同じ手順で HANDOFF.md を更新してコミットする。

### 9. trace.log 確認（任意）

```bash
cat ~/.claude/sessions/$(date '+%Y-%m-%d')-trace.log 2>/dev/null | tail -20
```

### 10. 全 repos 同期

`/sync-repos` の手順を実行する。全リポジトリが ahead=0 dirty=0 であることを確認。

**sessions-archive は push しない**（local-only repo — 生データにセンシティブ情報あり）。

## Notes

- **save-laius-session = dumpmem + JSONL archive**。dumpmem は中間保存、これは完全終了
- JSONL archive は sessions-archive repo が存在する場合のみ実行
- sessions-archive は local-only — **絶対に push しない**（生の会話ログは機密）
- PreCompact hook からも JSONL archive を呼べるようにする（将来）
