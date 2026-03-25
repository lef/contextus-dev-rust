# CS-MD — Contextus Structured Markdown

> L0: applies to all projects using contextus. Agent-agnostic.
> L0: contextus を使う全プロジェクトに適用。エージェント非依存。

## Purpose # 目的

CS-MD is the common language between agents and humans.
CS-MD はエージェントと人間の共通言語。

Markdown is the protocol. No new format is invented.
Markdown がプロトコル。新しいフォーマットは発明しない。

Design principles:
- grep/awk で section 抽出可能。特殊パーサー不要
- Postel's Law: 未知のフィールドは無視する、拒否しない
- MUST fields は最小限。拡張は MAY で自由に追加
- 他ツール（Spec Kit, GSD, OpenSpec）とコンフリクトしない（検証済み）

## Document Structure # 文書構造

```markdown
---
Type: HANDOFF                    ← YAML frontmatter: header fields
Updated: 2026-03-21              ← ISO 8601
---

# Title                          ← H1: 文書名（1 つだけ）

## Section Name                  ← H2: 固定名 section（type が定義）
### Subsection                   ← H3 以下: 自由
- item                           ← list: 項目
- [ ] task                       ← checkbox: タスク
- key: value                     ← inline metadata
```

## Header Fields # ヘッダーフィールド

YAML frontmatter（`---` で囲んだ `Key: Value` ブロック、ファイル先頭）で記述する。

**旧形式**: 2026-03-23 以前は `> Key: Value`（blockquote）を使用していた。
旧形式のファイルを見つけたら YAML frontmatter に変換すること（フィールド名・値は同一）。

### MUST Fields

全 CS-MD 文書に必須。パーサーはこれらに依存してよい。

| Field | Format | Description |
|---|---|---|
| Type | enum | 文書種別 |
| Updated | ISO 8601 (`YYYY-MM-DD` or `YYYY-MM-DDTHH:MM`) | 最終更新日時 |

### MAY Fields

あってもなくても文書は valid。後から自由に追加可能（Postel's Law）。

| Field | Format | Description |
|---|---|---|
| Version | SemVer `X.Y.Z` | 文書バージョン。Major = section 構造変更（breaking）、Minor = section 追加、Patch = 内容更新 |
| Provenance | `layer/repo` or chain `L3/x → L2/y → L0/z` | 来歴 |
| Status | enum: `draft`, `discussion`, `in_progress`, `confirmed`, `archived` | ライフサイクル状態 |
| Tags | comma-separated: `decision, security, fetch-mcp` | 分類・検索用 |
| Context | reference to MINUTES or discussion | 議論経緯への参照 |
| Description | 1 行の要約 | INDEX 生成、検索用 |

### Header Compatibility # ヘッダー互換性

**Postel's Law (RFC 761)**: 送るものは厳格に、受け取るものは寛容に。

- MUST fields のみパーサーが依存してよい
- MAY fields はあってもなくても動く
- **未知の field は無視する**（拒否しない）
- 新しい field の追加は breaking change ではない
- パーサーは未知の field でエラーにしてはならない

## Document Types # 文書種別

### 役割による分類

```
Constraints:   CONSTITUTION          — 絶対制約（normative）
Deliverables:  PLAN → SPEC → TODO → TASK  — 成果物（Structured Flow 本流）
References:    DRAFT ↔ KNOWLEDGE     — 参考情報（informative、対になる）
State:         HANDOFF               — session 状態（ephemeral）
```

### Type 一覧と必須 section

| Type | 役割 | MUST section | ファイル配置 |
|---|---|---|---|
| HANDOFF | session state | ## Task, ## Context | project root |
| TODO | backlog | phase/category ごとの ## | $FLOW_DIR/ |
| TASK | 実行単位 | ## Goal, ## Context | $FLOW_DIR/tasks/ |
| PLAN | 意図 | 自由形式 | $FLOW_DIR/ |
| SPEC / DESIGN | 構造化文書 | L2 が定義 | $FLOW_DIR/ |
| KNOWLEDGE | 決定・検証済み | topic ごとの ## | $FLOW_DIR/ |
| DRAFT | 探索・議論中 | ## 問題, ## 未解決 | $FLOW_DIR/ |
| CONSTITUTION | 絶対制約 | ## Inherited Principles | $FLOW_DIR/ |

