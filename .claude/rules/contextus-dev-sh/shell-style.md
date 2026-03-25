# Shell Script Style Guide

## Allowed Commands in Host Scripts # ホストスクリプトで使えるもの

Host-side scripts may ONLY use:
ホスト側スクリプトで使えるのは以下のみ:

- **Shell builtins and POSIX utilities** (bash, grep, sed, awk, cut, tr, sort, mktemp, etc.)
  シェル組み込みと POSIX ユーティリティ
- **Static binaries** with no runtime dependency (compiled, self-contained)
  ランタイム依存のない静的バイナリ

Everything else is forbidden unless the human explicitly approves for a specific use.
上記以外は全て禁止。人間が特定の用途で明示的に承認した場合のみ例外。

Not even one-liners. Not even "just for this one thing". Ask first.
ワンライナーでも、「これだけ」でもダメ。先に聞く。

Inside sandboxes or containers, any language/tool is acceptable.
sandbox やコンテナ内では何でも OK。

## Basics

- Always start scripts with `set -euo pipefail`
- Bash-specific features are allowed (this layer assumes bash)
- Always double-quote variables: `"$VAR"` (except where word splitting is intentional)

## Variables

- Constants in UPPER_CASE: `MAX_RETRIES`, `OUTPUT_DIR`
- Support environment variable overrides: `OUTPUT_DIR="${MY_OUTPUT_DIR:-/tmp/output}"`
- Local variables in lower_case: `local exit_code=$?`

## Error Handling

- Error messages to stderr: `echo "error: ..." >&2`
- Info messages with `:: ` prefix: `echo ":: starting..." >&2`
- Ensure exit codes propagate correctly

## Temporary Files

- Always use `mktemp`
- Guarantee cleanup with `trap cleanup EXIT`
- Name pattern: `/tmp/myscript-XXXXXX`

## Argument Parsing

- Define a `usage()` function
- Use `--` to separate options from operands
- Exit with error on unknown options

## File Size

- Target 200 lines per script (split if growing larger)
- Target 30 lines per function

## Comments

- Comment only non-obvious logic
- Reference design documents by section if applicable: `# See design-doc.md §3.2`
- No comments on self-evident code
