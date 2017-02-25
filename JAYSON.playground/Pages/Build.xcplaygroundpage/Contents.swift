//: [Previous](@previous)

import Foundation
@testable import JAYSON

var json = JSON()
json["id"] = 18737649
json["active"] = true
json["name"] = "muukii"

json["images"] = JSON([
    "large" : "http://...foo",
    "medium" : "http://...foo",
    "small" : "http://...foo",
    ])

let data: Data = try json.data(options: .prettyPrinted)

do {
    let data = try json.data(options: .prettyPrinted)
    print(String(data: data, encoding: .utf8)!)
} catch {
    print(error)
}


//: [Next](@next)
