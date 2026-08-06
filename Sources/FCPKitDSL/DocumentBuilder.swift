//
//  DocumentBuilder.swift
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

/// Builds a document or story body from declarative child values.
@resultBuilder
public enum DocumentBuilder {
  /// Joins child content values into a ``DocumentGroup``, flattening nested groups.
  public static func buildBlock(_ components: any DocumentContent...) -> DocumentGroup {
    DocumentGroup(
      components.flatMap { component -> [any DocumentContent] in
        if let group = component as? DocumentGroup {
          return group.contents
        }
        return [component]
      }
    )
  }

  /// Passes an expression through as document content.
  public static func buildExpression(_ expression: any DocumentContent) -> any DocumentContent {
    expression
  }

  /// Builds an optional child for `if` without `else`.
  public static func buildOptional(_ component: DocumentGroup?) -> DocumentGroup {
    component ?? DocumentGroup([])
  }

  /// Builds the first branch of `if`/`else`.
  public static func buildEither(first component: DocumentGroup) -> DocumentGroup {
    component
  }

  /// Builds the second branch of `if`/`else`.
  public static func buildEither(second component: DocumentGroup) -> DocumentGroup {
    component
  }

  /// Flattens `for`/`in` results into one group.
  public static func buildArray(_ components: [DocumentGroup]) -> DocumentGroup {
    DocumentGroup(components.flatMap(\.contents))
  }
}
