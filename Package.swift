// swift-tools-version:6.0
import PackageDescription

let package = Package(
  name: "JAYSON",
  products: [
    .library(
      name: "JAYSON",
      targets: ["JAYSON"]
    )
  ],
  targets: [
    .target(
      name: "JAYSON"
    ),
    .testTarget(
      name: "JAYSONTests",
      dependencies: ["JAYSON"],
      resources: [.copy("Fixtures")]
    ),
  ],
  swiftLanguageModes: [.v6]
)
