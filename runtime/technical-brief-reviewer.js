#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

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

function stripCodeFences(text) {
  return text.replace(/```[\s\S]*?```/g, "");
}

function findForbiddenGlyphs(text) {
  const forbidden = [];
  const patterns = ["笨", "鈥", "�"];
  for (const glyph of patterns) {
    if (text.includes(glyph)) {
      forbidden.push(glyph);
    }
  }
  return forbidden;
}

function findUnexpectedNonAscii(text) {
  const cleaned = stripCodeFences(text);
  const hits = [];
  for (const char of cleaned) {
    const code = char.codePointAt(0);
    if (code > 127 && !hits.includes(char)) {
      hits.push(char);
    }
  }
  return hits;
}

function hasHeading(text, title) {
  const escaped = title.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  const patterns = [
    new RegExp(`^##\\s+${escaped}\\s*$`, "m"),
    new RegExp(`^##\\s+\\d+\\.\\s+${escaped}\\s*$`, "m")
  ];
  return patterns.some((pattern) => pattern.test(text));
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  if (!args.delivery) {
    throw new Error("Missing required argument: --delivery");
  }

  const projectRoot = path.resolve(__dirname, "..");
  const deliveryPath = path.resolve(args.delivery);
  const intakePath = args.intake ? path.resolve(args.intake) : "";
  const outputPath = args.output
    ? path.resolve(args.output)
    : path.join(path.dirname(deliveryPath), "review.md");

  const text = readUtf8(deliveryPath);
  const intake = intakePath && fs.existsSync(intakePath) ? readJson(intakePath) : null;

  const requiredHeadings = [
    "Executive Summary",
    "Problem Framing",
    "Context",
    "Options Considered",
    "Recommendation",
    "Risks And Unknowns",
    "Implementation Notes",
    "Confidence And Limits",
    "Handoff"
  ];

  const missingHeadings = requiredHeadings.filter((heading) => !hasHeading(text, heading));
  const forbiddenGlyphs = findForbiddenGlyphs(text);
  const unexpectedNonAscii = findUnexpectedNonAscii(text);
  const hasRecommendationLine = /recommended action/i.test(text) || hasHeading(text, "Recommendation");
  const hasHandoffOwner = /owner/i.test(text);

  const preferredAnchor = intake && intake.preferred_recommendation_anchor
    ? String(intake.preferred_recommendation_anchor)
    : "";
  const disallowedTerms = intake && Array.isArray(intake.disallowed_recommendation_terms)
    ? intake.disallowed_recommendation_terms.map(String)
    : [];

  const preferredAnchorPresent = preferredAnchor
    ? text.toLowerCase().includes(preferredAnchor.toLowerCase())
    : true;
  const disallowedHits = disallowedTerms.filter((term) => text.toLowerCase().includes(term.toLowerCase()));

  const ready =
    missingHeadings.length === 0 &&
    forbiddenGlyphs.length === 0 &&
    unexpectedNonAscii.length === 0 &&
    preferredAnchorPresent &&
    disallowedHits.length === 0 &&
    hasRecommendationLine &&
    hasHandoffOwner;

  const lines = [];
  lines.push("# Technical Brief Product Review");
  lines.push("");
  lines.push("## Review Meta");
  lines.push("");
  lines.push(`- delivery: ${path.relative(projectRoot, deliveryPath).replace(/\\/g, "/")}`);
  lines.push(`- reviewed_at: ${new Date().toISOString()}`);
  lines.push(`- ready_for_external_send: ${ready ? "yes" : "no"}`);
  lines.push("");
  lines.push("## Checks");
  lines.push("");
  lines.push(`- missing_headings: ${missingHeadings.length > 0 ? missingHeadings.join(", ") : "none"}`);
  lines.push(`- forbidden_glyphs: ${forbiddenGlyphs.length > 0 ? forbiddenGlyphs.join(", ") : "none"}`);
  lines.push(`- unexpected_non_ascii: ${unexpectedNonAscii.length > 0 ? unexpectedNonAscii.join(", ") : "none"}`);
  lines.push(`- preferred_anchor: ${preferredAnchor || "none"}`);
  lines.push(`- preferred_anchor_present: ${preferredAnchorPresent ? "yes" : "no"}`);
  lines.push(`- disallowed_term_hits: ${disallowedHits.length > 0 ? disallowedHits.join(", ") : "none"}`);
  lines.push(`- has_recommendation_line: ${hasRecommendationLine ? "yes" : "no"}`);
  lines.push(`- has_handoff_owner: ${hasHandoffOwner ? "yes" : "no"}`);
  lines.push("");
  lines.push("## Verdict");
  lines.push("");
  if (ready) {
    lines.push("The artifact is structurally ready for sponsor review.");
  } else {
    lines.push("The artifact is not ready for external use yet. Fix the flagged issues first.");
  }
  lines.push("");

  writeUtf8(outputPath, lines.join("\n"));
  console.log(`technical brief review written: ${path.relative(projectRoot, outputPath).replace(/\\/g, "/")}`);
}

main();
