//: [Previous](@previous)

import Foundation
import JAYSON

let root = JSONDictionary()

root.add(key: "aaa", value: "AAA")
root.add(key: "bbb", value: "BBB")

let array = JSONArray()
array.add(value: Int64(1))
array.add(value: Double(1.11))
array.add(value: Double(true))
root.add(key: "ccc", value: array)

let sub = JSONDictionary()
sub.add(key: "aaa", value: "AAA")
sub.add(key: "bbb", value: "BBB")

root.add(key: "sub", value: sub)


print(String(data: try root.build(), encoding: .utf8)!)

//: [Next](@next)
