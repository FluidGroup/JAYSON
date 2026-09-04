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

public struct JSONProvenance: Hashable, Sendable, Identifiable {
  public struct ID: Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
      self.rawValue = rawValue
    }
  }

  public let id: ID

  public init(id: ID) {
    self.id = id
  }
}

private final class JSONDocumentStorage: Sendable {
  let provenance: JSONProvenance

  init(provenance: JSONProvenance) {
    self.provenance = provenance
  }
}

public enum JSONError: Error {
  case notFoundKey(key: String, json: JSON)
  case notFoundIndex(index: Int, json: JSON)
  case failedToGetString(json: JSON)
  case failedToGetBool(json: JSON)
  case failedToGetNumber(json: JSON)
  case failedToGetArray(json: JSON)
  case failedToGetDictionary(json: JSON)
  case failedToParseURL(json: JSON)
  case decodeError(json: JSON, decodeError: Error)
  case failedToInitializeFromJSONString(String)
  case invalidJSONObject
}

public struct JSON: Hashable, Sendable {

  public static func ==(lhs: JSON, rhs: JSON) -> Bool {
    return (lhs.source as? NSObject) == (rhs.source as? NSObject)
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.source as? NSObject)
  }

  public static let null = JSON()
  
  nonisolated(unsafe)
  public internal(set) var source: Any

  let breadcrumb: Breadcrumb?
  private let documentStorage: JSONDocumentStorage?

  public var provenance: JSONProvenance? {
    documentStorage?.provenance
  }

  public init(_ object: JSONWritableType) {
    self.init(source: object.jsonValueBox.source, breadcrumb: nil)
  }

  public init(_ object: [JSONWritableType]) {
    self.init(source: object.map { $0.jsonValueBox.source }, breadcrumb: nil)
  }

  public init(_ object: [JSON]) {
    self.init(
      source: object.map { $0.source },
      breadcrumb: nil,
      documentStorage: Self.commonDocumentStorage(for: object)
    )
  }

  public init(_ object: [String : JSON]) {
    self.init(
      source: object.reduce(into: [String : Any]()) { (dictionary, object) in
        dictionary[object.key] = object.value.source
      },
      breadcrumb: nil,
      documentStorage: Self.commonDocumentStorage(for: object.values)
    )
  }

  public init(_ object: [String : JSONWritableType]) {
    self.init(
      source: object.reduce(into: [String : Any]()) { (dictionary, object) in
        dictionary[object.key] = object.value.jsonValueBox.source
      },
      breadcrumb: nil
    )
  }

  public init() {
    self.init(source: NSNull(), breadcrumb: nil)
  }

  public init(jsonString: consuming sending String) throws(JSONError) {
    guard let data = jsonString.data(using: .utf8) else {
      throw JSONError.failedToInitializeFromJSONString(jsonString)
    }
    try self.init(data: data)
  }

  public init(data: sending Data) throws(JSONError) {
    let source = try Self.parse(data: data)
    self.init(source: source, breadcrumb: nil)
  }

  public init(data: sending Data, provenance: JSONProvenance) throws(JSONError) {
    let documentStorage = JSONDocumentStorage(provenance: provenance)
    let source = try Self.parse(data: data, documentStorage: documentStorage)
    self.init(
      source: source,
      breadcrumb: nil,
      documentStorage: documentStorage
    )
  }

  private static func parse(
    data: Data,
    documentStorage: JSONDocumentStorage? = nil
  ) throws(JSONError) -> Any {
    let source: Any
    do {
      source = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
    } catch {
      let json = documentStorage.map {
        JSON(source: NSNull(), breadcrumb: nil, documentStorage: $0)
      } ?? JSON.null
      throw JSONError.decodeError(json: json, decodeError: error)
    }
    return source
  }

  public init(any: sending Any) throws(JSONError) {
    guard JSONSerialization.isValidJSONObject(any) else {
      throw JSONError.invalidJSONObject
    }
    self.init(source: any, breadcrumb: nil)
  }

  private init(
    source: Any,
    breadcrumb: Breadcrumb?,
    documentStorage: JSONDocumentStorage? = nil
  ) {
    self.source = source
    self.breadcrumb = breadcrumb
    self.documentStorage = documentStorage
  }

  public func data(options: JSONSerialization.WritingOptions = []) throws(JSONError) -> Data {
    guard JSONSerialization.isValidJSONObject(source) else {
      throw JSONError.invalidJSONObject
    }
    do {
      return try JSONSerialization.data(withJSONObject: source, options: options)
    } catch {
      throw JSONError.decodeError(json: self, decodeError: error)
    }
  }

  public func currentPath() -> String {
    return breadcrumb?.renderPath() ?? ""
  }

  func derived(source: Any, breadcrumb: Breadcrumb?) -> JSON {
    JSON(
      source: source,
      breadcrumb: breadcrumb,
      documentStorage: documentStorage
    )
  }

  private static func commonDocumentStorage<Values: Collection>(
    for values: Values
  ) -> JSONDocumentStorage? where Values.Element == JSON {
    guard let documentStorage = values.first?.documentStorage else {
      return nil
    }

    guard values.dropFirst().allSatisfy({ $0.documentStorage === documentStorage }) else {
      return nil
    }

    return documentStorage
  }

  private static func commonDocumentStorage(
    for first: JSON,
    and second: JSON
  ) -> JSONDocumentStorage? {
    guard let documentStorage = first.documentStorage,
      second.documentStorage === documentStorage
    else {
      return nil
    }

    return documentStorage
  }
}

