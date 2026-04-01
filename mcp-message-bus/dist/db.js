"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const better_sqlite3_1 = __importDefault(require("better-sqlite3"));
const path_1 = __importDefault(require("path"));
const fs_1 = __importDefault(require("fs"));
const DATA_DIR = path_1.default.join(__dirname, "..", "data");
fs_1.default.mkdirSync(DATA_DIR, { recursive: true });
const db = new better_sqlite3_1.default(path_1.default.join(DATA_DIR, "messages.db"));
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

  CREATE INDEX IF NOT EXISTS idx_messages_to ON messages(to_agent, read);
  CREATE INDEX IF NOT EXISTS idx_messages_channel ON messages(channel);
`);
// Seed default channels
const insertChannel = db.prepare("INSERT OR IGNORE INTO channels (name, description) VALUES (?, ?)");
insertChannel.run("#presidents", "社長間チャンネル");
insertChannel.run("#northbridge", "Northbridge Systems 社内");
insertChannel.run("#southgate", "Southgate Research 社内");
insertChannel.run("#all-hands", "全社チャンネル");
exports.default = db;
