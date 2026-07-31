//
//  FCPTimeIntervalTests.swift
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
import Foundation
import Testing

@Suite
internal struct FCPTimeIntervalTests {
  @Test
  internal func secondsMinutesHoursConstructors() {
    #expect(FCPTime.seconds(5).description == "5s")
    #expect(FCPTime.seconds(5.5).description == "5500/1000s")
    #expect(FCPTime.minutes(2).description == "120s")
    #expect(FCPTime.hours(1).description == "3600s")
  }

  @Test
  internal func timeIntervalAndDurationInitializers() {
    let interval: TimeInterval = 10.0
    #expect(FCPTime(interval).description == "10s")

    if #available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *) {
      let duration = Duration.seconds(15)
      #expect(FCPTime(duration).description == "15s")
    }
  }

  @Test
  internal func universalDurationModifiersOnDSLNodes() throws {
    let title = Title(.basic, text: "Title").duration(.seconds(4))
    #expect(title.duration == FCPTime.seconds(4))

    let gap = Gap().duration(TimeInterval(3.0))
    #expect(gap.duration == FCPTime.seconds(3))

    let color = Color.red.duration(2)
    #expect(color.duration == FCPTime.seconds(2))

    if #available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *) {
      let transition = Transition(.crossDissolve).duration(Duration.seconds(1))
      #expect(transition.duration == FCPTime.seconds(1))
    }
  }

  private struct TestRGBDocument: Document {
    var body: some DocumentContent {
      Project {
        Sequence {
          Color.red.duration(.seconds(5.0))
          Transition(.crossDissolve)
          Color.green.duration(.seconds(5.0))
          Transition(.crossDissolve)
          Color.blue.duration(.seconds(5.0))
        }
      }
    }
  }

  @Test
  internal func rgbDocumentExportsThreeColorGeneratorsAndTransitions() throws {
    let doc = TestRGBDocument()
    let exported = try doc.export()

    let sequence = try #require(exported.library?.events?.first?.projects?.first?.sequence)
    let spine = try #require(sequence.spine)
    #expect(spine.items.count == 5)

    guard case .video(let g1) = spine.items[0] else {
      Issue.record("Expected spine item 0 to be video generator")
      return
    }
    #expect(g1.offset == "0s")
    #expect(g1.param?.first?.value == "1 0 0")

    guard case .transition(let t1) = spine.items[1] else {
      Issue.record("Expected spine item 1 to be transition")
      return
    }
    #expect(t1.offset == "4s")

    guard case .video(let g2) = spine.items[2] else {
      Issue.record("Expected spine item 2 to be video generator")
      return
    }
    #expect(g2.offset == "10800/2400s")
    #expect(g2.param?.first?.value == "0 1 0")

    guard case .transition(let t2) = spine.items[3] else {
      Issue.record("Expected spine item 3 to be transition")
      return
    }
    #expect(t2.offset == "8s")

    guard case .video(let g3) = spine.items[4] else {
      Issue.record("Expected spine item 4 to be video generator")
      return
    }
    #expect(g3.offset == "20400/2400s")
    #expect(g3.param?.first?.value == "0 0 1")
  }
}
