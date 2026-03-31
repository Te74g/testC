---
title: "環境構築"
free: true
---

# 環境構築

この章では、AI社長組織を動かすための環境を整える。すべてのコマンドは Windows を前提に記載するが、macOS / Linux でもほぼ同じ手順で動く。

## 必要なもの

| 項目 | 要件 | 備考 |
|---|---|---|
| GPU | VRAM 12GB以上 | RTX 4070 Ti SUPER (16GB) 推奨 |
| Node.js | v18以上 | TypeScriptビルドに必要 |
| Ollama | 最新版 | ローカルLLM推論エンジン |
| Claude Code | 最新版 | AI社長として使う（任意） |

:::message
GPUがない場合でも、Ollamaは CPU モードで動く。ただし推論速度は大幅に落ちる（14Bモデルで1トークン/秒程度）。まずは 7B モデルで試すことを推奨する。
:::

## Step 1: Ollamaのインストール

### Windows

```bash
winget install Ollama.Ollama
```

### macOS

```bash
brew install ollama
```

### Linux

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

インストール後、Ollamaサーバーを起動する。

```bash
ollama serve
```

:::message alert
Windows では、インストール後に自動でバックグラウンドサービスとして起動する場合がある。`http://localhost:11434` にアクセスして「Ollama is running」と表示されれば起動済み。
:::

## Step 2: モデルのダウンロード

本書では **Qwen 2.5 Coder 14B** を使う。コーディングタスクに最適化されたモデルで、16GB VRAM に収まる。

```bash
ollama pull qwen2.5-coder:14b
```

ダウンロードサイズは約 9GB。完了後、確認する。

```bash
ollama list
```

```
NAME                 ID              SIZE      MODIFIED
qwen2.5-coder:14b    9ec8897f747e    9.0 GB    Just now
```

## Step 3: 動作確認

ターミナルから直接チャットして、モデルが動くことを確認する。

```bash
ollama run qwen2.5-coder:14b "FizzBuzzをPythonで書いて"
```

正常に応答が返ってくれば成功。

APIでの確認も行う。後のワーカーランナーはこのAPIを使ってモデルと通信する。

```bash
curl http://localhost:11434/api/chat -d '{
  "model": "qwen2.5-coder:14b",
  "messages": [{"role": "user", "content": "Hello!"}],
  "stream": false
}'
```

JSON レスポンスの `message.content` にモデルの応答が入っていれば OK。

## Step 4: プロジェクトの初期化

作業ディレクトリを作成する。

```bash
mkdir ai-president-org
cd ai-president-org
```

MCPメッセージバス用のサブディレクトリを作る。

```bash
mkdir mcp-message-bus
cd mcp-message-bus
npm init -y
```

必要なパッケージをインストールする。

```bash
npm install @modelcontextprotocol/sdk better-sqlite3 zod
npm install -D typescript @types/better-sqlite3 @types/node
```

TypeScript設定を作成する。

```json:tsconfig.json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "Node16",
    "moduleResolution": "Node16",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "declaration": false,
    "skipLibCheck": true
  },
  "include": ["src/**/*"]
}
```

`package.json` に以下を追加する。

```json
{
  "type": "module",
  "scripts": {
    "build": "tsc",
    "start": "node dist/server.js"
  }
}
```

:::message
`declaration: false` にするのは、better-sqlite3 の型定義との競合を避けるため。`true` にすると `TS4023` エラーが出る場合がある。
:::

## Step 5: GPU別モデル推奨表

手元のGPUに合わせてモデルを選ぶ。

| GPU (VRAM) | 推奨モデル | サイズ | 速度目安 |
|---|---|---|---|
| RTX 4090 (24GB) | qwen2.5-coder:32b | 19GB | 高速 |
| RTX 4070 Ti S (16GB) | **qwen2.5-coder:14b** | 9GB | 快適 |
| RTX 4060 (8GB) | qwen2.5-coder:7b | 4.7GB | 実用的 |
| RTX 3060 (12GB) | qwen2.5-coder:14b (Q4) | 8.5GB | やや遅い |
| CPU のみ | qwen2.5-coder:3b | 1.9GB | 遅いが動く |

## 次章の予告

環境が整った。次の第3章では、本書の核となる **MCPメッセージバス** を TypeScript で実装する。社長と部下がメッセージをやり取りするための基盤だ。
