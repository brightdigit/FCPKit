//
//  FCPApplication.swift
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

/// Final Cut Pro application access for the read-only ScriptingBridge inspector.
///
/// Consuming macOS apps must declare `NSAppleEventsUsageDescription` in `Info.plist` and include
/// the `com.apple.security.automation.apple-events` entitlement so ScriptingBridge can talk to
/// Final Cut Pro. See the README Scripting section for details.
public enum FCPApplication {
  /// Bundle identifier for Final Cut Pro (including Creator Studio installs).
  public static let bundleIdentifier = "com.apple.FinalCutApp"

  /// Returns whether Final Cut Pro is currently running.
  public static func isFinalCutRunning() -> Bool {
    #if os(macOS)
      return FCPLibraryInspector.isFinalCutRunning()
    #else
      return false
    #endif
  }
}
