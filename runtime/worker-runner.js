#!/usr/bin/env node

const path = require("path");
const fs = require("fs");
const http = require("http");
const Database = require(path.join(__dirname, "..", "mcp-message-bus", "node_modules", "better-sqlite3"));

const PROJECT_ROOT = path.join(__dirname, "..");
const DB_PATH = path.join(PROJECT_ROOT, "mcp-message-bus", "data", "messages.db");
const BINDINGS_PATH = path.join(PROJECT_ROOT, "runtime", "config", "local-llm-bindings.v1.json");
const POLL_INTERVAL_MS = parseInt(process.env.POLL_INTERVAL || "5000", 10);

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function buildError(message, details = {}) {
  const error = new Error(message);
  Object.assign(error, details);
  return error;
}

function serializeError(error) {
  if (error instanceof Error) {
    return {
      message: error.message || error.name || "Unknown error",
      name: error.name || "Error",
      code: error.code || "",
      details: error.details || null
    };
  }

  if (typeof error === "string") {
    return {
      message: error,
      name: "ErrorString",
      code: "",
      details: null
    };
  }

  if (error && typeof error === "object") {
    return {
      message: error.message || JSON.stringify(error),
      name: error.name || "ErrorObject",
      code: error.code || "",
      details: error.details || error
    };
  }

  return {
    message: "Unknown error",
    name: "UnknownError",
    code: "",
    details: { raw: error }
  };
}

function resolvePromptPath(binding) {
  const candidates = Array.isArray(binding.prompt_candidates) ? binding.prompt_candidates : [];
  for (const candidate of candidates) {
    const fullPath = path.join(PROJECT_ROOT, candidate);
    if (fs.existsSync(fullPath)) {
      return fullPath;
    }
  }
  throw new Error(`No prompt candidate exists for ${binding.agent_id}`);
}

const BINDINGS = readJson(BINDINGS_PATH);
const OLLAMA_BASE = process.env.OLLAMA_BASE || BINDINGS.base_url || "http://localhost:11434";
const WORKERS = Object.entries(BINDINGS.workers)
  .filter(([, binding]) => binding.enabled)
  .map(([workerKey, binding]) => {
    const promptPath = resolvePromptPath(binding);
    return {
      key: workerKey,
      id: binding.agent_id,
      name: binding.display_name || workerKey,
      role: "worker",
      model: binding.model || BINDINGS.default_model,
      temperature: Number.isFinite(binding.temperature) ? binding.temperature : (BINDINGS.default_temperature || 0.2),
      prompt_path: promptPath,
      system: fs.readFileSync(promptPath, "utf8")
    };
  });

if (!fs.existsSync(DB_PATH)) {
  console.error(`DB not found: ${DB_PATH}`);
  console.error("Run the MCP message-bus first to initialize the database.");
  process.exit(1);
}

const db = new Database(DB_PATH);
db.pragma("journal_mode = WAL");

const upsertAgent = db.prepare(
  `INSERT INTO agents (id, name, role, last_seen) VALUES (?, ?, ?, datetime('now'))
   ON CONFLICT(id) DO UPDATE SET name=?, role=?, last_seen=datetime('now')`
);

for (const worker of WORKERS) {
  upsertAgent.run(worker.id, worker.name, worker.role, worker.name, worker.role);
  console.log(
    `[runner] registered ${worker.id} (${worker.name}) -> ${worker.model} | prompt: ${path.relative(PROJECT_ROOT, worker.prompt_path)}`
  );
}

