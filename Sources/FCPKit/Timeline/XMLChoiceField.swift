//
//  XMLChoiceField.swift
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

/// A type-erased decode/encode handler for one XML choice element.
///
/// Choice enums store a table of these fields and walk it with a for-loop
/// instead of multi-branch `if` / `switch` ladders.
internal struct XMLChoiceField<Item, Key: CodingKey> {
  internal let key: Key
  private let decodeFrom: (KeyedDecodingContainer<Key>) throws -> Item
  private let encodeInto: (Item, inout KeyedEncodingContainer<Key>) throws -> Bool

  /// Creates a field that wraps and unwraps an associated `Payload` value.
  internal init<Payload: Codable>(
    key: Key,
    wrap: @escaping (Payload) -> Item,
    unwrap: @escaping (Item) -> Payload?
  ) {
    self.key = key
    self.decodeFrom = { container in
      wrap(try container.decode(Payload.self, forKey: key))
    }
    self.encodeInto = { item, container in
      guard let payload = unwrap(item) else {
        return false
      }
      try container.encode(payload, forKey: key)
      return true
    }
  }

  /// Decodes the payload for this field's key and wraps it as `Item`.
  internal func decode(from container: KeyedDecodingContainer<Key>) throws -> Item {
    try decodeFrom(container)
  }

  /// Encodes `item` when it matches this field; returns whether a value was written.
  internal func encode(
    _ item: Item,
    into container: inout KeyedEncodingContainer<Key>
  ) throws -> Bool {
    try encodeInto(item, &container)
  }
}

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
