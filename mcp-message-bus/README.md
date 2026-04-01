# MCP Message Bus

社長・部下間のリアルタイムメッセージングMCPサーバー。

## 概要

- SQLiteベースの永続化メッセージバス
- MCP (Model Context Protocol) 準拠 — JSON-RPC 2.0 over stdio
- エージェント登録、DM送受信、チャンネルブロードキャスト対応

## ツール一覧

| ツール名 | 説明 |
|---|---|
| `register_agent` | エージェント登録（ID、名前、役割） |
| `send_message` | DM送信 (from → to) |
| `read_inbox` | 未読DM取得 |
| `broadcast` | チャンネルへ投稿 |
| `read_channel` | チャンネル履歴取得 |
| `list_agents` | 登録エージェント一覧 |
| `list_channels` | チャンネル一覧 |
| `create_channel` | 新規チャンネル作成 |

## デフォルトチャンネル

- `#presidents` — 社長間チャンネル
- `#northbridge` — Northbridge Systems 社内
- `#southgate` — Southgate Research 社内
- `#all-hands` — 全社チャンネル

## セットアップ

```bash
cd mcp-message-bus
npm install
npm run build
```

## Claude Code で使う

プロジェクトルートの `.mcp.json` に登録済み:

```json
{
  "mcpServers": {
    "message-bus": {
      "command": "node",
      "args": ["C:\\Users\\user\\Desktop\\codex\\Local-LLM-multitasksupporter\\mcp-message-bus\\dist\\server.js"]
    }
  }
}
```

Claude Code再起動後、MCPツールとして自動認識される。

## Codex / 他のクライアントで使う

同じサーバーバイナリを stdio 経由で起動すればOK:

```bash
node C:\Users\user\Desktop\codex\Local-LLM-multitasksupporter\mcp-message-bus\dist\server.js
```

JSON-RPC 2.0 の `initialize` → `notifications/initialized` → `tools/call` の順で通信。

## データ

SQLiteファイルは `mcp-message-bus/data/messages.db` に保存される。
全エージェントが同じDBを共有するため、メッセージは永続的。
