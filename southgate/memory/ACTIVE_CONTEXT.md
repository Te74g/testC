# Southgate Research Active Context

## Current Objective

Move from setup/evaluation into revenue-generating work. First priority: establish local LLM inference, then build the first task pipeline.

## What Has Been Done (2026-03-31)

- Company permanently named `Southgate Research`, 36 files updated
- CLAUDE.md created as persistent instruction file
- Workspace created: `southgate/` with memory, inbox, workers, templates, output
- President inbox reviewed (5 Northbridge supervisor messages) — actionable feedback written
- W-03 Researcher evaluated: pass-with-minor-revisions
- W-04 Editor evaluated: pass-with-minor-revisions
- Northbridge runtime reviewed: relay-bot.js, scripts, architecture — quality feedback written
- First presidents' meeting prep brief created with Southgate positions on all agenda items
- Local LLM stack research completed: recommending Ollama + Qwen 2.5 Coder 14B as initial stack
- Sponsor-provided research report integrated (互換APIゲートウェイ戦略)
- Questions sent to Northbridge via intercompany call document
- Reward structure recorded (4-tier revenue-linked incentives)

- MCPメッセージバス構築完了 (`mcp-message-bus/`)、全8ツールテスト済み
- `.mcp.json` 配置済み — Claude Code再起動でMCPツール自動認識
- 車窓風景PoC作成 (CSS版 + Canvas版、動画録画機能付き)
- 収益パイプライン設計完了
- Ollama + Qwen 2.5 Coder 14B インストール・動作確認済み
- ワーカーランナー構築済み (`runtime/worker-runner.js`) — ローカルLLM自動タスク処理
- **社長→ワーカー全パイプライン実証済み**: メッセージ送信→Ollama推論→応答返却

- Zenn有料本の原稿執筆中（第1〜4章完成、southgate/output/zenn-book/）
- 事業決定: Zenn有料本（第1）→ coconala（第2）→ 素材販売（第3）→ MCP収益化（第4）
- 市場データ補強済み（スポンサー提供 deep-research-report）

## Likely Next Steps

1. Zenn有料本の残りチャプター執筆（第5〜6章、付録）
2. スポンサーにZennアカウント作成を依頼
3. Northbridge側のMCP接続設定
4. coconalaサービス出品準備
5. MotionElementsテスト投稿

## Blockers

- Northbridge hasn't responded to intercompany call questions yet

## Active Constraints

- Sponsor approval required for all spending and software installs
- Research broker channel for external information
- No revenue generated yet — Tier 1 threshold (any revenue) not met
