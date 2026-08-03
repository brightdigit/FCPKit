//
//  ResourceStore.swift
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

/// The document's shared table of assets, formats, and effects.
///
/// Instances are created and threaded through the build by the DSL itself. The type is
/// `public` only so that ``DSLNode/build(_:)`` can name it; every member is internal, so
/// it offers no extension point outside this module.
public struct ResourceStore {
  internal static let draftID: ResourceID = "draft"

  private var assets: [FCPKit.Asset] = []
  private var formats: [FCPKit.Format] = []
  private var effects: [FCPKit.Effect] = []
  private var fingerprints: [String: ResourceID] = [:]
  private var explicitFingerprints: [String: String] = [:]
  private var nextNumber = 1

  private static func formatFingerprint(_ format: FCPKit.Format) -> String {
    [
      format.name ?? "",
      format.frameDuration ?? "",
      format.width ?? "",
      format.height ?? "",
      format.colorSpace ?? "",
    ].joined(separator: "|")
  }

  private static func assetFingerprint(_ asset: FCPKit.Asset) -> String {
    let media = (asset.mediaRep ?? [])
      .map { "\($0.kind?.rawValue ?? "")|\($0.src ?? "")|\($0.sig ?? "")" }
      .joined(separator: ";")
    return [
      asset.name ?? "",
      asset.uid ?? "",
      asset.src ?? "",
      asset.start ?? "",
      asset.duration ?? "",
      asset.hasVideo?.description ?? "",
      asset.hasAudio?.description ?? "",
      asset.audioChannels ?? "",
      asset.audioRate ?? "",
      asset.videoSources ?? "",
      asset.audioSources ?? "",
      media,
    ].joined(separator: "|")
  }

  internal mutating func format(_ preset: FormatPreset) throws(BuildError) -> ResourceRef<
    FormatKind
  > {
    let fingerprint = Self.formatFingerprint(preset.format)
    let id = try register(
      key: "format:\(fingerprint)",
      explicitID: preset.explicitID,
      fingerprint: fingerprint
    )
    if !formats.contains(where: { $0.id == id }) {
      var copy = preset.format
      copy.id = id
      formats.append(copy)
    }
    return try resourceRef(id)
  }

  internal mutating func asset(_ source: AssetSource) throws(BuildError) -> ResourceRef<AssetKind> {
    let fingerprint = Self.assetFingerprint(source.asset)
    let id = try register(
      key: "asset:\(fingerprint)",
      explicitID: source.explicitID,
      fingerprint: fingerprint
    )
    if !assets.contains(where: { $0.id == id }) {
      var copy = source.asset
      copy.id = id
      if let attachedFormat = source.format {
        copy.format = try self.format(FormatPreset(attachedFormat))
      }
      assets.append(copy)
    }
    return try resourceRef(id)
  }

  internal mutating func effect(name: String, uid: String) throws(BuildError) -> ResourceRef<
    EffectKind
  > {
    let fingerprint = "\(name)|\(uid)"
    let id = try register(
      key: "effect:\(fingerprint)",
      explicitID: nil,
      fingerprint: fingerprint
    )
    if !effects.contains(where: { $0.id == id }) {
      effects.append(FCPKit.Effect(id: id, name: name, uid: uid))
    }
    return try resourceRef(id)
  }

  internal func materialize() -> FCPKit.Resources {
    FCPKit.Resources(
      assets: assets.isEmpty ? nil : assets,
      formats: formats.isEmpty ? nil : formats,
      effects: effects.isEmpty ? nil : effects
    )
  }

  private mutating func register(
    key: String,
    explicitID: ResourceID?,
    fingerprint: String
  ) throws(BuildError) -> ResourceID {
    if let existing = fingerprints[key] {
      return existing
    }
    if let explicitID, explicitID != Self.draftID {
      let token = explicitID.rawValue
      if let prior = explicitFingerprints[token], prior != fingerprint {
        throw BuildError.conflictingResourceID(token)
      }
      explicitFingerprints[token] = fingerprint
      fingerprints[key] = explicitID
      return explicitID
    }
    guard let id = ResourceID("r\(nextNumber)") else {
      throw BuildError.invalidResourceID("r\(nextNumber)")
    }
    nextNumber += 1
    fingerprints[key] = id
    return id
  }

  private func resourceRef<Kind>(_ id: ResourceID) throws(BuildError) -> ResourceRef<Kind> {
    guard let ref = ResourceRef<Kind>(id.rawValue) else {
      throw BuildError.invalidResourceID(id.rawValue)
    }
    return ref
  }
}
