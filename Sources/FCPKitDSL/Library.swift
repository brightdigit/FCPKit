//
//  Library.swift
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

/// A library shell around an event.
public struct Library: DSLNode {
  internal let location: String?
  internal let colorProcessing: ColorProcessing?
  internal let content: DocumentGroup

  /// Creates a library with optional location and color-processing mode.
  public init(
    location: String? = nil,
    colorProcessing: ColorProcessing? = nil,
    @DocumentBuilder content: () -> DocumentGroup
  ) {
    self.location = location
    self.colorProcessing = colorProcessing
    self.content = content()
  }

  internal func build(_ resources: inout ResourceStore) throws -> Built {
    let built = try content.build(&resources)
    let event = try event(from: built)
    return .library(
      FCPKit.Library(
        location: location,
        colorProcessing: colorProcessing,
        events: [event],
        smartCollections: Defaults.smartCollections()
      )
    )
  }

  private func event(from built: Built) throws -> FCPKit.Event {
    switch built {
    case .event(let event): return event
    case .project(let project): return FCPKit.Event(name: "Untitled", projects: [project])
    case .sequence(let sequence):
      return FCPKit.Event(
        name: "Untitled",
        projects: [FCPKit.Project(name: "Untitled", sequence: sequence)]
      )
    default: throw BuildError.unsupportedContent
    }
  }
}
