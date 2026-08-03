//
//  Title+Modifiers.swift
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

extension Title {
  /// Sets the font family, such as `Helvetica`.
  public func font(_ name: String) -> Title {
    var updated = style
    updated.font = name
    return replacing(style: updated)
  }

  /// Sets the font size in points.
  public func fontSize(_ points: Double) -> Title {
    var updated = style
    updated.fontSize = points
    return replacing(style: updated)
  }

  /// Sets the font face or weight within the family, such as `Bold`.
  public func fontFace(_ face: String) -> Title {
    var updated = style
    updated.fontFace = face
    return replacing(style: updated)
  }

  /// Sets the text color.
  public func fontColor(_ color: Color) -> Title {
    var updated = style
    updated.fontColor = color
    return replacing(style: updated)
  }

  /// Sets the paragraph alignment.
  public func alignment(_ alignment: TitleStyle.Alignment) -> Title {
    var updated = style
    updated.alignment = alignment
    return replacing(style: updated)
  }

  /// Renders the text bold.
  ///
  /// Final Cut writes `fontFace` rather than `bold` for most families, so prefer
  /// ``fontFace(_:)`` with a face known to exist for the chosen font.
  public func bold(_ isBold: Bool = true) -> Title {
    var updated = style
    updated.bold = isBold
    return replacing(style: updated)
  }

  /// Replaces the whole text style.
  public func style(_ style: TitleStyle) -> Title {
    replacing(style: style)
  }

  /// Sets the title clip's display name, independent of its text.
  public func name(_ name: String) -> Title {
    replacing(displayName: name)
  }
}

extension Title {
  /// Positions the title at a frame alignment, optionally inset in points.
  ///
  /// Alignment positions never require a frame size. A centered title with no
  /// inset emits no `adjust-transform` at all.
  public func position(_ alignment: FramePosition.Alignment, inset: Double = 0) -> Title {
    replacing(position: .aligned(alignment, inset: inset))
  }

  /// Positions the title at absolute pixel coordinates, with the origin top-left.
  ///
  /// - Throws: At `export()`, ``BuildError/missingFrameSize`` when the title has
  ///   no enclosing ``Sequence`` format to resolve against.
  public func position(x: Double, y: Double) -> Title {
    replacing(position: .absolute(x: x, y: y))
  }
}
