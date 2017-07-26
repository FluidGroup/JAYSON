// JSON.swift
//
// Copyright (c) 2016 muukii
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

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

public struct JSON: Equatable {

  public static func ==(lhs: JSON, rhs: JSON) -> Bool {
    return (lhs.source as? NSObject) == (rhs.source as? NSObject)
  }

  public static let null = JSON()

  public internal(set) var source: Any

  fileprivate let breadcrumb: Breadcrumb?

  public init(_ object: JSONWritableType) {
    source = object.jsonValueBox.source
    breadcrumb = nil
  }

  public init(_ object: [JSONWritableType]) {
    source = object.map { $0.jsonValueBox.source }
    breadcrumb = nil
  }

  public init(_ object: [JSON]) {
    source = object.map { $0.source }
    breadcrumb = nil
  }

  public init(_ object: [String : JSON]) {
    source = object.reduce([String : Any]()) { dictionary, object in
      var dictionary = dictionary
      dictionary[object.key] = object.value.source
      return dictionary
    }
    breadcrumb = nil
  }

  public init(_ object: [String : JSONWritableType]) {
    source = object.reduce([String : Any]()) { dic, element in
      var dic = dic
      dic[element.key] = element.value.jsonValueBox.source
      return dic
    }
    breadcrumb = nil
  }

  public init() {
    source = NSNull()
    breadcrumb = nil
  }

  public init(data: Data) throws {
    let source = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
    self.init(source: source, breadcrumb: nil)
  }

  public init(any: Any) throws {
    guard JSONSerialization.isValidJSONObject(any) else {
      throw JSONError.invalidJSONObject
    }
    self.init(source: any, breadcrumb: nil)
  }

  init(source: Any, breadcrumb: Breadcrumb?) {
    self.source = source
    self.breadcrumb = breadcrumb
  }

  public func data(options: JSONSerialization.WritingOptions = []) throws -> Data {
    guard JSONSerialization.isValidJSONObject(source) else {
      throw JSONError.invalidJSONObject
    }
    return try JSONSerialization.data(withJSONObject: source, options: options)
  }

  public func currentPath() -> String {

    var path: String = ""

    var currentBreadcrumb: Breadcrumb? = breadcrumb

    while let _currentBreadcrumb = currentBreadcrumb {
      path = _currentBreadcrumb.path + path
      currentBreadcrumb = _currentBreadcrumb.json.breadcrumb
    }

    return "Root->" + path
  }
}

extension JSON {

  final class Breadcrumb: CustomStringConvertible, CustomDebugStringConvertible {

    let json: JSON
    let path: String

    init(json: JSON, key: String) {
      self.json = json
      self.path = "[\"\(key)\"]"
    }

    init(json: JSON, index: Int) {
      self.json = json
      self.path = "[\(index)]"
    }

    var description: String {
      return "\(path)"
    }

    var debugDescription: String {
      return "\(path)\n\(json)"
    }
  }
}

extension JSON {

  fileprivate mutating func set(any: Any, for key: String) {
    if source is NSNull {
      source = [String : Any]()
    }

    guard var dictionary = source as? [String : Any] else {
      return
    }
    dictionary[key] = any
    source = dictionary
  }

  /// if key is not found, return JSON.null
  public subscript (key: String) -> JSON {
    get {
      return (source as? NSDictionary)
        .flatMap { $0[key] }
        .map { JSON(source: $0, breadcrumb: Breadcrumb(json: self, key: key)) } ?? JSON.null
    }
    set {
      set(any: newValue.source, for: key)
    }
  }

  /// if index is not found return JSON.null
  public subscript (index: Int) -> JSON {
    get {
      return (source as? NSArray)
        .flatMap {
          if $0.count > index {
            return $0[index]
          }
          return nil
        }
        .map { JSON(source: $0, breadcrumb: Breadcrumb(json: self, index: index)) } ?? JSON.null
    }
    /*
     set {

     if source is NSNull {
     source = [Any]()
     }

     guard var array = source as? [Any] else {
     return
     }

     guard array.count >= index else {
     return
     }

     array[index] = newValue.source
     source = array
     }
     */
  }
}

