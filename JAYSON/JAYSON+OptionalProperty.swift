// JAYSON+OptionalProperty.swift
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

extension JAYSON {
    
    public var dictionary: [String : JAYSON]? {
        return (source as? [String : Any])?.reduce([String : JAYSON]()) { dic, element in
            var dic = dic
            dic[element.key] = JAYSON(source: element.value, breadcrumb: Breadcrumb(jayson: self, key: element.key))
            return dic
        }
    }
    
    public var array: [JAYSON]? {
        return (source as? [Any])?
            .enumerated()
            .map { JAYSON(source: $0.element, breadcrumb: Breadcrumb(jayson: self, index: $0.offset)) }
    }
    
    public var string: String? {
        return source as? String
    }
    
    public var number: NSNumber? {
        return source as? NSNumber
    }
    
    public var double: Double? {
        return number?.doubleValue
    }
    
    public var float: Float? {
        return number?.floatValue
    }
    
    public var int: Int? {
        return number?.intValue
    }
    
    public var uInt: UInt? {
        return number?.uintValue
    }
    
    public var int8: Int8? {
        return number?.int8Value
    }
    
    public var uInt8: UInt8? {
        return number?.uint8Value
    }
    
    public var int16: Int16? {
        return number?.int16Value
    }
    
    public var uInt16: UInt16? {
        return number?.uint16Value
    }
    
    public var int32: Int32? {
        return number?.int32Value
    }
    
    public var uInt32: UInt32? {
        return number?.uint32Value
    }
    
    public var int64: Int64? {
        return number?.int64Value
    }
    
    public var uInt64: UInt64? {
        return number?.uint64Value
    }
    
    public var bool: Bool? {
        return number?.boolValue
    }
        
    public func getOrNil<T>(with decoder: Decoder<T>) -> T? {
        do {
            return try decoder.decode(self)
        } catch {
            return nil
        }
    }
    
    public func getOrNil<T>(_ s: (JAYSON) throws -> T) -> T? {
        do {
            return try s(self)
        } catch {
            return nil
        }
    }
}
