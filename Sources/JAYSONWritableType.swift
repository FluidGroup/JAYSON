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

public struct JAYSONValueBox {
    
    public let source: Any
    
    public init(_ object: NSNull) {
        self.source = object
    }
    
    public init(_ object: String) {
        self.source = object
    }
    
    public init(_ object: NSString) {
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

public protocol JAYSONWritableType {
    
    var jsonValueBox: JAYSONValueBox { get }
}

extension NSNull: JAYSONWritableType {
    public var jsonValueBox: JAYSONValueBox {
        return JAYSONValueBox(self)
    }
}

extension String: JAYSONWritableType {
    public var jsonValueBox: JAYSONValueBox {
        return JAYSONValueBox(self)
    }
}

extension NSString: JAYSONWritableType {
    public var jsonValueBox: JAYSONValueBox {
        return JAYSONValueBox(self)
    }
}

extension NSNumber: JAYSONWritableType {
    public var jsonValueBox: JAYSONValueBox {
        return JAYSONValueBox(self)
    }
}

extension Int: JAYSONWritableType {
    public var jsonValueBox: JAYSONValueBox {
        return JAYSONValueBox(self)
    }
}

extension Float: JAYSONWritableType {
    public var jsonValueBox: JAYSONValueBox {
        return JAYSONValueBox(self)
    }
}

extension Double: JAYSONWritableType {
    public var jsonValueBox: JAYSONValueBox {
        return JAYSONValueBox(self)
    }
}

extension Bool: JAYSONWritableType {
    public var jsonValueBox: JAYSONValueBox {
        return JAYSONValueBox(self)
    }
}

extension Int8: JAYSONWritableType {
    public var jsonValueBox: JAYSONValueBox {
        return JAYSONValueBox(NSNumber(value: self))
    }
}

extension Int16: JAYSONWritableType {
    public var jsonValueBox: JAYSONValueBox {
        return JAYSONValueBox(NSNumber(value: self))
    }
}

extension Int32: JAYSONWritableType {
    public var jsonValueBox: JAYSONValueBox {
        return JAYSONValueBox(NSNumber(value: self))
    }
}

extension Int64: JAYSONWritableType {
    public var jsonValueBox: JAYSONValueBox {
        return JAYSONValueBox(NSNumber(value: self))
    }
}

extension UInt: JAYSONWritableType {
    public var jsonValueBox: JAYSONValueBox {
        return JAYSONValueBox(NSNumber(value: self))
    }
}

extension UInt8: JAYSONWritableType {
    public var jsonValueBox: JAYSONValueBox {
        return JAYSONValueBox(NSNumber(value: self))
    }
}

extension UInt16: JAYSONWritableType {
    public var jsonValueBox: JAYSONValueBox {
        return JAYSONValueBox(NSNumber(value: self))
    }
}

extension UInt32: JAYSONWritableType {
    public var jsonValueBox: JAYSONValueBox {
        return JAYSONValueBox(NSNumber(value: self))
    }
}

extension UInt64: JAYSONWritableType {
    public var jsonValueBox: JAYSONValueBox {
        return JAYSONValueBox(NSNumber(value: self))
    }
}

#if !os(Linux)
#if os(macOS)
    import AppKit
    #else
    import UIKit
#endif
    
    extension CGFloat: JAYSONWritableType {
        public var jsonValueBox: JAYSONValueBox {
            return JAYSONValueBox(self as NSNumber)
        }
    }
#endif
