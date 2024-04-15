import Danger
import Foundation

let danger = Danger()

if FileManager.default.fileExists(atPath: "release_notes.json"),
  let contents = FileManager.default.contents(atPath: "release_notes.json"),
  let jsonObject = try? JSONSerialization.jsonObject(
    with: contents, 
    options: []
  ) as? [String: Any],
  let releaseNotes = jsonObject["releaseNotes"] as? String {
  markdown("Release notes:\n\(releaseNotes)")
} else if FileManager.default.fileExists(atPath: "swift_conventional_commit_parser_error.txt"),
  let contents = FileManager.default.contents(atPath: "swift_conventional_commit_parser_error.txt"),
  let errorMessage = String(data: contents, encoding: .utf8),
  errorMessage.isEmpty == false {
  fail(errorMessage)
} else {
  fail("No formatted commit.")
}

let summary = XCodeSummary(filePath: "result.json")

summary.report()

Coverage.xcodeBuildCoverage(
    // Note: derived data cannot be in the same folder as the package, or
    // xcodebuild gets upset: https://forums.swift.org/t/xcode-and-swift-package-manager/44704/7
    .xcresultBundle("../DerivedDataTests/coverage.xcresult"), 
    minimumCoverage: 0, 
    excludedTargets: [String]()
)

if FileManager.default.fileExists(atPath: ".swiftlint.yml") {
    let filesToLint = danger.git.modifiedFiles + danger.git.createdFiles

    SwiftLint.lint(
      .files(filesToLint), 
      inline: true, 
      configFile: ".swiftlint.yml",
      swiftlintPath: .bin("./CI-Tooling/swiftlint")
    )
}