public extension JSONError {
  var provenance: JSONProvenance? {
    switch self {
    case let .notFoundKey(key: _, json: json),
      let .notFoundIndex(index: _, json: json),
      let .failedToGetString(json: json),
      let .failedToGetBool(json: json),
      let .failedToGetNumber(json: json),
      let .failedToGetArray(json: json),
      let .failedToGetDictionary(json: json),
      let .failedToParseURL(json: json),
      let .decodeError(json: json, decodeError: _):
      return json.provenance
    case .failedToInitializeFromJSONString, .invalidJSONObject:
      return nil
    }
  }
}

extension JSON {

  struct Breadcrumb: Sendable {
    
    enum Component {
      case key(String)
      case index(Int)
    }
    
    var component: [Component]
    
    init(key: String) {
      component = [.key(key)]
    }
    
    init(index: Int) {
      component = [.index(index)]
    }  
    
    consuming func appending(_ component: Component) -> Self {
      self.component.append(component)
      return self
    }
    
    func renderPath() -> String {
      return component.map { c in
        switch c {
        case .key(let key):
          return "[\"\(key)\"]"
        case .index(let index):
          return "[\(index)]"
        }
      }.joined()
    }
    
  }
}

extension JSON {

  fileprivate mutating func set(_ json: JSON?, for key: String) {
    var source = source
    if source is NSNull {
      source = [String : Any]()
    }

    guard var dictionary = source as? [String : Any] else {
      return
    }

    dictionary[key] = json?.source

    let documentStorage: JSONDocumentStorage?
    if let json {
      documentStorage = Self.commonDocumentStorage(for: self, and: json)
    } else {
      documentStorage = self.documentStorage
    }

    self = JSON(
      source: dictionary,
      breadcrumb: breadcrumb,
      documentStorage: documentStorage
    )
  }

  /// if key is not found, return nil
  public subscript (key: String) -> JSON? {
    get {
      return (source as? NSDictionary)
        .flatMap {
          let value = $0[key]
          if value is NSNull {
            return nil
          }
          return value
        }
        .map {
          JSON(
            source: $0,
            breadcrumb: breadcrumb?.appending(.key(key)) ?? Breadcrumb(key: key),
            documentStorage: documentStorage
          )
        }
    }
    set {
      set(newValue, for: key)
    }
  }

  /// if index is not found return JSON.null
  public subscript (index: Int) -> JSON? {
    get {
      let childBreadcrumb = breadcrumb?.appending(.index(index)) ?? Breadcrumb(index: index)
      return (source as? NSArray)
        .flatMap {
          if index >= 0, index < $0.count {
            return $0[index]
          }
          return nil
        }
        .map {
          derived(
            source: $0,
            breadcrumb: childBreadcrumb
          )
        } ?? derived(source: NSNull(), breadcrumb: childBreadcrumb)
    }
  }
}

extension JSON {

