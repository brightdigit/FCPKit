//
//  FCPXMLDSLCommand+Usage.swift
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

extension FCPXMLDSLCommand {
  internal static func printUsage() {
    // swiftlint:disable indentation_width
    print(
      """
      fcpxml-dsl - Export FCPKitDSL documents to FCPXML for Final Cut import

      USAGE:
          fcpxml-dsl export transitions <left> <right> [output.fcpxml]
          fcpxml-dsl export titles <media> [output.fcpxml]
          fcpxml-dsl export rgb [output.fcpxml]
          fcpxml-dsl export presentation [output.fcpxml]
          fcpxml-dsl verify-import <file.fcpxml>

      OPTIONS:
          --project <name>   Project name (defaults per kind; verify-import: expected name)
          --text <string>    Title text for `titles` (default: Title)
          --version <ver>    FCPXML version (default: 1.14)
          --timeout <sec>    verify-import wait in seconds (default: 30)
          -h, --help         Show this help

      EXAMPLES:
          fcpxml-dsl export transitions Left.mov Right.mov transitions.fcpxml
          fcpxml-dsl export titles Left.mov titles.fcpxml --text "Hello"
          fcpxml-dsl export rgb rgb.fcpxml
          fcpxml-dsl export presentation presentation.fcpxml
          fcpxml-dsl verify-import presentation.fcpxml

      DESCRIPTION:
          `export` probes media durations with AVFoundation, builds a typed DSL
          document, and writes FCPXML you can import into Final Cut Pro.

          `verify-import` opens the file in Final Cut Pro and confirms the
          project appears in the library (needs Automation permission; the
          rejection alert check also needs Accessibility). The import lands in
          the active library and must be cleaned up manually.
      """
    )
    // swiftlint:enable indentation_width
  }
}
