# TODO

## Rules レビュー（2026-03 AI生成 → 人間レビュー必須）

以下のファイルは調査エージェントが生成したもの。内容の正確性・適切性を後でレビューする。

- [ ] workspace.md — ワークスペース構成ガイドのレビュー
- [ ] dependencies.md — 依存管理・セキュリティのレビュー
- [ ] async-patterns.md — tokio パターンのレビュー
- [ ] features.md — feature flags ガイドのレビュー
- [ ] ci-checks.md — CI/CD フローのレビュー
- [ ] profiling.md — プロファイリングガイドのレビュー
- [ ] fuzzing.md — ファジングガイドのレビュー

## Dogfooding フィードバック（ductus プロジェクトより、2026-03）

- [ ] **rust-style.md の重複問題**: contextus-claude (L1) にも `rust-style.md` が存在しうる。L2 がどう上書き・置換するかの指針を `README.md` か `setup.sh` で明確化すべき
- [ ] **testing.md の統合テストサンプル追加**: `tests/` ディレクトリでの port-0 spawn パターン（tokio proxy テスト）のボイラープレート例があると実用的
- [ ] **ai-agent-rust.md と testing.md の TDD 記述が重複**: どちらが canonical か整理が必要（参照関係にするか統合するか）
- [ ] **setup.sh との連携**: L2 インストール時に `rules/rust/` サブディレクトリへの配置を想定した構造にする（現在は `rules/*.md` フラットで、インストール先のディレクトリ構成が未定義）
