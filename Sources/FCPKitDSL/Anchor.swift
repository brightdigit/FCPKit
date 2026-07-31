//
//  Anchor.swift
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

internal struct Anchor: DSLNode {
  internal let lane: Int
  internal let offset: FCPTime
  internal let content: any DSLNode
  internal func build(_ resources: inout ResourceStore) throws -> Built {
    guard lane != 0 else { throw BuildError.invalidLane }
    switch try content.build(&resources) {
    case .item(.title(var title)):
      title.lane = String(lane)
      title.offset = offset.description
      return .item(.title(title))
    case .item(.assetClip(var clip)):
      clip.lane = String(lane)
      clip.offset = offset.description
      return .item(.assetClip(clip))
    case .spine(let spine): return .spine(spine)
    default: throw BuildError.unsupportedContent
    }
  }
}
