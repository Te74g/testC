---
title: "ローカルLLMワーカーを接続する"
free: false
---

# ローカルLLMワーカーを接続する

この章では、MCPメッセージバスの未読メッセージを自動的に取得し、Ollama で推論して応答を返す **ワーカーランナー** を実装する。

## 仕組み

```
┌──────────┐    send_message    ┌──────────────┐
│  AI社長   │ ──────────────────▶ │  SQLite DB    │
│(Claude)   │                    │  messages     │
└──────────┘                    └──────┬───────┘
                                       │ poll (5秒毎)
                                       ▼
                                ┌──────────────┐
                                │ worker-runner │
                                │   (Node.js)   │
                                └──────┬───────┘
                                       │ HTTP POST
                                       ▼
                                ┌──────────────┐
                                │   Ollama      │
                                │ Qwen 2.5 14B  │
                                └──────┬───────┘
                                       │ 応答
                                       ▼
                                ┌──────────────┐
                                │  SQLite DB    │ ──▶ 社長が read_inbox で回収
                                │  (reply)      │
                                └──────────────┘
```

ワーカーランナーは以下を5秒間隔で繰り返す。

1. 各ワーカーの未読メッセージをDBから取得
2. メッセージがあれば、ワーカーのシステムプロンプト + メッセージ本文で Ollama API を呼ぶ
3. 応答を送信者への返信としてDBに書き込む
4. 元メッセージを既読にする

## ワーカー定義

各ワーカーには、プロンプトファイルで役割を定義する。

```markdown:workers/researcher/prompt.md
あなたはローカルワーカー「Researcher」です。
役割: 選択肢分析とソース収集

## ルール
- 常に3つの選択肢を提示する
- 推奨を1つ選び、理由を述べる
- 不確実な点を明記する
- 権限外のこと（お金・契約・公開）はエスカレーションする

## 出力フォーマット
summary: ...
result: Option 1: ... Option 2: ... Option 3: ...
  Recommendation: ...
confidence: high|medium|low
risks: ... Uncertainty: ...
escalation_needed: true|false
```

```markdown:workers/editor/prompt.md
あなたはローカルワーカー「Editor」です。
役割: 要約・決定フレーミング・整形

## ルール
- 簡潔な段落で書く（箇条書きの羅列禁止）
- 決定を捏造しない
- 次のアクションと未解決リスクで締める

## 出力フォーマット
summary: ...
result: ... Next action: ...
confidence: high|medium|low
risks: ... Unresolved risk: ...
escalation_needed: true|false
```

## ワーカーランナーの実装

```javascript:runtime/worker-runner.js
const path = require("path");
const fs = require("fs");
const http = require("http");
const Database = require(
  path.join(__dirname, "..", "mcp-message-bus",
            "node_modules", "better-sqlite3")
);

// ─── 設定 ───
const OLLAMA_BASE = process.env.OLLAMA_BASE
  || "http://localhost:11434";
const OLLAMA_MODEL = process.env.OLLAMA_MODEL
  || "qwen2.5-coder:14b";
const POLL_INTERVAL_MS = 5000;
const DB_PATH = path.join(
  __dirname, "..", "mcp-message-bus", "data", "messages.db"
);

// ─── ワーカー定義の読み込み ───
const WORKERS = [
  {
    id: "w03-researcher",
    name: "Compass (Researcher)",
    role: "worker",
    system: fs.readFileSync(
      path.join(__dirname, "..", "workers",
               "researcher", "prompt.md"), "utf-8"
    ),
  },
  {
    id: "w04-editor",
    name: "Quill (Editor)",
    role: "worker",
    system: fs.readFileSync(
      path.join(__dirname, "..", "workers",
               "editor", "prompt.md"), "utf-8"
    ),
  },
];

// ─── DB接続 & ワーカー登録 ───
const db = new Database(DB_PATH);
db.pragma("journal_mode = WAL");

const upsertAgent = db.prepare(
  `INSERT INTO agents (id, name, role, last_seen)
   VALUES (?, ?, ?, datetime('now'))
   ON CONFLICT(id) DO UPDATE SET
     name=?, role=?, last_seen=datetime('now')`
);

for (const w of WORKERS) {
  upsertAgent.run(w.id, w.name, w.role, w.name, w.role);
  console.log(`[runner] Registered ${w.id}`);
}
```

### Ollama API呼び出し

