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

function readUtf8(filePath) {
  return fs.readFileSync(filePath, "utf8");
}

function readJson(filePath) {
  return JSON.parse(readUtf8(filePath));
}

function resolveRelativePath(projectRoot, filePathValue) {
  const normalized = String(filePathValue || "").replace(/[\\/]/g, path.sep);
  return path.resolve(projectRoot, normalized);
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

  return {
    message: String(error || "Unknown error"),
    name: "ErrorValue",
    code: "",
    stack: "",
    details: null
  };
}

function sanitizeSlug(value) {
  return String(value || "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 80) || "untitled-brief";
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
              reject(buildError(`Technical brief generation got HTTP ${statusCode}`, {
                code: `HTTP_${statusCode}`,
                details: { base_url: candidateBase, body_preview: raw.slice(0, 500) }
              }));
              return;
            }
            try {
              const parsed = JSON.parse(raw);
              const content = parsed && parsed.message && parsed.message.content ? String(parsed.message.content) : "";
              if (!content.trim()) {
                reject(buildError("Technical brief generation returned empty content.", {
                  code: "EMPTY_MESSAGE_CONTENT",
                  details: { base_url: candidateBase }
                }));
                return;
              }
              resolve(content);
            } catch (error) {
              reject(buildError("Failed to parse local model response for technical brief generation.", {
                code: "PARSE_ERROR",
                details: { base_url: candidateBase, body_preview: raw.slice(0, 500), parse_error: serializeError(error) }
              }));
            }
          });
        }
      );

      request.on("error", (error) => {
        const serialized = serializeError(error);
        const nextErrors = priorErrors.concat({ base_url: candidateBase, error: serialized });
        if (index + 1 < candidates.length) {
          tryCandidate(index + 1, nextErrors);
          return;
        }
        reject(buildError("Unable to reach local model runtime for technical brief generation.", {
          code: "LOCAL_LLM_UNREACHABLE",
          details: { attempts: nextErrors }
        }));
      });

      request.setTimeout(timeoutMs, () => {
        request.destroy(buildError(`Technical brief generation timed out after ${timeoutMs}ms`, {
          code: "TIMEOUT",
          details: { base_url: candidateBase, timeout_ms: timeoutMs }
        }));
      });

      request.write(payload);
      request.end();
    };

    tryCandidate(0, []);
  });
}

function formatList(value) {
  if (!value) {
    return "- none";
  }
  const items = Array.isArray(value) ? value : [value];
  if (items.length === 0) {
    return "- none";
  }
  return items.map((entry) => `- ${String(entry)}`).join("\n");
}

function formatObjectEntries(value) {
  if (!value || typeof value !== "object") {
    return "- none";
  }
  const entries = Object.entries(value);
  if (entries.length === 0) {
    return "- none";
  }
  return entries.map(([key, entry]) => `- ${key}: ${String(entry)}`).join("\n");
}

function buildSystemPrompt(serviceLineText, deliveryTemplateText) {
  return [
    "You are Northbridge Systems, producing a bounded technical brief for a paying client.",
    "Stay within the provided intake only. Do not invent repo access, benchmarks, or validation that did not happen.",
    "The output must be useful, cautious, and easy to review.",
    "Never market. Write as an internal technical advisor preparing a client-facing deliverable.",
    "When information is missing, state that clearly in Risks And Unknowns or Confidence And Limits.",
    "Use ASCII only in normal prose. Use '-' for bullets. Do not emit decorative glyphs or smart punctuation.",
    "If the intake is clearly about the current repository or runtime, prefer the known repo evidence over generic advice.",
    "Do not recommend replacing an already working repo pattern with a new one unless the intake explicitly demands that change.",
    "",
    "Service line context:",
    serviceLineText.trim(),
    "",
    "Delivery shape to match:",
    deliveryTemplateText.trim()
  ].join("\n");
}

