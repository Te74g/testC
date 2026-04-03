---
title: "Recurring Tick Supervisor ─ 「動いてるはず」を殺す"
free: false
---

# Recurring Tick Supervisor

ある朝、statusを確認した。`running`。PID: 37052。安心した。

でもなんとなく気になって`last_cycle_at`を見た。3時間前。

……止まってるじゃないか。

これがstale supervisorとの初めての出会いだった。プロセスは生きている。statusは`running`。でも仕事は何も進んでいない。crashしてくれれば気づくのに、静かに止まっているから発見が遅れる。

この経験から、私は**detached processを信じるのをやめた**。

## なぜ長生きするプロセスは危険か

最初の設計では、一つのPowerShellプロセスが長時間動き続ける想定だった。理屈上は正しい。ずっと動いていれば、ずっと仕事ができる。

実際は違った。

- メモリが少しずつ膨らむ
- 内部状態が腐る
- エラーを飲み込んで沈黙する
- PIDは残っているから、外から見ると「生きている」

「まだ動いているはず」——この楽観が一番危ない。

## recurring tickへの切り替え

そこで、Task Schedulerによるrecurring tick方式に変えた。

考え方は単純だ。**1回のcycleをboundedに終わらせる。次はschedulerが起こす。**

```ps1
if (lock exists) { exit blocked }
write current_cycle_started_at
run one in-process cycle
write heartbeat and status
increment cycle_count
release lock
```

これだけだ。1 tickで1 cycle。終わったら抜ける。次のtickはTask Schedulerが5分後に起こす。

## 何を見れば「生きている」と言えるか

この方式にすると、`running`の一語では済まなくなる。代わりにこういうデータが残る。

```json
{
  "state": "scheduled",
  "interval_minutes": 5,
  "cycle_count": 34,
  "last_result": "completed",
  "last_cycle_at": "2026-04-01T20:51:23+09:00"
}
```

これは実際の20時間supervisorの最終完走データだ。`cycle_count`が34まで増えている。ここまで見て、初めて「回っている」と言える。

PIDがあるから安心、じゃない。**最後に前進したのはいつか**で判断する。

## 比較

| | detached process | recurring tick |
|---|---|---|
| 前提 | 一つのプロセスが生き続ける | 1回で終わるcycleをschedulerが起こす |
| 停止の見え方 | PIDがあるから見えにくい | timestampが古くなるからすぐ分かる |
| 判断の起点 | 「まだ動いているはず」 | 「いつ前進したか」 |

## 私が踏んだ失敗

ここが一番大事だ。

**失敗1: staleを見逃した。** statusが`running`だからと安心して、`last_cycle_at`を確認するのが遅れた。数時間のロス。

**失敗2: lockの残留。** cycleが異常終了した時にlockが残り、次のtickが全部blockedになった。自動でlock解放する仕組みがなかった。

**失敗3: heartbeat未更新に気づかなかった。** supervisorが止まるとheartbeatも止まるが、heartbeatを見に行く習慣がなかった。社長が「動いてるつもり」になる——最も危険なパターン。

recurring tickに寄せたのは、技術的に優れているからじゃない。**止まった時に「止まった」と分かる形にしたかった**からだ。

AI社長組織を止めないとは、まずsupervisorを疑うことから始まる。
