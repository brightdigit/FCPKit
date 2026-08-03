import XCTest

@testable import FCPKit

extension RealFCPXMLTests {
  internal func testCrossDissolveCanBeReadMutatedAndRoundTripped() throws {
    let parser = FCPXMLParser()
    var document = try loadUntitledDocument()
    let originalTransition = try crossDissolve(in: document)
    let videoFilter = try XCTUnwrap(originalTransition.filterVideo?.first)
    let audioFilter = try XCTUnwrap(originalTransition.filterAudio?.first)
    let originalData = try XCTUnwrap(videoFilter.data?.first)

    XCTAssertEqual(videoFilter.name, "Cross Dissolve")
    XCTAssertEqual(audioFilter.name, "Audio Crossfade")
    XCTAssertEqual(
      videoFilter.param?.map(\.name),
      [
        "Look", "Amount", "Ease", "Ease Amount", "disableDRT",
      ]
    )
    XCTAssertEqual(videoFilter.param?.first(where: { $0.name == "Amount" })?.value, "50")
    XCTAssertEqual(originalData.key, "effectConfig")
    XCTAssertFalse(try XCTUnwrap(originalData.value).isEmpty)

    let mediaIndex = try XCTUnwrap(
      document.resources?.media?.firstIndex { $0.name == "Music Intro" }
    )
    let transition = document.resources?.media?[mediaIndex].sequence?.spine?.transitions?[0]
    let amountIndex = try XCTUnwrap(
      transition?.filterVideo?[0].param?.firstIndex { $0.name == "Amount" }
    )
    try withSpine(in: &document, mediaAt: mediaIndex) {
      $0.transitions?[0].filterVideo?[0].param?[amountIndex].value = "65"
    }

    let encoded = try parser.encode(document)
    let reparsed = try parser.parse(data: encoded)
    let reparsedTransition = try crossDissolve(in: reparsed)
    let reparsedVideo = try XCTUnwrap(reparsedTransition.filterVideo?.first)

    XCTAssertEqual(reparsedVideo.param?.first(where: { $0.name == "Amount" })?.value, "65")
    XCTAssertEqual(reparsedVideo.param?.count, 5)
    XCTAssertEqual(reparsedVideo.data?.first?.value, originalData.value)
    XCTAssertEqual(reparsedTransition.filterAudio?.first?.name, "Audio Crossfade")
  }

  internal func testSharedParametersAnimationsAndFadesCanBeReadAndMutated() throws {
    let parser = FCPXMLParser()
    var document = try loadUntitledDocument()
    let assetClips =
      document.resources?.media?.flatMap {
        $0.sequence?.spine?.assetClips ?? []
      } ?? []
    let titles = assetClips.flatMap { $0.titles ?? [] }
    let title = try XCTUnwrap(titles.first { $0.name?.contains("SyntaxKit") == true })
    let customSpeed = try XCTUnwrap(title.param?.first { $0.name == "Custom Speed" })
    let tracking = try XCTUnwrap(
      title.textStyleDef?.first?.textStyle?.param?.first?.param?.first
    )

    XCTAssertNil(customSpeed.value)
    XCTAssertEqual(customSpeed.keyframeAnimation?.keyframes?.map(\.value), ["0", "1"])
    XCTAssertEqual(tracking.name, "motionTextTracking")
    XCTAssertEqual(tracking.value, "-1.7751")

    let mediaIndex = try XCTUnwrap(
      document.resources?.media?.firstIndex { media in
        media.sequence?.spine?.assetClips?.contains {
          $0.adjustVolume?.param?.contains { $0.keyframeAnimation != nil } == true
        } == true
      }
    )
    let assetIndex = try XCTUnwrap(
      document.resources?.media?[mediaIndex].sequence?.spine?.assetClips?.firstIndex {
        $0.adjustVolume?.param?.contains { $0.keyframeAnimation != nil } == true
      }
    )
    let volume = try XCTUnwrap(
      document.resources?.media?[mediaIndex].sequence?.spine?.assetClips?[assetIndex]
        .adjustVolume?.param?.first
    )
    XCTAssertEqual(volume.fadeIn?.type, "easeIn")
    XCTAssertEqual(volume.fadeOut?.duration, FCPTime("1947511/720000s"))
    XCTAssertEqual(volume.keyframeAnimation?.keyframes?.count, 3)

    try withAssetClip(in: &document, mediaAt: mediaIndex, at: assetIndex) {
      $0.adjustVolume?.param?[0].keyframeAnimation?.keyframes?[2].value = "-3dB"
    }
    let reparsed = try parser.parse(data: parser.encode(document))
    let changedVolume = try XCTUnwrap(
      reparsed.resources?.media?[mediaIndex].sequence?.spine?.assetClips?[assetIndex]
        .adjustVolume?.param?.first
    )

    XCTAssertEqual(changedVolume.keyframeAnimation?.keyframes?[2].value, "-3dB")
    XCTAssertEqual(changedVolume.fadeIn?.type, "easeIn")
    XCTAssertEqual(changedVolume.fadeOut?.duration, FCPTime("1947511/720000s"))
    XCTAssertEqual(changedVolume.keyframeAnimation?.keyframes?.count, 3)
  }

