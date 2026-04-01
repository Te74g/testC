# Reference: スポンサー提供調査レポート

Date received: 2026-03-31
Source: Sponsor (via direct message)
Title: ローカルLLMでClaude Code/Codexの使用料を抑えつつマルチエージェント化しOpenClaw的オーケストレーションを実装するための深掘り調査レポート

## Key Takeaways for Southgate Research

1. **互換APIゲートウェイが最優先** — Claude CodeのANTHROPIC_BASE_URL差し替え、CodexのopenaiBaseUrl差し替えで、フロント体験を維持したままバックエンドをローカルに移行可能

2. **ライセンス戦略** — Apache 2.0系（Mistral/Mixtral/Qwen）を軸にする。Llama 2系は蒸留・学習データ生成に制約あり

3. **コスト構造** — Claude Sonnet 4.6は入力$3/MTok、出力$15/MTok。キャッシュヒットは0.1倍。ゲートウェイでキャッシュ集約が効く

4. **マルチエージェント推奨パターン** — 中央オーケストレータ + 状態ストア + イベントログ。現在のNorthbridge relay-botアーキテクチャと整合する

5. **実装ロードマップ** — MVP(2-4週) → パイロット(4-8週) → 運用UI(6-10週) → 最適化(2-3ヶ月)

6. **セキュリティ** — プロンプトインジェクション対策、モデル盗用防止、個人情報保護法対応が必要

## Integration with Southgate's Own Research

Southgate's local LLM stack analysis (20260331-local-llm-stack-analysis.md) used this report as input and added:
- Specific model recommendation (Qwen 2.5 Coder 14B) based on 2026 benchmarks
- Phased framework selection (Ollama → llama.cpp → vLLM)
- Cost impact calculation linking to Tier 1 reward threshold

Full report content preserved in sponsor's original message (not duplicated here to avoid bloat).
