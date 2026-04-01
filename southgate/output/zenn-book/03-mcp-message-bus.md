---
title: "MCPメッセージバスを作る"
free: false
---

# MCPメッセージバスを作る

この章では、AI社長と部下ワーカーがメッセージをやり取りするための **MCPメッセージバスサーバー** を TypeScript で実装する。

## MCPとは

MCP (Model Context Protocol) は、AIクライアントとツールサーバーの間の通信プロトコルだ。

- **プロトコル:** JSON-RPC 2.0
- **トランスポート:** stdio（標準入出力）
- **機能:** ツール（tools）、リソース（resources）、プロンプト（prompts）の提供

Claude Code、Cursor、Cline などのAIクライアントは、MCPサーバーを「ツール」として認識し、会話中に呼び出すことができる。

本書では、MCPの「ツール」機能を使って、8つのメッセージング機能を提供するサーバーを作る。

## データベース設計

メッセージの永続化にはSQLiteを使う。3つのテーブルを定義する。

```typescript:src/db.ts
import Database from "better-sqlite3";
import path from "path";
import fs from "fs";

const DATA_DIR = path.join(__dirname, "..", "data");
fs.mkdirSync(DATA_DIR, { recursive: true });

const db = new Database(path.join(DATA_DIR, "messages.db"));

db.pragma("journal_mode = WAL");
db.pragma("foreign_keys = ON");

db.exec(`
  CREATE TABLE IF NOT EXISTS agents (
    id   TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'worker',
    last_seen TEXT
  );

  CREATE TABLE IF NOT EXISTS messages (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    from_agent TEXT NOT NULL,
    to_agent   TEXT,
    channel    TEXT,
    content    TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    read       INTEGER NOT NULL DEFAULT 0
  );

  CREATE TABLE IF NOT EXISTS channels (
    name        TEXT PRIMARY KEY,
    description TEXT
  );

  CREATE INDEX IF NOT EXISTS idx_messages_to
    ON messages(to_agent, read);
  CREATE INDEX IF NOT EXISTS idx_messages_channel
    ON messages(channel);
`);

// デフォルトチャンネルを作成
const insertChannel = db.prepare(
  "INSERT OR IGNORE INTO channels (name, description) VALUES (?, ?)"
);
insertChannel.run("#presidents", "社長間チャンネル");
insertChannel.run("#northbridge", "Northbridge Systems 社内");
insertChannel.run("#southgate", "Southgate Research 社内");
insertChannel.run("#all-hands", "全社チャンネル");

export default db;
```

**設計のポイント:**

- `messages` テーブルの `to_agent` はDM用、`channel` はブロードキャスト用。どちらか一方を使う
- `read` フラグでワーカーが未読メッセージだけを取得できる
- WALモードで複数プロセスからの同時アクセスに対応

## MCPサーバーの実装

8つのツールを持つサーバーを実装する。

```typescript:src/server.ts
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport }
  from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
import db from "./db.js";

const server = new McpServer({
  name: "message-bus",
  version: "1.0.0",
});
```

### ツール1: register_agent

エージェント（社長やワーカー）をバスに登録する。

```typescript
server.tool(
  "register_agent",
  "Register yourself as an agent on the message bus",
  {
    agent_id: z.string()
      .describe("Unique agent ID (e.g. 'southgate-president')"),
    name: z.string()
      .describe("Display name"),
    role: z.enum(["president", "worker", "supervisor", "bot"])
      .describe("Agent role"),
  },
  async ({ agent_id, name, role }) => {
    const stmt = db.prepare(
      `INSERT INTO agents (id, name, role, last_seen)
       VALUES (?, ?, ?, datetime('now'))
       ON CONFLICT(id) DO UPDATE SET
         name=?, role=?, last_seen=datetime('now')`
    );
    stmt.run(agent_id, name, role, name, role);
    return {
      content: [{
        type: "text",
        text: `Registered: ${agent_id} (${name}, ${role})`
      }]
    };
  }
);
```

### ツール2: send_message

エージェント間のダイレクトメッセージを送る。

