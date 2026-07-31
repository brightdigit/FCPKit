---
name: fcp-scripting-live-facts
description: Live-verified FCP scripting facts — inspector KVC keys crash against real FCP; AppleScript census works; DTD/xmllint quirks
metadata:
  node_type: memory
  type: project
---

# Final Cut Pro scripting: live-verified facts (2026-07-31)

Verified against Final Cut Pro Creator Studio on Leo's machine while building
`fcpxml-dsl verify-import` (step 6 branch).

## FCPLibraryInspector crashes against a real running FCP (open bug)

- `FCPLibraryInspector.libraries()` raises `NSUnknownKeyException`
  (`valueForUndefinedKey: displayName`) the moment FCP is running. ObjC
  exceptions are uncatchable from Swift, so **`swift test` crashes the whole
  `FCPKitScriptingTests` binary whenever FCP is open** — the live test
  `readsLibrariesWhenFinalCutIsRunning` only ever ran its early-return path.
- Root cause: `SBObject+FCPScriptingObject.swift` passes the sdef **cocoa
  keys** (`displayName`, `uniqueIdentifier`, `durationDict`, `URL`, …) to
  `value(forKey:)`, but SBObject proxies resolve the sdef **term names**
  (`name`, `id`, `duration`, `file`, …). The mock tests pin the cocoa keys, so
  they pass while the live path is broken.
- FCP's sdef: `Contents/Resources/ProEditor.sdef` (or `sdef "/Applications/Final
  Cut Pro Creator Studio.app"`). Read-only suite `com.apple.FinalCut.library.inspection`;
  classes library/event/project/sequence; `name`→cocoa `displayName`,
  `file`→cocoa `URL`, records `media time` for duration/start.

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
