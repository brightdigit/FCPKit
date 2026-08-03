//
//  FCPXMLDSLCommand+VerifyImport.swift
//  FCPKit
//
//  Created by Leo Dion.
//  Copyright © 2026 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import FCPKit
import FCPKitScripting
import Foundation

extension FCPXMLDSLCommand {
  #if os(macOS)
    /// Opens an FCPXML file in Final Cut Pro and verifies the import landed.
    ///
    /// Success is a project from the document appearing in an open library
    /// (censused over AppleScript, which reads Final Cut Pro's
    /// `com.apple.FinalCut.library.inspection` scripting suite); failure is
    /// the "could not be imported" alert (via System Events UI scripting,
    /// best-effort) or a timeout.
    internal static func verifyImport(
      positionals: [String],
      options: [String: String]
    ) async throws {
      guard positionals.count == 1 else {
        throw FCPXMLDSLCommandError.usage
      }
      let fileURL = URL(fileURLWithPath: positionals[0])
      guard FileManager.default.fileExists(atPath: fileURL.path) else {
        throw FCPXMLDSLCommandError.fileNotFound(fileURL.path)
      }
      let timeout = TimeInterval(options["timeout"] ?? "") ?? 30
      let expected = try expectedProjectNames(in: fileURL, override: options["project"])
      let before = try await ensureFinalCutReady()
      try openInFinalCut(fileURL)
      print("Sent \(fileURL.lastPathComponent) to Final Cut Pro; waiting for \(expected)…")
      try await waitForImport(expected: expected, before: before, timeout: timeout)
    }

    private static func expectedProjectNames(
      in fileURL: URL,
      override: String?
    ) throws -> [String] {
      if let override {
        return [override]
      }
      let document = try FCPXMLParser().parse(data: Data(contentsOf: fileURL))
      let events = document.library?.events ?? []
      let names = events.flatMap { $0.projects ?? [] }.compactMap(\.name)
      guard !names.isEmpty else {
        throw FCPXMLDSLCommandError.missingProjectName(fileURL.path)
      }
      return names
    }

    /// Launches Final Cut Pro if needed and returns the pre-import project census.
    private static func ensureFinalCutReady() async throws -> [String] {
      if !FCPApplication.isFinalCutRunning() {
        print("Launching Final Cut Pro…")
        try runOpenTool(["-b", FCPApplication.bundleIdentifier])
      }
      let deadline = Date().addingTimeInterval(60)
      while Date() < deadline {
        if let names = currentProjectNames() {
          return names
        }
        try await Task.sleep(nanoseconds: 1_000_000_000)
      }
      throw FCPXMLDSLCommandError.finalCutUnavailable
    }

    private static func openInFinalCut(_ fileURL: URL) throws {
      try runOpenTool(["-b", FCPApplication.bundleIdentifier, fileURL.path])
    }

    /// Snapshots open project names via AppleScript, or nil when Final Cut
    /// Pro is absent, still launching, or Automation permission is missing.
    private static func currentProjectNames() -> [String]? {
      let census = """
        set out to ""
        tell application id "\(FCPApplication.bundleIdentifier)"
          repeat with lib in libraries
            repeat with ev in events of lib
              repeat with proj in projects of ev
                set out to out & (name of proj) & linefeed
              end repeat
            end repeat
          end repeat
        end tell
        return out
        """
      let result = runOSAScript(census)
      guard result.status == 0 else {
        return nil
      }
      return result.output.split(separator: "\n").map(String.init)
    }

    private static func waitForImport(
      expected: [String],
      before: [String],
      timeout: TimeInterval
    ) async throws {
      var warnedAlertCheckUnavailable = false
      let deadline = Date().addingTimeInterval(timeout)
      while Date() < deadline {
        if let message = rejectionAlertText(warned: &warnedAlertCheckUnavailable) {
          dismissRejectionAlert()
          throw FCPXMLDSLCommandError.importRejected(message)
        }
        let after = currentProjectNames() ?? before
        let imported = FCPScriptedLibrary.newlyImportedNames(
          expected: expected,
          before: before,
          after: after
        )
        if !imported.isEmpty {
          print("Import verified: \(imported.joined(separator: ", ")) now in the library.")
          return
        }
        try await Task.sleep(nanoseconds: 1_000_000_000)
      }
      throw FCPXMLDSLCommandError.importTimedOut(expected.joined(separator: ", "))
    }

    private static func rejectionAlertText(warned: inout Bool) -> String? {
      let query = """
        tell application "System Events"
          set fcp to first application process ¬
            whose bundle identifier is "\(FCPApplication.bundleIdentifier)"
          set collected to ""
          repeat with w in windows of fcp
            repeat with t in static texts of w
              set collected to collected & (value of t) & linefeed
            end repeat
          end repeat
          return collected
        end tell
        """
      let result = runOSAScript(query)
      guard result.status == 0 else {
        if !warned {
          warned = true
          print("warning: alert check unavailable; grant Accessibility to detect rejections")
        }
        return nil
      }
      guard result.output.contains("could not be imported") else {
        return nil
      }
      return result.output.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func dismissRejectionAlert() {
      let click = """
        tell application "System Events"
          set fcp to first application process ¬
            whose bundle identifier is "\(FCPApplication.bundleIdentifier)"
          click button "OK" of window 1 of fcp
        end tell
        """
      _ = runOSAScript(click)
    }

    private static func runOpenTool(_ arguments: [String]) throws {
      let process = Process()
      process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
      process.arguments = arguments
      try process.run()
      process.waitUntilExit()
      guard process.terminationStatus == 0 else {
        throw FCPXMLDSLCommandError.finalCutUnavailable
      }
    }

    private static func runOSAScript(_ script: String) -> (status: Int32, output: String) {
      let process = Process()
      process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
      process.arguments = ["-e", script]
      let pipe = Pipe()
      process.standardOutput = pipe
      process.standardError = Pipe()
      do {
        try process.run()
      } catch {
        return (1, "")
      }
      process.waitUntilExit()
      let data = pipe.fileHandleForReading.readDataToEndOfFile()
      return (process.terminationStatus, String(decoding: data, as: UTF8.self))
    }
  #else
    /// Import verification requires macOS (ScriptingBridge and Final Cut Pro).
    internal static func verifyImport(
      positionals: [String],
      options: [String: String]
    ) async throws {
      throw FCPXMLDSLCommandError.unsupportedPlatform
    }
  #endif
}
