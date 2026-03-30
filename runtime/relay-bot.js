"use strict";

const fs = require("fs");
const path = require("path");

const runtimeRoot = __dirname;
const queueRoot = path.join(runtimeRoot, "queue");
const logsRoot = path.join(runtimeRoot, "logs");
const stateRoot = path.join(runtimeRoot, "state");
const inboxRoot = path.join(runtimeRoot, "inbox");
const registryPath = path.join(runtimeRoot, "command-registry.v1.json");
const statusPath = path.join(stateRoot, "relay-bot.status.json");
const logPath = path.join(logsRoot, "relay-bot.jsonl");

const directories = [
  path.join(queueRoot, "pending"),
  path.join(queueRoot, "processing"),
  path.join(queueRoot, "done"),
  path.join(queueRoot, "failed"),
  path.join(inboxRoot, "memory"),
  path.join(inboxRoot, "call"),
  path.join(inboxRoot, "resume"),
  logsRoot,
  stateRoot,
];

let registry = null;
let startedAt = new Date().toISOString();
let processedCount = 0;
let failedCount = 0;
let isProcessing = false;
let heartbeatHandle = null;
let pollHandle = null;

function ensureDirectories() {
  for (const dir of directories) {
    fs.mkdirSync(dir, { recursive: true });
  }
}

function loadRegistry() {
  registry = JSON.parse(fs.readFileSync(registryPath, "utf8"));
}

function writeJson(filePath, value) {
  const tempPath = `${filePath}.tmp`;
  fs.writeFileSync(tempPath, `${JSON.stringify(value, null, 2)}\n`, "utf8");
  fs.renameSync(tempPath, filePath);
}

function appendJsonl(filePath, value) {
  fs.appendFileSync(filePath, `${JSON.stringify(value)}\n`, "utf8");
}

function queueCounts() {
  const result = {};
  for (const state of ["pending", "processing", "done", "failed"]) {
    const dir = path.join(queueRoot, state);
    result[state] = fs.readdirSync(dir).filter((name) => name.endsWith(".json")).length;
  }
  return result;
}

function writeStatus(extra = {}) {
  writeJson(statusPath, {
    pid: process.pid,
    started_at: startedAt,
    last_heartbeat: new Date().toISOString(),
    processed_count: processedCount,
    failed_count: failedCount,
    queue_counts: queueCounts(),
    ...extra,
  });
}

function logEvent(level, event, details = {}) {
  appendJsonl(logPath, {
    timestamp: new Date().toISOString(),
    level,
    event,
    pid: process.pid,
    ...details,
  });
}

function validateEnvelope(envelope) {
  const requiredFields = [
    "id",
    "command",
    "sender",
    "receiver",
    "reason",
    "priority",
    "created_at",
    "approval_status",
    "payload",
  ];

  for (const field of requiredFields) {
    if (!(field in envelope)) {
      throw new Error(`Missing required field: ${field}`);
    }
  }

  if (typeof envelope.payload !== "object" || envelope.payload === null || Array.isArray(envelope.payload)) {
    throw new Error("Payload must be an object");
  }

  const commandSpec = registry.commands[envelope.command];
  if (!commandSpec) {
    throw new Error(`Unknown command: ${envelope.command}`);
  }

  if (commandSpec.allowedReceiver && !commandSpec.allowedReceiver.includes(envelope.receiver)) {
    throw new Error(`Receiver not allowed for command: ${envelope.receiver}`);
  }

  for (const field of commandSpec.requiredPayload || []) {
    if (!(field in envelope.payload)) {
      throw new Error(`Missing required payload field: ${field}`);
    }
  }

  const allowedPayloadValues = commandSpec.allowedPayloadValues || {};
  for (const [field, allowedValues] of Object.entries(allowedPayloadValues)) {
    if (field in envelope.payload && !allowedValues.includes(envelope.payload[field])) {
      throw new Error(`Invalid payload value for ${field}: ${envelope.payload[field]}`);
    }
  }

  return commandSpec;
}

function safeCommandName(commandName) {
  return commandName.replace(/[^a-zA-Z0-9._-]/g, "_");
}

function deliveryFileName(envelope) {
  const stamp = new Date().toISOString().replace(/[:.]/g, "-");
  return `${stamp}-${safeCommandName(envelope.command)}-${envelope.id}.json`;
}

function deliverCommand(envelope, commandSpec) {
  const inboxDir = path.join(inboxRoot, commandSpec.inbox);
  const targetPath = path.join(inboxDir, deliveryFileName(envelope));
  const deliveredRecord = {
    delivered_at: new Date().toISOString(),
    envelope,
  };
  writeJson(targetPath, deliveredRecord);
  return targetPath;
}

function moveResult(sourcePath, targetState, body) {
  const destination = path.join(queueRoot, targetState, path.basename(sourcePath));
  writeJson(destination, body);
  fs.unlinkSync(sourcePath);
  return destination;
}

function processFile(fileName) {
  const pendingPath = path.join(queueRoot, "pending", fileName);
  const processingPath = path.join(queueRoot, "processing", fileName);

  fs.renameSync(pendingPath, processingPath);

  let raw = null;
  let envelope = null;

  try {
    raw = fs.readFileSync(processingPath, "utf8");
    envelope = JSON.parse(raw.replace(/^\uFEFF/, ""));
    const commandSpec = validateEnvelope(envelope);
    const deliveryPath = deliverCommand(envelope, commandSpec);
    const resultPath = moveResult(processingPath, "done", {
      processed_at: new Date().toISOString(),
      status: "done",
      delivery_path: deliveryPath,
      envelope,
    });
    processedCount += 1;
    logEvent("info", "command_processed", {
      command: envelope.command,
      id: envelope.id,
      result_path: resultPath,
      delivery_path: deliveryPath,
    });
  } catch (error) {
    const failureRecord = {
      failed_at: new Date().toISOString(),
      status: "failed",
      error: error.message,
    };

    if (envelope) {
      failureRecord.envelope = envelope;
    } else if (raw !== null) {
      failureRecord.raw = raw;
    }

    const resultPath = moveResult(processingPath, "failed", failureRecord);
    failedCount += 1;
    logEvent("error", "command_failed", {
      id: envelope && envelope.id ? envelope.id : null,
      result_path: resultPath,
      error: error.message,
    });
  }
}

function processPendingQueue() {
  if (isProcessing) {
    return;
  }

  isProcessing = true;
  try {
    const pendingDir = path.join(queueRoot, "pending");
    const files = fs
      .readdirSync(pendingDir)
      .filter((name) => name.endsWith(".json"))
      .sort();

    for (const fileName of files) {
      processFile(fileName);
    }
  } finally {
    isProcessing = false;
    writeStatus();
  }
}

function start() {
  ensureDirectories();
  loadRegistry();
  writeStatus({ state: "starting" });
  logEvent("info", "relay_bot_started", { registry_version: registry.version });

  heartbeatHandle = setInterval(() => {
    writeStatus({ state: "running" });
  }, 2000);

  pollHandle = setInterval(() => {
    processPendingQueue();
  }, 1000);

  processPendingQueue();
}

function stop(signal) {
  if (heartbeatHandle) {
    clearInterval(heartbeatHandle);
  }
  if (pollHandle) {
    clearInterval(pollHandle);
  }
  writeStatus({ state: "stopped", stopped_by_signal: signal });
  logEvent("info", "relay_bot_stopped", { signal });
  process.exit(0);
}

process.on("SIGINT", () => stop("SIGINT"));
process.on("SIGTERM", () => stop("SIGTERM"));

start();