```typescript
server.tool(
  "send_message",
  "Send a direct message to another agent",
  {
    from: z.string().describe("Sender agent ID"),
    to: z.string().describe("Recipient agent ID"),
    content: z.string().describe("Message content"),
  },
  async ({ from, to, content }) => {
    const stmt = db.prepare(
      "INSERT INTO messages (from_agent, to_agent, content) VALUES (?, ?, ?)"
    );
    const result = stmt.run(from, to, content);
    db.prepare(
      "UPDATE agents SET last_seen = datetime('now') WHERE id = ?"
    ).run(from);

    return {
      content: [{
        type: "text",
        text: `Message #${result.lastInsertRowid} sent: ${from} → ${to}`,
      }],
    };
  }
);
```

### ツール3: broadcast

チャンネルにメッセージを投稿する。

```typescript
server.tool(
  "broadcast",
  "Send a message to a channel",
  {
    from: z.string().describe("Sender agent ID"),
    channel: z.string().describe("Channel name (e.g. '#presidents')"),
    content: z.string().describe("Message content"),
  },
  async ({ from, channel, content }) => {
    const ch = db.prepare(
      "SELECT name FROM channels WHERE name = ?"
    ).get(channel);
    if (!ch) {
      return {
        content: [{
          type: "text",
          text: `Error: channel '${channel}' does not exist`
        }]
      };
    }

    const stmt = db.prepare(
      "INSERT INTO messages (from_agent, channel, content) VALUES (?, ?, ?)"
    );
    const result = stmt.run(from, channel, content);
    db.prepare(
      "UPDATE agents SET last_seen = datetime('now') WHERE id = ?"
    ).run(from);

    return {
      content: [{
        type: "text",
        text: `Broadcast #${result.lastInsertRowid} to ${channel}`,
      }],
    };
  }
);
```

### ツール4: read_inbox

未読のダイレクトメッセージを取得する。

```typescript
server.tool(
  "read_inbox",
  "Read unread direct messages for an agent",
  {
    agent_id: z.string().describe("Your agent ID"),
    mark_read: z.boolean().optional().default(true)
      .describe("Mark messages as read after fetching"),
  },
  async ({ agent_id, mark_read }) => {
    type Msg = {
      id: number; from_agent: string;
      content: string; created_at: string;
    };
    const messages = db.prepare(
      `SELECT id, from_agent, content, created_at
       FROM messages
       WHERE to_agent = ? AND read = 0
       ORDER BY created_at ASC`
    ).all(agent_id) as Msg[];

    if (messages.length === 0) {
      return {
        content: [{ type: "text", text: "No unread messages." }]
      };
    }

    if (mark_read) {
      const ids = messages.map((m) => m.id);
      db.prepare(
        `UPDATE messages SET read = 1
         WHERE id IN (${ids.map(() => "?").join(",")})`
      ).run(...ids);
    }

    const formatted = messages
      .map((m) => `[${m.created_at}] ${m.from_agent}: ${m.content}`)
      .join("\n");

    return {
      content: [{
        type: "text",
        text: `${messages.length} unread message(s):\n${formatted}`,
      }],
    };
  }
);
```

### ツール5〜8: read_channel, list_agents, list_channels, create_channel

残りの4つのツールも同じパターンで実装する。全コードは付録Aに掲載するが、ここではポイントだけ示す。

- `read_channel` — チャンネルの最新N件を取得（`ORDER BY created_at DESC LIMIT ?`）
- `list_agents` — 全登録エージェントを一覧表示
- `list_channels` — 全チャンネルを一覧表示
- `create_channel` — 新しいチャンネルを作成（名前は `#` で始まる必要がある）

### サーバー起動

```typescript
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch((err) => {
  console.error("Fatal:", err);
  process.exit(1);
});
```

## ビルドと動作確認

```bash
npm run build
```

JSON-RPC で動作確認する。

```bash
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0.0"}}}' | node dist/server.js
```

`serverInfo` に `message-bus` が表示されれば成功。

## Claude Code への登録

プロジェクトルートに `.mcp.json` を作成する。

```json:.mcp.json
{
  "mcpServers": {
    "message-bus": {
      "command": "node",
      "args": ["/path/to/mcp-message-bus/dist/server.js"]
    }
  }
}
```

Claude Code を再起動すると、`send_message` や `read_inbox` などのツールが会話中に使えるようになる。

## 次章の予告

メッセージバスが動いた。次の第4章では、このバスに**ローカルLLMワーカーを接続**する。メッセージを受け取ったら Ollama で推論し、応答を自動的に返すデーモンを作る。
