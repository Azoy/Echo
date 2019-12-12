// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "Echo",
  products: [
    .library(
      name: "Echo",
      targets: ["Echo"]
    )
  ],
  targets: [
    .target(
      name: "CEcho",
      dependencies: []
    ),
    .target(
      name: "Echo",
      dependencies: ["CEcho"]
    ),
    .target(
      name: "EchoMirror",
      dependencies: ["Echo"]
    ),
    .target(
      name: "EchoStoredProperties",
      dependencies: ["Echo"]
    ),
    .testTarget(
      name: "EchoTests",
      dependencies: ["Echo"]
    )
  ],
  swiftLanguageVersions: [.v5]
)

