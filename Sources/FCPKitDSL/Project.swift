//
//  Project.swift
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

/// A project shell around a sequence.
public struct Project: DSLNode {
  internal let name: String?
  internal let uid: String?
  internal let modDate: String?
  internal let colorProcessing: ColorProcessing?
  internal let content: DocumentGroup

  /// Creates a project with optional name, uid, and modification date.
  public init(
    name: String? = nil,
    uid: String? = nil,
    modDate: String? = nil,
    @DocumentBuilder content: () -> DocumentGroup
  ) {
    self.init(
      name: name,
      uid: uid,
      modDate: modDate,
      colorProcessing: nil,
      content: content()
    )
  }

  private init(
    name: String?,
    uid: String?,
    modDate: String?,
    colorProcessing: ColorProcessing?,
    content: DocumentGroup
  ) {
    self.name = name
    self.uid = uid
    self.modDate = modDate
    self.colorProcessing = colorProcessing
    self.content = content
  }

  /// Sets the soft-promoted library's color-processing mode.
  ///
  /// When set, export wraps this project in a `<library>` that carries
  /// `colorProcessing` so Final Cut Pro does not treat the document as
  /// standard against a wide-gamut HDR library.
  public func colorProcessing(_ mode: ColorProcessing) -> Project {
    Project(
      name: name,
      uid: uid,
      modDate: modDate,
      colorProcessing: mode,
      content: content
    )
  }

  /// Lowers this project into a `<project>` wrapping its promoted sequence.
  ///
  /// When ``colorProcessing(_:)`` was applied, returns a `<library>` with that
  /// mode so soft-promotion does not drop the attribute.
  public func build(_ resources: inout ResourceStore) throws(BuildError) -> Built {
    guard case .sequence(let sequence) = try content.build(&resources) else {
      throw BuildError.unsupportedContent
    }
    let project = FCPKit.Project(
      name: name ?? "Untitled",
      uid: uid,
      modDate: modDate,
      sequence: sequence
    )
    guard let colorProcessing else {
      return .project(project)
    }
    return .library(
      FCPKit.Library(
        colorProcessing: colorProcessing,
        events: [FCPKit.Event(name: "Untitled", projects: [project])],
        smartCollections: resources.version.defaultSmartCollections
      )
    )
  }
}
