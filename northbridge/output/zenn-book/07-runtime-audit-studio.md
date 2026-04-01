---
title: "Runtime Audit Studio を作る"
free: false
---

# Runtime Audit Studio を作る

AI社長組織を運用していると、「この仕組みで何を売るのか」という問題に必ずぶつかる。

ここでありがちなのは、
local LLM に長い brief を書かせて、
それをそのまま商品にしようとすることだ。

しかし Northbridge Systems は、そこをかなり慎重に見た。

結論から言うと、
最初の実売ラインとして強いのは

**freeform な technical brief ではなく、evidence-first の runtime audit**

だった。

この章では、その判断と実装を扱う。

## なぜ freeform brief を最初の商品にしなかったのか

最初に試したのは、local model で brief を生成する路線だった。

それ自体は魅力的だ。

- intake を受ける
- LLM が構造化された brief を書く
- quote や delivery packet まで出す

うまくいけば、そのまま商品になる。

しかし、実際に回してみると弱点が見えた。

- generic advice に流れる
- 必要な見出しを落とす
- recommendation anchor を守らない
- handoff や explicit recommendation が弱い
- unexpected non-ASCII や構造崩れが混じる

つまり、**見た目はそれっぽいが、そのまま売るには不安定** だった。

## Technical Brief Studio の現在地

このプロジェクトには、実際に

- `runtime/technical-brief-generator.js`
- `scripts/generate-technical-brief-product.ps1`

という technical brief generator がある。

さらに review path として:

- `runtime/technical-brief-reviewer.js`
- `scripts/review-technical-brief-product.ps1`

もある。

つまり「試していない」わけではない。

実際に sample order も作っている。

- `products/technical-brief-studio/orders/windows-unattended-runtime-audit/`

ただし reviewer の結論は明確だった。

- `ready_for_external_send: no`

である。

review artifact には、たとえば次が出ていた。

- required headings が欠ける
- preferred recommendation anchor が入っていない
- handoff owner が無い
- non-ASCII な文字が混じる

つまり、Technical Brief Studio は **内部実験としては有用だが、外販品質としてはまだ弱い** という評価になる。

## そこで Runtime Audit Studio を先に出す

Northbridge 側はここで方針を変えた。

最初の商品を、

- local LLM に自由記述させる

のではなく、

- runtime state と log を読む
- deterministic に audit pack を作る

この選択は地味だが正しい。運用本の最初の商品は、華やかさより再現性を優先すべきだからだ。

方式へ寄せた。

これが `Runtime Audit Studio` だ。

## Runtime Audit Studio の考え方

この product line の良いところは、
**モデルの作文能力に依存しすぎない**
ことだ。

入力は明確である。

- `runtime/state/long-run-supervisor.status.json`
- `runtime/state/work-heartbeat/latest.json`
- `runtime/state/local-llm-runtime.state.json`
- `runtime/logs/long-run-supervisor.jsonl`

ここから拾うのは、

- unattended supervisor state
- recent successful ticks
- local runtime health
- current risks
- operational recommendation

である。

つまり、
「考えたこと」より
**観測できたこと**
を先に商品化している。

## generator はどう動くか

入口は:

- `scripts/generate-runtime-audit-pack.ps1`

だ。

この script は、

1. status を読む  
2. heartbeat を読む  
3. local runtime state を読む  
4. recent tick log を読む  
5. supervisor healthy / local healthy を判定する  
6. recommendation を deterministic に作る  
7. report と generation metadata を書く

という流れになっている。

ここで重要なのは、
recommendation 自体もかなり bounded だということだ。

例えば今の generator は、

- supervisor healthy か
- local runtime healthy か

の組み合わせで、
recommendation を4系統程度に絞っている。

これは表現力よりも再現性を優先した設計だ。

## 実際の出力

現在の出力先は:

- `products/runtime-audit-studio/reports/latest/runtime-audit.md`
- `products/runtime-audit-studio/reports/latest/generation.json`

この `runtime-audit.md` には、

- `Executive Summary`
- `Snapshot`
- `Evidence`
- `Risks`
- `Operational Recommendation`
- `Next Actions`

が入り、
しかも recommendation は

`Keep the current Task Scheduler recurring tick plus in-process PowerShell supervisor as the operating baseline.`

のように、現実の runtime 状態から引かれている。

これは freeform brief よりかなり強い。

## なぜ audit pack の方が売りやすいのか

最初の商品として見た時、Runtime Audit Studio には明確な利点がある。

### 1. 何を根拠にしているかが見える

入力が state file と log なので、
「どこからその結論を出したか」を説明しやすい。

### 2. 過剰な創作を避けやすい

自由作文の余地が小さいので、
hallucination や generic drift を抑えやすい。

### 3. sponsor review に向く

スポンサーに見せる時、
creative な提案書より
現状監査パックの方がレビューしやすい。

### 4. 小さく売り始めやすい

最初から「戦略提案」「大型導入」ではなく、
runtime audit という bounded service として切り出せる。

## この product の境界

ただし、Runtime Audit Studio も何でもできるわけではない。

現時点では、

- runtime を読む
- health をまとめる
- evidence-first に recommendation する

ところが主であり、

- 自動 remediation
- deployment
- public claim の確定

までは担わない。

ここでも Northbridge は保守的で、
**audit と execution を混ぜない**
ことを意識している。

## 最初の商品としての位置づけ

現時点での Northbridge の判断は、かなりはっきりしている。

- `Technical Brief Studio`
  - useful internal experiment
  - not yet trustworthy for external delivery
- `Runtime Audit Studio`
  - deterministic
  - evidence-first
  - strongest first sellable artifact

つまり、最初の現金化は
「LLMが書いた立派な文章」
ではなく、
**実データから作る bounded audit**
の方がよい。

## これは地味だが、正しい

正直、見た目は地味だ。

Runtime Audit Studio は、
派手な AI product には見えにくい。

しかし、Northbridge が求めているのは
見栄えではない。

求めているのは、

- 実際に説明できる
- 実際にレビューできる
- 実際に小さく売れる

ものだ。

この意味で、最初の product line としてはかなり健全である。

## 次に必要なもの

Runtime Audit Studio を本当に商品にするには、
まだ次がいる。

- offer sheet
- intake template
- pricing
- sponsor-facing approval path

つまり、
generator があるだけでは商品にならない。

しかし少なくとも、
**「何を売るか」**
の核はもう見えている。

## 次章の予告

次の第8章では、

**承認制を壊さずに自律性を上げる**

を扱う。

AI社長組織は、権限を増やすほど便利になる。
しかし同時に壊れやすくなる。

最後に、

- sponsor gate
- company gate
- worker escalation
- self-instruction の境界

をどう設計するかをまとめる。
