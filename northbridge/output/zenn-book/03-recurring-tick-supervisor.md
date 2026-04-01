---
title: "長時間運転を成立させる recurring tick supervisor"
free: false
---

# 長時間運転を成立させる recurring tick supervisor

AI社長組織を少し動かしてみると、かなり早い段階でぶつかる問題がある。

**「長時間動いているように見えるが、本当に動いているのか分からない」**

これは地味だが、かなり危険だ。

- PID は残っている
- status は `running` に見える
- しかし実際には新しい仕事をしていない
- memory も inbox も heartbeat も進んでいない

この状態を放置すると、「止まっているのに動いている気分」になる。運用本としては、ここを曖昧にした時点で負けだ。

Northbridge Systems では、この問題を避けるために **recurring tick supervisor** を採用した。

## なぜ長生きする1プロセスを捨てるのか

最初に思いつくのは、長生きする detached process を1本立てるやり方だ。

例えば、

- PowerShell をバックグラウンドで起動
- その中で `Start-Sleep`
- 一定間隔で loop を回す

という方式である。

見た目は簡単だが、実際には弱い。

問題は次の通りだ。

- stale になっても「まだ生きている」ように見える
- shell の継承状態や権限境界が絡む
- 子プロセスの状態が読みにくい
- 途中で落ちた時、どこから再開されたのか追いにくい
- 1本の長命プロセスを信じる設計になりやすい

Northbridge はここで発想を変えた。

**長く生きることを supervisor の責務にしない。**

代わりに、

- 1回だけ動く bounded tick を作る
- それを scheduler が繰り返す

という方式へ寄せた。

## 基本の考え方

recurring tick supervisor の考え方は単純だ。

1. scheduler が起こす
2. tick が lock を取る
3. 1 cycle だけ処理する
4. state と log を書く
5. lock を外して終わる
6. 次の tick は別プロセスとしてまた起きる

この設計だと、

- 1 cycle の境界がはっきりする
- stale の発見が楽になる
- 「仕事をした証拠」を cycle 単位で残せる
- 1本の長命プロセスを信仰しなくて済む

要するに、Northbridge は「生きているように見える process」ではなく、「仕事をした証拠が残る cycle」を信じる。

## 実際のファイル構成

このプロジェクトでの主要ファイルは次の通りだ。

- 起動:
  - `scripts/start-long-run-supervisor.ps1`
- 1 tick 実行:
  - `scripts/run-supervisor-tick.ps1`
- 状態確認:
  - `scripts/status-long-run-supervisor.ps1`
- 停止:
  - `scripts/stop-long-run-supervisor.ps1`
- state:
  - `runtime/state/long-run-supervisor.status.json`
- lock:
  - `runtime/state/long-run-supervisor.tick.lock`
- log:
  - `runtime/logs/long-run-supervisor.jsonl`

このうち本丸は `run-supervisor-tick.ps1` だ。

この script は、

- 現在の status を読む
- lock を確認する
- `continue-bot-work.ps1 -InProcess` を1回だけ回す
- heartbeat を更新する
- 結果を `ok / failed / completed` として残す

ところまでを1回でやって終わる。

## state machine を単純に保つ

この方式で重要なのは、state を増やしすぎないことだ。

今の Northbridge 側では、status file は主に次を持つ。

- `state`
- `started_at`
- `end_at`
- `interval_minutes`
- `cycle_count`
- `last_cycle_at`
- `current_cycle_started_at`
- `last_result`
- `last_progress_at`
- `last_heartbeat`

状態としては実質、

- `running`
- `scheduled`
- `completed`

が見えれば十分だ。

細かい気持ちのいい抽象状態を増やすより、
**「今 cycle 中か」「次の tick 待ちか」「時間窓が終わったか」**
が分かる方が強い。

## lock を入れる理由

recurring tick 方式では、逆に別の問題が出る。

それは overlap だ。

5分ごとに tick を起こしているのに、
1回の処理が5分以上かかったら次と重なりうる。

だから lock を入れる。

このプロジェクトでは:

- `runtime/state/long-run-supervisor.tick.lock`

