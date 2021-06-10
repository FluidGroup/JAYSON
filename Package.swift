// swift-tools-version:5.3
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
