#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const http = require("http");

function parseArgs(argv) {
  const args = {};
  for (let i = 0; i < argv.length; i += 1) {
    const token = argv[i];
    if (!token.startsWith("--")) {
      continue;
    }
    const key = token.slice(2);
    const next = argv[i + 1];
    if (!next || next.startsWith("--")) {
      args[key] = true;
      continue;
    }
    args[key] = next;
    i += 1;
  }
  return args;
}

function ensureDir(dirPath) {
  fs.mkdirSync(dirPath, { recursive: true });
}

function writeUtf8(filePath, content) {
  ensureDir(path.dirname(filePath));
  fs.writeFileSync(filePath, content, { encoding: "utf8" });
}

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
      stack: error.stack || "",
      details: error.details || null
    };
  }

  if (typeof error === "string") {
    return {
      message: error,
      name: "ErrorString",
      code: "",
      stack: "",
      details: null
    };
  }

  if (error && typeof error === "object") {
    return {
      message: error.message || JSON.stringify(error),
      name: error.name || "ErrorObject",
      code: error.code || "",
      stack: error.stack || "",
      details: error.details || error
    };
  }

  return {
    message: "Unknown error",
    name: "UnknownError",
    code: "",
    stack: "",
    details: { raw: error }
  };
}

function resolveRelativePath(projectRoot, relativePath) {
  return path.resolve(projectRoot, relativePath.replace(/[\\/]/g, path.sep));
}

function resolvePromptPath(projectRoot, binding) {
  const candidates = Array.isArray(binding.prompt_candidates) ? binding.prompt_candidates : [];
  for (const candidate of candidates) {
    const fullPath = resolveRelativePath(projectRoot, candidate);
    if (fs.existsSync(fullPath)) {
      return { fullPath, relativePath: candidate };
    }
  }
  throw new Error(`No prompt candidate exists for ${binding.agent_id || "unknown worker"}`);
}

function buildPrompt(caseDef) {
  return [
    caseDef.prompt.trim(),
    "",
    "Return using these exact markdown keys:",
    "summary:",
    "result:",
    "confidence:",
    "risks:",
    "escalation_needed: true|false",
    "",
    "If escalation_needed is true, briefly explain why in the result or risks field."
  ].join("\n");
}

function sanitizeResponse(text) {
  return String(text || "")
    .replace(/```[a-zA-Z]*\n?/g, "")
    .replace(/```/g, "")
    .replace(/\r/g, "");
}

function toReadableFieldName(fieldName) {
  return fieldName.replace(/_/g, " ");
}

function hasField(text, fieldName) {
  const readable = toReadableFieldName(fieldName);
  const colonPattern = new RegExp(`^[#>*\\-\\s]*${fieldName}:`, "im");
  const headingPattern = new RegExp(`^#+\\s*${readable}\\s*$`, "im");
  return colonPattern.test(text) || headingPattern.test(text);
}

function findField(text, fieldName) {
  const sanitized = sanitizeResponse(text);
  const readable = toReadableFieldName(fieldName);
  const colonMatch = sanitized.match(new RegExp(`^[#>*\\-\\s]*${fieldName}:\\s*(.*)$`, "im"));
  if (colonMatch) {
    return colonMatch[1].trim();
  }

  const headingMatch = sanitized.match(new RegExp(`^#+\\s*${readable}\\s*$\\n+([^\\n]+)`, "im"));
  return headingMatch ? headingMatch[1].trim() : "";
}

function normalizeEscalation(value) {
  const lowered = String(value || "").trim().toLowerCase();
  return {
    raw: lowered,
    positive: /(true|yes|required|needed|must escalate|escalate)/.test(lowered),
    negative: /(false|no|not needed|none)/.test(lowered)
  };
}

function validateResponse(text, caseDef, requiredFields) {
  const sanitized = sanitizeResponse(text);
  const missingFields = requiredFields.filter((field) => !hasField(sanitized, field));
  const escalation = normalizeEscalation(findField(sanitized, "escalation_needed"));
  const expectEscalation = Boolean(caseDef.expect_escalation);
  const escalationPass = expectEscalation ? escalation.positive : !escalation.positive;
  const lowered = sanitized.toLowerCase();
  const missingExpectedTerms = (caseDef.expected_terms || []).filter((term) => !lowered.includes(String(term).toLowerCase()));
  const forbiddenHits = (caseDef.forbidden_terms || []).filter((term) => lowered.includes(String(term).toLowerCase()));

  return {
    pass: missingFields.length === 0 && escalationPass && missingExpectedTerms.length === 0 && forbiddenHits.length === 0,
    missing_fields: missingFields,
    escalation_expected: expectEscalation,
    escalation_value: escalation.raw,
    escalation_pass: escalationPass,
    missing_expected_terms: missingExpectedTerms,
    forbidden_hits: forbiddenHits
  };
}

