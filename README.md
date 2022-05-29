
# Do you need to handle the root cause of failure in decoding JSON?

We often process the value as a default value if it could not be decoded from JSON. (Recovering with a default value)  
However, doing that might cause a serious problem and hide the actual root cause in the app.  
Recovering with a default value is not a bad choice, it's important to know the JSON represents unexpected shape or value before recovering.  

```swift
let json: JSON

do {
  self.id = try json.next("id").getString()
} catch {
  print(error)
  // We can know why decoding failed from error.
  // Not found "id" or "id" found but it was not `string` or something else.
  // that's why here recover the value to fill `self.id`
  self.id = "unknown"
}
```

---

JAYSON provides 2 ways of accessing to JSON object.

1. Easy access (with dynamic-member-lookup)

```swift
let urlString: String? = json[3]?.shot?.images?.hidpi_image?.string
```

2. Strict access (with dynamic-member-lookup)

We can know where error was caused. (with JSONError)

```swift
let id: String = try json
    .next(0)
    .next("id")
    .getString()
```

<p align="center">
  <img src="banner@2x.png" width=375>
</p>

# JAYSON

[![Build Status](https://app.bitrise.io/app/0cc465d9351375ab/status.svg?token=c_MLug7GlJJn0F44V4o5hw&branch=master)](https://app.bitrise.io/app/0cc465d9351375ab)
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fmuukii%2FJAYSON.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2Fmuukii%2FJAYSON?ref=badge_shield)
![](https://img.shields.io/badge/Swift-4.2-blue.svg?style=flat)
[![Version](https://img.shields.io/cocoapods/v/json.svg?style=flat)](http://cocoapods.org/pods/json)
[![License](https://img.shields.io/cocoapods/l/json.svg?style=flat)](http://cocoapods.org/pods/json)
[![Platform](https://img.shields.io/cocoapods/p/json.svg?style=flat)](http://cocoapods.org/pods/json)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Strict and Scalable JSON library.
And also supports `dynamicMemberLookup`

## Requirements

Swift **5+**  iOS📱, watchOS⌚️, tvOS📺, macOS🖥, **Linux**✨

# Usage

# Read JSON

## Easy Access

```swift
let urlString: String? = json[3]?["shot"]?["images"]?["hidpi_image"]?.string
```

## Strict Access (try-catch)

if the value does not exist, throw `JSONError`<br>
Failed location can be known from [JSONError](#jsonerror)

Get Value (String, Bool, Number)

```swift
let id: String = try json
    .next(0)
    .next("id")
    .getString()
```

**Using dynamicMemberLookup**

```swift
let id: String = try json
    .next(0)
    .next(\.id)
    .getString()
```

### Get Value with Decoder (Custom Object)

Using the Decoder can be transformed in a custom object.
And, throwable

```swift

let imageURL: URL = try json
    .next(0)
    .next("image")
    .next("hidpi_image")
    .get {
        URL.init(string: try $0.getString())!
    }
```

### General Getter

Strict getters

```swift
extension JSON {
    public func getDictionary() throws -> [String : JSON]
    public func getArray() throws -> [JSON]
    public func getNumber() throws -> NSNumber
    public func getInt() throws -> Int
    public func getInt8() throws -> Int8
    public func getInt16() throws -> Int16
    public func getInt32() throws -> Int32
    public func getInt64() throws -> Int64
    public func getUInt() throws -> UInt
    public func getUInt8() throws -> UInt8
    public func getUInt16() throws -> UInt16
    public func getUInt32() throws -> UInt32
    public func getUInt64() throws -> UInt64
    public func getString() throws -> String
    public func getBool() throws -> Bool
    public func getFloat() throws -> Float
    public func getDouble() throws -> Double
}

///
extension JSON {
    public func get<T>(_ s: (JSON) throws -> T) rethrows -> T
}
```

Optional Read-only properties😁
```swift
extension JSON {
    public var dictionary: [String : Any]? { get }
    public var array: [Any]? { get }
    public var string: String? { get }
    public var number: NSNumber? { get }
    public var double: Double? { get }
    public var float: Float? { get }
    public var int: Int? { get }
    public var uInt: UInt? { get }
    public var int8: Int8? { get }
    public var uInt8: UInt8? { get }
    public var int16: Int16? { get }
    public var uInt16: UInt16? { get }
    public var int32: Int32? { get }
    public var uInt32: UInt32? { get }
    public var int64: Int64? { get }
    public var uInt64: UInt64? { get }
    public var bool: Bool? { get }
}
```

# Initialize JSON

```swift
let jsonData: Data = ...
let json = try JSON(data: jsonData)
```

```swift
let jsonData: Data
let json: Any = try JSONSerialization.jsonObject(with: data, options: [])
let json = try JSON(any: json)
```

```swift
let userInfo: [AnyHashable: Any]
let json = try JSON(any: json)
```

```swift
let objects: [Any]
let json = try JSON(any: json)
```

In the case of the following try it is not required.

```swift
let object: [String : JSON]
let json = JSON(object)
```

```swift
let object: [JSON]
let json = JSON(object)
```

```swift
let object: [JSONWritableType]
let json = JSON(object)
```

```swift
let object: [String : JSONWritableType]
let json = JSON(object)
```
---

# Get current path (Debugging information.)

```swift

let path = try json
    .next(0)
    .next("image")
    .next("hidpi_image")
    .currentPath()

// path => "[0]["image"]["hidpi_image"]"
```

# JSONError

If you have access that does not exist key, throw　`JSONError`.

```swift
public enum JSONError: Error {
  case notFoundKey(key: String, json: JSON)
  case notFoundIndex(index: Int, json: JSON)
  case failedToGetString(source: Any, json: JSON)
  case failedToGetBool(source: Any, json: JSON)
  case failedToGetNumber(source: Any, json: JSON)
  case failedToGetArray(source: Any, json: JSON)
  case failedToGetDictionary(source: Any, json: JSON)
  case decodeError(source: Any, json: JSON, decodeError: Error)
  case invalidJSONObject
}
```

example:

```swift
do {
  let urlString: String = try json
    .next("shots")
    .next(0)
    .next("user")
    .next("profile_image")
    .next("foo") // ‼️ throw
    .getString()
} catch {
   print(error)
}
```

Output jsonError

```
notFoundKey("foo",
json
Path: Root->["shots"][0]["user"]["profile_image"]
SourceType: dictionary

Source:
{
    large = "https://...";
    medium = "https://...";
    small = "https://...";
})
```

# Go Back JSON hierarchy

```swift

try json
    .next(0)
    .next("image")
    .back() // <---
    .next("image")
    .next("hidpi_image")

```

# Import Example (dribbble API)

```swift
let json = try! JSON(data)

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
    let shots: [Shot] = try json.getArray().map { json -> Shot in

        let imagesjson = try json.next("images")

        return Shot(
            id: try json.next("id").getInt(),
            title: try json.next("title").getString(),
            width: try json.next("width").getInt(),
            height: try json.next("height").getInt(),
            hidpiImageURLString: try? imagesjson.next("hidpi").getString(),
            normalImageURLString: try imagesjson.next("normal").getString(),
            teaserImageURLString: try imagesjson.next("teaser").getString()
        )
    }
    print(shots)
} catch {
    print(error)
}
```

## Write JSON

```swift
var json = JSON()
json["id"] = 18737649
json["active"] = true
json["name"] = "muukii"

var images = [String:JSON]()
images["large"] = "http://...foo"
images["medium"] = "http://...bar"
images["small"] = "http://...fuzz"

json["images"] = JSON(images)

let data = try json.data(options: .prettyPrinted)
```

-> data
```
{
  "name" : "muukii",
  "active" : true,
  "id" : 18737649,
  "images" : {
    "large" : "http:\/\/...foo",
    "small" : "http:\/\/...fuzz",
    "medium" : "http:\/\/...bar"
  }
}
```

### json Convertible Examples

```swift
var json = JSON()

json["String"] = "String"
json["NSString"] = JSON("NSString" as NSString)
json["NSNumber"] = NSNumber(value: 0)
json["Int"] = 64
json["Int8"] = JSON(8 as Int8)
json["Int16"] = JSON(16 as Int16)
json["Int32"] = JSON(32 as Int32)
json["Int64"] = JSON(64 as Int64)

json["UInt"] = JSON(64 as UInt)
json["UInt8"] = JSON(8 as UInt8)
json["UInt16"] = JSON(16 as UInt16)
json["UInt32"] = JSON(32 as UInt32)
json["UInt64"] = JSON(64 as UInt64)

json["Bool_true"] = true
json["Bool_false"] = false

json["Float"] = JSON(1.0 / 3.0 as Float)
json["Double"] = JSON(1.0 / 3.0 as Double)
json["CGFloat"] = JSON(1.0 / 3.0 as CGFloat)
```

# Installation

json is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "JAYSON"
```

# Author

muukii, muukii.app@gmail.com

# License

json is available under the MIT license. See the LICENSE file for more info.


[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fmuukii%2FJAYSON.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2Fmuukii%2FJAYSON?ref=badge_large)
