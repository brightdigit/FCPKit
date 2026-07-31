//
//  AssetSource.swift
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

/// An asset whose resource identity is assigned when its document is exported.
public struct AssetSource {
  internal let asset: FCPKit.Asset
  internal let format: FCPKit.Format?
  internal let formatOnClip: Bool
  internal let explicitID: ResourceID?
  /// Creates an asset draft from a media URL.
  ///
  /// The URL is emitted as a nested `media-rep` child element, as required by
  /// FCPXML 1.6 and later (`<!ELEMENT asset (media-rep+, metadata?)>`).
  public init(url: URL, name: String? = nil, duration: FCPTime? = nil, id: ResourceID? = nil) {
    self.asset = FCPKit.Asset(
      id: id ?? ResourceStore.draftID,
      name: name ?? url.deletingPathExtension().lastPathComponent,
      duration: duration?.description,
      mediaRep: [FCPKit.MediaRep(kind: .originalMedia, src: url.absoluteString)]
    )
    self.format = nil
    self.formatOnClip = false
    self.explicitID = id
  }
  /// Wraps a decoded asset, optionally replacing its id and attaching a format spec.
  public init(
    _ asset: FCPKit.Asset,
    format: FCPKit.Format? = nil,
    formatOnClip: Bool = false,
    id: ResourceID? = nil
  ) {
    var copy = asset
    copy.id = id ?? ResourceStore.draftID
    copy.format = nil
    self.asset = copy
    self.format = format
    self.formatOnClip = formatOnClip
    self.explicitID = id
  }
}
