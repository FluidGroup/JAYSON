// JSON+StrictGetter.swift
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
extension JSON {

  public func getDictionary() throws(JSONError) -> [String : JSON] {
    guard let value = dictionary else {
      throw JSONError.failedToGetDictionary(json: self)
    }
    return value
  }

  public func getArray() throws(JSONError) -> [JSON] {
    guard let value = array else {
      throw JSONError.failedToGetArray(json: self)
    }
    return value
  }

  public func getNumber() throws(JSONError) -> NSNumber {
    guard let value = number else {
      throw JSONError.failedToGetNumber(json: self)
    }
    return value
  }

  public func getInt() throws(JSONError) -> Int {
    return try getNumber().intValue
  }

  public func getInt8() throws(JSONError) -> Int8 {
    return try getNumber().int8Value
  }

  public func getInt16() throws(JSONError) -> Int16 {
    return try getNumber().int16Value
  }

  public func getInt32() throws(JSONError) -> Int32 {
    return try getNumber().int32Value
  }

  public func getInt64() throws(JSONError) -> Int64 {
    return try getNumber().int64Value
  }

  public func getUInt() throws(JSONError) -> UInt {
    return try getNumber().uintValue
  }

  public func getUInt8() throws(JSONError) -> UInt8 {
    return try getNumber().uint8Value
  }

  public func getUInt16() throws(JSONError) -> UInt16 {
    return try getNumber().uint16Value
  }

  public func getUInt32() throws(JSONError) -> UInt32 {
    return try getNumber().uint32Value
  }

  public func getUInt64() throws(JSONError) -> UInt64 {
    return try getNumber().uint64Value
  }

  public func getString() throws(JSONError) -> String {
    guard let value = string else {
      throw JSONError.failedToGetString(json: self)
    }
    return value
  }

  public func getBool() throws(JSONError) -> Bool {
    guard let value = source as? Bool else {
      throw JSONError.failedToGetBool(json: self)
    }
    return value
  }

  public func getFloat() throws(JSONError) -> Float {
    return try getNumber().floatValue
  }

  public func getDouble() throws(JSONError) -> Double {
    return try getNumber().doubleValue
  }

  public func getURL() throws(JSONError) -> URL {
    let string = try getString()
    if let url = URL(string: string) {
        return url
    }
    throw JSONError.failedToParseURL(json: self)
  }

  public func get<T>(_ s: (JSON) throws -> T) throws(JSONError) -> T {
    do {
      return try s(self)
    } catch let jsonError as JSONError {
      throw jsonError
    } catch {
      throw JSONError.decodeError(json: self, decodeError: error)
    }
  }

  public func get<T>(with decoder: Decoder<T>) throws(JSONError) -> T {
    return try decoder.decode(self)
  }

}

