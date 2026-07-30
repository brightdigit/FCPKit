import FCPKit
import FCPKitMediaTools
import XCTest

// Fixture factories for TypedGenerationTests, which is gated on CoreMedia,
// so these helpers only exist on Apple platforms.
#if canImport(CoreMedia)
  import AVFoundation
  import CoreMedia

  extension TypedGenerationTests {
    /// Builds the minimal typed project used by the round-trip assertions.
    internal func makeMinimalProject() -> FCPXML {
      FCPXML(
        version: "1.13",
        resources: makeMinimalResources(),
        library: makeMinimalLibrary()
      )
    }

    /// Builds the asset and format resources for the minimal typed project.
    internal func makeMinimalResources() -> Resources {
      Resources(
        assets: [
          Asset(
            id: "r2",
            name: "Interview",
            uid: "ASSET-UID",
            start: "0s",
            duration: "240/24s",
            format: "r1",
            hasVideo: "1",
            hasAudio: "1",
            audioChannels: "2",
            audioRate: "48000",
            mediaRep: [
              MediaRep(
                kind: .originalMedia,
                sig: "ASSET-SIGNATURE",
                src: "file:///Users/Shared/FCPKitMedia/interview.mov"
              )
            ]
          )
        ],
        formats: [
          Format(
            id: "r1",
            name: "FFVideoFormat1920x1080p24",
            frameDuration: "1/24s",
            width: "1920",
            height: "1080",
            colorSpace: "1-1-1 (Rec. 709)"
          )
        ]
      )
    }

    /// Builds the library with one event and project for the minimal typed project.
    internal func makeMinimalLibrary() -> Library {
      Library(
        location: "file:///Users/Shared/FCPKitTypedGeneration.fcpbundle/",
        events: [
          Event(
            name: "Typed Event",
            uid: "EVENT-UID",
            projects: [
              Project(
                name: "Typed Project",
                uid: "PROJECT-UID",
                modDate: "2026-07-17 12:00:00 -0400",
                sequence: Sequence(
                  format: "r1",
                  duration: "240/24s",
                  tcStart: "0s",
                  tcFormat: "NDF",
                  audioLayout: "stereo",
                  audioRate: "48k",
                  spine: Spine(
                    assetClips: [
                      AssetClip(
                        ref: "r2",
                        name: "Interview",
                        duration: "240/24s",
                        start: "0s",
                        format: "r1",
                        tcFormat: "NDF",
                        offset: "0s"
                      )
                    ]
                  )
                )
              )
            ]
          )
        ]
      )
    }

    /// Builds video metadata with the common multicam-test fields filled in.
    internal func makeVideoMetadata(
      path: String,
      duration: CMTime,
      dimensions: CGSize,
      audioChannels: Int
    ) -> VideoMetadata {
      VideoMetadata(
        url: URL(fileURLWithPath: path),
        duration: duration,
        dimensions: dimensions,
        frameRate: 24,
        hasVideo: true,
        hasAudio: true,
        audioChannels: audioChannels,
        audioSampleRate: 48_000
      )
    }
  }
#endif
