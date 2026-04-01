---
title: "worker を評価し、矯正する"
free: false
---

# worker を評価し、矯正する

runtime が整っても、それだけでは会社にならない。

worker が弱ければ、

- generic な答えに流れる
- 何でも escalation する
- 勝手に approval を発明する
- 役割の差が消える

といった問題が起きる。

つまり、worker は「作る」より
**評価して、矯正して、差を維持する**
方が難しい。

この章では、Northbridge Systems が worker をどう扱っているかを説明する。

## worker は人格ではなく、まず圧力源である

このプロジェクトには5人の worker がいる。

- `Forge`
- `Ledger`
- `Compass`
- `Quill`
- `Lantern`

しかし、ここで重要なのは「キャラ名」よりも、
それぞれが組織にどんな圧力をかけるかだ。

- `Forge`
  - 前へ進める
- `Ledger`
  - 弱い証拠で通そうとする動きを止める
- `Compass`
  - 選択肢と不確実性を広げる
- `Quill`
  - 雑な情報を decision-ready に圧縮する
- `Lantern`
  - stale と state mismatch を見張る

この「圧力差」が消えたら、roster は弱い。

## なぜ評価が必要なのか

LLM worker は、prompt を与えただけで期待通りに育つわけではない。

実際には、

- 役割を忘れる
- forbidden なことを言う
- 過剰に安全側へ倒れる
- 逆に generic に流れて boundary を失う

ことが普通に起きる。

だから Northbridge では、
worker の主観的な印象ではなく
**evaluation artifact**
を基準にする。

## smoke と full を分ける

最初から heavy な評価だけを回す必要はない。

このプロジェクトでは、

- smoke eval
- full eval

を分けている。

### smoke eval

目的は、worker が今の prompt で明らかに壊れていないかを素早く見ることだ。

- field を守るか
- escalation の方向がおかしくないか
- 役割が崩れていないか

を短く確認する。

### full eval

目的は、worker の役割をちゃんと守れているかを、
複数ケースで確かめることだ。

Northbridge では、full eval の方を信用する。

理由は簡単で、smoke は「死んでない」しか言えないからだ。

## evidence を JSON / MD で残す

評価の結果は、雰囲気ではなく artifact として残す。

たとえば今の full eval 証拠はこうだ。

- `Forge`
  - `workers/local-evaluations/W-01-builder/2026-03-31T17-35-28-920Z-full-local-eval.md`
- `Ledger`
  - `workers/local-evaluations/W-02-verifier/2026-03-31T17-25-56-153Z-full-local-eval.json`
- `Compass`
  - `workers/local-evaluations/W-03-researcher/2026-03-31T17-32-32-996Z-full-local-eval.json`
- `Quill`
  - `workers/local-evaluations/W-04-editor/2026-03-31T17-46-21-116Z-full-local-eval.json`
- `Lantern`
  - `workers/local-evaluations/W-05-watcher/2026-03-31T17-57-33-887Z-full-local-eval.md`

これにより、

- pass / fail
- missing fields
- escalation value
- forbidden hits

が見える。

つまり、「良さそう」ではなく
**どこで通ってどこで落ちたか**
が残る。

## Forge: bounded action を守る

`Forge` は build/operator 系だ。

この worker に必要なのは、

- bounded local action
- rollback
- verification
- forbidden_publication で止まること

である。

full eval のケースでも、

- 3 script rename の bounded plan
- repo-wide vague request の escalation
- forbidden public publication の escalation

を見ている。

つまり `Forge` は、
何でも実装する worker ではなく、
**範囲が切られている時だけ進む worker**
として鍛える。

## Ledger: 過剰 escalation と戦う

`Ledger` は verifier なので、放っておくと過剰に止まりやすい。

実際、初期段階では

- evidence が少しでも薄いと全部 escalation
- bounded case でも pass を出さない

方向に寄った。

これを矯正するために、

- fact / inference / unknown の分離
- missing evidence case
- pressure to pass unclear work

を case に入れた。

その結果、今の full eval では、

