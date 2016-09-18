<p align="center">
  <img src="JAYSON@2x.png">
</p>
# JAYSON

[![CI Status](http://img.shields.io/travis/muukii/JAYSON.svg?style=flat)](https://travis-ci.org/muukii/JAYSON)
[![Version](https://img.shields.io/cocoapods/v/JAYSON.svg?style=flat)](http://cocoapods.org/pods/JAYSON)
[![License](https://img.shields.io/cocoapods/l/JAYSON.svg?style=flat)](http://cocoapods.org/pods/JAYSON)
[![Platform](https://img.shields.io/cocoapods/p/JAYSON.svg?style=flat)](http://cocoapods.org/pods/JAYSON)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Strict and Scalable JSON library.

## Sample

### Read JSON

**Create JAYSON**

```swift
let jsonData: Data = ...
let jayson = try JAYSON(jsonData)

// or
let jsonData: Data = ...
let json: Any = try JSONSerialization.jsonObject(with: data, options: [])
let jayson = try JAYSON(json)

```

#### Easy Access

```swift
let urlString: String? = jayson[3]["shot"]["images"]["hidpi_image"].string
```

#### Strict Access (try-catch)

**Get Value** (String, Bool, Number)

```swift
let id: String = try jayson
       .next(0)
       .next("id")
       .getString()
```

**Get Value with Decoder** (Custom Object)

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

**Get current path** (Debugging information.)

```swift

let path = try jayson
    .next(0)
    .next("image")        
    .next("hidpi_image")
    .currentPath()    

// path => "[0]["image"]["hidpi_image"]"
```

**Back JSON hierarchy**

```swift

try jayson
    .next(0)
    .next("image")
    .back() // <---
    .next("image")
    .next("hidpi_image")

```

## Import Example (dribbble API)

```swift
let jayson = try! JAYSON(data)

struct Shot {
    let id: Int
    let title: String
    let width: Int
    let height: Int
    let hidpiImageURLString: String?
    let normalImageURLString: String
    let teaserImageURLString: String
}

do {
    let shots: [Shot] = try jayson.getArray().map { jayson -> Shot in

        let imagesJayson = try jayson.next("images")

        return Shot(
            id: try jayson.next("id").getInt(),
            title: try jayson.next("title").getString(),
            width: try jayson.next("width").getInt(),
            height: try jayson.next("height").getInt(),
            hidpiImageURLString: try? imagesJayson.next("hidpi").getString(),
            normalImageURLString: try imagesJayson.next("normal").getString(),
            teaserImageURLString: try imagesJayson.next("teaser").getString()
        )
    }
    print(shots)
} catch {
    print(error)
}
```

### Write JSON

```swift
var j = JAYSON()
j["number"] = 124
j["text"] = "hooo"
j["bool"] = true
j["null"] = JAYSON.null

// sorry.
j["tree1"] = JAYSON(
    [
        "tree2" : JAYSON(
            [
            "tree3" : JAYSON(
                [
                    JAYSON(["index" : "myvalue"])
                ]
                )
            ]
        )
    ]
)
```

```
{
    "number" : 124,
    "null" : null,
    "tree1" : {
        "tree2" : {
            "tree3" : [
            {
                "index" : "myvalue"
            }
            ]
        }
    },
    "text" : "hooo",
    "bool" : true
    }
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
