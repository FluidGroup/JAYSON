// JAYSON.swift
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

public enum JAYSONError: Error {
    case notFoundKey(key: String, jayson: JAYSON)
    case notFoundIndex(index: Int, jayson: JAYSON)
    case failedToGetString(source: Any, jayson: JAYSON)
    case failedToGetBool(source: Any, jayson: JAYSON)
    case failedToGetNumber(source: Any, jayson: JAYSON)
    case failedToGetArray(source: Any, jayson: JAYSON)
    case failedToGetDictionary(source: Any, jayson: JAYSON)
    case decodeError(source: Any, jayson: JAYSON, decodeError: Error)
    case invalidJSONObject
}

public struct JAYSON: CustomDebugStringConvertible, Equatable {

    public static func ==(lhs: JAYSON, rhs: JAYSON) -> Bool {
        return (lhs.source as? NSObject) == (rhs.source as? NSObject)
    }

    public static let null = JAYSON()

    public fileprivate(set) var source: Any

    fileprivate let breadcrumb: Breadcrumb?

    public init(_ object: JAYSONWritableType) {
        source = object.jsonValueBox.source
        breadcrumb = nil        
    }

    public init(_ object: [JAYSONWritableType]) {
        source = object.map { $0.jsonValueBox.source }
        breadcrumb = nil
    }

    public init(_ object: [JAYSON]) {
        source = object.map { $0.source }
        breadcrumb = nil
    }

    public init(_ object: [String : JAYSON]) {
        source = object.reduce([String : Any]()) { dictionary, object in
            var dictionary = dictionary
            dictionary[object.key] = object.value.source
            return dictionary
        }
        breadcrumb = nil
    }

    public init(_ object: [String : JAYSONWritableType]) {
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
            throw JAYSONError.invalidJSONObject
        }
        self.init(source: any, breadcrumb: nil)
    }

    init(source: Any, breadcrumb: Breadcrumb?) {
        self.source = source
        self.breadcrumb = breadcrumb
    }

    public func data(options: JSONSerialization.WritingOptions = []) throws -> Data {
        guard JSONSerialization.isValidJSONObject(source) else {
            throw JAYSONError.invalidJSONObject
        }
        return try JSONSerialization.data(withJSONObject: source, options: options)
    }

    public func currentPath() -> String {

        var path: String = ""

        var currentBreadcrumb: Breadcrumb? = breadcrumb

        while let _currentBreadcrumb = currentBreadcrumb {
            path = _currentBreadcrumb.path + path
            currentBreadcrumb = _currentBreadcrumb.jayson.breadcrumb
        }

        return "Root->" + path
    }

    public var debugDescription: String {
        return "\n"
            + "JAYSON\n"
            + "Path: \(currentPath())\n"
            + "SourceType: \(sourceType)\n"
            + "\n"
            + "Source:\n\(source)"
    }
}

extension JAYSON {

    final class Breadcrumb: CustomStringConvertible, CustomDebugStringConvertible {

        let jayson: JAYSON
        let path: String

        init(jayson: JAYSON, key: String) {
            self.jayson = jayson
            self.path = "[\"\(key)\"]"
        }

        init(jayson: JAYSON, index: Int) {
            self.jayson = jayson
            self.path = "[\(index)]"
        }

        var description: String {
            return "\(path)"
        }

        var debugDescription: String {
            return "\(path)\n\(jayson)"
        }
    }
}

extension JAYSON {

    /// if key is not found, return JAYSON.null
    public subscript (key: String) -> JAYSON {
        get {
            return (source as? [String : Any])
                .flatMap { $0[key] }
                .map { JAYSON(source: $0, breadcrumb: Breadcrumb(jayson: self, key: key)) } ?? JAYSON.null
        }
        set {
            if source is NSNull {
                source = [String : Any]()
            }

            guard var dictionary = source as? [String : Any] else {
                return
            }
            dictionary[key] = newValue.source
            source = dictionary
        }
    }

    /// if index is not found return JAYSON.null
    public subscript (index: Int) -> JAYSON {
        get {
            return (source as? [Any])
                .flatMap { $0[index] }
                .map { JAYSON(source: $0, breadcrumb: Breadcrumb(jayson: self, index: index)) } ?? JAYSON.null
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

/// Control JAYSON hierarchy
extension JAYSON {

    private func next(_ key: String) throws -> JAYSON {
        guard !(self[key].source is NSNull) else {
            throw JAYSONError.notFoundKey(key: key, jayson: self)
        }
        return self[key]
    }

    /**
     if `type` is `Dictonary`, return `JAYSON` whose object is `dictionary[key]`, otherwise throw `JAYSONError`.
     */
    public func next(_ key: String...) throws -> JAYSON {
        return try key.reduce(self) { jayson, key -> JAYSON in
            try jayson.next(key)
        }
    }

    /**
     if `type` is `Array`, return `JAYSON` whose object is `array[index]`, otherwise throw `JAYSONError`.
     */
    public func next(_ index: Int) throws -> JAYSON {
        guard !(self[index].source is NSNull) else {
            throw JAYSONError.notFoundIndex(index: index, jayson: self)
        }
        return self[index]
    }

    /**
     if `self` has parent JAYSON, return parent `JAYSON`, otherwise return `self`
     */
    public func back() -> JAYSON {
        return breadcrumb?.jayson ?? self
    }
}

extension JAYSON: Swift.ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self.init()
    }
}

extension JAYSON: Swift.ExpressibleByStringLiteral {

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

extension JAYSON: Swift.ExpressibleByIntegerLiteral {

    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value)
    }
}

extension JAYSON: Swift.ExpressibleByBooleanLiteral {

    public init(booleanLiteral value: BooleanLiteralType) {
        self.init(value)
    }
}

extension JAYSON: Swift.ExpressibleByFloatLiteral {

    public init(floatLiteral value: FloatLiteralType) {
        self.init(value)
    }
}

extension JAYSON: Swift.ExpressibleByDictionaryLiteral {

    public init(dictionaryLiteral elements: (String, JAYSON)...) {
        let dictionary = elements.reduce([String : JAYSON]()) { dic, element in
            var dic = dic
            dic[element.0] = element.1
            return dic
        }
        self.init(dictionary)
    }
}

extension JAYSON: Swift.ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: JAYSON...) {
        self.init(elements)
    }
}
