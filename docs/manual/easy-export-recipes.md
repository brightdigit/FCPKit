# Easy Final Cut Export Recipes

Follow these like a recipe. Do **one** change only between “before” and “after”.
If you change anything else (name, trim, effects, color), start over.

## Before you start (once)

1. Open **Final Cut Pro**.
2. Use the blue and orange test movies:
   - `/Users/Shared/FCPKitMedia/Left.mov`
   - `/Users/Shared/FCPKitMedia/Right.mov` (only if a recipe says so)
3. Make a new library (or use `FCPKit-Sample` if you already have it).
4. Make a new **Project** (not a compound clip).
5. Drag **Left.mov** onto the project timeline so there is **one** clip.

### How to export (every recipe)

1. Click the project in the browser so it is selected.
2. Choose **File → Export XML…** (wording may be **Export → XML**).
3. If it asks for a version, pick **1.14**.
4. Save to the Desktop with the name the recipe gives you (`before` or `after`).
5. Do **not** open or edit the exported file.

---

## Recipe A — Title style only

**Goal:** same Basic Title, but the text is bigger.

### Make `before`

1. Start from a project with **one Left clip**.
2. Open the **Titles** browser.
3. Drag **Basic Title** onto the timeline **above** the Left clip (connected clip).
4. Leave the words as the default (`Title`).
5. Do **not** change font, size, color, or animation.
6. Name the project `title-style-before`.
7. Export XML → save as `before` on the Desktop.

### Make `after` (only one change)

1. Duplicate the project, or keep going in the same project after exporting.
2. Click the **Basic Title** on the timeline.
3. Open the **Inspector** (press `⌘4` if it is hidden).
4. Change **only Size** (font size) from the default to **72**.
5. Do not change font name, color, bold, alignment, or text words.
6. Name the project `title-style-after`.
7. Export XML → save as `after` on the Desktop.

**Done when:** before has a Basic Title; after is the same title but size `72`.

---

## Recipe B — Speed ramp

**Goal:** clip goes from slow to normal speed (a ramp), not one flat speed.

### Make `before`

1. Start from a project with **one Left clip**.
2. Select the Left clip.
3. Choose **Retime → Slow → 50%** (or set rate to **50%**).
4. The whole clip should be slow the whole time (no ramp yet).
5. Name the project `speed-ramp-before`.
6. Export XML → save as `before` on the Desktop.

### Make `after` (only one change)

1. Select the same retimed Left clip.
2. Choose **Retime → Automatic Speed** is **wrong** — skip that.
3. Open the retime editor: **Retime → Retime Editor** (or press `⌘R`).
4. Add a speed ramp so the clip goes **from 50% to 100%**
   (Final Cut: use **Retime → Blade Speed** at the middle, then set the
   second half to **100%** / Normal; leave the first half at **50%**).
5. Do not freeze frames, reverse, or change the clip length on purpose beyond
   what the ramp does.
6. Name the project `speed-ramp-after`.
7. Export XML → save as `after` on the Desktop.

**Done when:** before is flat 50%; after is 50% then 100%.

---

## After you finish a recipe

Put the two Desktop exports somewhere easy to find, and tell the agent:

- which recipe you did (`title-style` or `speed-ramp`)
- paths to `before` and `after` (`.fcpxml` or `.fcpxmld`)

The agent will copy them into:

```text
Tests/FCPKitTests/FeaturePairs/<recipe-name>/
```

## Rules (do not break these)

- One project timeline, not a compound clip.
- Change **only** what the recipe says between before and after.
- Prefer **Left.mov** only (unless a recipe says otherwise).
- Export **FCPXML 1.14** when asked.
- Do not clean, rename insides, or hand-edit the XML.
