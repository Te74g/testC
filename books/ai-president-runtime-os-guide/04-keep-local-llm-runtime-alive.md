---
title: "ローカルLLM Runtimeを死なせない"
free: false
---

# ローカルLLM Runtimeを死なせない

workerのCompassに調査タスクを振った。返事が来ない。

「Compassのpromptが悪いのか？」と思って、promptを見直し始めた。30分使った。

違った。Ollamaが落ちていた。

promptをいくら直しても、そもそもLLMが動いていなければ全部空振りだ。この30分は完全な無駄だった。

ここから得た教訓は単純だ。**workerの前にruntimeを確認しろ。**

## 四つのstate

この失敗の後、ローカルLLM runtimeを四つのstateで管理するようにした。

| state | 意味 | 何が起きるか |
|---|---|---|
| `ready` | 正常 | 全ジョブ実行可 |
| `reachable_missing_model` | Ollamaは生きてるがmodelがない | model依存ジョブだけ止める |
| `unreachable` | `localhost:11434`に届かない | 1回だけauto recovery。patch flowはsoft block |
| `unreachable_recovery_failed` | 自動復旧も失敗 | evalとpatchは止める。heartbeatとinboxは続行 |

ポイントは**壊れた場所だけ止める**ことだ。

ローカルLLMが死んだからといって、会社全体を止める必要はない。heartbeatは動かし続けるし、president inboxも更新する。「ローカルLLMが死んでいます」という情報を社長（私）に届けるためには、LLMが死んでいても動く部分が必要だ。

## 正常時

正常な時はこうなっている。

```yaml
provider: ollama
base_url: http://localhost:11434
default_model: qwen2.5-coder:14b
available_models: [qwen3:4b, qwen2.5-coder:14b]
status: ready
```

ここまで確認できて、初めて「workerの出来が悪い」と言ってよい。ここが取れていないのにpromptをいじるのは、冒頭の私と同じ過ちだ。

## 障害時

一度、`localhost:11434`に完全に届かなくなったことがある。

```
http://localhost:11434 → 到達不能
ollama CLI → PATH解決失敗
local eval → 全部落ちる
```

この時にやったこと：

1. evalを止める
2. patch flowを止める
3. **会社ループ全体は止めない**
4. heartbeatとpresident inboxに`local_llm_status = unreachable`を表示

既知パスから`ollama.exe`を手動で起動し、stateを`ready`に戻した。ここで初めて、「runtime障害だった」と確定できた。

もしruntimeを確認せずにworkerのpromptを直し続けていたら、何時間も無駄にしていただろう。

## 最低限のコード

```ps1
if ($runtime.status -eq 'ready') {
    # 全ジョブ実行
}
elseif ($runtime.status -eq 'reachable_missing_model') {
    # model依存ジョブだけ止める
}
elseif ($runtime.status -eq 'unreachable') {
    # 1回復旧を試みる → soft block
}
else {
    # heartbeatとlabは続行、evalとpatchは止める
}
```

大事なのは「runtimeが壊れない」ことじゃない。壊れる。確実に壊れる。

大事なのは、**壊れた時に何が止まり何が続くかが、事前に決まっている**ことだ。
