//
//  MulticamXMLBuilder+Library.swift
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

#if canImport(CoreMedia)
  import CoreMedia

  extension MulticamXMLBuilder {
    /// Builds the library tree: event, project, sequence and multicam clip.
    internal func buildLibrary(projectName: String, context: BuildContext) -> Library {
      Library(
        location: "file:///Users/Shared/Generated.fcpbundle/",
        events: [
          Event(
            name: projectName,
            uid: context.eventUID,
            refClips: [
              RefClip(
                ref: "r1",
                name: "Both",
                duration: context.maxDuration,
                modDate: context.currentTime,
                useAudioSubroles: "1"
              ),
              RefClip(
                ref: "r3",
                name: context.leftName,
                duration: context.leftDuration,
                modDate: context.currentTime,
                useAudioSubroles: "1"
              ),
              RefClip(
                ref: "r5",
                name: context.rightName,
                duration: context.rightDuration,
                modDate: context.currentTime,
                useAudioSubroles: "1"
              ),
            ],
            mcClips: [
              MCClip(
                ref: "r8",
                name: "Multicam Clip",
                duration: context.maxDuration,
                modDate: context.currentTime,
                mcSources: [
                  MCSource(angleID: context.angleBothID, srcEnable: "all")
                ]
              )
            ]
          )
        ]
      )
    }
  }
#endif
