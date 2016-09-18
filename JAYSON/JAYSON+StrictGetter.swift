// JAYSON+StrictGetter.swift
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

// Get Swift Value
extension JAYSON {
    
    public func getNumber() throws -> NSNumber {
        guard let value = number else {
            throw JAYSONError.FailedToGetNumber(source, self)
        }
        return value
    }
    
    public func getInt() throws -> Int {
        return try getNumber().intValue
    }
    
    public func getInt64() throws -> Int64 {
        return try getNumber().int64Value
    }
    
    public func getString() throws -> String {
        guard let value = string else {
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
    
    public func getFloat() throws -> Float {
        return try getNumber().floatValue
    }
    
    public func getDouble() throws -> Double {
        return try getNumber().doubleValue
    }
    
    public func getArray() throws -> [JAYSON] {
        guard let value = source as? [Any] else {
            throw JAYSONError.FailedToGetArray(source, self)
        }
        return value.enumerated().map { JAYSON(source: $0.element, breadcrumb: Breadcrumb(jayson: self, index: $0.offset)) }
    }
}

///
extension JAYSON {
    
    public func get<T>(_ s: (JAYSON) throws -> T) rethrows -> T {
        do {
            return try s(self)
        } catch {
            throw JAYSONError.DecodeError(source, self, error)
        }
    }
    
    public func get<T>(with decoder: Decoder<T>) throws -> T {
        do {
            return try decoder.decode(self)
        } catch {
            throw JAYSONError.DecodeError(source, self, error)
        }
    }
}

