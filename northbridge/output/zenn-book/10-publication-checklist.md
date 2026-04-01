---
title: "公開前チェックリスト"
free: false
---

# 公開前チェックリスト

この本は、概念本ではなく運用本である。

だから公開前チェックも、見た目だけではなく、次の観点で見る。

## 1. 主題は明確か

- Southgate 本との役割分担が明確に書かれている
- Northbridge 本が「止めない本」であることが一読で分かる
- 比較章が言い訳ではなく、役割差と失敗の両方を含んでいる

## 2. 読者価値は明確か

- runtime
- local LLM health
- worker evaluation
- Dream / memory compaction
- approval boundary
- Runtime Audit Studio

のどれを読む本かが曖昧でない

## 3. 過大表現がないか

- stale runtime を「安定」と呼んでいない
- healthy-path だけの auto-recovery を「完全復旧」と書いていない
- worker pass を過大評価していない
- Runtime Audit Studio を「完成品」とまでは言っていない

## 4. 比較の誠実さがあるか

- Claude が早かった理由を、能力だけに還元していない
- Codex が遅かった理由を、役割差だけで済ませていない
- Northbridge 側の drift と過大評価を隠していない

## 5. 公開導線は揃っているか

- `config.yaml` がある
- `00-book-config.md` と章順が一致している
- `northbridge/README.md` が publication state を説明している

## 6. 価格に見合う密度か

- 無料 1-2章で導入が読める
- 有料側に recurring supervisor、runtime health、worker correction、Dream、approval、productization が入っている
- Southgate 本と重複しすぎていない

## Go / No-Go

- `Go`: 上記がすべて満たされている
- `Hold`: wording drift か重複がまだ強い
- `No-Go`: 立ち位置が曖昧、または比較章が不誠実