```javascript
function ollamaChat(systemPrompt, userMessage) {
  return new Promise((resolve, reject) => {
    const payload = JSON.stringify({
      model: OLLAMA_MODEL,
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: userMessage },
      ],
      stream: false,
    });

    const url = new URL(`${OLLAMA_BASE}/api/chat`);
    const req = http.request({
      hostname: url.hostname,
      port: url.port,
      path: url.pathname,
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Content-Length": Buffer.byteLength(payload),
      },
    }, (res) => {
      let data = "";
      res.on("data", (chunk) => (data += chunk));
      res.on("end", () => {
        try {
          const json = JSON.parse(data);
          resolve(json.message?.content || "(no response)");
        } catch (e) {
          reject(new Error(`Parse error: ${data.slice(0, 200)}`));
        }
      });
    });

    req.on("error", reject);
    req.setTimeout(180000, () => {
      req.destroy();
      reject(new Error("Ollama timeout (180s)"));
    });
    req.write(payload);
    req.end();
  });
}
```

### メインポーリングループ

```javascript
const getUnread = db.prepare(
  `SELECT id, from_agent, content, created_at
   FROM messages WHERE to_agent = ? AND read = 0
   ORDER BY created_at ASC`
);
const markRead = db.prepare(
  "UPDATE messages SET read = 1 WHERE id = ?"
);
const sendReply = db.prepare(
  `INSERT INTO messages (from_agent, to_agent, content)
   VALUES (?, ?, ?)`
);

async function processWorker(worker) {
  const messages = getUnread.all(worker.id);
  if (messages.length === 0) return;

  for (const msg of messages) {
    console.log(
      `[${worker.id}] Task from ${msg.from_agent}: ` +
      `${msg.content.slice(0, 80)}...`
    );

    try {
      const response = await ollamaChat(
        worker.system, msg.content
      );
      sendReply.run(worker.id, msg.from_agent, response);
      console.log(
        `[${worker.id}] Replied (${response.length} chars)`
      );
    } catch (err) {
      sendReply.run(
        worker.id, msg.from_agent, `[Error] ${err.message}`
      );
    }

    markRead.run(msg.id);
  }
}

async function pollLoop() {
  console.log(`[runner] Polling every ${POLL_INTERVAL_MS}ms`);
  while (true) {
    for (const worker of WORKERS) {
      await processWorker(worker);
    }
    await new Promise((r) => setTimeout(r, POLL_INTERVAL_MS));
  }
}

pollLoop();
```

## 起動と動作確認

ワーカーランナーを起動する。

```bash
node runtime/worker-runner.js
```

```
[runner] Registered w03-researcher
[runner] Registered w04-editor
[runner] Polling every 5000ms — model: qwen2.5-coder:14b
```

別のターミナルから、社長としてメッセージを送ってみる。

```bash
cd mcp-message-bus
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0.0"}}}
{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"send_message","arguments":{"from":"president","to":"w03-researcher","content":"TypeScriptとRustの比較を3つの観点で分析してください"}}}' \
| node dist/server.js
```

30秒ほど待ってから、社長の受信箱を確認する。

```bash
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0.0"}}}
{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"read_inbox","arguments":{"agent_id":"president"}}}' \
| node dist/server.js
```

ワーカーからの応答が返ってくれば、**AI社長組織が稼働した**ことになる。

## 実際の応答例

筆者の環境（RTX 4070 Ti SUPER）での実際の応答を示す。

**社長 → Researcher:**
> 「ローカルLLM推論の量子化設定（Q4_K_M / Q5_K_M / Q8_0）のトレードオフを分析して」

**Researcher → 社長（約23秒後）:**
```
summary: 3つの量子化レベルを速度・品質・VRAMで比較
result:
  Option 1: Q4_K_M — 高速、品質最低、VRAM小
  Option 2: Q5_K_M — 中速、中品質、VRAM中
  Option 3: Q8_0 — 最遅、最高品質、VRAM大
  Recommendation: Q5_K_M（バランス型）
confidence: high
risks: 具体的なベンチマーク未計測。
  Uncertainty: 実タスクでの品質差は未検証
escalation_needed: false
```

プロンプトで定義した出力フォーマット（3選択肢+推奨+不確実性）に従っていることが分かる。

## 次章の予告

第5章では、ワーカーのプロンプトを **訓練** する方法を解説する。テストシナリオを設計し、良い応答と悪い応答を比較して、プロンプトを改善していく。