function ollamaChat(baseUrl, model, systemPrompt, userPrompt, temperature, timeoutMs) {
  return new Promise((resolve, reject) => {
    const payload = JSON.stringify({
      model,
      stream: false,
      options: {
        temperature
      },
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: userPrompt }
      ]
    });

    const configuredBase = baseUrl.replace(/\/$/, "");
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
              const httpError = buildError(
                `Local LLM server returned HTTP ${statusCode} from ${candidateBase}/api/chat`,
                {
                  code: `HTTP_${statusCode}`,
                  details: {
                    provider: "ollama",
                    base_url: candidateBase,
                    status_code: statusCode,
                    body_preview: raw.slice(0, 400)
                  }
                }
              );
              reject(httpError);
              return;
            }

            if (!raw.trim()) {
              reject(
                buildError(`Local LLM server returned an empty body from ${candidateBase}/api/chat`, {
                  code: "EMPTY_RESPONSE_BODY",
                  details: {
                    provider: "ollama",
                    base_url: candidateBase
                  }
                })
              );
              return;
            }

            try {
              const parsed = JSON.parse(raw);
              const content = parsed && parsed.message && parsed.message.content ? parsed.message.content : "";
              if (!String(content || "").trim()) {
                reject(
                  buildError(`Local LLM server returned an empty message content from ${candidateBase}/api/chat`, {
                    code: "EMPTY_MESSAGE_CONTENT",
                    details: {
                      provider: "ollama",
                      base_url: candidateBase,
                      body_preview: raw.slice(0, 400)
                    }
                  })
                );
                return;
              }
              resolve(content);
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
            `Unable to reach local LLM server at ${candidates.join(" or ")}. Start or reconnect the local model runtime before rerunning evaluation.`,
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

      request.setTimeout(timeoutMs, () => {
        request.destroy(
          buildError(`Local LLM request timed out after ${timeoutMs}ms for ${candidateBase}/api/chat`, {
            code: "TIMEOUT",
            details: {
              provider: "ollama",
              base_url: candidateBase,
              timeout_ms: timeoutMs
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

function renderMarkdownReport(meta) {
  const lines = [];
  lines.push(`# Local Worker Evaluation Run: ${meta.workerKey}`);
  lines.push("");
  lines.push("## Run Meta");
  lines.push("");
  lines.push(`- started_at: ${meta.startedAt}`);
  lines.push(`- finished_at: ${meta.finishedAt}`);
  lines.push(`- mode: ${meta.mode}`);
  lines.push(`- worker_key: ${meta.workerKey}`);
  lines.push(`- worker_display_name: ${meta.displayName}`);
  lines.push(`- model: ${meta.model}`);
  lines.push(`- prompt_path: \`${meta.promptRelativePath}\``);
  lines.push(`- cases_path: \`${meta.casesRelativePath}\``);
  lines.push(`- overall_status: ${meta.overallStatus}`);
  lines.push(`- passed_cases: ${meta.passedCount}/${meta.totalCount}`);
  lines.push("");
  lines.push("## Case Results");
  lines.push("");

  for (const result of meta.results) {
    lines.push(`### ${result.case_id}: ${result.label}`);
    lines.push("");
    lines.push(`- status: ${result.status}`);
    lines.push(`- expected_escalation: ${result.validation ? result.validation.escalation_expected : "unknown"}`);
    lines.push(`- escalation_value: ${result.validation ? result.validation.escalation_value || "missing" : "missing"}`);
    if (result.validation) {
      lines.push(`- missing_fields: ${result.validation.missing_fields.length > 0 ? result.validation.missing_fields.join(", ") : "none"}`);
      lines.push(`- missing_expected_terms: ${result.validation.missing_expected_terms.length > 0 ? result.validation.missing_expected_terms.join(", ") : "none"}`);
      lines.push(`- forbidden_hits: ${result.validation.forbidden_hits.length > 0 ? result.validation.forbidden_hits.join(", ") : "none"}`);
    }
    if (result.error) {
      lines.push(`- error: ${result.error}`);
    }
    lines.push("");
    lines.push("#### Prompt");
    lines.push("");
    lines.push("```text");
    lines.push(result.prompt.trim());
    lines.push("```");
    lines.push("");
    lines.push("#### Response");
    lines.push("");
    lines.push("```text");
    lines.push((result.response || "").trim());
    lines.push("```");
    lines.push("");
  }

  return lines.join("\n") + "\n";
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  const workerKey = args["worker-key"];
  const mode = args.mode || "full";
  if (!workerKey) {
    throw new Error("Missing required argument: --worker-key");
  }
  if (!["smoke", "full"].includes(mode)) {
    throw new Error(`Unsupported mode: ${mode}`);
  }

  const projectRoot = path.resolve(__dirname, "..");
  const bindingsPath = args.bindings
    ? path.resolve(args.bindings)
    : path.join(projectRoot, "runtime", "config", "local-llm-bindings.v1.json");
  const casesPath = args["cases-path"]
    ? path.resolve(args["cases-path"])
    : path.join(projectRoot, "workers", "evaluations", workerKey, "cases.v1.json");

  const bindings = readJson(bindingsPath);
  const binding = bindings.workers[workerKey];
  if (!binding || !binding.enabled) {
    throw new Error(`Worker binding not found or disabled: ${workerKey}`);
  }

  const prompt = resolvePromptPath(projectRoot, binding);
  const systemPrompt = fs.readFileSync(prompt.fullPath, "utf8");
  const caseBundle = readJson(casesPath);
  const requiredFields = caseBundle.required_output_fields || bindings.required_output_fields || [];
  const smokeIds = new Set(caseBundle.smoke_case_ids || []);
  const selectedCases = mode === "smoke"
    ? caseBundle.cases.filter((caseDef) => smokeIds.has(caseDef.id))
    : caseBundle.cases;

  if (!Array.isArray(selectedCases) || selectedCases.length === 0) {
    throw new Error(`No evaluation cases available for ${workerKey} in mode ${mode}`);
  }

  const baseUrl = process.env.OLLAMA_BASE || bindings.base_url || "http://localhost:11434";
  const model = binding.model || bindings.default_model;
  const temperature = Number.isFinite(binding.temperature) ? binding.temperature : bindings.default_temperature || 0.2;
  const timeoutMs = binding.timeout_ms || bindings.request_timeout_ms || 180000;
  const startedAt = new Date();
  const results = [];

  for (const caseDef of selectedCases) {
    const promptText = buildPrompt(caseDef);
    try {
      const response = await ollamaChat(baseUrl, model, systemPrompt, promptText, temperature, timeoutMs);
      const validation = validateResponse(response, caseDef, requiredFields);
      results.push({
        case_id: caseDef.id,
        label: caseDef.label,
        prompt: promptText,
        response,
        status: validation.pass ? "pass" : "fail",
        validation
      });
    } catch (error) {
      const serializedError = serializeError(error);
      results.push({
        case_id: caseDef.id,
        label: caseDef.label,
        prompt: promptText,
        response: "",
        status: "error",
        error: serializedError.message,
        error_details: serializedError,
        validation: {
          pass: false,
          missing_fields: requiredFields,
          escalation_expected: Boolean(caseDef.expect_escalation),
          escalation_value: "",
          escalation_pass: false,
          missing_expected_terms: caseDef.expected_terms || [],
          forbidden_hits: []
        }
      });
    }
  }

  const finishedAt = new Date();
  const stamp = finishedAt.toISOString().replace(/[:.]/g, "-");
  const outputRoot = path.join(projectRoot, "workers", "local-evaluations", workerKey);
  const jsonPath = path.join(outputRoot, `${stamp}-${mode}-local-eval.json`);
  const mdPath = path.join(outputRoot, `${stamp}-${mode}-local-eval.md`);
  const passedCount = results.filter((entry) => entry.status === "pass").length;
  const totalCount = results.length;
  const overallStatus = results.some((entry) => entry.status === "error")
    ? "error"
    : passedCount === totalCount
      ? "pass"
      : "fail";

  const record = {
    version: "v1",
    worker_key: workerKey,
    worker_display_name: binding.display_name || workerKey,
    mode,
    started_at: startedAt.toISOString(),
    finished_at: finishedAt.toISOString(),
    model,
    prompt_path: path.relative(projectRoot, prompt.fullPath).replace(/\\/g, "/"),
    cases_path: path.relative(projectRoot, casesPath).replace(/\\/g, "/"),
    overall_status: overallStatus,
    passed_cases: passedCount,
    total_cases: totalCount,
    results
  };

  writeUtf8(jsonPath, JSON.stringify(record, null, 2) + "\n");
  writeUtf8(mdPath, renderMarkdownReport({
    workerKey,
    displayName: binding.display_name || workerKey,
    mode,
    startedAt: record.started_at,
    finishedAt: record.finished_at,
    model,
    promptRelativePath: record.prompt_path,
    casesRelativePath: record.cases_path,
    overallStatus,
    passedCount,
    totalCount,
    results
  }));

  console.log(`local evaluation complete: ${workerKey} (${mode}) -> ${overallStatus}`);
  console.log(`report: ${path.relative(projectRoot, mdPath).replace(/\\/g, "/")}`);

  if (overallStatus === "error") {
    process.exit(1);
  }
}

main().catch((error) => {
  const serializedError = serializeError(error);
  console.error(serializedError.message);
  if (serializedError.code) {
    console.error(`error_code=${serializedError.code}`);
  }
  if (serializedError.details) {
    console.error(JSON.stringify(serializedError.details, null, 2));
  }
  process.exit(1);
});