  internal func testTitleTextAndStyleCanBeMutatedWithoutBreakingReferences() throws {
    let parser = FCPXMLParser()
    var document = try loadUntitledDocument()
    let mediaIndex = try XCTUnwrap(
      document.resources?.media?.firstIndex { media in
        media.sequence?.spine?.assetClips?.contains {
          $0.titles?.contains { $0.name?.contains("SyntaxKit") == true } == true
        } == true
      }
    )
    let assetIndex = try XCTUnwrap(
      document.resources?.media?[mediaIndex].sequence?.spine?.assetClips?.firstIndex {
        $0.titles?.contains { $0.name?.contains("SyntaxKit") == true } == true
      }
    )
    let clips = document.resources?.media?[mediaIndex].sequence?.spine?.assetClips
    let titleIndex = try XCTUnwrap(
      clips?[assetIndex].titles?.firstIndex { $0.name?.contains("SyntaxKit") == true }
    )
    let originalTitle = try XCTUnwrap(clips?[assetIndex].titles?[titleIndex])

    XCTAssertEqual(originalTitle.text?.flatMap { $0.textStyle ?? [] }.map(\.ref), ["ts1", "ts2"])
    XCTAssertEqual(originalTitle.textStyleDef?.map(\.id), ["ts1", "ts2"])
    XCTAssertEqual(originalTitle.textStyleDef?.first?.textStyle?.font, "Helvetica Neue")
    XCTAssertEqual(originalTitle.textStyleDef?.first?.textStyle?.fontSize, "183")
    XCTAssertEqual(originalTitle.textStyleDef?.first?.textStyle?.bold, "1")
    XCTAssertEqual(originalTitle.textStyleDef?.first?.textStyle?.kerning, "-1.7751")

    try withAssetClip(in: &document, mediaAt: mediaIndex, at: assetIndex) {
      $0.titles?[titleIndex].text?[0].textStyle?[0].content = "FCPKit"
      $0.titles?[titleIndex].textStyleDef?[0].textStyle?.fontColor = "1 0.5 0 1"
    }

    let reparsed = try parser.parse(data: parser.encode(document))
    let changedClips = reparsed.resources?.media?[mediaIndex].sequence?.spine?.assetClips
    let changedTitle = try XCTUnwrap(changedClips?[assetIndex].titles?[titleIndex])

    XCTAssertEqual(changedTitle.text?[0].textStyle?[0].content, "FCPKit")
    XCTAssertEqual(changedTitle.textStyleDef?[0].textStyle?.fontColor, "1 0.5 0 1")
    XCTAssertEqual(changedTitle.text?.flatMap { $0.textStyle ?? [] }.map(\.ref), ["ts1", "ts2"])
    XCTAssertEqual(changedTitle.textStyleDef?.map(\.id), ["ts1", "ts2"])
    XCTAssertEqual(changedTitle.textStyleDef?[0].textStyle?.bold, "1")
    XCTAssertEqual(changedTitle.textStyleDef?[0].textStyle?.kerning, "-1.7751")
  }

  internal func testNestedTimelineMutationPreservesSiblingReferencesAndTiming() throws {
    let parser = FCPXMLParser()
    var document = try loadUntitledDocument()
    let mediaIndex = try XCTUnwrap(
      document.resources?.media?.firstIndex { media in
        media.sequence?.spine?.refClips?.contains { $0.refClips?.isEmpty == false } == true
      }
    )
    let parentIndex = try XCTUnwrap(
      document.resources?.media?[mediaIndex].sequence?.spine?.refClips?.firstIndex {
        $0.refClips?.isEmpty == false
      }
    )
    let children = try XCTUnwrap(
      document.resources?.media?[mediaIndex].sequence?.spine?.refClips?[parentIndex].refClips
    )
    let childIndex = try XCTUnwrap(children.firstIndex { $0.adjustTransform != nil })
    let originalReferences = children.map(\.ref)
    let originalTiming = children.map { [$0.offset, $0.start, $0.duration] }

    try withSpine(in: &document, mediaAt: mediaIndex) {
      $0.refClips?[parentIndex].refClips?[childIndex].adjustTransform?.position = "10 20"
    }
    let reparsed = try parser.parse(data: parser.encode(document))
    let changedChildren = try XCTUnwrap(
      reparsed.resources?.media?[mediaIndex].sequence?.spine?.refClips?[parentIndex].refClips
    )

    XCTAssertEqual(changedChildren[childIndex].adjustTransform?.position, "10 20")
    XCTAssertEqual(changedChildren.map(\.ref), originalReferences)
    XCTAssertEqual(changedChildren.map { [$0.offset, $0.start, $0.duration] }, originalTiming)
  }
}
