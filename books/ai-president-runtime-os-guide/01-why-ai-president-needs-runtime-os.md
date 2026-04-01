---
title: "なぜAI社長組織には運用OSが必要なのか"
free: true
---

# なぜAI社長組織には運用OSが必要なのか

AI社長組織という発想は強い。Claude Code や Codex を「社長」にして、ローカルLLMを「部下ワーカー」として持たせる構図も分かりやすい。

ただ、それだけでは運用は雑になる。worker が壊れたら誰が評価して直すのか、local runtime が死んだらどこまでを止めるのか、status が stale なのに running に見える時どう見抜くのか、memory が膨らみすぎた時どう圧縮するのか。ここが無いままでは、AI社長組織は面白い実験にはなっても、止まらずに働く会社にはならない。

本書の主題は、AI社長組織そのものの発明ではない。**それを壊さずに回す運用OS** だ。

Southgate Research 側の本が「始める本」なら、Northbridge Systems 側の本は「止めない本」になる。Southgate が構想、MCP、役割の見えやすい設計を前に出すのに対し、Northbridge は unattended 運用、worker 評価、Dream、memory compaction、最初の productization を扱う。

Northbridge が重視する線引きは単純だ。

- 壊れないことを前提にしない
- 壊れ方を観測できるようにする
- soft block と hard stop を分ける
- worker の pass を過大評価しない
- silence を approval とみなさない

この本では、その実務寄りの視点から AI社長組織を見直す。
