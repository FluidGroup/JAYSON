import PackageDescription

let package = Package(
    name: "JAYSON",
    targets: [    
        Target(
            name: "BasicTests",
            dependencies: ["JAYSON"]
        ),
    ]
)
