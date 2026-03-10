# contextus-rust-dev

Rust development profile for [contextus](https://github.com/lef/contextus) (L2).

Provides Rust-specific coding conventions to be merged with a contextus L1 layer.

## Installation

```bash
# With contextus (L0) + contextus-claude (L1):
git clone --depth=1 https://github.com/lef/contextus . && rm -rf .git
git clone --depth=1 https://github.com/lef/contextus-claude .claude && rm -rf .claude/.git
git clone --depth=1 https://github.com/lef/contextus-rust-dev .claude/rules/rust && rm -rf .claude/rules/rust/.git
```

## What's Inside

| Path | Purpose |
|---|---|
| `rules/rust-style.md` | Rust coding conventions |

## Layer Position

```
L0: contextus           ← upstream
L1: contextus-claude    ← Claude Code layer
L2: contextus-rust-dev  ← this repo (Rust dev conventions)
```

## Key Principles

- Language-neutral where possible; Rust-specific where necessary
- Minimal dependencies: rules are plain markdown