  public mutating func append(_ json: JSON) {
    guard let appendDictionary = json.source as? NSDictionary else {
      return
    }

    guard appendDictionary.count > 0 else {
      return
    }

    var source = source
    if source is NSNull {
      source = [String : Any]()
    }

    guard var dictionary = source as? [String : Any] else {
      return
    }

    for value in appendDictionary {
      dictionary[value.key as! String] = value.value
    }

    self = JSON(
      source: dictionary,
      breadcrumb: breadcrumb,
      documentStorage: Self.commonDocumentStorage(for: self, and: json)
    )
  }
}

/// Control JSON hierarchy
extension JSON {

  private func _next(_ key: String) throws(JSONError) -> JSON {
    var result = self
    for keyPart in key.split(separator: ".").map(String.init) {
      guard let value = result[keyPart] else {
        throw JSONError.notFoundKey(key: keyPart, json: self)
      }
      result = value
    }
    return result
  }

  private func _next(_ keys: [String]) throws(JSONError) -> JSON {
    var result = self
    for key in keys {
      result = try result._next(key)
    }
    return result
  }

  /**
   Returns a JSON represents the value pointed by key.
   It throws an error when the value represents null or the key was not found.
   
   if `type` is `Dictonary`, return `JSON` whose object is `dictionary[key]`, otherwise throw `JSONError`.
   e.g next("a", "b", "c") or next("a.b.c")
   */
  public func next(_ key: String...) throws(JSONError) -> JSON {
    return try _next(key)
  }

  /**
   Returns a JSON represents the value pointed by key.
   It throws an error when the value represents null or the key was not found.
   */
  public func next<T: RawRepresentable>(_ key: T) throws(JSONError) -> JSON where T.RawValue == String {
    return try _next(key.rawValue)
  }

  /**
   Returns a JSON represents the value pointed by key.
   It throws an error when the value represents null or the key was not found.
   
   if `type` is `Array`, return `JSON` whose object is `array[index]`, otherwise throw `JSONError`.
   */
  public func next(_ index: Int) throws(JSONError) -> JSON {
    guard let value = self[index], !(value.source is NSNull) else {
      throw JSONError.notFoundIndex(index: index, json: self)
    }
    return value
  }

  /**
   Returns a JSON represents the value pointed by key.
   It throws an error when the value represents null or the key was not found.
   */
  public func next<T: RawRepresentable>(_ key: T) throws(JSONError) -> JSON where T.RawValue == Int {
    return try next(key.rawValue)
  }

  public func removed(_ key: String) -> JSON {

    guard let _source = (source as? NSDictionary)?.mutableCopy() as? NSMutableDictionary else {
      return self
    }
    _source.removeObject(forKey: key)
    return JSON(
      source: _source,
      breadcrumb: breadcrumb,
      documentStorage: documentStorage
    )
  }

  /**
   Returns a Boolean value that indicates if the key contains a value (including NSNull).

   The following JSONs return true from finding key `name`.
   ```json
   {
     "name": "John"
   }
   ```

   ```json
   {
     "name": null
   }
   ```
   */
  public func contains(_ key: String...) -> Bool {
    contains(key)
  }

  /**
   Returns a Boolean value that indicates if the key contains a value (including NSNull).

   The following JSONs return true from finding key `name`.
   ```json
   {
     "name": "John"
   }
   ```

   ```json
   {
     "name": null
   }
   ```
   */
  public func contains(_ keys: [String]) -> Bool {
    var _source: Any = self.source
    for key in keys {
      guard
        let dictionary = _source as? NSDictionary,
        let nextSource = dictionary.value(forKey: key)
      else {
        return false
      }
      _source = nextSource
    }
    return true
  }

  /**
   Returns a Boolean value that indicates if the key contains a value (including NSNull).

   The following JSONs return true from finding key `name`.
   ```json
   {
     "name": "John"
   }
   ```

   ```json
   {
     "name": null
   }
   ```
   */
  public func contains(_ key: String) -> Bool {

    guard let dictionary = (source as? NSDictionary) else {
      return false
    }

    return dictionary.value(forKey: key) != nil

  }

  /**
   Returns a Boolean value that indicates if the index presents a value (including NSNull).
   */
  public func contains(_ index: Int) -> Bool {

    guard let array = (source as? NSArray) else {
      return false
    }

    return index < array.count
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