### DRAFT ↔ KNOWLEDGE の対称性

- DRAFT: 未決定、仮説、探索中。`[NEEDS CLARIFICATION]` が残ってよい
- KNOWLEDGE: 決定済み、検証済み。evidence あり
- DRAFT が解決 → KNOWLEDGE に移動。KNOWLEDGE から新疑問 → DRAFT に戻る

### TODO と TASK の分離

- TODO = backlog（Structured Flow の Tasks ステップ出力、計画レベル）
- TASK = 実行単位（agent に渡す具体的作業指示、実行レベル）
- orchestrator が TODO から選択 → TASK を生成 → agent に渡す

## References # 参照

### 構文

**標準 markdown link を使う。新しい構文を発明しない。**

```markdown
内部参照: [FG-PAT セットアップ](fg-pat-setup.md#設計決定)
外部参照: [Rob Pike's Rules](https://users.ece.utexas.edu/~adnan/pike.html)
```

- 内部参照: `[text](relative/path.md#heading)` — git が rename を追跡
- 外部参照: `[text](https://...)` — permalink

### 双方向参照

INDEX.jsonl の `refs_out` + `refs_in` で逆引き可能。
文書自体に双方向リンクを書く必要はない（INDEX が導出する）。

### [NEEDS CLARIFICATION] マーカー

未解決の曖昧さを示す inline marker。

```markdown
## Data Model
- Permission model [NEEDS CLARIFICATION: RBAC vs ACL undecided]
```

- SPEC/DESIGN: 確認前に全マーカーを解消すること
- DRAFT: 残ってよい（探索中の文書）
- KNOWLEDGE: 残ってはならない（決定済みの文書）

## KNOWLEDGE Management # ナレッジ管理

### 3 分類

| 分類 | いつ発生 | 安定度 | archive 戦略 |
|---|---|---|---|
| Decision | Structure 段階 | 高（ADR 的） | そのまま archive |
| Finding | Execute 段階 | 低（陳腐化する） | 要 validity check |
| Lesson | Record 段階 | 高（転用可能） | L0/L2 昇格候補 |

Tags で分類: `Tags: decision, security` / `Tags: finding, fetch-mcp` / `Tags: lesson, apt`

### INDEX.jsonl

KNOWLEDGE の検索・graph 構造を提供する **導出された cache**。

```jsonl
{"id":"gh-oauth-fallback","file":"gh-oauth-fallback.md","title":"gh OAuth fallback 削除","tags":["decision","security"],"provenance":"tutus/master","context":"MINUTES:2026-03-21#gh認証","refs_out":["fg-pat-setup"],"refs_in":["enforcement-design"],"updated":"2026-03-21","status":"active"}
```

- source of truth は各 .md ファイル。INDEX は cache
- `refs_out`: この文書が参照するもの
- `refs_in`: この文書を参照するもの（逆引きで生成）
- 壊れても再生成可能（`make index`）

### MINUTES との関係

- MINUTES = 生の議論（対話、時系列）
- KNOWLEDGE = 蒸留された結果（構造化、concise）
- Context field で MINUTES を参照（WHY を深掘りするとき辿る）

## Registry # レジストリ

`registry.jsonl` が CS-MD の trust anchor（IANA Registry に相当）。

- 全 header field 名、section 名、marker の正規定義
- MUST / SHOULD / MAY レベル
- `registered_by` で誰が追加したか（L0 / L2 / L3）
- L2/L3 が domain-specific field を追加できる（拡張可能）

### 2 つの名前空間 # Two Namespaces

Registry は header field と inline marker を別の名前空間で管理する。
The registry manages header fields and inline markers as separate namespaces.

| 種類 | 場所 | 粒度 | 例 | registry 区分 |
|------|------|------|-----|---------------|
| **Header field** | `> Key: value` | 文書全体 | `> Status: stable` | `kind: "header"` |
| **Inline marker** | `[MARKER]` | body 内の特定箇所 | `[NEEDS CLARIFICATION]` | `kind: "marker"` |

同じ概念でも文書レベル（header `> Status:`）と箇所レベル（marker `[STABLE]`）は別物。
Even for the same concept, document-level (header) and location-level (marker) are distinct.

### Inline Markers # インラインマーカー

