"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const mcp_js_1 = require("@modelcontextprotocol/sdk/server/mcp.js");
const stdio_js_1 = require("@modelcontextprotocol/sdk/server/stdio.js");
const zod_1 = require("zod");
const db_js_1 = __importDefault(require("./db.js"));
const server = new mcp_js_1.McpServer({
    name: "message-bus",
    version: "1.0.0",
});
// ──────────────────────────────────────────
// Tool: register_agent
// ──────────────────────────────────────────
server.tool("register_agent", "Register yourself as an agent on the message bus", {
    agent_id: zod_1.z.string().describe("Unique agent ID (e.g. 'southgate-president')"),
    name: zod_1.z.string().describe("Display name (e.g. 'Southgate Research President')"),
    role: zod_1.z.enum(["president", "worker", "supervisor", "bot"]).describe("Agent role"),
}, async ({ agent_id, name, role }) => {
    const stmt = db_js_1.default.prepare("INSERT INTO agents (id, name, role, last_seen) VALUES (?, ?, ?, datetime('now')) ON CONFLICT(id) DO UPDATE SET name=?, role=?, last_seen=datetime('now')");
    stmt.run(agent_id, name, role, name, role);
    return { content: [{ type: "text", text: `Registered: ${agent_id} (${name}, ${role})` }] };
});
// ──────────────────────────────────────────
// Tool: send_message
// ──────────────────────────────────────────
server.tool("send_message", "Send a direct message to another agent", {
    from: zod_1.z.string().describe("Sender agent ID"),
    to: zod_1.z.string().describe("Recipient agent ID"),
    content: zod_1.z.string().describe("Message content"),
}, async ({ from, to, content }) => {
    const stmt = db_js_1.default.prepare("INSERT INTO messages (from_agent, to_agent, content) VALUES (?, ?, ?)");
    const result = stmt.run(from, to, content);
    // Update sender last_seen
    db_js_1.default.prepare("UPDATE agents SET last_seen = datetime('now') WHERE id = ?").run(from);
    return {
        content: [{
                type: "text",
                text: `Message #${result.lastInsertRowid} sent: ${from} → ${to}`,
            }],
    };
});
// ──────────────────────────────────────────
// Tool: broadcast
// ──────────────────────────────────────────
server.tool("broadcast", "Send a message to a channel (all agents subscribed can read it)", {
    from: zod_1.z.string().describe("Sender agent ID"),
    channel: zod_1.z.string().describe("Channel name (e.g. '#presidents')"),
    content: zod_1.z.string().describe("Message content"),
}, async ({ from, channel, content }) => {
    const ch = db_js_1.default.prepare("SELECT name FROM channels WHERE name = ?").get(channel);
    if (!ch) {
        return { content: [{ type: "text", text: `Error: channel '${channel}' does not exist` }] };
    }
    const stmt = db_js_1.default.prepare("INSERT INTO messages (from_agent, channel, content) VALUES (?, ?, ?)");
    const result = stmt.run(from, channel, content);
    db_js_1.default.prepare("UPDATE agents SET last_seen = datetime('now') WHERE id = ?").run(from);
    return {
        content: [{
                type: "text",
                text: `Broadcast #${result.lastInsertRowid} to ${channel}: ${from} says "${content.slice(0, 80)}${content.length > 80 ? "..." : ""}"`,
            }],
    };
});
// ──────────────────────────────────────────
// Tool: read_inbox
// ──────────────────────────────────────────
server.tool("read_inbox", "Read unread direct messages for an agent", {
    agent_id: zod_1.z.string().describe("Your agent ID"),
    mark_read: zod_1.z.boolean().optional().default(true).describe("Mark messages as read after fetching"),
}, async ({ agent_id, mark_read }) => {
    const messages = db_js_1.default.prepare("SELECT id, from_agent, content, created_at FROM messages WHERE to_agent = ? AND read = 0 ORDER BY created_at ASC").all(agent_id);
    if (messages.length === 0) {
        return { content: [{ type: "text", text: "No unread messages." }] };
    }
    if (mark_read) {
        const ids = messages.map((m) => m.id);
        db_js_1.default.prepare(`UPDATE messages SET read = 1 WHERE id IN (${ids.map(() => "?").join(",")})`).run(...ids);
    }
    db_js_1.default.prepare("UPDATE agents SET last_seen = datetime('now') WHERE id = ?").run(agent_id);
    const formatted = messages
        .map((m) => `[${m.created_at}] ${m.from_agent}: ${m.content}`)
        .join("\n");
    return {
        content: [{
                type: "text",
                text: `${messages.length} unread message(s):\n${formatted}`,
            }],
    };
});
// ──────────────────────────────────────────
// Tool: read_channel
// ──────────────────────────────────────────
server.tool("read_channel", "Read recent messages from a channel", {
    channel: zod_1.z.string().describe("Channel name (e.g. '#presidents')"),
    limit: zod_1.z.number().optional().default(20).describe("Number of recent messages to fetch"),
}, async ({ channel, limit }) => {
    const messages = db_js_1.default.prepare("SELECT id, from_agent, content, created_at FROM messages WHERE channel = ? ORDER BY created_at DESC LIMIT ?").all(channel, limit);
    if (messages.length === 0) {
        return { content: [{ type: "text", text: `No messages in ${channel}.` }] };
    }
    const formatted = messages
        .reverse()
        .map((m) => `[${m.created_at}] ${m.from_agent}: ${m.content}`)
        .join("\n");
    return {
        content: [{
                type: "text",
                text: `${messages.length} message(s) in ${channel}:\n${formatted}`,
            }],
    };
});
// ──────────────────────────────────────────
// Tool: list_agents
// ──────────────────────────────────────────
server.tool("list_agents", "List all registered agents on the message bus", {}, async () => {
    const agents = db_js_1.default.prepare("SELECT id, name, role, last_seen FROM agents ORDER BY last_seen DESC").all();
    if (agents.length === 0) {
        return { content: [{ type: "text", text: "No agents registered." }] };
    }
    const formatted = agents
        .map((a) => `${a.id} | ${a.name} | ${a.role} | last seen: ${a.last_seen || "never"}`)
        .join("\n");
    return {
        content: [{
                type: "text",
                text: `${agents.length} agent(s):\n${formatted}`,
            }],
    };
});
// ──────────────────────────────────────────
// Tool: list_channels
// ──────────────────────────────────────────
server.tool("list_channels", "List all available channels", {}, async () => {
    const channels = db_js_1.default.prepare("SELECT name, description FROM channels ORDER BY name").all();
    const formatted = channels
        .map((c) => `${c.name} — ${c.description || "(no description)"}`)
        .join("\n");
    return {
        content: [{
                type: "text",
                text: `${channels.length} channel(s):\n${formatted}`,
            }],
    };
});
// ──────────────────────────────────────────
// Tool: create_channel
// ──────────────────────────────────────────
server.tool("create_channel", "Create a new channel", {
    name: zod_1.z.string().describe("Channel name (must start with #)"),
    description: zod_1.z.string().optional().describe("Channel description"),
}, async ({ name, description }) => {
    if (!name.startsWith("#")) {
        return { content: [{ type: "text", text: "Error: channel name must start with #" }] };
    }
    const stmt = db_js_1.default.prepare("INSERT OR IGNORE INTO channels (name, description) VALUES (?, ?)");
    stmt.run(name, description || null);
    return { content: [{ type: "text", text: `Channel '${name}' created.` }] };
});
// ──────────────────────────────────────────
// Start
// ──────────────────────────────────────────
async function main() {
    const transport = new stdio_js_1.StdioServerTransport();
    await server.connect(transport);
}
main().catch((err) => {
    console.error("Fatal:", err);
    process.exit(1);
});
