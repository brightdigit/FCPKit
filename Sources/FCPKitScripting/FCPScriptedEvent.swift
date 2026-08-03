//
//  FCPScriptedEvent.swift
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

import Foundation

/// A Final Cut Pro event containing projects and standalone sequences.
public struct FCPScriptedEvent: Hashable, Sendable {
  /// The event display name from Final Cut Pro.
  public var name: String

  /// The event unique identifier from Final Cut Pro.
  public var id: String

  /// The stable hexadecimal persistent identifier from Final Cut Pro.
  ///
  /// Declared in the scripting dictionary but not returned by current
  /// Final Cut Pro releases, so live inspection yields `nil`.
  public var persistentID: String?

  /// Projects contained in the event.
  public var projects: [FCPScriptedProject]

  /// Standalone sequences contained in the event.
  public var sequences: [FCPScriptedSequence]

  /// Creates a scripted event snapshot.
  public init(
    name: String,
    id: String,
    persistentID: String? = nil,
    projects: [FCPScriptedProject] = [],
    sequences: [FCPScriptedSequence] = []
  ) {
    self.name = name
    self.id = id
    self.persistentID = persistentID
    self.projects = projects
    self.sequences = sequences
  }
}
