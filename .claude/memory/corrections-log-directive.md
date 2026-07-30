---
name: corrections-log-directive
description: Standing rule to log every user correction / always-never directive in .claude/agent-notes.md
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 1dec778e-d507-47f9-a9de-21c7aea1aff1
---

Whenever the user corrects me, or gives an explicit "always"/"never" directive, immediately add exactly one concise line to `.claude/agent-notes.md` **in the repo** (not the machine-local memory dir). Do this proactively, without being asked. Record the instruction's literal meaning, not an interpretation.

**Why:** The user maintains this file, committed to the repo, as the single source of truth for how I should work on this project — so it is shared and easy for any agent to find.

**How to apply:** The file lives at `.claude/agent-notes.md`. **Read it at the start of every session, before doing any work.** Newest lines at the bottom, one line per entry, prefixed with the date (YYYY-MM-DD). When a directive supersedes an earlier one, update or remove the stale line rather than leaving both — the log should read as the current rule set, not a full history.

Superseded 2026-07-29: this log was previously `.claude/CORRECTIONS.md` and was strictly append-only ("never rewrite, reorder, or delete"). That file has been merged into `.claude/agent-notes.md` and the append-only rule replaced by the update-stale-lines rule above.
