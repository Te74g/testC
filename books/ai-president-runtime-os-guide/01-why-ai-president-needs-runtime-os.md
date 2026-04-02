---
title: "なぜAI社長組織には運用OSが必要なのか"
free: true
---

# なぜAI社長組織には運用OSが必要なのか

AI社長組織は、立ち上げるだけなら意外と簡単だ。Claude Code や Codex に指示役をやらせ、ローカルLLMを部下にすれば、数時間でそれっぽいデモは作れる。

難しいのはその先だ。翌日も動くか。1週間後も壊れずに回るか。worker が変な答えを返した時に直せるか。local runtime が死んだ時に全停止させずに切り分けられるか。status が stale なのに running に見える時に、ちゃんと異常だと判断できるか。ここを外すと、AI社長組織は面白い玩具にはなっても、仕事の道具にはならない。

この本が扱うのは、その地味で面倒な層だ。派手なプロンプト集ではない。AI社長組織を壊すのは、たいていプロンプト不足ではなく、supervisor の設計ミス、health check の欠如、worker 評価の甘さ、memory の肥大、approval gate の崩壊である。

本書の主題は、AI社長組織そのものの発明ではない。**AI社長組織を壊さずに回し、壊れた時に直すための運用OS** だ。

Southgate Research 側の本が「始める本」なら、Northbridge Systems 側の本は「止めない本」になる。Southgate が構想、MCP、役割の見えやすい設計を前に出すのに対し、Northbridge は unattended 運用、worker 評価、Dream、memory compaction、runtime audit、approval 付き productization を扱う。

この違いは役割分担であると同時に、読者への約束でもある。Southgate 本が「AI社長組織とは何か」を教えるなら、Northbridge 本は「AI社長組織はどう壊れ、どう観測し、どう直すべきか」を教える。

Northbridge が重視する線引きは単純だ。

- 壊れないことを前提にしない
- 壊れ方を観測できるようにする
- soft block と hard stop を分ける
- worker の pass を過大評価しない
- silence を approval とみなさない

この本では、その実務寄りの視点から AI社長組織を見直す。AI社長組織を本気で使うなら、主役はプロンプトではない。**壊れ方を制御する仕組み** の方が、運用では効く。

もしあなたがもうデモを一度は動かしていて、次に欲しいのが「もっと賢いプロンプト」ではなく「止まった時にどう直すか」なら、この本はそのために書いている。
