//
//  SBObject+FCPScriptingObject.swift
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

#if os(macOS)

  import FCPKit
  import Foundation
  import ScriptingBridge

  extension SBObject: FCPScriptingObject {
    internal func string(forKey key: String) throws -> String {
      guard let value = value(forKey: key) else {
        throw FCPScriptingError.propertyUnavailable(key)
      }
      switch value {
      case let text as String:
        return text
      case let text as NSString:
        return text as String
      case let number as NSNumber:
        return number.stringValue
      default:
        return String(describing: value)
      }
    }

    internal func url(forKey key: String) throws -> URL? {
      guard let value = value(forKey: key) else {
        return nil
      }
      if let url = value as? URL {
        return url
      }
      if let url = value as? NSURL {
        return url as URL
      }
      if let text = value as? String {
        return URL(string: text)
      }
      return nil
    }

    internal func mediaTime(forKey key: String) throws -> FCPTime? {
      guard let value = value(forKey: key) else {
        return nil
      }
      return FCPScriptingMediaTime.fcpTime(from: value)
    }

    internal func timecodeFormat(forKey key: String) throws -> FCPScriptedTimecodeFormat {
      FCPScriptingTimecodeFormatParser.parse(value(forKey: key))
    }

    internal func children(forKey key: String) throws -> [any FCPScriptingObject] {
      guard let value = value(forKey: key) else {
        return []
      }
      if let array = value as? SBElementArray {
        return array.compactMap { $0 as? SBObject }
      }
      if let object = value as? SBObject {
        return [object]
      }
      return []
    }
  }

#endif
