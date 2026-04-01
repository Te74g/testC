# Southgate Research — ローカルLLM推論スタック選択肢分析

Date: 2026-03-31
Author: Southgate Research (W-03 Researcher role, executed by president)
Scope: RTX 4070 Ti SUPER (16GB VRAM), Windows環境, ワーカー用推論基盤

---

## Option Table

### Option A: Ollama + Qwen 2.5 Coder 14B（推奨・初手）

| 項目 | 評価 |
|---|---|
| セットアップ難易度 | 低（1コマンドでモデル取得・起動） |
| Windows互換性 | 高（ネイティブ対応） |
| コーディング性能 | HumanEval ~85%（14Bクラス最強） |
| 推論速度 | ~25 tok/s（RTX 4070 Ti SUPER, Q4_K_M） |
| VRAM使用量 | ~8.5GB（Q4）、余裕あり |
| API互換性 | OpenAI互換API提供、Anthropic互換は非対応 |
| 欠点 | 同時接続に弱い（10並列で2s→45s劣化）、llama.cppより10-30%遅い |

**適用シナリオ:** V1ワーカーの推論バックエンド。シングルユーザー・シングルタスクで十分な初期段階に最適。

### Option B: llama.cpp server + Qwen 2.5 Coder 14B（本命・次段階）

| 項目 | 評価 |
|---|---|
| セットアップ難易度 | 中（ビルドまたはバイナリ取得が必要） |
| Windows互換性 | 高（ネイティブビルド可、CUDA対応） |
| コーディング性能 | 同上（モデル依存） |
| 推論速度 | Ollamaより10-30%高速 |
| VRAM使用量 | 同上 |
| API互換性 | OpenAI互換 + Anthropic Messages API互換（2026年3月時点で対応済み） |
| 欠点 | GUIなし、設定はCLI |

**適用シナリオ:** 互換APIゲートウェイ構築時のバックエンド。Anthropic互換があるため、Claude Codeの`ANTHROPIC_BASE_URL`差し替えに直接使える。

### Option C: vLLM + Mistral 7B Instruct（高スループット用）

| 項目 | 評価 |
|---|---|
| セットアップ難易度 | 高（Linux必須、WSL2経由） |
| Windows互換性 | 低（本番はLinux only） |
| コーディング性能 | Mistral 7Bはコーディング特化ではない |
| 推論速度 | 16.6x Ollama比（マルチユーザー時） |
| VRAM使用量 | ~4GB（7B Q4） |
| API互換性 | OpenAI互換 + Anthropic Messages API互換（Claude Code公式ガイドあり） |
| 欠点 | Windowsネイティブ非対応、WSL2のGPUパススルー要 |

**適用シナリオ:** 複数ワーカー同時稼働が必要になったスケール段階。

---

## Recommendation

**初手はOption A（Ollama + Qwen 2.5 Coder 14B）。**

理由:
1. セットアップが最も簡単で、今日中に動かせる
2. 16GB VRAMに余裕で収まる（Q4で~8.5GB、Q6でも~11GB）
3. HumanEval 85%はコーディングタスクに十分実用的
4. V1ワーカーはシングルタスク設計なので同時接続の弱点が問題にならない

**次段階でOption Bに移行。** llama.cpp serverはAnthropic互換APIを持つため、互換APIゲートウェイ構成の中核になれる。スポンサー提供レポートの「互換APIゲートウェイを先に作る」戦略と整合する。

---

## Uncertainty Note

- GPT-OSS 20B（MoE）は139.93 tok/sと非常に高速だが、2026年3月登場で実績が浅い。安定性を確認してから検討
- Qwen 3 14BはMMLU-Pro 0.774と推論に強いが、コーディング特化ベンチマークが不足。Qwen 2.5 Coder 14Bの方がコーディングには確実
- ライセンス: Qwen 2.5シリーズはApache 2.0。蒸留・学習データ生成に制約なし。Llama系は「出力を他LLM改良に使わない」条項があるため避けるべき

---

## Cost Impact

ローカル推論に移行した場合のAPI使用料削減試算（スポンサーレポートより引用）:

- 現状想定: 50 req/day → Claude Sonnet 4.6で月$99（キャッシュなし）
- ローカル化後: ルーティンタスクの80%をローカル処理 → 外部API月$20以下
- 電力コスト: RTX 4070 Ti SUPER TDP 285W × 8h/day × 30日 × ~30円/kWh ≈ 月2,052円

**ローカル推論は月$80+（約12,000円+）のAPI費用削減が見込める。Tier 1報酬（15,000円/月）の達成に直結する。**

---

## Next Action

1. スポンサーに確認: Ollamaインストールの承認
2. Northbridge Systemsに依頼: Ollama + Qwen 2.5 Coder 14Bの実装・テスト
3. 互換APIゲートウェイの設計開始（llama.cpp server + ルーティング）

## Unresolved Risk

ローカルLLMの品質がClaude/GPTに及ばない場合、外部APIフォールバック率が想定より高くなり、コスト削減効果が限定的になる可能性がある。品質ベンチマークを実タスクで計測する必要がある。

---

Sources:
- [Best Local LLMs for 16GB VRAM](https://localllm.in/blog/best-local-llms-16gb-vram)
- [Best Local LLM Models 2026 | SitePoint](https://www.sitepoint.com/best-local-llm-models-2026/)
- [Best Local Coding Models Ranked 2026 | InsiderLLM](https://insiderllm.com/guides/best-local-coding-models-2026/)
- [llama.cpp vs Ollama vs vLLM | DecodesFuture](https://www.decodesfuture.com/articles/llama-cpp-vs-ollama-vs-vllm-local-llm-stack-guide)
- [Ollama vs vLLM Benchmark 2026 | SitePoint](https://www.sitepoint.com/ollama-vs-vllm-performance-benchmark-2026/)
- [Best Local LLMs for RTX 40 Series](https://apxml.com/posts/best-local-llm-rtx-40-gpu)
- [Local LLM Inference Guide 2026 | Starmorph](https://blog.starmorph.com/blog/local-llm-inference-tools-guide)
