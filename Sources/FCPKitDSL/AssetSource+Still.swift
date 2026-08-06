//
//  AssetSource+Still.swift
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

extension AssetSource {
  /// An image still as Final Cut Pro expects it: `duration="0s"`, `hasVideo`,
  /// `videoSources="1"`, and a `FFVideoFormatRateUndefined` format.
  ///
  /// ``AssetClip`` lowers stills to spine `<video>` (not `<asset-clip>`),
  /// matching real Final Cut still PNG exports. URL-only
  /// ``AssetSource/init(url:name:duration:id:)`` is for movies. Storyline
  /// length comes from ``AssetClip/duration(_:)`` (required for stills).
  ///
  /// - Parameters:
  ///   - url: On-disk image URL written into `media-rep/@src`.
  ///   - width: Pixel width of the still (and its format resource).
  ///   - height: Pixel height of the still (and its format resource).
  ///   - name: Browser name; defaults to the URL's basename without extension.
  ///   - id: Optional explicit resource id.
  /// - Returns: An asset source that registers itself and its still format on export.
  public static func still(
    url: URL,
    width: Int,
    height: Int,
    name: String? = nil,
    id: ResourceID? = nil
  ) -> AssetSource {
    let asset = FCPKit.Asset(
      id: id ?? ResourceStore.draftID,
      name: name ?? url.deletingPathExtension().lastPathComponent,
      start: "0s",
      duration: "0s",
      hasVideo: true,
      videoSources: "1",
      mediaRep: [FCPKit.MediaRep(kind: .originalMedia, src: url.absoluteString)]
    )
    let format = FCPKit.Format(
      id: ResourceStore.draftID,
      name: "FFVideoFormatRateUndefined",
      width: String(width),
      height: String(height),
      colorSpace: "1-1-1 (Rec. 709)"
    )
    return AssetSource(asset, format: format, formatOnClip: false, id: id)
  }
}
