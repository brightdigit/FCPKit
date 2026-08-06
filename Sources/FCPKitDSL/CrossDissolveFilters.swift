//
//  CrossDissolveFilters.swift
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

internal enum CrossDissolveFilters {
  private static let effectConfig = [
    "YnBsaXN0MDDUAQIDBAUGBwpYJHZlcnNpb25ZJGFyY2hpdmVyVCR0b3BYJG9iamVjdHMSAAGGoF8QD05T",
    "S2V5ZWRBcmNoaXZlctEICVRyb290gAGlCwwVFhdVJG51bGzTDQ4PEBIUV05TLmtleXNaTlMub2JqZWN0",
    "c1YkY2xhc3OhEYACoROAA4AEXXBsdWdpblZlcnNpb24QAdIYGRobWiRjbGFzc25hbWVYJGNsYXNzZXNf",
    "EBNOU011dGFibGVEaWN0aW9uYXJ5oxocHVxOU0RpY3Rpb25hcnlYTlNPYmplY3QIERokKTI3SUxRU1lf",
    "Zm55gIKEhoiKmJqfqrPJzdoAAAAAAAABAQAAAAAAAAAeAAAAAAAAAAAAAAAAAAAA4w==",
  ].joined()
  internal static func make(video: ResourceRef<EffectKind>, audio: ResourceRef<EffectKind>)
    -> ([FilterVideo]?, [FilterAudio]?)
  {
    (
      [
        FilterVideo(
          ref: video,
          name: "Cross Dissolve",
          data: [DataElement(key: "effectConfig", value: effectConfig)],
          param: [
            // Flexo Look indices: 11 = Shadows, 12 = Video. Older exports
            // mislabeled `"11 (Video)"`; FCP 12.x rejects that as unexpected.
            ParamElement(name: "Look", key: "1", value: "12 (Video)"),
            ParamElement(name: "Amount", key: "2", value: "50"),
            ParamElement(name: "Ease", key: "50", value: "2 (In & Out)"),
            ParamElement(name: "Ease Amount", key: "51", value: "0"),
            ParamElement(name: "disableDRT", key: "3733", value: "1"),
          ]
        )
      ],
      [FilterAudio(ref: audio, name: "Audio Crossfade")]
    )
  }
}
