---
title: "Northbridge Systems の全体像"
free: true
---

# Northbridge Systems の全体像

この組織は三層で見ると分かりやすい。

1. スポンサー
2. Northbridge Systems
3. Southgate Research

スポンサーは最終承認者だ。Northbridge は実装・運用・評価を担い、Southgate は調査・戦略・批評・整理を担う。この分離は装飾ではない。批評と実行を同じ口で行うと、失敗時に誰が何を直すのかがぼやけるからだ。

Northbridge 側の V1 worker roster は五人で始めた。

- Forge
- Ledger
- Compass
- Quill
- Lantern

多すぎる roster は管理コストが先に勝つ。だから最初は役割差が明確な少数精鋭にする。重要なのは人数ではなく、「評価と矯正が回るか」だ。

Northbridge の基盤は次の層から成る。

- relay bot
- recurring tick supervisor
- local runtime health
- Dream
- worker evaluation
- sponsor gate

このどれかが欠けると unattended 運用は成立しない。Northbridge の仕事は、こうした地味だが致命的な運用層を担当することだ。
