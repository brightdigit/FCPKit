//
//  SoftPromote.swift
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

/// Promotes a partially specified document into a full library.
internal enum SoftPromote {
  /// Wraps a built value in whatever shells it needs to become a `<library>`.
  internal static func promote(
    _ built: Built,
    resources: inout ResourceStore
  ) throws -> FCPKit.Library {
    switch built {
    case .library(let library):
      return library
    case .event(let event):
      return FCPKit.Library(
        events: [event],
        smartCollections: Defaults.smartCollections(version: resources.version)
      )
    case .project(let project):
      return library(
        for: FCPKit.Event(name: "Untitled", projects: [project]),
        version: resources.version
      )
    case .sequence(let sequence):
      return library(for: project(for: sequence), version: resources.version)
    case .spine(let spine):
      let version = resources.version
      let generatedSequence = try sequence(for: spine, resources: &resources)
      return library(for: project(for: generatedSequence), version: version)
    case .item(let item):
      let packed = try Layout.pack(
        [item],
        frameDuration: FormatPreset.p1080p24.format.frameDuration
      )
      let spine = FCPKit.Spine(items: packed.items)
      let version = resources.version
      let generatedSequence = try sequence(for: spine, resources: &resources)
      return library(for: project(for: generatedSequence), version: version)
    }
  }

  private static func library(for project: FCPKit.Project, version: FCPXMLVersion) -> FCPKit.Library
  {
    library(for: FCPKit.Event(name: "Untitled", projects: [project]), version: version)
  }

  private static func library(for event: FCPKit.Event, version: FCPXMLVersion) -> FCPKit.Library {
    FCPKit.Library(events: [event], smartCollections: Defaults.smartCollections(version: version))
  }

  private static func project(for sequence: FCPKit.Sequence) -> FCPKit.Project {
    FCPKit.Project(name: "Untitled", sequence: sequence)
  }

  private static func sequence(
    for spine: FCPKit.Spine,
    resources: inout ResourceStore
  ) throws -> FCPKit.Sequence {
    try Defaults.sequence(spine: spine, format: resources.format(.p1080p24))
  }
}
