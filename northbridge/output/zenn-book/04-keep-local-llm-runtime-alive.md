---
title: "local LLM runtime を死なせない"
free: false
---

# local LLM runtime を死なせない

AI社長組織を local-first で運用するなら、
local LLM runtime は心臓に近い。

worker がどれだけ良くても、

- Ollama が落ちる
- endpoint が消える
- model が見つからない

となれば、推論は止まる。

ここで雑な設計をすると、
**runtime が死んだ瞬間に組織全体まで巻き添えで止まる。**

Northbridge Systems がやりたいのは、それを避けることだ。

## 最悪なのは「落ちたことが分からない」状態

runtime 障害で本当に危ないのは、「落ちること」そのものではない。

もっと危ないのは、

- worker が変な理由で失敗する
- エラーが空文字になる
- status に runtime health が出ていない
- 誰も local LLM が死んだと気づかない

という状態だ。

これは、組織的には silent failure に近い。

だから Northbridge では、まず

**runtime failure を explicit な state にする**

ことから始めた。

## 入口は health check script 1本に寄せる

local runtime health の中核はこれだ。

- `scripts/check-local-llm-runtime.ps1`

この script がやることは、見た目より単純である。

1. provider 設定を読む  
2. `GET /api/tags` を叩く  
3. default model があるか確認する  
4. state file に結果を書く  
5. 必要なら bounded auto-recovery を試す

つまり、
**runtime の真実を worker 任せにしない**
ということだ。

worker は推論の利用者であって、runtime health の一次判定者ではない。

## config を分離する理由

runtime health は、binding と recovery policy を分けて持つ。

このプロジェクトでは:

- binding:
  - `runtime/config/local-llm-bindings.v1.json`
- runtime recovery config:
  - `runtime/config/local-llm-runtime.v1.json`

後者には、たとえば次のような情報が入る。

- `provider = ollama`
- `auto_recovery_enabled = true`
- `known_cli_candidates`
- `serve_arguments`
- `recovery_wait_seconds`
- `recovery_poll_interval_seconds`

この分離が大事なのは、
「どの model を使うか」と
「runtime が落ちた時にどう扱うか」が
別の問題だからだ。

## 最低限必要な状態

Northbridge が runtime state に持たせているのは、主にこれだ。

- `checked_at`
- `provider`
- `base_url`
- `default_model`
- `cli_available`
- `cli_source`
- `auto_recovery_enabled`
- `reachable`
- `model_available`
- `status`
- `available_models`
- `detail`
- `recovery_attempted`
- `recovery_succeeded`
- `recovery_detail`

この中で特に重要なのは、

- `reachable`
- `model_available`
- `status`

の3つだ。

ここが曖昧だと、worker failure と runtime failure が混ざる。

## ready と missing model は分ける

runtime が生きているかどうかと、
欲しい model があるかどうかは別問題だ。

そのため state は最低でもこう分ける。

- `ready`
  - endpoint reachable
  - configured model present
- `reachable_missing_model`
  - endpoint reachable
  - configured model absent
- `unreachable`
  - endpoint not reachable
- `unreachable_recovery_failed`
  - recovery まで試したが戻らない

ここを雑にすると、
「Ollama はいるが model が無い」
という状態を
「全部死んでいる」
と誤認しかねない。

## auto-recovery は bounded でなければいけない

AI組織の runtime recovery と聞くと、
何でも自動で直してくれるものを想像しがちだ。

しかし、そこは危険だ。

Northbridge の auto-recovery はかなり限定している。

現状では、

- known local path から
- `ollama.exe serve`
を起動し、
- 数秒待って再確認する

だけだ。

つまり、
**自動復旧といっても「決め打ちの最小限」までしかやらない。**

理由は単純で、復旧処理そのものが別の壊れ方を生むからだ。

## なぜ CLI source を state に残すのか

auto-recovery をやるなら、
「何を使って直そうとしたか」を残さないと危ない。

そのため state には:

- `cli_source`
- `cli_resolution`

を持たせている。

例えば今の環境では、

- `cli_available = true`
- `cli_source = C:\Users\user\AppData\Local\Programs\Ollama\ollama.exe`
- `cli_resolution = path`

のように見える。

これにより、
「recover したつもりだが、実は別のバイナリを叩いていた」
という事故を減らせる。

## soft block という考え方

Northbridge 側でかなり重要なのが
**soft block**
という考え方だ。

runtime が死んだからといって、
常に unattended loop 全体を止める必要はない。

例えば worker lane では、

- local eval が必要な処理
- patch flow が必要な処理

は止める。

一方で、

- lab artifact の生成
- training pack
- heartbeat
- president inbox

のような非推論依存の部分は続けられる。

この分離がないと、
runtime failure がそのまま会社全体停止に化ける。

## degraded mode の実装

今の `run-worker-lane.ps1` では、
local eval が `LOCAL_LLM_UNREACHABLE` で失敗した時、

- patch flow だけ止める
- lane 全体は続ける

ようになっている。

出力も:

- `soft block: local LLM unavailable`
- `worker lane degraded mode`

と明示する。

この設計の狙いは、
**「止めるべきものだけ止める」**
ことだ。

すべてを止めるのは簡単だが、それでは unattended 運用の価値が消える。

## worker failure と runtime failure を混ぜない

ここはかなり大事だ。

worker の prompt が悪いのか、
runtime が死んでいるのかが混ざると、
改善ループそのものが壊れる。

例えば以前は、

- eval が失敗する
- エラー情報が弱い
- worker の質が悪いのか runtime が悪いのか分からない

という状態があった。

今は少なくとも、

- runtime state
- worker local-eval artifact
- heartbeat
- president inbox

を見比べれば、
「これは runtime 側の failure」
と切り分けやすくなっている。

## healthy-path と failure-path は別に証明する

ここで、Northbridge 流の厳しさを1つ書いておく。

healthy-path で `ready` が出たからといって、
auto-recovery が証明されたことにはならない。

これは別物だ。

今の runtime でも、

- `status = ready`
- `recovery_attempted = false`

の healthy-path は通っている。

しかし、それだけでは
「本当に落ちた時に recover できる」
証拠にはならない。

したがって、
**failure-path は failure-path で別に踏んで証明する**
必要がある。

これは面倒だが、運用を盛らないために必要だ。

## 現時点の実状態

執筆時点では、少なくとも次が見えている。

- base URL は `http://localhost:11434`
- default model は `qwen2.5-coder:14b`
- `qwen3:4b` も利用可能
- provider は `ollama`
- runtime status は `ready`
- auto-recovery は `enabled`
- healthy-path では recovery 未使用

これだけ見ると良好に見える。

ただし Northbridge は、ここで言い切らない。

まだ未完の点がある。

- unreachable から ready に戻る経路の本番証拠
- recovery 後に worker lane がどう復帰するか
- recovery の retry policy をどこまで広げるか

だから現時点の評価は、

**runtime health は明示化された**

が、

**runtime self-healing はまだ限定的**

である。

## なぜここまで保守的なのか

理由は単純で、
recovery を盛るとすぐ魔法のように見えてしまうからだ。

しかし、実際に欲しいのは魔法ではない。

欲しいのは、

- 何が起きたか分かる
- どこまで自動で直したか分かる
- どこから人間判断か分かる

という境界だ。

AI社長組織は、ここを曖昧にした瞬間に壊れやすくなる。

## 次章の予告

次の第5章では、

**worker を評価し、矯正する**

を扱う。

runtime が整っても、worker が generic な出力や過剰 escalation に流れれば意味がない。
次は、

- smoke eval
- full eval
- prompt correction
- model split

をどう回すかを見ていく。
