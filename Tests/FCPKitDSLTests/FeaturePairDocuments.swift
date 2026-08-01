//
//  FeaturePairDocuments.swift
//  FCPKitDSLTests
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

internal enum FeaturePairDocuments {
  internal struct Transitions: Document {
    internal let left: FCPKit.Asset
    internal let right: FCPKit.Asset
    internal let format1080: FCPKit.Format
    internal let format720: FCPKit.Format
    internal let libraryLocation: String?
    internal let eventName: String?
    internal let eventUID: String?
    internal let projectName: String?
    internal let projectUID: String?
    internal let projectModDate: String?

    internal var body: some DocumentContent {
      Library(location: libraryLocation, colorProcessing: .wideHDR) {
        Event(name: eventName, uid: eventUID) {
          Project(name: projectName, uid: projectUID, modDate: projectModDate) {
            Sequence(format: FormatPreset(format1080)) {
              AssetClip(left, format: format1080).audioRole("dialogue")
              Transition(.crossDissolve)
              AssetClip(right, format: format720, formatOnClip: true).audioRole("dialogue")
            }
          }
        }
      }
    }
  }

  internal struct Titles: Document {
    internal let left: FCPKit.Asset
    internal let format1080: FCPKit.Format
    internal let libraryLocation: String?
    internal let eventName: String?
    internal let eventUID: String?
    internal let projectName: String?
    internal let projectUID: String?
    internal let projectModDate: String?

    internal var body: some DocumentContent {
      Library(location: libraryLocation, colorProcessing: .wideHDR) {
        Event(name: eventName, uid: eventUID) {
          Project(name: projectName, uid: projectUID, modDate: projectModDate) {
            Sequence(format: FormatPreset(format1080)) {
              AssetClip(left, format: format1080)
                .audioRole("dialogue")
                .anchor(lane: 1) {
                  Title(
                    .basic,
                    text: "Title",
                    duration: FCPTime(numerator: 24_100, denominator: 2_400)
                  )
                }
            }
          }
        }
      }
    }
  }
}
