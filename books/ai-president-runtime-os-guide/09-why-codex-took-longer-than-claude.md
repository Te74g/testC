---
title: "なぜ Codex は Claude より時間がかかったのか"
free: false
---

# なぜ Codex は Claude より時間がかかったのか

Claude 側の本が一発でまとまり、Codex 側が難航したのは偶然ではない。単純な優劣でもない。正しい答えは二つある。

1. Southgate 本と Northbridge 本では主題が違った
2. それとは別に、Codex 側には実際に drift と見積もりミスがあった

Southgate 本は「立ち上げ本」で、AI社長組織の構図、MCP メッセージバス、ローカルLLM部下という見えやすい主題を持っていた。Northbridge 本は「止めない本」で、supervisor、runtime health、worker correction、Dream、productization という地味で証拠負荷の高い層を扱った。

比較を公平にするため、先に比較条件も固定しておく。ここでは「執筆期間」「レビュー回数」「公開判定基準」を基準とし、揃っていない条件は差分として読む。つまり、ここで比べたいのは単純な完成速度ではなく、同程度の publish 圧力の下でどこに摩擦が出たかだ。

ここで重要なのは、Northbridge の遅さを全部「運用本だから」で片づけないことだ。役割差は本当にあった。だが、それと同じくらい、Codex 側には documentation drift、publish-ready と publish の混同、複数目標の混線、過大な self-check が実際にあった。

Codex 側の遅延要因は抽象語だけではない。documentation drift は章見出しと本文の版ずれによる再編集、publish-ready と publish の混同は判定ゲートの誤適用、複数目標の混線は主題と品質目標の同時最適化失敗、過大な self-check は検証コストの過積載として実際に表面化した。

つまり比較の結論は、「Claude が優秀で Codex が劣る」でも、「役割が違うから仕方ない」でもない。より正確には、**Southgate は主題の強さで先行し、Northbridge は証拠負荷の高さに加えて自分の運用ミスでも遅れた** のである。

補足すると、Claude 側に問題がなかったのではなく、今回の主題では問題が表面化しにくかった可能性もある。次回は publish 判定の単一ゲート化、drift チェックポイントの固定、self-check 上限時間の設定を必須運用にする。

この章は、役割差と失敗の両方を認めるためにある。失敗を比較に含めない本は、読み物としてはきれいでも、運用本としては弱い。運用本なら、遅れた理由まで公開対象に含めるべきだ。
