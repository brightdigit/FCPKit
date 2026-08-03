---
name: fcp-scripting-live-facts
description: Live-verified FCP scripting facts — no export/render verb exists (get only); SBObject term-name contract (#27 fixed); AppleScript census works; DTD/xmllint quirks
metadata:
  node_type: memory
  type: project
---

# Final Cut Pro scripting: live-verified facts (2026-07-31)

Verified against Final Cut Pro Creator Studio on Leo's machine while building
`fcpxml-dsl verify-import` (step 6 branch).

## SBObject KVC contract (bug #27, FIXED 2026-07-31)

- SBObject proxies resolve the sdef **term names** via `value(forKey:)` —
  `name`, `id`, `file`, `duration`, `frameDuration`, `startTime`,
  `timecodeFormat`, children `libraries`/`events`/`projects`/`sequences` and
  project's `sequence`. Passing the sdef **cocoa keys** (`displayName`,
  `uniqueIdentifier`, `durationDict`, `URL`, `persistent ID`, …) raises
  `NSUnknownKeyException`, which Swift cannot catch, killing the process.
  Fixed in `FCPLibraryInspector`; the mock tests now pin the term names.
- Live shapes (probed key-by-key in child processes against a running FCP):
  `media time` records arrive as `NSDictionary` with `value`/`timescale`/
  `epoch`/`flags` NSNumber entries; `timecode format` arrives as an NSNumber
  **OSType** (`drop`/`ndrp`/`unsp`). `persistentID` resolves but is always
  nil — FCP declares `persistent ID` in the sdef but errors (-1728) even in
  AppleScript, so the model field is optional.
- FCP's sdef: `Contents/Resources/ProEditor.sdef` (or `sdef "/Applications/Final
  Cut Pro Creator Studio.app"`). Read-only suite `com.apple.FinalCut.library.inspection`;
  classes library/event/project/sequence.

## No export/render verb exists (verified 2026-08-02)

The sdef declares **exactly one command — `get`**. There is no `export`, `share`,
`render`, or `open` verb anywhere in it, every property on every class is
`access="r"`, and both suites sit behind
`<access-group identifier="com.apple.FinalCut.library.inspection" access="r"/>`.
So **ScriptingBridge cannot trigger a Final Cut export** — it is not a matter of
finding the right selector; there is no verb to call. Exporting a movie is a manual
Share → Master File step, or UI scripting via System Events (brittle, needs
Accessibility).

Re-verify against a future FCP release with:

```sh
sdef "$(mdfind 'kMDItemCFBundleIdentifier == com.apple.FinalCutApp' | head -1)" \
  | grep -o '<command name="[^"]*"'
```

Resolve by bundle id, not path — `sdef "/Applications/Final Cut Pro.app"` fails with
error -43 on this machine, where the app is `Final Cut Pro Creator Studio.app`. The
bundle id `com.apple.FinalCutApp` is stable across both.

## What does work live

- AppleScript (osascript) with sdef terminology works:
  `tell application id "com.apple.FinalCutApp" to get name of every project of
  every event of every library`. `fcpxml-dsl verify-import` uses this for its
  project census instead of the inspector.
- Sending an `.fcpxml` via `open -b com.apple.FinalCutApp file` triggers
  import; an invalid file pops the "could not be imported" alert titled
  "sent from application "(null)"". Driving/inspecting FCP dialogs needs
  Accessibility (assistive access) for the calling process — Automation
  (Apple events) consent alone is not enough.

## DTD validation quirks

- `xmllint --dtdvalid <path with spaces>` fails (`xmlSAX2ResolveEntity`) on the
  DTD inside "Final Cut Pro Creator Studio.app" — copy the `.dtd` to a
  space-free path first. The in-repo `FCPXMLDTDValidator` handles this.
- FCPXML ≥1.6 requires `<asset>(media-rep+, metadata?)`; `src` on `asset` is
  pre-1.6 only (fixed in `AssetSource` on this branch).
