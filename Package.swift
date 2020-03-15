// swift-tools-version:5.1

import PackageDescription

let package = Package(
  name: "Echo",
  products: [
    .library(
      name: "Echo",
      targets: ["Echo", "EchoMirror", "EchoStoredProperties"]
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
      dependencies: ["Echo"],
      swiftSettings: [
        .unsafeFlags(["-parse-stdlib"])
      ]
    ),
    .testTarget(
      name: "EchoTests",
      dependencies: ["Echo", "EchoStoredProperties"]
    )
  ]
)

