//
//  FCPXMLGeneratorTool.swift
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

import FCPKitMediaTools
import Foundation

/// Command-line entry point that generates a multicam FCPXML file from two video files.
///
/// The generator extracts metadata from real media files, which requires AVFoundation.
/// On platforms without it, `main()` prints an error and exits so cross-platform CI stays honest.
@main
internal enum FCPXMLGeneratorTool {
  #if canImport(AVFoundation)
    /// Validated command-line inputs: the two source videos, output location, and project name.
    private struct ResolvedInputs {
      fileprivate let video1: URL
      fileprivate let video2: URL
      fileprivate let output: URL
      fileprivate let projectName: String
    }

    internal static func main() async {
      let args = CommandLine.arguments

      // Check for help flag
      if args.contains("-h") || args.contains("--help") {
        printUsage()
        return
      }

      let inputs = resolveInputs(args)

      print("🎬 Generating multicam FCPXML...")
      print("📹 Video 1: \(inputs.video1.lastPathComponent)")
      print("📹 Video 2: \(inputs.video2.lastPathComponent)")
      print("📄 Output: \(inputs.output.lastPathComponent)")
      print("🎯 Project: \(inputs.projectName)")
      print()

      await generate(
        video1URL: inputs.video1,
        video2URL: inputs.video2,
        outputURL: inputs.output,
        projectName: inputs.projectName
      )
    }

    /// Parses command-line arguments into validated input, output, and project-name values.
    private static func resolveInputs(_ args: [String]) -> ResolvedInputs {
      // Validate arguments
      guard args.count >= 3 else {
        print("Error: Not enough arguments provided.")
        printUsage()
        exit(1)
      }

      let video1Path = args[1]
      let video2Path = args[2]
      let outputPath = args.count > 3 ? args[3] : "output.fcpxml"
      let projectName = args.count > 4 ? args[4] : "Multicam Project"

      // Convert paths to URLs
      let video1URL = URL(fileURLWithPath: video1Path)
      let video2URL = URL(fileURLWithPath: video2Path)
      let outputURL = URL(fileURLWithPath: outputPath)

      // Validate input files exist
      guard FileManager.default.fileExists(atPath: video1URL.path) else {
        print("Error: Video file 1 not found: \(video1Path)")
        exit(1)
      }

      guard FileManager.default.fileExists(atPath: video2URL.path) else {
        print("Error: Video file 2 not found: \(video2Path)")
        exit(1)
      }

      return ResolvedInputs(
        video1: video1URL,
        video2: video2URL,
        output: outputURL,
        projectName: projectName
      )
    }

    /// Extracts metadata from both videos, builds the multicam FCPXML, and writes it to disk.
    private static func generate(
      video1URL: URL,
      video2URL: URL,
      outputURL: URL,
      projectName: String
    ) async {
      do {
        // Extract metadata from both videos
        print("📊 Extracting metadata from video files...")
        let extractor = VideoMetadataExtractor()

        let video1Metadata = try await extractor.extractMetadata(from: video1URL)
        print(describe(video1URL, video1Metadata))

        let video2Metadata = try await extractor.extractMetadata(from: video2URL)
        print(describe(video2URL, video2Metadata))

        // Generate FCPXML
        print("\n🏗️  Generating FCPXML structure...")
        let generator = MulticamXMLBuilder()
        let xmlString = generator.generateMulticamFCPXML(
          leftSideVideo: video1Metadata,
          rightSideVideo: video2Metadata,
          projectName: projectName
        )

        // Write to file. (This branch is Apple-only — see the #if above — so
        // atomic writing is always available here.)
        try xmlString.write(to: outputURL, atomically: true, encoding: .utf8)

        print("✅ Successfully generated FCPXML file!")
        print("📁 Output saved to: \(outputURL.path)")

        // Print summary
        print("\n📋 Summary:")
        print("   • Combined media with side-by-side layout")
        let angle1 = video1URL.deletingPathExtension().lastPathComponent
        let angle2 = video2URL.deletingPathExtension().lastPathComponent
        print("   • Multicam clip with 3 angles (Both, \(angle1), \(angle2))")
        print("   • Standard smart collections included")
        print("   • Ready to import into Final Cut Pro")
      } catch {
        print("❌ Error: \(error.localizedDescription)")
        exit(1)
      }
    }

    /// Formats a one-line summary of an extracted video's dimensions and frame rate.
    private static func describe(_ url: URL, _ metadata: VideoMetadata) -> String {
      let width = Int(metadata.dimensions.width)
      let height = Int(metadata.dimensions.height)
      return "✅ \(url.lastPathComponent): \(width)x\(height) @ \(metadata.frameRate)fps"
    }

    internal static func printUsage() {
      // Help text is laid out for a terminal: sections are indented four spaces
      // and the wording is wrapped for reading, not for Swift source width.
      // swiftlint:disable indentation_width
      print(
        """
        fcpxml-generator - Generate multicam FCPXML from two video files

        USAGE:
            fcpxml-generator <video1> <video2> [output.fcpxml] [project_name]

        ARGUMENTS:
            video1        Path to first video file (Leo)
            video2        Path to second video file (Rachel)
            output        Output FCPXML file path (optional, default: output.fcpxml)
            project_name  Project name (optional, default: "Multicam Project")

        EXAMPLES:
            fcpxml-generator leo.mp4 rachel.mp4
            fcpxml-generator leo.mp4 rachel.mp4 my_project.fcpxml
            fcpxml-generator leo.mp4 rachel.mp4 my_project.fcpxml "Interview Project"

        OPTIONS:
            -h, --help    Show this help message

        DESCRIPTION:
            This tool extracts metadata from two video files and generates an FCPXML
            file with a multicam setup similar to Both-Multicam.fcpxml. The generated
            file includes:

            • Individual media sequences for each video
            • Combined "Both" media with side-by-side layout
            • Multicam clip with three angles (Both, Video1, Video2)
            • Standard smart collections

            The first video is positioned on the left, the second on the right.
        """
      )
      // swiftlint:enable indentation_width
    }
  #else
    internal static func main() {
      FileHandle.standardError.write(
        Data(
          "fcpxml-generator requires AVFoundation and is unavailable on this platform.\n".utf8
        )
      )
      exit(1)
    }
  #endif
}
