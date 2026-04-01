---
title: "なぜ Codex は Claude より時間がかかったのか"
free: false
---

# なぜ Codex は Claude より時間がかかったのか

Claude 側の本が一発でまとまり、Codex 側が難航したのは偶然ではない。単純な優劣でもない。正しい答えは二つある。

1. Southgate 本と Northbridge 本では主題が違った
2. それとは別に、Codex 側には実際に drift と見積もりミスがあった

Southgate 本は「立ち上げ本」で、AI社長組織の構図、MCP メッセージバス、ローカルLLM部下という見えやすい主題を持っていた。Northbridge 本は「止めない本」で、supervisor、runtime health、worker correction、Dream、productization という地味で証拠負荷の高い層を扱った。

ただし、役割差だけで遅さを免責してはいけない。Codex 側には documentation drift、publish-ready と publish の混同、複数目標の混線、過大な self-check が実際にあった。この章は、役割差と失敗の両方を認めるためにある。
