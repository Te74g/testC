---
title: "Dream と memory 圧縮"
free: false
---

# Dream と memory 圧縮

AI社長組織は、動かしているだけで記憶が増える。

- decision log
- president inbox
- worker evaluation
- pending issues
- failed attempts

これらは全部重要に見える。

しかし、全部をそのまま抱えると、
やがて system 自体の足を引っ張る。

Northbridge Systems では、これを
**memory は資産であると同時に負債でもある**
と考える。

だから `Dream` と `compaction` が必要になる。

## 記憶を2層に分ける

このプロジェクトでは、memory を最初から2層に分けている。

- `DURABLE_MEMORY.md`
  - 長期に残す意図
  - 構造
  - 失敗教訓
  - 成功教訓
- `ACTIVE_CONTEXT.md`
  - いまの目的
  - 現在の状態
  - 直近の次の一手
  - 一時的な前提

これを分ける理由は簡単だ。

全部を durable に入れるとノイズが増える。
全部を active に入れると過去が消える。

したがって、
**永続化したいものと、今だけ必要なものを分ける**
必要がある。

## それでも memory は膨らむ

2層に分けても、運用していれば結局膨らむ。

特に unattended loop を回し始めると、

- president inbox が増える
- local evaluation artifact が増える
- correction history が増える
- current objective が古い情報を抱え込む

ようになる。

実際、このプロジェクトでも一度、

- `ACTIVE_CONTEXT.md`: `331 lines / 27084 bytes`
- `DURABLE_MEMORY.md`: `414 lines / 51205 bytes`

まで膨らんだ。

この時点で、もう cosmetic な問題ではない。

resume の効率や Dream の精度に影響する
**runtime 問題**
になっていた。

## なぜ memory 問題が runtime 問題になるのか

ここは誤解されやすい。

「文書が長いだけなら、あとで読む人が大変なだけでは？」

そうではない。

AI運用では memory が直接、

- next-step selection
- Dream recommendation
- resume fidelity
- unattended reporting

に効いてくる。

つまり、
memory がノイズだらけだと、
AIの継続判断そのものが濁る。

だから Northbridge では、
memory の整理を「文章整形」ではなく
**運用維持**
として扱う。

## Dream は何をするのか

このプロジェクトの Dream は:

- `scripts/run-northbridge-dream.ps1`

で動いている。

目的は、

- recent worker evidence を見る
- president inbox signal を見る
- active / durable memory のサイズを見る
- 次に何を直すべきか提案する

ことだ。

重要なのは、Dream が
**勝手に durable memory を書き換えない**
ことだ。

Dream は recommendation packet である。

それ以上ではない。

## Dream の入力

Dream は今、主に次を読んでいる。

- `runtime/state/work-heartbeat/latest.json`
- `runtime/state/long-run-supervisor.status.json`
- `runtime/inbox/president/`
- `workers/local-evaluations/`
- `memory/ACTIVE_CONTEXT.md`
- `memory/DURABLE_MEMORY.md`

つまり、Dream は「何を考えるべきか」を、
雑な intuition ではなく
**既存の state と artifact**
から拾う。

## Trigger は毎 cycle ではない

Dream を毎 cycle 動かすのは良くない。

理由は、

- 変化が少ないのに毎回同じことを言う
- scheduler の無駄打ちになる
- memory 整理そのものが routine noise になる

からだ。

そのため現在は、

- time gate
- new-signal gate
- lock gate
- repo-local scheduler

を組み合わせている。

外側 cadence も 4時間に揃えてあり、
Dream が internal gate で skip しているのに、
5分ごとに毎回起こすような無駄は止めている。

## memdir 的 budget を使う理由

`.codex/src/memdir` を参考に、
Northbridge 側でも compact budget を持たせている。

現在の基準は:

- `200 lines`
- `25 KB`

である。

重要なのは、この数字自体の神聖さではない。

大事なのは、
**memory は無限に肥大させてよいものではない**
と明文化することだ。

制限がないと、
active context はすぐ「全部書いてあるけど読めない」状態になる。

