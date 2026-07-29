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

public struct Event: Codable {
  enum CodingKeys: String, CodingKey {
    case name
    case uid
    case projects = "project"
    case assetClips = "asset-clip"
    case refClips = "ref-clip"
    case mcClips = "mc-clip"
    case syncClips = "sync-clip"
  }

  public var name: String?
  public let uid: String?
  public var projects: [Project]?
  public var assetClips: [AssetClip]?
  public var refClips: [RefClip]?
  public var mcClips: [MCClip]?
  public var syncClips: [SyncClip]?

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
