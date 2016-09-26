// JAYSON+SourceType.swift
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
    
    public enum SourceType {
        
        case number
        case string
        case bool
        case array
        case dictionary
        case null
    }
    
    public var sourceType: SourceType {
        switch source {
        case let number as NSNumber:
            if number.isBool {
                return .bool
            }
            return .number
        case _ as String:
            return .string
        case  _ as NSNull:
            return .null
        case _ as [Any]:
            return .array
        case _ as [String : Any]:
            return .dictionary
        default:
            fatalError("What happen? Unsupported Type.")
        }
    }
}

extension NSNumber {
    
    fileprivate var isBool: Bool {
        let objCType = String(cString: self.objCType)
        if (compare(trueNumber) == ComparisonResult.orderedSame && objCType == trueObjCType)
            || (compare(falseNumber) == ComparisonResult.orderedSame && objCType == falseObjCType){
            return true
        } else {
            return false
        }
    }
}

fileprivate let trueNumber = NSNumber(value: true)
fileprivate let falseNumber = NSNumber(value: false)
fileprivate let trueObjCType = String(cString: trueNumber.objCType)
fileprivate let falseObjCType = String(cString: falseNumber.objCType)
