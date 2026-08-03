//
//  Built+Promotion.swift
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

extension Built {
  /// Wraps a sequence in the default project, event, and library shells.
  private static func library(
    wrapping sequence: FCPKit.Sequence,
    version: FCPXMLVersion
  ) -> FCPKit.Library {
    library(wrapping: FCPKit.Project(name: "Untitled", sequence: sequence), version: version)
  }

  /// Wraps a project in the default event and library shells.
  private static func library(
    wrapping project: FCPKit.Project,
    version: FCPXMLVersion
  ) -> FCPKit.Library {
    FCPKit.Library(
      events: [FCPKit.Event(name: "Untitled", projects: [project])],
      smartCollections: version.defaultSmartCollections
    )
  }

  /// Synthesizes the sequence shell for a spine, interning the default format.
  private static func sequence(
    wrapping spine: FCPKit.Spine,
    resources: inout ResourceStore
  ) throws(BuildError) -> FCPKit.Sequence {
    try ModelSequence(packing: spine, format: try resources.format(.p1080p24))
  }

  /// Wraps this value in whatever shells it needs to become a `<library>`.
  ///
  /// A document may be authored at any rung of the FCPXML hierarchy — a bare
  /// story item is as valid as a full library — so each case enters the ladder
  /// at its own level and folds upward:
  /// item → spine → sequence → project → event → library.
  ///
  /// - Parameter resources: The document's resource table. Promotion may intern
  ///   a format when it has to synthesize a sequence.
  /// - Returns: The promoted library.
  /// - Throws: ``BuildError`` when an item cannot be packed onto a timeline.
  internal func promotedLibrary(
    resources: inout ResourceStore
  ) throws(BuildError) -> FCPKit.Library {
    let version = resources.version
    switch self {
    case .library(let library):
      return library
    case .event(let event):
      return FCPKit.Library(events: [event], smartCollections: version.defaultSmartCollections)
    case .project(let project):
      return Self.library(wrapping: project, version: version)
    case .sequence(let sequence):
      return Self.library(wrapping: sequence, version: version)
    case .spine(let spine):
      let sequence = try Self.sequence(wrapping: spine, resources: &resources)
      return Self.library(wrapping: sequence, version: version)
    case .item(let item):
      let sequence = try Self.sequence(
        wrapping: FCPKit.Spine(items: [item]),
        resources: &resources
      )
      return Self.library(wrapping: sequence, version: version)
    }
  }
}
