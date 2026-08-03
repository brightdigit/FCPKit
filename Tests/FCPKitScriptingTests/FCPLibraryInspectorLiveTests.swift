//
//  FCPLibraryInspectorLiveTests.swift
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

  import FCPKitScripting
  import Testing

  @Suite
  internal struct FCPLibraryInspectorLiveTests {
    @Test
    internal func readsLibrariesWhenFinalCutIsRunning() throws {
      guard FCPLibraryInspector.isFinalCutRunning() else {
        return
      }
      let inspector = FCPLibraryInspector()
      let libraries = try inspector.libraries()
      // Final Cut always has at least the current library open, and every
      // scripted object must surface non-empty name/id term properties.
      #expect(!libraries.isEmpty)
      for library in libraries {
        #expect(!library.name.isEmpty)
        #expect(!library.id.isEmpty)
        for event in library.events {
          #expect(!event.name.isEmpty)
          #expect(!event.id.isEmpty)
        }
      }
    }

    @Test
    internal func applicationEntryMatchesInspectorRunningCheck() {
      #expect(FCPApplication.isFinalCutRunning() == FCPLibraryInspector.isFinalCutRunning())
    }
  }

#endif