| Marker | 意味 | 許可される Type | 行動規則 |
|--------|------|----------------|---------|
| `[NEEDS CLARIFICATION]` | 未解決の曖昧さ | SPEC, DESIGN, DRAFT | SPEC/DESIGN: 確認前に全解消。DRAFT: 残ってよい |
| `[STABLE]` | 安定。archive 可能 | KNOWLEDGE | archive 判断の根拠。変更されない |
| `[ACTIVE]` | 進行中。頻繁に参照 | KNOWLEDGE, TODO | Layer 1（目次注入）に残す |
| `[DEPRECATED]` | 置き換え済み | any | archive 候補。参照先を示すこと |
| `[RECALL-REQUIRED]` | 参照必須 | KNOWLEDGE | 設計判断前に必ず Read する（enforcement trigger） |
| `[MUST]` | 必須要件 | SPEC, CONSTITUTION | RFC 2119 準拠 |
| `[MAY]` | 任意要件 | SPEC | RFC 2119 準拠 |
| `[SPECIFIED]` | SPEC から導出 | TODO, TASK | 由来の SPEC が存在する。参照先を示すこと |
| `[DIRECTED]` | 人間が直接指示 | TODO, TASK | 対話/指示から。MINUTES or 日付を示すこと |
| `[DISCOVERED]` | 作業中の発見 | TODO, TASK | KNOWLEDGE or 発見経緯を示すこと |

### 語彙発見: agent が CS-MD を理解する 3 段階 # Vocabulary Discovery

CS-MD 文書は `> Type:` で自己識別するが、マーカーの意味は文書内に含まれない。
人間は meta context（Google → spec を探す）で語彙を学ぶが、agent にはそれがない。
CS-MD documents self-identify via `> Type:` but marker semantics are external.
Humans discover specs via meta context; agents need explicit guidance.

**3 段階で解決する（段階 1 が最重要、3 は将来）:**

**段階 1: Oath（rules injection）**
この rules ファイル（structured-markdown.md）が agent に injection される。
agent はこのファイルを通じて CS-MD の語彙と行動規則を学ぶ。
**CS-MD の語彙は CONTEXTUS-REGISTRY (`registry.jsonl`) に正式定義されている。**
マーカーの意味が不明な場合は registry を Read せよ。

**段階 2: Convention（well-known path）**
Registry は常に contextus L0 リポジトリの `registry.jsonl` にある。
Provenance header (`> Provenance: contextus@main`) から L0 を辿れる。
`.contextus/layers` マニフェストに contextus L0 のパスが記録されている。

```
文書 → Provenance → L0 repo → registry.jsonl → 語彙定義
文書 → .contextus/layers → contextus path → registry.jsonl
```

**段階 3: 自己参照 header（将来、MAY field）**
外部 agent が contextus rules なしで CS-MD を読む場合の self-reference。

```yaml
# in YAML frontmatter:
Type: SPEC
Registry: contextus/registry.jsonl
```

`Registry:` field は MAY（Postel's Law で追加可能）。
contextus rules が injection されている環境では不要（段階 1 で十分）。
公開リポジトリや cross-project 参照で必要になったら追加する。

## Domain Customization # ドメインカスタマイズ

CS-MD core は L0 が定義する。L2 が domain-specific な拡張を行う。

| 項目 | L0（共通） | L2-dev | L2-kw |
|---|---|---|---|
| Flow directory | $FLOW_DIR（L2 が設定） | `.spec/` | `.design/` |
| Structure doc | SPEC or DESIGN | SPEC.md | DESIGN.md |
| Verify method | Evidence step | TDD (test-first) | evidence-first |
| MUST sections | Type ごとに定義 | L2 が追加可能 | L2 が追加可能 |

## Compatibility # 互換性

CS-MD は以下のツールとコンフリクトしない（2026-03-21 検証済み）:

| Tool | metadata 形式 | 共存 |
|---|---|---|
| Spec Kit (GitHub) | `**Key**: value` inline | ✅ |
| GSD | YAML frontmatter + XML tags | ✅ |
| OpenSpec | heading patterns `### Requirement:` | ✅ |
| AGENTS.md (AAIF) | free-form | ✅ |

「両方あったら両方読む」。ディレクトリ名を合わせない。
