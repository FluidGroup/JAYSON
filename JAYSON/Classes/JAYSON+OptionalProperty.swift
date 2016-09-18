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
    
    public var string: String? {
        get {
            return source as? String
        }
        set {
            source = newValue ?? NSNull()
        }
    }
    
    public var number: NSNumber? {
        get {
            return source as? NSNumber
        }
        set {
            source = newValue ?? NSNull()
        }
    }
    
    public var double: Double? {
        get {
            return self.number?.doubleValue
        }
        set {
            source = newValue ?? NSNull()
        }
    }
    
    public var float: Float? {
        get {
            return self.number?.floatValue
        }
        set {
            source = newValue ?? NSNull()
        }
    }
    
    public var int: Int? {
        get {
            return self.number?.intValue
        }
        set {
            source = newValue ?? NSNull()
        }
    }
    
    public var uInt: UInt? {
        get {
            return self.number?.uintValue
        }
        set {
            source = newValue ?? NSNull()
        }
    }
    
    public var int8: Int8? {
        get {
            return self.number?.int8Value
        }
        set {
            source = newValue ?? NSNull()
        }
    }
    
    public var uInt8: UInt8? {
        get {
            return self.number?.uint8Value
        }
        set {
            source = newValue ?? NSNull()
        }
    }
    
    public var int16: Int16? {
        get {
            return self.number?.int16Value
        }
        set {
            source = newValue ?? NSNull()
        }
    }
    
    public var uInt16: UInt16? {
        get {
            return self.number?.uint16Value
        }
        set {
            source = newValue ?? NSNull()
        }
    }
    
    public var int32: Int32? {
        get {
            return self.number?.int32Value
        }
        set {
            source = newValue ?? NSNull()
        }
    }
    
    public var uInt32: UInt32? {
        get {
            return self.number?.uint32Value
        }
        set {
            source = newValue ?? NSNull()
        }
    }
    
    public var int64: Int64? {
        get {
            return self.number?.int64Value
        }
        set {
            source = newValue ?? NSNull()
        }
    }
    
    public var uInt64: UInt64? {
        get {
            return self.number?.uint64Value
        }
        set {
            source = newValue ?? NSNull()
        }
    }
}
