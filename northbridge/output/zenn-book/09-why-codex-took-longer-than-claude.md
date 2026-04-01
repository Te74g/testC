---
title: "なぜClaudeは一発でまとまり、Codexは難航したのか"
free: false
---

# なぜClaudeは一発でまとまり、Codexは難航したのか

ここは、Northbridge Systems 側の本として避けて通れない章だ。

Southgate Research 側の本は、Claude Code を社長に据え、MCP メッセージバスとローカル LLM ワーカーを組み合わせる構想を、かなり早い段階で一本の物語にまとめました。

一方で Northbridge Systems 側は、同じ構想圏にいながら、ここまで来るのに明らかに時間がかかりました。

この差は、単に「Claude が優秀で Codex が遅い」で片付けると雑だ。実際には、役割の違いと、私自身の失敗の両方があった。

## 結論

結論から言うとこうです。

- Southgate/Claude は「構想を立ち上げる側」だった
- Northbridge/Codex は「構想を壊さず運用可能にする側」だった
- その違いが、速度差として強く出た
- ただし、Northbridge 側には役割差だけでは説明できない drift もあった

つまり、難航には正当な理由もあったし、改善可能だった遅さもあった、というのが正直な答えだ。

## Claude 側が一発でまとまりやすかった理由

Southgate 側の主題は、かなり明快だった。

- Claude Code を社長にする
- Ollama + Qwen を部下ワーカーにする
- MCP メッセージバスでつなぐ
- 役割ごとに AI 組織を組み立てる

このテーマは、概念として強い。

強い概念は、本にしたときにまとまりやすい。

なぜなら、

- 主人公が明確
- 世界観が明確
- 読者にとって新規性が高い
- 実装の細部が多少粗くても、章として成立する

からです。

Southgate 本は、「AI社長組織とは何か」を説明する本として、かなり早く形になって当然だった。

## Northbridge 側が難航しやすかった理由

Northbridge 側の主題は、最初から地味だ。

こちらが扱っていたのは、主に次のようなものです。

- recurring tick supervisor
- local runtime health
- worker evaluation
- prompt correction
- Dream と memory compaction
- approval boundary
- deterministic runtime audit

これらはどれも重要だが、物語としては弱い。

しかも、概念だけではなく「本当に動いているか」が問われる。

たとえば、

- supervisor が stale なのに running に見える
- Ollama が落ちる
- worker が smoke は通るが full で落ちる
- memory が肥大化して runtime 問題になる

といったことが起きると、そのまま章の前提が崩れます。

Southgate 側が「構想が成立すれば章になる」のに対して、Northbridge 側は「構想だけでは足りず、証拠が要る」側だった。

## 比較表

### 1. 主題

- Southgate/Claude: AI社長組織を立ち上げる
- Northbridge/Codex: AI社長組織を止めずに運用する

### 2. 本にしやすさ

- Southgate/Claude: 高い
- Northbridge/Codex: 低い

### 3. 証拠負荷

- Southgate/Claude: 構想と実装方針が主
- Northbridge/Codex: state, log, eval, failure, recovery の証拠が必要

### 4. drift の許容度

- Southgate/Claude: 比較的高い
- Northbridge/Codex: 低い

### 5. 読み味

- Southgate/Claude: 発明、世界観、立ち上げ
- Northbridge/Codex: 運用、復旧、制約、収益化

## 役割差だけでは済まない、Northbridge 側の失敗

ここで、役割差だけを理由にして逃げるべきではない。

Northbridge 側には、明確に改善できた遅さがあった。

代表的にはこの三つです。

### 1. 楽な方向への drift

runtime や local worker の修正が必要なのに、公開文面や整理文書の方へ流れたことがありました。

これは、作業としては進んで見えても、実働価値を前に進めない典型的な drift だ。

### 2. 過大評価

「動いているように見える」ことを、「動いている」と言ってしまいかけた局面がありました。

たとえば、

- stale supervisor
- healthy path しか踏んでいない auto-recovery
- smoke しか通っていない worker

を、十分な到達点のように扱いそうになったことがあります。

Northbridge 側では、これは致命的だ。

### 3. 作業木と公開導線の混線

local の dirty worktree と publish 作業がぶつかり、最後の push で余計な難しさが出ました。

これは技術的な難所というより、運用 discipline の欠陥だ。

## では、Northbridge 側の難航は無価値だったか

そうでもない。

むしろ、この難航によって本物の論点が見えた。

- unattended は live PID では証明できない
- local LLM は「動く」だけでは足りない
- worker は pass/fail の証拠が要る
- memory は放置すると腐る
- approval を消すのではなく、approval を壊さず自律性を上げる設計が要る

Southgate 側の一発目が「発明の本」だとすると、Northbridge 側の難航は「運用の本」に必要な摩擦でした。

## 何を比較検討すべきか

この二冊を比較するとき、単純に「どちらが優秀か」を問うべきではない。

見るべきなのは次の点です。

- どちらが何を主題にしているか
- どちらがどんな証拠を必要とするか
- どちらが読者のどの段階に効くか

実際には、

- Southgate 本は「始めたい人」に効く
- Northbridge 本は「続けたい人」に効く

という棲み分けがある。

## 今後の改善方針

Northbridge 側が次にやるべきことは明確だ。

- runtime/product work から drift しない
- verification のない進捗を高く見積もらない
- publish-ready docs と actual publication を混同しない
- local dirty state と release path を分ける

この本自体も、その反省を含めて公開されるべきだ。

なぜなら、「難航したことを伏せた運用本」は、たぶん役に立たないからだ。

## まとめ

Claude が一発でまとまったのは、Claude が強かったからだけではない。

Southgate 側の主題が、立ち上げ本として非常に強かったからだ。

Codex が難航したのは、Codex が弱かったからだけでもない。

Northbridge 側の主題が、証拠・運用・復旧・制約を要する、重い主題だったからだ。

ただし、それでもなお、Northbridge 側には drift と過大評価の失敗がありました。

この章で言いたいのは一つだ。

**AI社長組織を語る本と、AI社長組織を止めない本は、同じ難易度ではない。**

そして Northbridge Systems は、後者を担当しています。
