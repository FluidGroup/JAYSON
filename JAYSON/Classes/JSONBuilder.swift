//
//  JSONBuilder.swift
//  Pods
//
//  Created by muukii on 9/15/16.
//
//

import Foundation

public protocol JSONWritableType {

}

public protocol JSONWritableConvertibleType {
    var jsonWritableType: JSONWritableType { get }
}

extension NSNull: JSONWritableType {
}

extension String: JSONWritableType {
}

extension NSNumber: JSONWritableType {
}

extension Int: JSONWritableType {
}

extension Int8: JSONWritableConvertibleType {
    public var jsonWritableType: JSONWritableType {
        return NSNumber(value: self)
    }
}

extension Int16: JSONWritableConvertibleType {
    public var jsonWritableType: JSONWritableType {
        return NSNumber(value: self)
    }
}

extension Int32: JSONWritableConvertibleType {
    public var jsonWritableType: JSONWritableType {
        return NSNumber(value: self)
    }
}

extension Int64: JSONWritableConvertibleType {
    public var jsonWritableType: JSONWritableType {
        return NSNumber(value: self)
    }
}

extension Float: JSONWritableType {
}

extension Double: JSONWritableType {
}

extension Bool: JSONWritableType {
}
