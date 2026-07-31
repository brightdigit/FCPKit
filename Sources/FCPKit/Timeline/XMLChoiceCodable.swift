//
//  XMLChoiceCodable.swift
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
import XMLCoder

/// An XML choice enum decoded and encoded via a ``XMLChoiceField`` table.
internal protocol XMLChoiceCodable: Codable {
  associatedtype ChoiceKey: CodingKey & XMLChoiceCodingKey
  /// Field handlers attempted in declaration order.
  static var choiceFields: [XMLChoiceField<Self, ChoiceKey>] { get }
  /// Value used when no known choice key is present.
  static var unsupportedChoice: Self { get }
}

extension XMLChoiceCodable {
  /// Decodes by selecting the first matching ``choiceFields`` entry.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: ChoiceKey.self)
    for field in Self.choiceFields where container.contains(field.key) {
      self = try field.decode(from: container)
      return
    }
    self = Self.unsupportedChoice
  }

  /// Encodes by writing the first matching ``choiceFields`` entry.
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: ChoiceKey.self)
    for field in Self.choiceFields where try field.encode(self, into: &container) {
      return
    }
  }
}
