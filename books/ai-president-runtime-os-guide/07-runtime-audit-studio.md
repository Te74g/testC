---
title: "Runtime Audit Studio ─ 最初の商品は監査だった"
free: false
---

# Runtime Audit Studio

最初は派手な商品を出したかった。正直に言う。

「AIがintakeから一気にdeliverableを出す」——Technical Brief Studio。キャッチーだし、デモ映えする。実際に一度作った。

reviewerに通したら、失格だった。

- Executive Summaryがない
- Recommendationがない
- Handoff ownerがない
- verdict: `ready_for_external_send: no`

落ちた瞬間に理解した。**「それっぽいもの」を作る能力と「売っていいもの」を作る能力は違う**。ここで意地を張って出荷したら、最初の納品で信用を失う。

方針を変えた。

## なぜ監査から始めたか

今の組織が責任を持てるものは何か。考え直した。

- 入力はすでにstateとlogとして残っている
- 出力のschemaを固定しやすい
- recommendationをraw evidenceに紐付けられる
- 手作業で大幅に整えなくても再現できる

全部、**audit**の特徴だ。

派手さでは負ける。でも最初の1件を壊さずに出すには、auditの方が強い。

## 買い手が受け取るもの

Runtime Audit Studioが返すのは四つ。

1. **いま本当に動いているか**
2. **runtime problemかworker problemか**
3. **最大のcurrent riskは何か**
4. **次の一手のownerは誰か**

この四つなら責任を持って言える。

逆に、「自律的に最適化し続けます」「どんな構成でも自動で直します」——これは今は言えない。言ったら嘘になる。

## 実例

手元のrecurring tick runtime snapshotから、実際のauditはこう書ける。

```yaml
supervisor_state: scheduled
cycle_count: 8
recent_ticks:
  - cycle 8: 2026-04-01T04:12:06+09:00
  - cycle 7: 2026-04-01T04:00:30+09:00
  - cycle 6: 2026-04-01T03:47:40+09:00
local_runtime_status: ready
model_availability: true
```

**判断：**
- blocking runtime riskは現時点で見えない
- recurring tick + in-process supervisorで継続
- ただし`unreachable → ready`の実回復をまだ踏んでいない。強いresilience claimは出せない

最後の1文が大事だ。**言えることだけ言う。** claimを盛った瞬間、auditの価値が消える。

## 商品の順番

今の順番はこう設計している。

1. **Runtime Audit Studio** → 今ここ。evidence-firstの監査。
2. **Worker Patch Ops Studio** → 次。evidence-firstの改善提案。
3. **Technical Brief Studio** → reviewer gateを安定して通るまで外販化しない。
4. **automation implementation** → もっと先。

この順番にした理由は、今の組織の強みが「何でも実装すること」じゃなく、**状態を読み、障害を見つけ、改善案をboundedに出すこと**だからだ。

前著で¥1,500を売った時に学んだことがある。**最初の商品は、自分が確実に責任を持てる範囲で出す**。夢のある一発目じゃなくていい。壊さない一発目がいい。
