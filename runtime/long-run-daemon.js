"use strict";

const { spawnSync } = require("child_process");
const fs = require("fs");
const path = require("path");

const runtimeRoot = __dirname;
const projectRoot = path.resolve(runtimeRoot, "..");
const stateRoot = path.join(projectRoot, "runtime", "state");
const logsRoot = path.join(projectRoot, "runtime", "logs");
const statusPath = path.join(stateRoot, "long-run-supervisor.status.json");
const pidPath = path.join(stateRoot, "long-run-supervisor.pid");
const logPath = path.join(logsRoot, "long-run-supervisor.jsonl");
const runtimeSettingsPath = path.join(projectRoot, "runtime", "config", "runtime-settings.v1.json");
const powerShellPath = process.env.SystemRoot
  ? path.join(process.env.SystemRoot, "System32", "WindowsPowerShell", "v1.0", "powershell.exe")
  : "powershell.exe";

function ensureDir(dirPath) {
  fs.mkdirSync(dirPath, { recursive: true });
}

function readRuntimeSettings() {
  if (!fs.existsSync(runtimeSettingsPath)) {
    return {
      default_supervisor_hours: 20,
      default_interval_minutes: 5,
      approved_parallel_worker_slots: 10,
      current_effective_worker_lanes: 1,
    };
  }
  return JSON.parse(fs.readFileSync(runtimeSettingsPath, "utf8"));
}

function parseArgs() {
  const args = process.argv.slice(2);
  const parsed = {};
  for (let i = 0; i < args.length; i += 1) {
    if (args[i] === "--hours") {
      parsed.hours = Number(args[i + 1]);
      i += 1;
      continue;
    }
    if (args[i] === "--interval-minutes") {
      parsed.intervalMinutes = Number(args[i + 1]);
      i += 1;
    }
  }
  return parsed;
}

function writeJson(filePath, value) {
  ensureDir(path.dirname(filePath));
  fs.writeFileSync(filePath, JSON.stringify(value, null, 2) + "\n", "utf8");
}

function appendJsonl(filePath, value) {
  ensureDir(path.dirname(filePath));
  fs.appendFileSync(filePath, JSON.stringify(value) + "\n", "utf8");
}

function writeStatus({
  state,
  startedAt,
  endAt,
  intervalMinutes,
  approvedParallelWorkerSlots,
  currentEffectiveWorkerLanes,
  cycleCount,
  lastCycleAt,
  lastResult,
}) {
  writeJson(statusPath, {
    pid: process.pid,
    state,
    started_at: startedAt,
    end_at: endAt,
    interval_minutes: intervalMinutes,
    approved_parallel_worker_slots: approvedParallelWorkerSlots,
    current_effective_worker_lanes: currentEffectiveWorkerLanes,
    cycle_count: cycleCount,
    last_cycle_at: lastCycleAt,
    last_result: lastResult,
    last_heartbeat: new Date().toISOString(),
  });
}

function logEvent(event, details) {
  appendJsonl(logPath, {
    timestamp: new Date().toISOString(),
    event,
    details,
  });
}

