//
//  FCPScriptingObjectMock.swift
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
import Foundation

/// In-memory stand-in for ScriptingBridge objects used by unit tests.
internal struct FCPScriptingObjectMock: FCPScriptingObject {
  internal var strings: [String: String] = [:]
  internal var urls: [String: URL] = [:]
  internal var mediaTimes: [String: FCPTime] = [:]
  internal var timecodeFormats: [String: FCPScriptedTimecodeFormat] = [:]
  internal var childObjects: [String: [FCPScriptingObjectMock]] = [:]

  internal func string(forKey key: String) throws -> String {
    guard let value = strings[key] else {
      throw FCPScriptingError.propertyUnavailable(key)
    }
    return value
  }

  internal func url(forKey key: String) throws -> URL? {
    urls[key]
  }

  internal func mediaTime(forKey key: String) throws -> FCPTime? {
    mediaTimes[key]
  }

  internal func timecodeFormat(forKey key: String) throws -> FCPScriptedTimecodeFormat {
    timecodeFormats[key] ?? .unspecified
  }

  internal func children(forKey key: String) throws -> [any FCPScriptingObject] {
    childObjects[key] ?? []
  }
}
