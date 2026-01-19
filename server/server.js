const express = require("express");
const cors = require("cors");
const sqlite3 = require("sqlite3").verbose();
const path = require("path");

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

const dbPath = path.join(__dirname, "chat.db");
const db = new sqlite3.Database(dbPath);

db.serialize(() => {
  db.run(
    "CREATE TABLE IF NOT EXISTS messages (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT NOT NULL, text TEXT NOT NULL, created_at TEXT NOT NULL)"
  );
});

app.get("/messages", (req, res) => {
  db.all(
    "SELECT id, username, text, created_at FROM messages ORDER BY id ASC",
    (err, rows) => {
      if (err) {
        res.status(500).json({ error: "Failed to load messages" });
        return;
      }
      const messages = rows.map((row) => ({
        id: row.id,
        username: row.username,
        text: row.text,
        timestamp: row.created_at,
      }));
      res.json(messages);
    }
  );
});

app.post("/messages", (req, res) => {
  const { username, text } = req.body;
  if (!username || !text) {
    res.status(400).json({ error: "Username and text are required" });
    return;
  }

  const timestamp = new Date().toISOString();
  const statement =
    "INSERT INTO messages (username, text, created_at) VALUES (?, ?, ?)";
  db.run(statement, [username, text, timestamp], function (err) {
    if (err) {
      res.status(500).json({ error: "Failed to save message" });
      return;
    }
    res.status(201).json({
      id: this.lastID,
      username,
      text,
      timestamp,
    });
  });
});

app.listen(port, () => {
  // eslint-disable-next-line no-console
  console.log(`Chat server listening on http://localhost:${port}`);
});
