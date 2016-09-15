# JAYSON

[![CI Status](http://img.shields.io/travis/muukii/JAYSON.svg?style=flat)](https://travis-ci.org/muukii/JAYSON)
[![Version](https://img.shields.io/cocoapods/v/JAYSON.svg?style=flat)](http://cocoapods.org/pods/JAYSON)
[![License](https://img.shields.io/cocoapods/l/JAYSON.svg?style=flat)](http://cocoapods.org/pods/JAYSON)
[![Platform](https://img.shields.io/cocoapods/p/JAYSON.svg?style=flat)](http://cocoapods.org/pods/JAYSON)

More strict and scalable JSON library.

![](sample1.png)

## Sample

```swift
let jsonData: Data = ...
```

```swift
let id: String = try jayson
       .next(0)
       .next("id")
       .getString()
```

** Scalable Transform**

```swift
let urlDecoder = Decoder<URL> { (jayson) -> URL in
    URL(string: try jayson.getString())!
}


let imageURL: URL = try jayson
       .next(0)
       .next("image")
       .next("hidpi_image")
       .get(with: urlDecoder)
```

** Get current path** (Debugging information.)

```swift

let path = try jayson
    .next(0)
    .next("image")        
    .next("hidpi_image")
    .currentPath()    

// path => "[0]["image"]["hidpi_image"]"
```

** Back JSON hierarchy**

```swift

try jayson
    .next(0)
    .next("image")
    .back() // <---
    .next("image")
    .next("hidpi_image")

```

## Requirements

Swift **3.0**

## Installation

JAYSON is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "JAYSON"
```

## Author

muukii, m@muukii.me

## License

JAYSON is available under the MIT license. See the LICENSE file for more info.
