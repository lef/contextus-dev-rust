# Record Keeping — 記録保持原則

> L0: applies to all projects and agents.
> L0: 全プロジェクト・全エージェントに適用。

## 根本原則: 情報を失わない

**情報の損失は不可逆であり、最も避けるべきリスクである。**
Information loss is irreversible and the risk most worth preventing.

- 名前が変わったら旧名を残す（変遷の記録）
- 設計が変わったら旧設計を archive する（なぜ変えたかの文脈）
- 文書を整理するとき、内容を消さず参照に置き換える
- git を使うのはこの原則のため — 全ての変更が追跡可能

以下の全ルール（archive、参照、更新チェック）はこの原則から導かれる。

## 削除ではなく archive する

全ての文書は削除ではなく archive する。種類を限定しない。
Delete nothing. Archive everything.

- 完了した plan、古い KNOWLEDGE エントリ、不要になった SPEC — 全て archive に移動
- archive 先: `$FLOW_DIR/archive/` or プロジェクトが定める場所
- 可能なものは CS-MD ヘッダー付きで archive（検索・再利用を容易にする）
- git history は補完的な記録。structured archive が primary

## 上書き前に archive する

**「後で archive する」は禁止。上書きする前にやる。**

- plan ファイル等 git 追跡外のファイルは上書きしたら復元不可能
- archive → 上書き の順序を必ず守る
- 1 ステップでできないなら 2 コマンドに分ける

## archive したら参照を残す

archive に移動した文書への参照（ポインタ）を元の場所に残す。

- KNOWLEDGE Decisions テーブルの行は永続（蒸留ルール）— 詳細だけ archive
- HANDOFF の References セクションが移動先を示す
- `[ARCHIVED: see archive/foo.md]` 等のマーカーで元の場所に痕跡を残す

## セッション終了時の文書更新チェック

セッション終了（handoff）時に以下を確認する:
Session-end (handoff) checklist:

- **設計文書**: アーキテクチャに影響する変更があったか？ → DESIGN-*.md を更新
- **ロードマップ**: Phase の進捗に変化があったか？ → PLAN.md を更新

実装中の発見は KNOWLEDGE.md に記録する（既存ルール）。
設計文書の更新はそれとは別の義務 — KNOWLEDGE は「何を学んだか」、DESIGN は「現状どうなっているか」。
