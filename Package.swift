// swift-tools-version:4.0
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
      name: "JAYSON",
      path: "Sources/JAYSON"
    )
  ] 
)
