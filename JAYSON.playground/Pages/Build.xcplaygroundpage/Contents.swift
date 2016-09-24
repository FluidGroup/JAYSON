//: [Previous](@previous)

import Foundation
@testable import JAYSON

var jayson = JAYSON()
jayson["id"] = 18737649
jayson["active"] = true
jayson["name"] = "muukii"

jayson["images"] = JAYSON([
    "large" : "http://...foo",
    "medium" : "http://...foo",
    "small" : "http://...foo",
    ])

let data: Data = try jayson.data(options: .prettyPrinted)

do {
    let data = try jayson.data(options: .prettyPrinted)
    print(String(data: data, encoding: .utf8)!)
} catch {
    print(error)
}


//: [Next](@next)
