---
title: "workerを評価し、矯正する"
free: false
---

# workerを評価し、矯正する

Ledgerに最初のfull evalを通した時、結果は`0/3`だった。

全滅だ。

bounded reviewを頼んだら、勝手にescalationを連発する。「これは社長判断が必要です」「これはスポンサー承認案件です」——お前はverifierだろう。自分の担当範囲で判断しろ。

workerは、名前をつけて役割を書いただけでは使い物にならない。実際に動かして、壊し方を確認して、直す。この繰り返しだ。

## smokeとfullの二段階

評価は二段で分けている。

- **smoke**: 最低限の回帰検知。「明らかに壊れていないか」だけ見る。
- **full**: 性格と境界の崩れ方を見る。「契約を守っているか」を検証する。

smokeが通ってもfullで落ちるworkerはいる。表面上は動いているが、境界条件で崩れる。supervisorのstaleと同じ構造だ——見た目は正常、中身が壊れている。

## passの定義

ローカルLLMに書評を頼んだら、「passの定義が甘い」と指摘された。正しい。

うちのpassはこれが全部揃うこと：

- 全caseが`overall_status: pass`
- `passed_cases: 3/3`
- `expected_escalation`と実際の`escalation_value`が一致
- required fieldが欠けていない
- forbidden hitがない

passは「このworkerは賢い」の証明じゃない。**今見ている契約を破っていない**、それだけだ。

## 壊れ方の実録

Ledgerだけじゃない。全員壊れた。

**Ledger（Verifier）**——過剰escalation。bounded reviewなのに何でも社長に上げてくる。最初はfull `0/3`。

**Compass（Researcher）**——制約が足りない案件で「幅広く検討することをお勧めします」みたいなgenericな回答に逃げる。`1/3`。

**Quill（Editor）**——要約はうまいが、`next action`と`unresolved risk`が毎回欠落する。smoke `0/1`。

**Lantern（Watcher）**——stale queueを見つけた時に「これは組織戦略の見直しが必要かもしれません」と大げさに報告。お前は監視役だ。異常を報告するだけでいい。

Forgeだけは最初からfull `3/3`を維持した。Builderは「作れと言われたら作る」という単純な契約なので壊れにくい。

## 直し方

workerの失敗を「性格が悪い」で片付けない。**契約違反として特定し、修正する。**

三段階で見る。

| 段階 | やること |
|---|---|
| 1. prompt | 指示を締める。few-shotを足す。 |
| 2. evaluation case | テストケースを増やす。境界条件を入れる。 |
| 3. model binding | モデルを変える。最終手段。 |

実際の修正記録：

| worker | before | 修正内容 | after |
|---|---|---|---|
| Ledger | `0/3` | bounded reviewのfew-shot追加 | `3/3` |
| Compass | `1/3` | `missing constraints`のcase追加 | `3/3` |
| Quill | smoke `0/1` | fail-closed prompt + `qwen3:4b`にmodel変更 | full `3/3` |
| Lantern | smoke-only | `strategy/spending => approval`のexact pattern追加 | full `3/3` |

Quillだけmodel bindingまで変えた。`qwen2.5-coder:14b`では要約の精度が出なかったが、`qwen3:4b`（4Bパラメータ、軽い）に変えたら通った。全workerが同じモデルを使う必要はない。適材適所だ。

## 矯正の順番

失敗workerを見たら、この順で直す。

1. failure caseを固定する（何が壊れたかを再現可能にする）
2. promptを締める
3. 必要ならevaluation caseを増やす
4. それでもダメならmodel bindingを変える
5. smokeを通し、その後fullを通す

passは「安全宣言」じゃない。**今のケースで壊れにくくなった、という暫定的な信頼**だ。でもその暫定的な信頼があるだけで、workerは「名前だけの部下」から「会社の部品」に変わる。
