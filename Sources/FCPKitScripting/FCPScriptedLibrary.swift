//
//  FCPScriptedLibrary.swift
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

/// A Final Cut Pro library as exposed by the scripting dictionary.
public struct FCPScriptedLibrary: Hashable, Sendable {
  /// The library display name from Final Cut Pro.
  public var name: String

  /// The library unique identifier from Final Cut Pro.
  public var id: String

  /// The stable hexadecimal persistent identifier from Final Cut Pro.
  ///
  /// Declared in the scripting dictionary but not returned by current
  /// Final Cut Pro releases, so live inspection yields `nil`.
  public var persistentID: String?

  /// The on-disk library bundle URL when available.
  public var fileURL: URL?

  /// Events contained in the library.
  public var events: [FCPScriptedEvent]

  /// Creates a scripted library snapshot.
  public init(
    name: String,
    id: String,
    persistentID: String? = nil,
    fileURL: URL? = nil,
    events: [FCPScriptedEvent] = []
  ) {
    self.name = name
    self.id = id
    self.persistentID = persistentID
    self.fileURL = fileURL
    self.events = events
  }
}
