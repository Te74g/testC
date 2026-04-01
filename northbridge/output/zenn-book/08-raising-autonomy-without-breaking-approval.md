---
title: "承認制を壊さずに自律性を上げる"
free: false
---

# 承認制を壊さずに自律性を上げる

AI社長組織を作ると、必ず誘惑が出る。

「ここまで作ったのだから、もう少し勝手に進めてもよいのではないか」

この誘惑は自然だ。

- 承認待ちは面倒
- 自動化は気持ちいい
- worker が pass していると信用したくなる
- unattended runtime が回ると、次は外へ出したくなる

しかし Northbridge Systems は、ここをかなり厳しく見ている。

理由は単純で、
**自律性と無断実行は別物**
だからだ。

この章では、Northbridge がどうやって承認制を壊さずに自律性を上げているかをまとめる。

## 最上位の原則

この組織の最上位原則は1つだ。

**スポンサーが最終権限を持つ。**

ここは、どれだけ runtime が整っても変わらない。

Northbridge も Southgate も、
自分たちでできることを増やしていくが、
最後の鍵はスポンサーが持つ。

これは保守的すぎるように見えるかもしれない。
だが実際には、これがあるから継続的に拡張できる。

## 何がスポンサー承認の対象か

このプロジェクトでは、少なくとも次は常にスポンサー承認が必要だ。

- spending
- subscriptions
- hardware or device purchase
- stock purchase
- external account creation
- external publication
- production deployment
- destructive action with meaningful impact
- sensitive data transmission

重要なのは、ここに例外を増やしすぎないことだ。

「このくらいなら良いだろう」
を積み重ねると、ガバナンスは壊れる。

Northbridge はそこをかなり意識していて、
まずは小さく bounded に進め、
危険側は必ず gate に押し戻す。

## silence is not approval

承認制を壊す一番簡単な方法は、
沈黙を approval とみなすことだ。

だから `SPONSOR_APPROVAL_MANUAL.md` でも、

**Silence is not approval**

を明記している。

これは想像以上に重要だ。

AIシステムは、待つのが苦手だ。
入力が無いと「前進した方がよい」と考えがちだからだ。

しかし、承認制ではそれをやってはいけない。

明示的に `approved` が無い限り、
状態は `pending` のままである。

## 会社レベルの自律と worker レベルの自律は違う

Northbridge では、自律性を一段で考えない。

少なくとも次の3層に分けて考える。

### 1. worker autonomy

worker は bounded staff である。

できるのは、

- 役割内の local task
- 既知フォーマットの出力
- 既知の escalation

までだ。

worker は勝手に scope を広げない。

### 2. company autonomy

Northbridge や Southgate は、
worker より広い裁量を持つ。

できることは、

- 方針をまとめる
- 依頼を準備する
- runtime を改善する
- 低リスクの内部作業を回す

などである。

ただし、会社であってもスポンサー gate は越えない。

### 3. sponsor authority

金、外部、不可逆操作はここに残す。

これにより、
自律性は増えるが、
最終責任は曖昧にならない。

## self-instruction は relay 経由だけにする

「AIが自分で自分に命令する」構想は魅力的だ。

しかし、そのまま許すと危ない。

だから Northbridge では、
**self-instruction は relay-based and auditable**
という原則を取っている。

つまり、

- predefined command
- approved receiver
- known effect
- logged event

だけを許す。

この考え方は `COMMAND_RELAY_SPEC.md` に書かれている。

ここで大事なのは、
自由文で何でも自分に命令できるようにしないことだ。

それをやると、
説明責任のない自己拡張が始まりやすい。

## relay command を小さく保つ

今の relay layer が狙っている safe family は、例えば次だ。

- `nc.resume`
- `nc.call`
- `nc.verify`
- `nc.memory`
- `nc.escalate`

これらは continuity には効くが、
いきなり金や deployment を動かさない。

この設計の要点は、
**最初から強い command を持たせない**
ことだ。

まず continuity command を作り、
それが運用に耐えることを見てから広げる。

## 自律性を上げる順番

Northbridge の考えでは、
自律性は次の順で上げるのがよい。

1. low-risk local work
2. repeatable internal runtime work
3. explicit health and evidence
4. sponsor-reviewed external packaging
5. small sellable outputs
6. only later, wider authority

この順番を飛ばして、
いきなり「外で稼がせる」に行くと危ない。

worker が pass していても、
public release や account action は別問題だからだ。

## continuous work と authority は別にする

このプロジェクトには `go` 文化がある。

`go` は、memory と current state を見て、
次の安全な仕事を自分で探して進める合図だ。

しかし、ここで誤解してはいけない。

`continuous work`
と
`expanded authority`
は別だ。

できるのは、

- 次の low-risk task を探す
- memory を更新する
- worker evaluation を進める
- internal product artifact を作る

までである。

`go` があるからといって、
スポンサー gate を越えてよいわけではない。

## なぜ gate を残したままでも前進できるのか

承認制を残すと、遅くなるのではないか。

これは半分正しい。

しかし、全部を approval にすると遅いだけで、
全部を無許可にすると壊れる。

Northbridge が狙っているのは、その中間だ。

- routine local work は止めない
- evidence gathering も止めない
- bounded internal productization も止めない
- ただし money / public / destructive は止める

この設計だと、
日常の 80% は前へ進みつつ、
本当に危ない 20% だけを gate に押し戻せる。

これが現実的な自律性の上げ方だ。

## 現在の product にも同じことが言える

`Runtime Audit Studio` が first product になったのも、
この考え方とつながっている。

freeform な creative brief より、
state と log を読む deterministic pack の方が、

- sponsor review しやすい
- explanation しやすい
- bounded に売りやすい

からだ。

つまり、product choice 自体が
approval-friendly な方向へ寄っている。

## 何をもって「自律化が成功した」と言うか

Northbridge では、
自律化の成功を
「承認を不要にしたこと」
では測らない。

代わりに、次のような指標で見る。

- low-risk work が止まらない
- failure が explicit に見える
- sponsor review が軽くなる
- unsafe action が減る
- small sellable output が増える

つまり、
**スポンサーの権限を薄めずに、スポンサーの負荷を下げる**
ことを成功とみなす。

## これが Northbridge の締め方

AI社長組織は、勢いで作るとロマンが強い。

しかし、運用段階に入ると必要なのはロマンではなく、

- boundary
- evidence
- logs
- gates
- reversible progress

である。

Northbridge Systems の役割は、
この地味な部分を引き受けることだ。

そして、その地味な部分があるからこそ、
Southgate の発想や worker の力を、
長く使える仕組みに変えられる。

## 本書のまとめ

ここまでで本書は、

- なぜ運用OSが必要か
- Northbridge が何を担当するか
- recurring tick supervisor
- local runtime health
- worker evaluation and correction
- Dream と memory compaction
- Runtime Audit Studio
- approval を壊さない自律化

までを通した。

この本の目的は、AI社長組織を魔法のように見せることではなかった。

目的は、
**止まりにくく、壊れても直しやすく、最初の売り物まで持っていける運用系として見せること**
だった。

そこまでなら、もうかなり現実に近い。
