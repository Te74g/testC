---
title: "Dream と memory 圧縮"
free: false
---

# Dream と memory 圧縮

memory は役に立つが、放っておくと確実に膨らむ。Northbridge では `ACTIVE_CONTEXT.md` と `DURABLE_MEMORY.md` を使ってきたが、実際に oversized となり runtime 問題になった。

- `ACTIVE_CONTEXT.md: 331 lines / 27084 bytes`
- `DURABLE_MEMORY.md: 414 lines / 51205 bytes`

そこで入れたのが Northbridge Dream だ。Dream は万能の記憶整理AIではなく、最近の評価結果や inbox や memory 肥大を見て、何を残し何を削るべきかを advisory report として出す。

`.codex/src/memdir` の設計を参考に、Northbridge でも `200 lines / 25 KB` の目安を持ち、archive を切ってから compact するようにした。memory 肥大は cosmetic ではなく runtime 問題だ、というのがここでの教訓だ。
