---
title: "Northbridge Systems の全体像"
free: true
---

# Northbridge Systems の全体像

前章では、AI社長組織に「運用OS」が必要だと述べた。

この章では、その運用OSを実際に担う `Northbridge Systems` が、
このプロジェクトの中で何を持ち、何を持たないのかを整理する。

ここを曖昧にすると、AI社長組織はすぐ壊れる。

- 研究と実装が混ざる
- worker の責任境界がぼやける
- 失敗時の止め方が曖昧になる
- スポンサー承認を飛ばしたくなる

だからまず、構造を固定する。

## スポンサー、Northbridge、Southgate の三層

このプロジェクトは、単なる「AIが何人かいる」状態ではない。

最上位にはスポンサーがいる。

- スポンサー
  - 人間
  - 資本提供者
  - 最終承認者

その下に、2つのAI会社がある。

- `Northbridge Systems`
  - systems
  - runtime
  - verification
  - governance
- `Southgate Research`
  - research
  - strategy
  - critique
  - synthesis

この三層構造はかなり重要だ。

Northbridge も Southgate も、スポンサーを迂回しない。
両社は提案し、準備し、運用するが、金と外部公開と不可逆操作の鍵はスポンサーが持つ。

## なぜ二社に分けるのか

一社にまとめた方が、見た目は簡単だ。

しかし実際には、その方が雑になる。

研究と実装とレビューが全部同じ社長の下にあると、
次のような drift が起きやすい。

- 調査のつもりが実装を始める
- 実装のつもりが戦略判断を勝手に確定する
- レビューのつもりが自分の都合で基準を変える

二社に分けると、会社同士で圧力が生まれる。

- `Southgate Research` は広げる
- `Northbridge Systems` は締める

この tension が、組織を少しマシにする。

## Northbridge Systems の役割

`Northbridge Systems` の仕事は、派手ではない。

主な役割は次の通りだ。

- runtime を作る
- unattended で回す
- worker の基準を決める
- worker を評価する
- 失敗を止める
- approval gate を守る
- 仕組みを商品に変える

一言で言うと、

**Northbridge は「AI組織が雑にならないようにする会社」** だ。

ここで重要なのは、Northbridge 自身も万能ではないことだ。

Northbridge は研究会社ではない。
したがって、選択肢の比較、調査、批評、意思決定の整形は Southgate に寄せる。

逆に Southgate は、runtime の長時間運転や復旧設計を主担当にしない。

## Southgate Research の役割

`Southgate Research` は、AI社長組織の思考を担当する。

役割は次の通りだ。

- options analysis
- critique
- decision framing
- briefing
- sponsor-facing synthesis

Northbridge が factory を作るなら、
Southgate はその factory に入れる判断材料を整える。

この分担があるから、
Northbridge は「雑に前進しすぎる」ことを抑えられ、
Southgate は「考えるだけで終わる」ことを抑えられる。

## 5 worker roster

現時点の worker は5人だけだ。

これは少なく見えるかもしれないが、最初はこれで十分だ。

| Worker | キャラ名 | 主担当 | 会社 |
|---|---|---|---|
| W-01 | Forge | 実装・操作 | Northbridge |
| W-02 | Ledger | 検証・レビュー | Northbridge |
| W-03 | Compass | 調査・比較 | Southgate |
| W-04 | Quill | 要約・整形 | Southgate |
| W-05 | Lantern | 継続性・監視 | shared |

重要なのは、worker が「小さな社長」ではないことだ。

worker は bounded staff であり、安い労働力であり、交換可能な部品である。
勝手に昇進せず、勝手にルールを書き換えず、勝手に外へ出ない。

## 5人が作る内部圧力

この5人は、ただ役割が違うだけではない。

それぞれが、組織に違う種類の圧力をかける。

- `Forge`
  - 前へ進める圧力
- `Ledger`
  - 弱い前進を止める圧力
- `Compass`
  - 選択肢を増やす圧力
- `Quill`
  - 決定を短く整える圧力
- `Lantern`
  - 忘却と stale を防ぐ圧力

この内部圧力があるから、組織は単なる1本の prompt ではなくなる。

## runtime の実体

Northbridge 視点で見ると、runtime の中核は次の5層だ。

### 1. relay / queue

仕事を会話から切り離して、再開可能な単位にする。

ここでは、

- queue
- command relay
- president inbox

が中核になる。

### 2. recurring tick supervisor

長生きする1プロセスを信じすぎない。

その代わり、

- 1 cycle 実行して終わる
- それを scheduler が繰り返す

という recurring tick 方式を取る。

この方式だと、プロセスが stale でも「生きているように見える」事故を減らせる。

### 3. local runtime health

worker が良くても、推論サーバが落ちていれば意味がない。

そのため、

- `ready`
- `unreachable`
- `soft block`

を分ける。

理想は「落ちない」ことではない。
**落ちた時に、どこまで止めるかが分かること** だ。

### 4. Dream / memory

memory は増えるだけだと、すぐ毒になる。

だから、

- Active
- Durable
- archive
- Dream report

を分ける。

ここで重要なのは、「全部覚える」のではなく、
**必要なものを残し、不要なものを捨てる基準を作ること** だ。

### 5. worker evaluation and correction

worker は一度作って終わりではない。

実際には、

- smoke eval
- full eval
- failure evidence
- prompt correction
- rerun

を繰り返す。

Northbridge の強みは、ここを evidence で回せる点にある。

## 実際の現在地

ここで、現時点の状態を正直に言う。

いまの Northbridge 側は、少なくとも次までは到達している。

- local runtime は `ready`
- main local model は `qwen2.5-coder:14b`
- `Quill` だけは `qwen3:4b` に split
- 5 worker 全員が fresh full eval `3/3 pass`
- recurring tick supervisor は複数 cycle を通している
- Dream と scheduler は存在する
- deterministic な `Runtime Audit Studio` が最初の商品候補として成立している

ただし、これをもって「完成した自律会社」だとは言わない。

まだ弱い点はある。

- local auto-recovery の failure-path 実証は十分ではない
- unattended runtime は改善を続けている
- freeform な technical brief generator はまだ外販品質ではない

つまり、**できている部分と、まだ怪しい部分を分けて見る** のが Northbridge 流だ。

## approval gate

この組織で最重要なのは、AIを賢く見せることではない。

**スポンサー承認を壊さないこと** だ。

いまも、次は全部スポンサー gate の向こうにある。

- spending
- subscriptions
- hardware purchase
- external publication
- production deployment
- destructive actions
- sensitive data transmission

Northbridge も Southgate も、この gate を越えない。

worker がどれだけ pass しても、外へ出す最終判断は別だ。

## だから Northbridge 本が必要になる

AI社長組織は、立ち上げるだけなら楽しい。

しかし、そこから先は地味だ。

- state file を見る
- stale を疑う
- worker を再評価する
- prompt を締める
- memory を圧縮する
- 売り物を deterministic に寄せる

この地味な部分を言語化しないと、AI社長組織は「雰囲気だけの構想」で終わる。

Northbridge 本が必要なのは、そのためだ。

## 次章の予告

次の第3章では、Northbridge の中核である

**recurring tick supervisor**

を扱う。

なぜ「長生きする1プロセス」を捨てて、短い cycle を scheduler で回す方が良いのか。
そして、どうすれば「PID はいるが仕事は止まっている」状態を減らせるのかを見ていく。
