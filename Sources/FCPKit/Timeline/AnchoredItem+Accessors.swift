//
//  AnchoredItem+Accessors.swift
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

extension AnchoredItem {
  internal var clip: Clip? {
    if case .clip(let val) = self {
      return val
    }
    return nil
  }
  internal var isClip: Bool {
    if case .clip = self {
      return true
    }
    return false
  }

  internal var gap: Gap? {
    if case .gap(let val) = self {
      return val
    }
    return nil
  }
  internal var isGap: Bool {
    if case .gap = self {
      return true
    }
    return false
  }

  internal var mcClip: MCClip? {
    if case .mcClip(let val) = self {
      return val
    }
    return nil
  }

  internal var isMCClip: Bool {
    if case .mcClip = self {
      return true
    }
    return false
  }

  internal var refClip: RefClip? {
    if case .refClip(let val) = self {
      return val
    }
    return nil
  }

  internal var isRefClip: Bool {
    if case .refClip = self {
      return true
    }
    return false
  }

  internal var syncClip: SyncClip? {
    if case .syncClip(let val) = self {
      return val
    }
    return nil
  }

  internal var isSyncClip: Bool {
    if case .syncClip = self {
      return true
    }
    return false
  }

  internal var assetClip: AssetClip? {
    if case .assetClip(let val) = self {
      return val
    }
    return nil
  }

  internal var isAssetClip: Bool {
    if case .assetClip = self {
      return true
    }
    return false
  }

  internal var title: Title? {
    if case .title(let val) = self {
      return val
    }
    return nil
  }

  internal var isTitle: Bool {
    if case .title = self {
      return true
    }
    return false
  }

  internal var generator: Generator? {
    if case .generator(let val) = self {
      return val
    }
    return nil
  }

  internal var isGenerator: Bool {
    if case .generator = self {
      return true
    }
    return false
  }

  internal var storyline: Storyline? {
    if case .storyline(let val) = self {
      return val
    }
    return nil
  }

  internal var isStoryline: Bool {
    if case .storyline = self {
      return true
    }
    return false
  }

  internal var compoundClip: CompoundClip? {
    if case .compoundClip(let val) = self {
      return val
    }
    return nil
  }

  internal var isCompoundClip: Bool {
    if case .compoundClip = self {
      return true
    }
    return false
  }

  internal var retimeClip: RetimeClip? {
    if case .retimeClip(let val) = self {
      return val
    }
    return nil
  }

  internal var isRetimeClip: Bool {
    if case .retimeClip = self {
      return true
    }
    return false
  }

  internal var caption: Caption? {
    if case .caption(let val) = self {
      return val
    }
    return nil
  }

  internal var isCaption: Bool {
    if case .caption = self {
      return true
    }
    return false
  }

  internal var video: Video? {
    if case .video(let val) = self {
      return val
    }
    return nil
  }

  internal var isVideo: Bool {
    if case .video = self {
      return true
    }
    return false
  }

  internal var spine: Spine? {
    if case .spine(let val) = self {
      return val
    }
    return nil
  }

  internal var isSpine: Bool {
    if case .spine = self {
      return true
    }
    return false
  }
}

