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
    guard case .clip(let val) = self else {
      return nil
    }
    return val
  }

  internal var gap: Gap? {
    guard case .gap(let val) = self else {
      return nil
    }
    return val
  }

  internal var mcClip: MCClip? {
    guard case .mcClip(let val) = self else {
      return nil
    }
    return val
  }

  internal var refClip: RefClip? {
    guard case .refClip(let val) = self else {
      return nil
    }
    return val
  }

  internal var syncClip: SyncClip? {
    guard case .syncClip(let val) = self else {
      return nil
    }
    return val
  }

  internal var assetClip: AssetClip? {
    guard case .assetClip(let val) = self else {
      return nil
    }
    return val
  }

  internal var title: Title? {
    guard case .title(let val) = self else {
      return nil
    }
    return val
  }

  internal var generator: Generator? {
    guard case .generator(let val) = self else {
      return nil
    }
    return val
  }

  internal var storyline: Storyline? {
    guard case .storyline(let val) = self else {
      return nil
    }
    return val
  }

  internal var compoundClip: CompoundClip? {
    guard case .compoundClip(let val) = self else {
      return nil
    }
    return val
  }

  internal var retimeClip: RetimeClip? {
    guard case .retimeClip(let val) = self else {
      return nil
    }
    return val
  }

  internal var caption: Caption? {
    guard case .caption(let val) = self else {
      return nil
    }
    return val
  }

  internal var video: Video? {
    guard case .video(let val) = self else {
      return nil
    }
    return val
  }

  internal var spine: Spine? {
    guard case .spine(let val) = self else {
      return nil
    }
    return val
  }
}