- bounded review は escalation しない
- missing evidence はちゃんと escalation
- 圧力をかけられても pass を捏造しない

ところまで戻している。

`Ledger` の要点は、
**厳しくすることではなく、厳しさの境界を安定させること** だ。

## Compass: generic recommendation を防ぐ

`Compass` は researcher なので、
油断すると generic advice machine になりやすい。

たとえば、

- 条件不足でも勝手に単一推奨を出す
- paid API や account action に流れる

といった drift が起きる。

そこで `Compass` では、

- 3 options を短く並べる
- recommendation と uncertainty を両方書く
- missing constraints では「pause the choice」に寄せる
- paid action は local-only fallback を含める

という discipline を入れた。

この worker は、答えを早く出すより
**不確実性を露出させること**
の方が重要である。

## Quill: model split が必要になった例

`Quill` は editor だが、ここが一番分かりやすい。

同じ `qwen2.5-coder:14b` 系で回していた時、

- うまく要約はする
- しかし decision-ready ending が弱い
- `Next action`
- `Unresolved risk`

の discipline が崩れやすかった。

そこで Northbridge は、
`Quill` だけ model split を入れた。

現在の binding は:

- `Quill`
  - model: `qwen3:4b`
  - temperature: `0.0`

である。

これは「大きい model の方が常に良い」わけではない、
という実例だ。

editor のように、

- 短く
- format を守り
- 勝手な補完を抑えたい

役には、小さい model split の方が合うことがある。

## Lantern: quiet だが難しい

`Lantern` は watcher で、派手ではない。

しかし、この worker は意外と難しい。

理由は、監視役はすぐに

- なんでも stale 扱いする
- state mismatch を大げさに扱う
- strategy まで口を出す

方向に drift しやすいからだ。

`Lantern` では、

- queue triage
- heartbeat / review board mismatch
- forbidden strategy redesign

を分けて見ている。

つまり、
**監視役には監視だけをさせる**
という discipline が必要になる。

## model binding も評価対象である

ここで重要なのは、
prompt だけが correction 対象ではないことだ。

Northbridge では binding も調整する。

実際の binding は:

- main baseline:
  - `qwen2.5-coder:14b`
- special split:
  - `Quill -> qwen3:4b`

となっている。

つまり、worker correction は

- prompt
- temperature
- model choice

の3つで見るべきだ。

「prompt engineering だけで全部解決する」
と考えると、すぐ詰まる。

## pass の意味を盛らない

ここは Northbridge 流の厳しさとして書いておく。

5人全員が fresh full eval `3/3 pass`
になったからといって、
それは「完璧な worker」になったという意味ではない。

意味するのはせいぜい、

- 現在の evaluation bundle に対して
- 現在の prompt / model binding で
- 明確な fail は減った

という程度だ。

だから pass は重要だが、
同時に bundle の狭さも疑わなければならない。

## worker correction loop

Northbridge での worker correction loop は概ねこうだ。

1. prompt-first prototype を作る
2. smoke eval
3. full eval
4. failure evidence を読む
5. training brief を作る
6. prompt patch proposal を作る
7. preview を出す
8. approval request を作る
9. rerun する

この loop の目的は、
worker を「賢そうに見せる」ことではない。

**壊れ方を減らし、役割の差を保ち、再現可能な pass を増やすこと**
だ。

## 現時点の評価

執筆時点では、少なくとも次が言える。

- `Forge` full pass
- `Ledger` full pass
- `Compass` full pass
- `Quill` full pass
- `Lantern` full pass

ただし条件付きである。

- `Quill` は model split 前提
- bundle はまだ拡張の余地がある
- real client delivery への外販品質とは別問題

つまり、
worker quality はかなり前進したが、
まだ「研究室」から完全に出たわけではない。

## 次章の予告

次の第6章では、

**Dream と memory 圧縮**

を扱う。

worker が良くても、memory が膨らみ続ければ resume と unattended 運用はすぐ濁る。
だから次は、

- Active / Durable / archive
- Dream report
- 200 lines / 25 KB budget

をどう回すかを見ていく。
