# Knowledge Recall — 想起の義務

> L0: applies to all projects and agents.
> L0: 全プロジェクト・全エージェントに適用。

## 設計判断・実装の前に既存の記録を確認する

新しい設計判断や実装を行う前に、既存の記録と矛盾しないか確認する。
Before making design decisions or implementing, check existing records for conflicts.

## 想起の 3 層モデル

```
Layer 0: 常時注入（enforcement, HANDOFF, CONSTITUTION）
  → 無条件で読む。判断不要。

Layer 1: 目次 / INDEX（KNOWLEDGE 見出し, TODO トップレベル）
  → タスクとの関連を判断し、関連する見出しだけ Read する

Layer 2: on-demand（PLAN, MINUTES, DESIGN, archive, 他の CS-MD 文書）
  → 目次にも出ない。grep / glob / 他文書からの参照で到達
```

## 具体的な義務

1. **設計判断・実装の前に、注入された目次（Layer 1）で関連エントリを確認せよ**
   設計判断・実装の前に、注入された目次（Layer 1）を確認する
2. **関連がありそうなら Read して詳細を確認せよ**
   見出しが関連しそうなら、本文を Read して詳細を把握する
3. **目次で見つからない場合、grep で Layer 2 を探索せよ**
   目次にない情報は grep / glob で探す
4. **既存の判断と矛盾していないか確認せよ**
   新しい判断が既存の Decisions テーブルや KNOWLEDGE と矛盾しないことを確認する

## 参照が解決できないとき — 黙って無視しない

TODO・TASK・SPEC に「〇〇参照」「see 〇〇」等の参照があるが、ファイルが見つからない場合:

1. **黙って無視しない** — 参照があるのに見つからないのは異常。無視して先に進まない
2. **調べる** — `.spec/` だけでなく、upstream repos も検索する
   - `.contextus/` 配下（bootstrap で取り込まれた L0/L1/L2）
   - `~/repos/` 配下（REPOS bind mount された関連リポジトリ）
   - grep でファイル名・キーワードを広く検索
3. **聞く** — 検索しても見つからなければ人間に聞く。「〇〇参照とありますが見つかりません。どこにありますか？」

**拒否しない**（Postel's Law）: 参照が壊れていてもエラーで止まらない。
ただし**無視もしない**: 調べるか聞くかして解決を試みる。

## INDEX との関係

現在は INDEX がないため Layer 1 = `## ` 見出しの注入。
INDEX が実装されたら Layer 1 = tag-based 絞り込みに進化する。
この Oath は注入方式に依存しない — 「目次/INDEX を確認せよ」で普遍的に機能する。
