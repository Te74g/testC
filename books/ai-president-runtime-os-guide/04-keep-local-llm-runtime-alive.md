---
title: "local LLM runtime を死なせない"
free: false
---

# local LLM runtime を死なせない

worker が失敗した時、すぐ prompt のせいにすると判断を誤る。実際には、model server が落ちている、endpoint に届かない、model 自体が見つからないといった runtime failure の方が先に来ることがある。

Northbridge では local LLM runtime を state 化し、少なくとも次を分けている。

- `ready`
- `reachable_missing_model`
- `unreachable`
- `unreachable_recovery_failed`

これにより、worker failure と runtime failure と config failure を別物として扱える。さらに degraded mode を使って、local eval や patch flow は止めても、lab や training や heartbeat は続ける。

重要なのは「runtime が壊れない」ことではなく、「runtime が壊れた時に何が止まり、何が続くかが読める」ことだ。
