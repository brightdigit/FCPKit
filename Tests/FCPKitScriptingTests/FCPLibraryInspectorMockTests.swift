//
//  FCPLibraryInspectorMockTests.swift
//  FCPKitScriptingTests
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

#if os(macOS)

  import FCPKit
  @testable import FCPKitScripting
  import Foundation
  import Testing

  @Suite
  internal struct FCPLibraryInspectorMockTests {
    private static var sampleApplication: FCPScriptingObjectMock {
      let sequence = FCPScriptingObjectMock(
        strings: [
          "displayName": "Main Sequence",
          "mediaIdentifier": "seq-1",
        ],
        mediaTimes: [
          "durationDict": FCPTime(numerator: 240, denominator: 24),
          "frameDurationDict": FCPTime(numerator: 1, denominator: 24),
          "startTimeDict": FCPTime(numerator: 0, denominator: 1),
        ],
        timecodeFormats: ["timecodeFormat": .dropFrame]
      )
      let project = FCPScriptingObjectMock(
        strings: [
          "displayName": "Project A",
          "uniqueIdentifier": "proj-1",
          "persistent ID": "deadbeef",
        ],
        childObjects: ["sequence": [sequence]]
      )
      let event = FCPScriptingObjectMock(
        strings: [
          "displayName": "Event 1",
          "uniqueIdentifier": "event-1",
          "persistent ID": "cafebabe",
        ],
        childObjects: [
          "projects": [project],
          "sequences": [sequence],
        ]
      )
      let library = FCPScriptingObjectMock(
        strings: [
          "displayName": "Library",
          "uniqueIdentifier": "lib-1",
          "persistent ID": "feedface",
        ],
        urls: ["URL": URL(fileURLWithPath: "/tmp/Library.fcpbundle")],
        childObjects: ["events": [event]]
      )
      return FCPScriptingObjectMock(childObjects: ["libraries": [library]])
    }

    @Test
    internal func mapsMockHierarchy() throws {
      let inspector = FCPLibraryInspector(applicationProvider: { Self.sampleApplication })
      let libraries = try inspector.libraries()
      #expect(libraries.count == 1)
      #expect(libraries[0].name == "Library")
      #expect(libraries[0].fileURL?.path == "/tmp/Library.fcpbundle")
      #expect(libraries[0].events.count == 1)
      #expect(libraries[0].events[0].projects.count == 1)
      #expect(libraries[0].events[0].projects[0].sequence?.name == "Main Sequence")
      #expect(libraries[0].events[0].sequences[0].timecodeFormat == .dropFrame)
      #expect(libraries[0].events[0].sequences[0].frameDuration.description == "1/24s")
    }

    @Test
    internal func defaultInspectorRequiresFinalCutRunning() throws {
      guard !FCPLibraryInspector.isFinalCutRunning() else {
        return
      }
      let inspector = FCPLibraryInspector()
      #expect(throws: FCPScriptingError.finalCutNotRunning) {
        _ = try inspector.libraries()
      }
    }
  }

#endif
