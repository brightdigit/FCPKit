//
//  DocumentGroup.swift
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

/// A group of declarative document or story children.
public struct DocumentGroup: DocumentContent, DSLNode {
  internal let contents: [any DocumentContent]

  /// Creates a group from already-built content values.
  public init(_ contents: [any DocumentContent]) {
    self.contents = contents
  }

  /// Lowers this group's single child, or a synthesized spine of its children.
  public func build(_ resources: inout ResourceStore) throws(BuildError) -> Built {
    if contents.count == 1, let node = contents[0] as? any DSLNode {
      return try node.build(&resources)
    }
    let items = try contents.spineItems(resources: &resources)
    let packed = try Layout.pack(items, frameDuration: FormatPreset.p1080p24.format.frameDuration)
    return .spine(FCPKit.Spine(items: packed.items))
  }
}
