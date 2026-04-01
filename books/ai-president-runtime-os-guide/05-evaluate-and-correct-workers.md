---
title: "worker を評価し、矯正する"
free: false
---

# worker を評価し、矯正する

worker roster は会社の見た目を整えるが、それだけでは役に立たない。重要なのは、各 worker が何を守るのか、どう失敗するのか、失敗した時にどう矯正するのかを evidence 付きで把握することだ。

Northbridge では評価を少なくとも二段に分けた。

- smoke
- full

smoke は回帰検知、full は性格と境界の崩れ方を見る。実際に Ledger は過剰 escalation、Compass は generic recommendation、Quill は next action の弱さ、Lantern は監視役の過剰 escalation で失敗した。

矯正は prompt 修正だけではない。Northbridge では Quill を `qwen2.5-coder:14b` から `qwen3:4b` に split した。つまり見るべきは次の三段だ。

1. prompt
2. evaluation case
3. model binding

pass は「問題なし」の証明ではない。今見ているケースに対して、少なくとも壊れにくくなったという程度の意味しか持たない。
