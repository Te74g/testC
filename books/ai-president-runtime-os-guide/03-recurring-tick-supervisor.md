---
title: "Recurring Tick Supervisor"
free: true
---

# Recurring Tick Supervisor

長時間動く detached process は、見た目より信用できない。PID が残っていることと、仕事が進んでいることは別だからだ。実際に問題になるのは、status は running なのに `last_cycle_at` が古いまま止まっている状態だ。

Northbridge ではここを避けるために、長寿命 process 依存をやめて、Task Scheduler による recurring tick 方式へ寄せた。

- 一回の cycle は bounded に終える
- 次回実行は scheduler が起こす
- overlap は lock で防ぐ

この方式により、永遠に寝続ける一つの PowerShell へ生命を預けなくて済む。見るべき status も `running` の一語ではなく、`cycle_count`、`last_cycle_at`、`current_cycle_started_at`、`last_progress_at` になる。

AI社長組織を止めないとは、まず supervisor を信用しすぎないことから始まる。