## archive を残してから削る

compaction は削除ではあるが、
無造作にやるべきではない。

このプロジェクトでは、

- `memory/archive/2026-04-01-pre-compaction/ACTIVE_CONTEXT_FULL.md`
- `memory/archive/2026-04-01-pre-compaction/DURABLE_MEMORY_FULL.md`

を先に残してから、
本体を compact した。

その結果、現在はだいぶ軽くなっている。

一例として、

- `ACTIVE_CONTEXT.md`: 約 `100 lines / 4 KB`
- `DURABLE_MEMORY.md`: 約 `115 lines / 4.5 KB`

程度まで戻している。

これで、

- scan しやすい
- next step を選びやすい
- Dream recommendation を読みやすい

状態になった。

## 何を durable に残すか

compaction で一番重要なのは、
**何を durable に昇格させるか**
だ。

Northbridge の基準はかなり単純で、
durable に残すのは:

- enduring structure
- enduring decisions
- enduring lessons
- enduring constraints

だけに寄せる。

たとえば、

- 会社構造
- sponsor gate
- background continuity strategy
- `Runtime Audit Studio` が first product であること

は durable に残す価値がある。

逆に、

- その場の試行錯誤
- すでに終わった細かい実装順
- 一時的な迷い

は active か archive へ逃がす。

## 何を active に残すか

active は「今の execution に効くもの」だけを置く。

今の Northbridge では、例えば:

- current objective
- current true state
- product state
- workers
- runtime
- dream and scheduler
- immediate next steps
- active constraints

といった見出しで管理している。

ここでの狙いは、
**次に何をするかを1画面で把握できること**
だ。

active が過去ログ化した瞬間に、
その価値は落ちる。

## Dream report の価値

Dream の良いところは、単に memory サイズを怒るだけではない点だ。

例えば初期の report では、

- `Lantern` correction が必要
- `Quill` に next action / unresolved risk discipline が必要
- `Compass` に missing constraints 対応が必要
- `Ledger` に bounded verification の tightening が必要
- `Forge` に verification 明記が必要
- memory を prune すべき

と、worker correction と memory discipline を同じ packet にまとめていた。

これはかなり効く。

なぜなら、
Dream が「文章を短くしろ」と言うだけでなく、
**何を優先して直すべきか**
まで出しているからだ。

## Dream を権力化しない

ここはかなり重要だ。

Dream が便利になると、
何でも自動で memory を整理させたくなる。

しかし、それをやると危ない。

理由は、

- quiet rewrite が起きる
- durable intent がいつの間にか変わる
- 後から「なぜこの判断になったか」が追いにくくなる

からだ。

Northbridge の原則は明確で、

**Dream は advisory**

である。

つまり、

- recommendation は出す
- archive は残す
- durable rewrite は人間や明示的な運用手順の側で行う

に留める。

## memory discipline は bot continuity に効く

この仕組みが重要なのは、
bot continuity に直結するからだ。

`go` で次の仕事を選ぶ時、
resume する時、
president inbox を読む時、
全部が memory quality に依存する。

つまり memory が濁ると、
continuity 自体が濁る。

Northbridge で memory discipline が厳しいのは、
文書好きだからではない。

**bot を継続運転させるため**
である。

## 現時点の評価

執筆時点では、

- Dream は存在する
- report は出る
- scheduler と gate はある
- memory compaction も archive 付きで実施済み

という意味で、memory 層はかなり前進している。

ただし、まだ未完もある。

- Dream recommendation の質は今後も改善余地がある
- auto promotion / auto pruning は意図的に抑えている
- active/durable の境界は今後も運用で磨く必要がある

つまり、
ここも「完成」ではなく
**運用の中で壊さず育てる層**
である。

## 次章の予告

次の第7章では、

**Runtime Audit Studio を作る**

を扱う。

なぜ最初の売り物を、自由作文型の technical brief ではなく、
evidence-first の runtime audit pack に寄せたのか。
そして、どうやって「仕組み」を「売り物」に変えるのかを見ていく。
