//: [Previous](@previous)

import Foundation
@testable import JAYSON

var j = JAYSON()

j["array"] = JAYSON(["aaa":JAYSON(1)])

print(j.source, "\n")

do {
    let data = try j.data(options: .prettyPrinted)
    print(String(data: data, encoding: .utf8)!)
} catch {
    print(error)
}

//: [Next](@next)
