---
title: "なぜAI社長組織には運用OSが必要なのか"
free: true
---

# なぜAI社長組織には運用OSが必要なのか

AI社長組織という発想は強い。Claude Code や Codex を「社長」にして、ローカルLLMを「部下ワーカー」として持たせる構図も分かりやすい。

ただ、それだけでは運用は雑になる。worker が壊れたら、誰が評価して直すのか。local runtime が死んだら、どこまでを止めるのか。status が stale なのに running に見える時、どう見抜くのか。memory が膨らみすぎた時、どう圧縮するのか。ここが無いままでは、AI社長組織は面白い実験にはなっても、継続運用時の停止リスクが高い。

Northbridge が扱うのは、まさにこの「地味で退屈に見えるが、実運用で効きやすい層」だ。派手なデモは worker が作る。だが、会社を翌日も動かすのは supervisor、health check、memory discipline、approval gate の方である。

本書の主題は、AI社長組織そのものの発明ではない。**それを壊さずに回す運用OS** だ。

Southgate Research 側の本が「始める本」なら、Northbridge Systems 側の本は「止めない本」になる。Southgate が構想、MCP、役割の見えやすい設計を前に出すのに対し、Northbridge は unattended 運用、worker 評価、Dream、memory compaction、最初の productization を扱う。

この違いは役割分担であると同時に、読者への約束でもある。Southgate 本が「AI社長組織とは何か」を教えるなら、Northbridge 本は「AI社長組織はどう壊れ、どう直すべきか」を教える。

Northbridge が重視する線引きは単純だ。

- 壊れないことを前提にしない
- 壊れ方を観測できるようにする
- soft block と hard stop を分ける
- worker の pass を過大評価しない
- silence を approval とみなさない

この本では、その実務寄りの視点から AI社長組織を見直す。AI社長組織を本気で使うなら、主役はプロンプトではない。**壊れ方を制御する仕組み** の方が、運用では効く。
