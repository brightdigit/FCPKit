//
//  DSLNode.swift
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

/// A piece of DSL content that can lower itself into FCPXML model values.
///
/// Conformance is an implementation detail of the built-in DSL types. The protocol is
/// `public` only so that public API such as ``StoryItem`` can name it; the pieces it
/// hands you (``ResourceStore``) expose no usable members outside this module.
public protocol DSLNode: DocumentContent {
  /// Lowers this node into a ``Built`` value, registering any resources it needs.
  ///
  /// - Parameter resources: The document's shared resource table, mutated in place as
  ///   assets, formats, and effects are interned.
  /// - Returns: The model value this node lowers to.
  /// - Throws: A ``BuildError`` when the node is incomplete or cannot be represented.
  /// - Warning: This signature is expected to evolve before 1.0.
  func build(_ resources: inout ResourceStore) throws(BuildError) -> Built
}
