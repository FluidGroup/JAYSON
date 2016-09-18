//: [Previous](@previous)

import Foundation
@testable import JAYSON

var j = JAYSON()

var o = [String:JAYSON]()
o["aaa"] = 1

j["array"] = JAYSON(o)

print(j.source, "\n")

do {
    let data = try j.data(options: .prettyPrinted)
    print(String(data: data, encoding: .utf8)!)
} catch {
    print(error)
}

//: [Next](@next)