extension JSON {

  public mutating func append(_ json: JSON) {
    guard let appendDictionary = json.source as? NSDictionary else {
      return
    }

    for v in appendDictionary {

      set(any: v.value, for: v.key as! String)
    }
  }
}

/// Control JSON hierarchy
extension JSON {

  private func _next(_ key: String) throws -> JSON {

    return try key.characters
      .split(separator: ".")
      .map { String($0) }
      .reduce(self) { j, key in
        guard !(j[key].source is NSNull) else {
          throw JSONError.notFoundKey(key: key, json: self)
        }
        return j[key]
    }
  }

  private func _next(_ keys: [String]) throws -> JSON {
    return try keys.reduce(self) { json, key -> JSON in
      try json._next(key)
    }
  }

  /**
   if `type` is `Dictonary`, return `JSON` whose object is `dictionary[key]`, otherwise throw `JSONError`.
   e.g next("a", "b", "c") or next("a.b.c")
   */
  public func next(_ key: String...) throws -> JSON {
    return try _next(key)
  }

  public func next<T: RawRepresentable>(_ key: T) throws -> JSON where T.RawValue == String {
    return try _next(key.rawValue)
  }

  /**
   if `type` is `Array`, return `JSON` whose object is `array[index]`, otherwise throw `JSONError`.
   */
  public func next(_ index: Int) throws -> JSON {
    guard !(self[index].source is NSNull) else {
      throw JSONError.notFoundIndex(index: index, json: self)
    }
    return self[index]
  }

  public func next<T: RawRepresentable>(_ key: T) throws -> JSON where T.RawValue == Int {
    return try next(key.rawValue)
  }

  /**
   if `self` has parent JSON, return parent `JSON`, otherwise return `self`
   */
  public func back() -> JSON {
    return breadcrumb?.json ?? self
  }

  public func removed(_ key: String) -> JSON {

    guard let _source = (source as? NSDictionary)?.mutableCopy() as? NSMutableDictionary else {
      return self
    }
    _source.removeObject(forKey: key)
    return try! JSON(any: _source)
  }

  public func exists(_ key: String...) -> Bool {
    do {
      let r = try _next(key)
      guard case .null = r.sourceType else {
        return true
      }
      return false
    } catch {
      return false
    }
  }

  public func exists(_ index: Int) -> Bool {
    do {
      let r = try next(index)
      guard case .null = r.sourceType else {
        return true
      }
      return false
    } catch {
      return false
    }
  }
}

extension JSON: Swift.ExpressibleByNilLiteral {
  public init(nilLiteral: ()) {
    self.init()
  }
}

extension JSON: Swift.ExpressibleByStringLiteral {

  public init(stringLiteral value: StringLiteralType) {
    self.init(value)
  }

  public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
    self.init(value)
  }

  public init(unicodeScalarLiteral value: StringLiteralType) {
    self.init(value)
  }
}

extension JSON: Swift.ExpressibleByIntegerLiteral {

  public init(integerLiteral value: IntegerLiteralType) {
    self.init(value)
  }
}

extension JSON: Swift.ExpressibleByBooleanLiteral {

  public init(booleanLiteral value: BooleanLiteralType) {
    self.init(value)
  }
}

extension JSON: Swift.ExpressibleByFloatLiteral {

  public init(floatLiteral value: FloatLiteralType) {
    self.init(value)
  }
}

extension JSON: Swift.ExpressibleByDictionaryLiteral {

  public init(dictionaryLiteral elements: (String, JSON)...) {
    let dictionary = elements.reduce([String : JSON]()) { dic, element in
      var dic = dic
      dic[element.0] = element.1
      return dic
    }
    self.init(dictionary)
  }
}

extension JSON: Swift.ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: JSON...) {
    self.init(elements)
  }
}
