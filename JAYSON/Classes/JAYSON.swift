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

public enum JAYSONError: Error {
    case NotFoundKey(String, JAYSON)
    case NotFoundIndex(Int, JAYSON)
    case FailedToGetString(Any, JAYSON)
    case FailedToGetBool(Any, JAYSON)
    case FailedToGetNumber(Any, JAYSON)
    case FailedToGetArray(Any, JAYSON)
}

public struct JAYSON: CustomDebugStringConvertible {
    
    let source: Any?
    
    fileprivate let breadcrumb: Breadcrumb?
    
    public init(_ source: Any?) throws {
        if let data = source as? Data {
            try self.init(data: data)
        } else {
            self.init(source: source, breadcrumb: nil)
        }
    }
    
    init(data: Data) throws {
        let source = try JSONSerialization.jsonObject(with: data, options: [])
        self.init(source: source, breadcrumb: nil)
    }
    
    init(source: Any?, breadcrumb: Breadcrumb?) {
        self.source = source
        self.breadcrumb = breadcrumb
    }
    
    public subscript (key: String) -> JAYSON? {
        return (source as? [AnyHashable : Any])
            .flatMap { $0[key] }
            .map { JAYSON(source: $0, breadcrumb: Breadcrumb(jayson: self, key: key)) }
    }
    
    public subscript (index: Int) -> JAYSON? {
        return (source as? [Any])
            .flatMap { $0[index] }
            .map { JAYSON(source: $0, breadcrumb: Breadcrumb(jayson: self, index: index)) }
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
        return ""
            + "Path: \(currentPath())\n"
            + "\n"
            + "\(source)"
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

/// Control JAYSON hierarchy
extension JAYSON {

    private func next(_ key: String) throws -> JAYSON {
        guard let jayson = self[key] else {
            throw JAYSONError.NotFoundKey(key, self)
        }
        return jayson
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
        guard let jayson = self[index] else {
            throw JAYSONError.NotFoundIndex(index, self)
        }
        return jayson
    }
    
    /**
     if `self` has parent JAYSON, return parent `JAYSON`, otherwise return `self`
     */
    public func back() -> JAYSON {
        return breadcrumb?.jayson ?? self
    }
}

// Get Swift Value
extension JAYSON {
    
    public func getNumber() throws -> NSNumber {
        guard let value = source as? NSNumber else {
            throw JAYSONError.FailedToGetNumber(source, self)
        }
        return value
    }
    
    public func getInt() throws -> Int {
        return try getNumber().intValue
    }
    
    public func getString() throws -> String {
        guard let value = source as? String else {
            throw JAYSONError.FailedToGetString(source, self)
        }
        return value
    }
    
    public func getBool() throws -> Bool {
        guard let value = source as? Bool else {
            throw JAYSONError.FailedToGetBool(source, self)
        }
        return value
    }
    
    public func getArray() throws -> [JAYSON] {
        guard let value = source as? [Any] else {
            throw JAYSONError.FailedToGetArray(source, self)
        }
        return value.enumerated().map { JAYSON(source: $0.element, breadcrumb: Breadcrumb(jayson: self, index: $0.offset)) }
    }
}

extension JAYSON {

    public var isNull: Bool {
        return source is NSNull
    }
}

/// 
extension JAYSON {

    public func get<T>(_ s: (JAYSON) throws -> T) rethrows -> T {
        return try s(self)
    }
    
    public func get<T>(with decoder: Decoder<T>) throws -> T {
        return try decoder.decode(self)
    }
}

public struct Decoder<T> {
    
    let decode: (JAYSON) throws -> T
    
    public init(_ s: @escaping (JAYSON) throws -> T) {
        self.decode = s
    }
}
