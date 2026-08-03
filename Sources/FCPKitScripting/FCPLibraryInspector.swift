//
//  FCPLibraryInspector.swift
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
import Foundation

#if os(macOS)
  import AppKit
  import ScriptingBridge
#endif

/// Read-only inspector for Final Cut Pro's library → event → project/sequence hierarchy.
///
/// Every call requires Final Cut Pro to be running. There is no AppleScript export automation.
public struct FCPLibraryInspector: Sendable {
  private let applicationProvider: @Sendable () throws -> any FCPScriptingObject
  private let requiresRunning: Bool

  /// Creates an inspector that talks to the running Final Cut Pro application.
  public init() {
    #if os(macOS)
      self.applicationProvider = FCPLibraryInspector.liveApplication
    #else
      self.applicationProvider = { throw FCPScriptingError.unsupportedPlatform }
    #endif
    self.requiresRunning = true
  }

  internal init(
    applicationProvider: @escaping @Sendable () throws -> any FCPScriptingObject,
    requiresRunning: Bool = false
  ) {
    self.applicationProvider = applicationProvider
    self.requiresRunning = requiresRunning
  }

  /// Returns whether Final Cut Pro is currently running.
  public static func isFinalCutRunning() -> Bool {
    #if os(macOS)
      !NSRunningApplication.runningApplications(
        withBundleIdentifier: FCPApplication.bundleIdentifier
      ).isEmpty
    #else
      false
    #endif
  }

  #if os(macOS)
    private static func liveApplication() throws -> any FCPScriptingObject {
      guard let application = SBApplication(bundleIdentifier: FCPApplication.bundleIdentifier)
      else {
        throw FCPScriptingError.finalCutNotRunning
      }
      guard application.isRunning else {
        throw FCPScriptingError.finalCutNotRunning
      }
      return application
    }

    private static func library(from object: any FCPScriptingObject) throws -> FCPScriptedLibrary {
      FCPScriptedLibrary(
        name: try object.string(forKey: "name"),
        id: try object.string(forKey: "id"),
        persistentID: try? object.string(forKey: "persistentID"),
        fileURL: try object.url(forKey: "file"),
        events: try object.children(forKey: "events").map { try event(from: $0) }
      )
    }

    private static func event(from object: any FCPScriptingObject) throws -> FCPScriptedEvent {
      FCPScriptedEvent(
        name: try object.string(forKey: "name"),
        id: try object.string(forKey: "id"),
        persistentID: try? object.string(forKey: "persistentID"),
        projects: try object.children(forKey: "projects").map { try project(from: $0) },
        sequences: try object.children(forKey: "sequences").compactMap { try sequence(from: $0) }
      )
    }

    private static func project(from object: any FCPScriptingObject) throws -> FCPScriptedProject {
      let sequenceObjects = try object.children(forKey: "sequence")
      let sequence = try sequenceObjects.first.flatMap { try sequence(from: $0) }
      return FCPScriptedProject(
        name: try object.string(forKey: "name"),
        id: try object.string(forKey: "id"),
        persistentID: try? object.string(forKey: "persistentID"),
        sequence: sequence
      )
    }

    private static func sequence(from object: any FCPScriptingObject) throws -> FCPScriptedSequence?
    {
      guard let duration = try object.mediaTime(forKey: "duration"),
        let frameDuration = try object.mediaTime(forKey: "frameDuration")
      else {
        return nil
      }
      return FCPScriptedSequence(
        name: try object.string(forKey: "name"),
        id: try object.string(forKey: "id"),
        startTime: try object.mediaTime(forKey: "startTime"),
        duration: duration,
        frameDuration: frameDuration,
        timecodeFormat: try object.timecodeFormat(forKey: "timecodeFormat")
      )
    }
  #endif

  /// Reads all open libraries and their events, projects, and sequences.
  public func libraries() throws -> [FCPScriptedLibrary] {
    if requiresRunning && !Self.isFinalCutRunning() {
      throw FCPScriptingError.finalCutNotRunning
    }
    #if os(macOS)
      let application = try applicationProvider()
      return try application.children(forKey: "libraries").map { try Self.library(from: $0) }
    #else
      throw FCPScriptingError.unsupportedPlatform
    #endif
  }
}