function runScript(scriptName) {
  const scriptPath = path.join(projectRoot, "scripts", scriptName);
  const result = spawnSync(
    powerShellPath,
    ["-ExecutionPolicy", "Bypass", "-File", scriptPath],
    {
      cwd: projectRoot,
      encoding: "utf8",
      windowsHide: true,
    }
  );

  const lines = [];
  if (result.stdout) {
    lines.push(...result.stdout.split(/\r?\n/).filter(Boolean));
  }
  if (result.stderr) {
    lines.push(...result.stderr.split(/\r?\n/).filter(Boolean));
  }

  if (result.error) {
    const error = new Error(`${scriptName} failed to spawn: ${result.error.message}`);
    error.output = lines;
    throw error;
  }

  if (result.status !== 0) {
    const error = new Error(`${scriptName} failed with exit code ${result.status}`);
    error.output = lines;
    throw error;
  }

  return lines;
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function main() {
  ensureDir(stateRoot);
  ensureDir(logsRoot);

  const runtimeSettings = readRuntimeSettings();
  const args = parseArgs();
  const hours = Number.isFinite(args.hours) && args.hours > 0 ? args.hours : Number(runtimeSettings.default_supervisor_hours || 20);
  const intervalMinutes =
    Number.isFinite(args.intervalMinutes) && args.intervalMinutes > 0
      ? args.intervalMinutes
      : Number(runtimeSettings.default_interval_minutes || 5);
  const approvedParallelWorkerSlots = Number(runtimeSettings.approved_parallel_worker_slots || 10);
  const currentEffectiveWorkerLanes = Number(runtimeSettings.current_effective_worker_lanes || 1);

  const startedAt = new Date().toISOString();
  const endAtDate = new Date(Date.now() + hours * 60 * 60 * 1000);
  const endAt = endAtDate.toISOString();

  fs.writeFileSync(pidPath, String(process.pid), "ascii");

  let cycleCount = 0;
  writeStatus({
    state: "running",
    startedAt,
    endAt,
    intervalMinutes,
    approvedParallelWorkerSlots,
    currentEffectiveWorkerLanes,
    cycleCount,
    lastCycleAt: "",
    lastResult: "starting",
  });
  logEvent("supervisor_started", {
    hours,
    interval_minutes: intervalMinutes,
    approved_parallel_worker_slots: approvedParallelWorkerSlots,
    current_effective_worker_lanes: currentEffectiveWorkerLanes,
    end_at: endAt,
  });

  try {
    while (Date.now() < endAtDate.getTime()) {
      cycleCount += 1;
      const cycleAt = new Date().toISOString();

      try {
        const continueOutput = runScript("continue-bot-work.ps1");
        const heartbeatOutput = runScript("write-bot-work-heartbeat.ps1");

        logEvent("supervisor_cycle_ok", {
          cycle: cycleCount,
          cycle_at: cycleAt,
          continue_output: continueOutput,
          heartbeat_output: heartbeatOutput,
        });

        writeStatus({
          state: "running",
          startedAt,
          endAt,
          intervalMinutes,
          approvedParallelWorkerSlots,
          currentEffectiveWorkerLanes,
          cycleCount,
          lastCycleAt: cycleAt,
          lastResult: "ok",
        });
      } catch (error) {
        logEvent("supervisor_cycle_failed", {
          cycle: cycleCount,
          cycle_at: cycleAt,
          error: error.message,
          output: error.output || [],
        });

        writeStatus({
          state: "running",
          startedAt,
          endAt,
          intervalMinutes,
          approvedParallelWorkerSlots,
          currentEffectiveWorkerLanes,
          cycleCount,
          lastCycleAt: cycleAt,
          lastResult: "failed",
        });
      }

      const remainingMs = endAtDate.getTime() - Date.now();
      if (remainingMs <= 0) {
        break;
      }

      await sleep(Math.min(intervalMinutes * 60 * 1000, remainingMs));
    }

    writeStatus({
      state: "completed",
      startedAt,
      endAt,
      intervalMinutes,
      approvedParallelWorkerSlots,
      currentEffectiveWorkerLanes,
      cycleCount,
      lastCycleAt: new Date().toISOString(),
      lastResult: "completed",
    });
    logEvent("supervisor_completed", {
      cycle_count: cycleCount,
    });
  } catch (error) {
    const fatalAt = new Date().toISOString();
    writeStatus({
      state: "failed",
      startedAt,
      endAt,
      intervalMinutes,
      approvedParallelWorkerSlots,
      currentEffectiveWorkerLanes,
      cycleCount,
      lastCycleAt: fatalAt,
      lastResult: "fatal",
    });
    logEvent("supervisor_fatal", {
      cycle: cycleCount,
      fatal_at: fatalAt,
      error: error.message,
    });
    throw error;
  } finally {
    if (fs.existsSync(pidPath)) {
      fs.unlinkSync(pidPath);
    }
  }
}

main().catch((error) => {
  process.stderr.write(String(error && error.stack ? error.stack : error) + "\n");
  process.exit(1);
});
