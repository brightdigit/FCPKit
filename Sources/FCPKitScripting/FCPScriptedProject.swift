//
//  FCPScriptedProject.swift
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

/// A Final Cut Pro project referencing a primary sequence.
public struct FCPScriptedProject: Hashable, Sendable {
  /// The project display name from Final Cut Pro.
  public var name: String

  /// The project unique identifier from Final Cut Pro.
  public var id: String

  /// The stable hexadecimal persistent identifier from Final Cut Pro.
  public var persistentID: String

  /// The project's primary sequence when present.
  public var sequence: FCPScriptedSequence?

  /// Creates a scripted project snapshot.
  public init(
    name: String,
    id: String,
    persistentID: String,
    sequence: FCPScriptedSequence? = nil
  ) {
    self.name = name
    self.id = id
    self.persistentID = persistentID
    self.sequence = sequence
  }
}
