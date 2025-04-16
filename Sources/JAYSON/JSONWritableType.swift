// JSONWritableType.swift
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

public struct JSONValueBox {

  public let source: Any & Sendable

  public init(_ object: NSNull) {
    self.source = object
  }

  public init(_ object: String) {
    self.source = object
  }

  public init(_ object: NSNumber) {
    self.source = object
  }

  public init(_ object: Int) {
    self.source = object
  }

  public init(_ object: Float) {
    self.source = object
  }

  public init(_ object: Double) {
    self.source = object
  }

  public init(_ object: Bool) {
    self.source = object
  }
}

public protocol JSONWritableType {

  var jsonValueBox: JSONValueBox { get }
}

extension NSNull: JSONWritableType {
  public var jsonValueBox: JSONValueBox {
    return JSONValueBox(self)
  }
}

extension String: JSONWritableType {
  public var jsonValueBox: JSONValueBox {
    return JSONValueBox(self)
  }
}

extension NSNumber: JSONWritableType {
  public var jsonValueBox: JSONValueBox {
    return JSONValueBox(self)
  }
}

extension Int: JSONWritableType {
  public var jsonValueBox: JSONValueBox {
    return JSONValueBox(self)
  }
}

extension Float: JSONWritableType {
  public var jsonValueBox: JSONValueBox {
    return JSONValueBox(self)
  }
}

extension Double: JSONWritableType {
  public var jsonValueBox: JSONValueBox {
    return JSONValueBox(self)
  }
}

extension Bool: JSONWritableType {
  public var jsonValueBox: JSONValueBox {
    return JSONValueBox(self)
  }
}

extension Int8: JSONWritableType {
  public var jsonValueBox: JSONValueBox {
    return JSONValueBox(NSNumber(value: self))
  }
}

extension Int16: JSONWritableType {
  public var jsonValueBox: JSONValueBox {
    return JSONValueBox(NSNumber(value: self))
  }
}

extension Int32: JSONWritableType {
  public var jsonValueBox: JSONValueBox {
    return JSONValueBox(NSNumber(value: self))
  }
}

extension Int64: JSONWritableType {
  public var jsonValueBox: JSONValueBox {
    return JSONValueBox(NSNumber(value: self))
  }
}

extension UInt: JSONWritableType {
  public var jsonValueBox: JSONValueBox {
    return JSONValueBox(NSNumber(value: self))
  }
}

extension UInt8: JSONWritableType {
  public var jsonValueBox: JSONValueBox {
    return JSONValueBox(NSNumber(value: self))
  }
}

extension UInt16: JSONWritableType {
  public var jsonValueBox: JSONValueBox {
    return JSONValueBox(NSNumber(value: self))
  }
}

extension UInt32: JSONWritableType {
  public var jsonValueBox: JSONValueBox {
    return JSONValueBox(NSNumber(value: self))
  }
}

extension UInt64: JSONWritableType {
  public var jsonValueBox: JSONValueBox {
    return JSONValueBox(NSNumber(value: self))
  }
}

#if !os(Linux)
#if os(macOS)
  import AppKit
  #else
  import UIKit
#endif

  extension CGFloat: JSONWritableType {
    public var jsonValueBox: JSONValueBox {
      return JSONValueBox(self as NSNumber)
    }
  }
#endif
