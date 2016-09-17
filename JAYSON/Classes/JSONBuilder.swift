//
//  JSONBuilder.swift
//  Pods
//
//  Created by muukii on 9/15/16.
//
//

import Foundation

public protocol JSONWritableType {
    
    var jsonValue: JSONWritableType { get }
}

extension String: JSONWritableType {
    public var jsonValue: JSONWritableType {
        return self
    }
}

extension NSNumber: JSONWritableType {
    public var jsonValue: JSONWritableType {
        return self
    }
}

extension Int: JSONWritableType {
    public var jsonValue: JSONWritableType {
        return self
    }
}

extension Int8: JSONWritableType {
    public var jsonValue: JSONWritableType {
        return NSNumber(value: self)
    }
}

extension Int16: JSONWritableType {
    public var jsonValue: JSONWritableType {
        return NSNumber(value: self)
    }
}

extension Int32: JSONWritableType {
    public var jsonValue: JSONWritableType {
        return NSNumber(value: self)
    }
}

extension Int64: JSONWritableType {
    public var jsonValue: JSONWritableType {
        return NSNumber(value: self)
    }
}

extension Float: JSONWritableType {
    public var jsonValue: JSONWritableType {
        return NSNumber(value: self)
    }
}

extension Double: JSONWritableType {
    public var jsonValue: JSONWritableType {
        return NSNumber(value: self)
    }
}

extension Bool: JSONWritableType {
    public var jsonValue: JSONWritableType {
        return self
    }
}

public class JSONArray: ExpressibleByArrayLiteral {
    
    public private(set) var source: [Any]
    
    public init() {
        source = []
    }
    
    
    public func add(value: JSONWritableType) {
        source.append(value.jsonValue)
    }
    
    public func add(value: JSONArray) {
        source.append(value.source)
    }
    
    public func add(value: JSONDictionary) {
        source.append(value.source)
    }
    
    public func build() throws -> Data {
        return try JSONSerialization.data(withJSONObject: source, options: .prettyPrinted)
    }
    
//    public var jsonValue: Any {
//        return source
//    }
    
    public typealias Element = JSONWritableType
    public required init(arrayLiteral elements: Element...) {
        source = elements
    }
}

public class JSONDictionary: ExpressibleByDictionaryLiteral {
    
    public init() {
        source = [:]
    }
    
    public private(set) var source: [String : Any]
    
    public func add(key: String, value: JSONWritableType) {
        source[key] = value.jsonValue
    }
    
    public func add(key: String, value: JSONArray) {
        source[key] = value.source
    }
    
    public func add(key: String, value: JSONDictionary) {
        source[key] = value.source
    }
    
    public func build() throws -> Data {
        return try JSONSerialization.data(withJSONObject: source, options: .prettyPrinted)
    }
    
//    public var jsonValue: JSONWritableType {
//        return source
//    }
    
    public typealias Key = String
    public typealias Value = JSONWritableType
    
    public required init(dictionaryLiteral elements: (Key, Value)...) {
        let _source = elements.reduce([String : Any]()) { dic, values in
            var dic = dic
            dic[values.0] = values.1
            return dic
        }
        source = _source
    }
}