function buildUserPrompt(intake) {
  const projectRoot = path.resolve(__dirname, "..");
  const routing = intake.internal_routing || {};
  const definition = intake.definition_of_done || {};
  const boundaries = intake.boundaries || {};
  const context = intake.context || {};
  const fit = intake.internal_fit || {};
  const risks = intake.risk_notes || {};
  const preferredAnchor = intake.preferred_recommendation_anchor || "";
  const disallowedTerms = Array.isArray(intake.disallowed_recommendation_terms)
    ? intake.disallowed_recommendation_terms
    : [];
  const evidencePaths = Array.isArray(intake.evidence_paths) ? intake.evidence_paths : [];
  const evidenceBlocks = evidencePaths.map((relativePath) => {
    try {
      const fullPath = resolveRelativePath(projectRoot, relativePath);
      const raw = readUtf8(fullPath).trim();
      const excerpt = raw.length > 2800 ? `${raw.slice(0, 2800)}\n[truncated]` : raw;
      return `Evidence file: ${relativePath}\n${excerpt}`;
    } catch {
      return `Evidence file: ${relativePath}\n[unavailable]`;
    }
  });

  return [
    "Prepare the technical brief in markdown.",
    "Use the exact numbered section headings from the delivery template:",
    "1. Executive Summary",
    "2. Problem Framing",
    "3. Context",
    "4. Options Considered",
    "5. Recommendation",
    "6. Risks And Unknowns",
    "7. Implementation Notes",
    "8. Confidence And Limits",
    "9. Handoff",
    "",
    "Constraints:",
    "- Keep the brief bounded and sponsor-safe.",
    "- Do not claim production access, external experiments, or hidden evidence.",
    "- Give 2 or 3 realistic options, not fake breadth.",
    "- The recommendation must be direct.",
    "- Handoff must include immediate next action, owner, and suggested follow-up deliverable.",
    "- Use ASCII only outside code blocks.",
    "- If the intake references the current repo/runtime, ground the recommendation in the repo's actual current state.",
    preferredAnchor ? `- Preferred recommendation anchor: ${preferredAnchor}` : "- Preferred recommendation anchor: none",
    disallowedTerms.length > 0 ? `- Disallowed recommendation terms: ${disallowedTerms.join(", ")}` : "- Disallowed recommendation terms: none",
    "",
    "Client intake:",
    `- project name: ${intake.project_name}`,
    `- requester: ${intake.requester}`,
    `- date: ${intake.date}`,
    `- package target: ${intake.package_target}`,
    `- deadline: ${intake.deadline}`,
    `- primary question: ${intake.primary_question}`,
    "- secondary questions:",
    formatList(intake.secondary_questions),
    `- expected output format: ${intake.expected_output_format}`,
    `- intended reader: ${intake.intended_reader}`,
    "- context:",
    formatObjectEntries(context),
    "- boundaries:",
    formatObjectEntries(boundaries),
    "- internal fit:",
    formatObjectEntries(fit),
    "- definition of done:",
    formatObjectEntries(definition),
    "- internal routing:",
    formatObjectEntries(routing),
    "- risk notes:",
    formatObjectEntries(risks),
    "",
    "Evidence bundle:",
    evidenceBlocks.length > 0 ? evidenceBlocks.join("\n\n---\n\n") : "- none"
  ].join("\n");
}

function normalizeGeneratedText(text) {
  return String(text || "")
    .replace(/笨・/g, "- ")
    .replace(/•/g, "- ")
    .replace(/[“”]/g, "\"")
    .replace(/[‘’]/g, "'")
    .replace(/[–—]/g, "-");
}

function buildQuoteRecord(intake) {
  const packageTable = {
    "package-a": {
      package_name: "Package A: Fast Technical Brief",
      quoted_price: "15,000 JPY",
      quoted_turnaround: "2 business days",
      included_revisions: "1 bounded revision",
      excluded_items: "implementation, deployments, production access"
    },
    "package-b": {
      package_name: "Package B: Decision Memo",
      quoted_price: "35,000 JPY",
      quoted_turnaround: "3 to 5 business days",
      included_revisions: "1 bounded revision",
      excluded_items: "implementation, deployments, production access"
    },
    "package-c": {
      package_name: "Package C: Documentation Support",
      quoted_price: "30,000 JPY",
      quoted_turnaround: "3 to 5 business days",
      included_revisions: "1 bounded revision",
      excluded_items: "production access, legal/compliance guarantees"
    }
  };

  return packageTable[intake.package_target] || packageTable["package-a"];
}

function renderQuoteMarkdown(intake, quote) {
  return [
    "# Technical Brief Quote",
    "",
    "## Quote Snapshot",
    "",
    `- project name: ${intake.project_name}`,
    `- requester: ${intake.requester}`,
    `- package: ${quote.package_name}`,
    `- quoted price: ${quote.quoted_price}`,
    `- quoted turnaround: ${quote.quoted_turnaround}`,
    `- included revisions: ${quote.included_revisions}`,
    `- excluded items: ${quote.excluded_items}`,
    "",
    "## Boundaries",
    "",
    "- sponsor approval is still required before external send",
    "- this quote assumes bounded documentation and decision support only",
    "- any production access, sensitive data handling, or implementation expansion requires re-scope",
    ""
  ].join("\n");
}

