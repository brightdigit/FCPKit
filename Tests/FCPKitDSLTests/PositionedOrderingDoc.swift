//
//  PositionedOrderingDoc.swift
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
import FCPKitDSL
import Foundation

/// A clip / transition / clip spine where the clips carry deferred positions.
///
/// The v0.1.0 Step 3 ordering guarantee is that `Spine.items` keeps DTD order.
/// Position resolution rewrites title elements on the way out, so these tests
/// assert order survives *after* resolution — the schema-completeness inventory
/// is order-blind and would not catch a reordering here.
internal struct PositionedOrderingDoc: Document {
  internal var body: some DocumentContent {
    Sequence(format: .p1080p24) {
      Title("First").duration(.seconds(5)).position(.topLeading)
      Transition(.crossDissolve)
      Title("Second").duration(.seconds(5)).position(x: 200, y: 300)
    }
  }
}
