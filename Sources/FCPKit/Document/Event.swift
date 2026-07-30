//
//  Event.swift
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
import XMLCoder

/// A Final Cut Pro `event` grouping projects and browser clips within a library.
public struct Event: Codable {
  internal enum CodingKeys: String, CodingKey {
    case name
    case uid
    case projects = "project"
    case assetClips = "asset-clip"
    case refClips = "ref-clip"
    case mcClips = "mc-clip"
    case syncClips = "sync-clip"
  }

  /// The event's display name.
  public var name: String?
  /// The event's unique identifier assigned by Final Cut Pro.
  public let uid: String?
  /// The `project` elements stored in the event.
  public var projects: [Project]?
  /// The event's browser `asset-clip` elements referencing media assets.
  public var assetClips: [AssetClip]?
  /// The event's browser `ref-clip` elements referencing compound clips.
  public var refClips: [RefClip]?
  /// The event's browser `mc-clip` elements referencing multicam media.
  public var mcClips: [MCClip]?
  /// The event's browser `sync-clip` elements of synchronized media.
  public var syncClips: [SyncClip]?

  /// Creates an `event` element with the given name, identifier, projects, and clips.
  public init(
    name: String? = nil,
    uid: String? = nil,
    projects: [Project]? = nil,
    assetClips: [AssetClip]? = nil,
    refClips: [RefClip]? = nil,
    mcClips: [MCClip]? = nil,
    syncClips: [SyncClip]? = nil
  ) {
    self.name = name
    self.uid = uid
    self.projects = projects
    self.assetClips = assetClips
    self.refClips = refClips
    self.mcClips = mcClips
    self.syncClips = syncClips
  }
}

extension Event: DynamicNodeEncoding {
  /// Encodes projects and clips as child elements and other keys as XML attributes.
  public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
    fcpNodeEncoding(
      for: key,
      elementKeys: [
        "project", "asset-clip", "ref-clip", "mc-clip", "sync-clip",
      ]
    )
  }
}
