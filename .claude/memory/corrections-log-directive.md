---
name: corrections-log-directive
description: Standing rule to append every user correction / always-never directive to CORRECTIONS.md
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 1dec778e-d507-47f9-a9de-21c7aea1aff1
---

Whenever the user corrects me, or gives an explicit "always"/"never" directive, immediately append exactly one concise line to `.claude/CORRECTIONS.md` **in the repo** (not the machine-local memory dir). Record the instruction's literal meaning, not an interpretation.

**Why:** The user maintains an append-only corrections file, committed to the repo, as the single source of truth for how I should work on this project — so it is shared and easy for any agent to find.

**How to apply:** The file lives at `.claude/CORRECTIONS.md` in the repo root. It is append-only — preserve all existing entries; never rewrite, reorder, or delete prior notes. Prefix each entry with the date (YYYY-MM-DD).