function renderOrderPacket(intake, quote, outputPaths) {
  return [
    "# Technical Brief Order Packet",
    "",
    "## 1. Order Snapshot",
    "",
    "- order type: technical brief",
    `- project name: ${intake.project_name}`,
    `- requester: ${intake.requester}`,
    `- date opened: ${intake.date}`,
    "- date closed:",
    "- status: draft prepared",
    "",
    "## 2. Intake Record",
    "",
    `- package target: ${intake.package_target}`,
    `- deadline: ${intake.deadline}`,
    `- primary question: ${intake.primary_question}`,
    "- secondary questions:",
    formatList(intake.secondary_questions),
    `- intended reader: ${intake.intended_reader}`,
    "- context:",
    formatObjectEntries(intake.context),
    "- boundaries:",
    formatObjectEntries(intake.boundaries),
    "",
    "## 3. Quote Record",
    "",
    `- quoted package: ${quote.package_name}`,
    `- quoted price: ${quote.quoted_price}`,
    `- quoted turnaround: ${quote.quoted_turnaround}`,
    `- included revisions: ${quote.included_revisions}`,
    `- excluded items: ${quote.excluded_items}`,
    "- sponsor quote status: pending sponsor send approval",
    "",
    "## 4. Worker Routing Record",
    "",
    "- Compass: option comparison and uncertainty mapping",
    "- Quill: structure and final readability",
    "- Ledger: contradiction and unsupported-claim check",
    "- Forge: concrete implementation notes and bounded commands",
    "- Lantern: continuity and checklist support",
    "",
    "## 5. Artifact Record",
    "",
    `- delivery artifact: ${outputPaths.deliveryRelative}`,
    `- quote artifact: ${outputPaths.quoteRelative}`,
    `- generation record: ${outputPaths.generationRelative}`,
    "- sponsor review before send: required",
    "- external send status: not sent",
    "",
    "## 6. Closeout Placeholder",
    "",
    "- result: pending",
    "- operational lesson:",
    "- next improvement target:",
    ""
  ].join("\n");
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (!args.intake) {
    throw new Error("Missing required argument: --intake");
  }

  const projectRoot = path.resolve(__dirname, "..");
  const intakePath = path.resolve(args.intake);
  const bindingsPath = path.join(projectRoot, "runtime", "config", "local-llm-bindings.v1.json");
  const serviceLinePath = path.join(projectRoot, "TECHNICAL_BRIEF_SERVICE_LINE_V1.md");
  const deliveryTemplatePath = path.join(projectRoot, "templates", "technical_brief_delivery_template.md");

  const intake = readJson(intakePath);
  const bindings = readJson(bindingsPath);
  const serviceLineText = readUtf8(serviceLinePath);
  const deliveryTemplateText = readUtf8(deliveryTemplatePath);

  const model = args.model || bindings.default_model || "qwen2.5-coder:14b";
  const baseUrl = args["base-url"] || bindings.base_url || "http://localhost:11434";
  const temperature = args.temperature ? Number(args.temperature) : 0.2;
  const timeoutMs = args["timeout-ms"] ? Number(args["timeout-ms"]) : (bindings.request_timeout_ms || 180000);

  const slug = intake.slug || sanitizeSlug(intake.project_name);
  const outputDir = args["output-dir"]
    ? path.resolve(args["output-dir"])
    : path.join(projectRoot, "products", "technical-brief-studio", "orders", slug);

  const systemPrompt = buildSystemPrompt(serviceLineText, deliveryTemplateText);
  const userPrompt = buildUserPrompt(intake);
  const startedAt = new Date();
  const response = await ollamaChat(baseUrl, model, systemPrompt, userPrompt, temperature, timeoutMs);
  const finishedAt = new Date();

  const quote = buildQuoteRecord(intake);
  const deliveryPath = path.join(outputDir, "delivery.md");
  const quotePath = path.join(outputDir, "quote.md");
  const generationPath = path.join(outputDir, "generation.json");
  const orderPacketPath = path.join(outputDir, "order-packet.md");

  const outputPaths = {
    deliveryRelative: path.relative(projectRoot, deliveryPath).replace(/\\/g, "/"),
    quoteRelative: path.relative(projectRoot, quotePath).replace(/\\/g, "/"),
    generationRelative: path.relative(projectRoot, generationPath).replace(/\\/g, "/")
  };

  writeUtf8(deliveryPath, normalizeGeneratedText(response).trim() + "\n");
  writeUtf8(quotePath, renderQuoteMarkdown(intake, quote));
  writeUtf8(orderPacketPath, renderOrderPacket(intake, quote, outputPaths));
  writeUtf8(generationPath, JSON.stringify({
    version: "v1",
    generated_at: finishedAt.toISOString(),
    started_at: startedAt.toISOString(),
    finished_at: finishedAt.toISOString(),
    duration_seconds: Math.round((finishedAt.getTime() - startedAt.getTime()) / 1000),
    intake_path: path.relative(projectRoot, intakePath).replace(/\\/g, "/"),
    output_dir: path.relative(projectRoot, outputDir).replace(/\\/g, "/"),
    base_url: baseUrl,
    model,
    temperature,
    timeout_ms: timeoutMs
  }, null, 2) + "\n");

  console.log(`technical brief generated: ${path.relative(projectRoot, outputDir).replace(/\\/g, "/")}`);
}

main().catch((error) => {
  const serialized = serializeError(error);
  console.error(serialized.message);
  if (serialized.code) {
    console.error(`error_code=${serialized.code}`);
  }
  if (serialized.details) {
    console.error(JSON.stringify(serialized.details, null, 2));
  }
  process.exit(1);
});