function ollamaChat(worker, userMessage) {
  return new Promise((resolve, reject) => {
    const payload = JSON.stringify({
      model: worker.model,
      stream: false,
      options: {
        temperature: worker.temperature
      },
      messages: [
        { role: "system", content: worker.system },
        { role: "user", content: userMessage }
      ]
    });

    const configuredBase = OLLAMA_BASE.replace(/\/$/, "");
    const candidates = [configuredBase];
    if (/^http:\/\/localhost(?::\d+)?$/i.test(configuredBase)) {
      candidates.push(configuredBase.replace("localhost", "127.0.0.1"));
    }

    const tryCandidate = (index, priorErrors) => {
      const candidateBase = candidates[index];
      const url = new URL(`${candidateBase}/api/chat`);
      const request = http.request(
        {
          hostname: url.hostname,
          port: url.port,
          path: url.pathname,
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Content-Length": Buffer.byteLength(payload)
          }
        },
        (response) => {
          let raw = "";
          response.on("data", (chunk) => {
            raw += chunk;
          });
          response.on("end", () => {
            const statusCode = response.statusCode || 0;
            if (statusCode < 200 || statusCode >= 300) {
              reject(
                buildError(`Local LLM server returned HTTP ${statusCode} from ${candidateBase}/api/chat`, {
                  code: `HTTP_${statusCode}`,
                  details: {
                    provider: "ollama",
                    base_url: candidateBase,
                    status_code: statusCode,
                    body_preview: raw.slice(0, 400)
                  }
                })
              );
              return;
            }

            try {
              const parsed = JSON.parse(raw);
              resolve(parsed.message && parsed.message.content ? parsed.message.content : "(no response)");
            } catch (error) {
              reject(
                buildError(`Failed to parse local LLM response from ${candidateBase}/api/chat`, {
                  code: "PARSE_ERROR",
                  details: {
                    provider: "ollama",
                    base_url: candidateBase,
                    body_preview: raw.slice(0, 400),
                    parse_error: serializeError(error)
                  }
                })
              );
            }
          });
        }
      );

      request.on("error", (error) => {
        const serialized = serializeError(error);
        const nextErrors = priorErrors.concat({
          base_url: candidateBase,
          error: serialized
        });

        if (index + 1 < candidates.length) {
          tryCandidate(index + 1, nextErrors);
          return;
        }

        reject(
          buildError(
            `Unable to reach local LLM server at ${candidates.join(" or ")}. Start or reconnect the local model runtime before continuing worker execution.`,
            {
              code: "LOCAL_LLM_UNREACHABLE",
              details: {
                provider: "ollama",
                attempts: nextErrors
              }
            }
          )
        );
      });

      request.setTimeout(BINDINGS.request_timeout_ms || 180000, () => {
        request.destroy(
          buildError("Local LLM request timed out", {
            code: "TIMEOUT",
            details: {
              provider: "ollama",
              base_url: candidateBase,
              timeout_ms: BINDINGS.request_timeout_ms || 180000
            }
          })
        );
      });

      request.write(payload);
      request.end();
    };

    tryCandidate(0, []);
  });
}

const getUnread = db.prepare(
  "SELECT id, from_agent, content, created_at FROM messages WHERE to_agent = ? AND read = 0 ORDER BY created_at ASC"
);
const markRead = db.prepare("UPDATE messages SET read = 1 WHERE id = ?");
const sendReply = db.prepare(
  "INSERT INTO messages (from_agent, to_agent, content) VALUES (?, ?, ?)"
);
const touchAgent = db.prepare("UPDATE agents SET last_seen = datetime('now') WHERE id = ?");

async function processWorker(worker) {
  const messages = getUnread.all(worker.id);
  if (messages.length === 0) {
    return;
  }

  for (const msg of messages) {
    console.log(`[${worker.id}] task from ${msg.from_agent}: ${msg.content.slice(0, 80)}...`);
    try {
      const response = await ollamaChat(worker, msg.content);
      sendReply.run(worker.id, msg.from_agent, response);
      console.log(`[${worker.id}] replied (${response.length} chars)`);
    } catch (error) {
      const serialized = serializeError(error);
      const errMsg = `[Error] ${serialized.message}`;
      sendReply.run(worker.id, msg.from_agent, errMsg);
      console.error(`[${worker.id}] error: ${serialized.message}`);
      if (serialized.code) {
        console.error(`[${worker.id}] error_code: ${serialized.code}`);
      }
    }

    markRead.run(msg.id);
    touchAgent.run(worker.id);
  }
}

async function pollLoop() {
  console.log(`[runner] polling every ${POLL_INTERVAL_MS}ms`);
  console.log(`[runner] watching inbox for: ${WORKERS.map((worker) => worker.id).join(", ")}`);

  while (true) {
    for (const worker of WORKERS) {
      await processWorker(worker);
    }
    await new Promise((resolve) => setTimeout(resolve, POLL_INTERVAL_MS));
  }
}

pollLoop().catch((error) => {
  console.error("[runner] fatal:", error);
  process.exit(1);
});
