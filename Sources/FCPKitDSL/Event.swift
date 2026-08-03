//
//  Event.swift
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

/// An event shell around a project.
public struct Event: DSLNode {
  internal let name: String?
  internal let uid: String?
  internal let content: DocumentGroup

  /// Creates an event with optional name and uid.
  public init(
    name: String? = nil, uid: String? = nil, @DocumentBuilder content: () -> DocumentGroup
  ) {
    self.name = name
    self.uid = uid
    self.content = content()
  }

  internal func build(_ resources: inout ResourceStore) throws(BuildError) -> Built {
    let built = try content.build(&resources)
    let project = try project(from: built)
    return .event(FCPKit.Event(name: name ?? "Untitled", uid: uid, projects: [project]))
  }

  private func project(from built: Built) throws(BuildError) -> FCPKit.Project {
    switch built {
    case .project(let project): return project
    case .sequence(let sequence): return FCPKit.Project(name: "Untitled", sequence: sequence)
    default: throw BuildError.unsupportedContent
    }
  }
}