を使っている。

考え方は保守的でいい。

- lock があり、しかも新しいなら skip
- lock が古すぎるなら stale とみなして除去候補

つまり、ここでも「止まらないこと」より
**壊れた時にどう見えるか** を優先している。

## Task Scheduler を使う理由

Windows 環境では、ownership を何に持たせるかが重要だ。

ここでは Task Scheduler を detached ownership に使っている。

理由は単純で、

- セッションから切り離しやすい
- 定期実行の責任を shell 自身に背負わせなくてよい
- recurring tick との相性が良い

からだ。

もちろん、Task Scheduler も万能ではない。

実際に起きた問題として、

- query access が取れない
- 現在 shell からは state が見えにくい
- `missing` と `inaccessible` を混同しやすい

があった。

だから `status-long-run-supervisor.ps1` 側で、

- `scheduled_task_lookup_result = inaccessible`
- `scheduled_task_state = inaccessible`

を明示するよう直している。

これは小さい修正に見えるが大事だ。

**存在しない** のと **見えない** のは全く違う。

## in-process batch を選んだ理由

tick の中でさらに子プロセスをたくさん生やすと、
また見えにくさが増える。

そのため、現在の unattended path は

- `continue-bot-work.ps1`
- worker roster の multi-worker batch

を、可能な限り in-process で回す設計に寄せている。

この方針の利点は、

- 1 tick の責任範囲が分かりやすい
- error serialization がしやすい
- state 更新のタイミングを揃えやすい

ことだ。

逆に、完全な高並列 executor にはまだしていない。
そこは future work であり、今は「まず見えること」を優先している。

## heartbeat を別で持つ理由

status file だけだと、まだ足りない。

理由は、status は「supervisor がどう見えているか」しか言えないからだ。

本当に知りたいのは、

- worker lab が進んだか
- local runtime は `ready` か
- eval は増えたか
- president inbox に新しい短報が来たか

である。

だから別に heartbeat を持つ。

このプロジェクトでは:

- `runtime/state/work-heartbeat/latest.json`

がその役割を持つ。

status と heartbeat を両方見ることで、
「プロセスがいる」ではなく
**「仕事が進んだ」** を判定できる。

## 実際にどう改善したか

この runtime は最初からきれいだったわけではない。

実際には、

- stale supervisor を `running` と誤認した
- `last_cycle_at` が古いままでも安心しかけた
- local runtime が死んだ時に worker loop まで巻き込んだ

といった失敗があった。

そこから、

- recurring tick 方式へ移行
- lock 導入
- status 項目の整理
- heartbeat の別管理
- local runtime を `ready / unreachable / soft block` で分離

へ進めた。

つまり、この章の設計は机上の理想ではなく、
**実際に壊れたものを直した結果** である。

## 現時点の状態

執筆時点での実態は、概ね次の通りだ。

- `interval_minutes = 5`
- `approved_parallel_worker_slots = 10`
- `current_effective_worker_lanes = 5`
- local runtime は `ready`
- supervisor state は cycle 中と idle を行き来する

この「cycle 中と scheduled が往復する」こと自体が、
長命プロセス方式との違いだ。

大事なのは「ずっと running であること」ではない。

**短い単位で仕事を終え、次の tick に責任を渡せること** が大事だ。

## この方式の限界

もちろん、この方式で全部解決するわけではない。

まだ弱い点はある。

- failure-path の auto-recovery 実証が足りない
- truly parallel な executor にはまだしていない
- scheduler access の揺れが残る
- 5 lane 以上へ広げる時は別の設計が必要になる

しかし、それでも長命 detached process を漫然と信じるよりは、
はるかに健全だ。

Northbridge が優先しているのは、

- glamorous autonomy

ではなく、

- bounded unattended reliability

である。

## 次章の予告

次の第4章では、

**local LLM runtime を死なせない**

を扱う。

worker がどれだけ優秀でも、Ollama が落ちれば会社は止まる。
だから次は、

- health check
- recovery
- soft block
- degraded operation

をどう設計するかを見ていく。
