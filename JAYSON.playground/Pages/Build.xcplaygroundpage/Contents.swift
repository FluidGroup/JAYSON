//: [Previous](@previous)

import Foundation
@testable import JAYSON

var jayson = JAYSON()
jayson["id"] = 18737649
jayson["active"] = true
jayson["name"] = "muukii"

var images = [String:JAYSON]()
images["large"] = "http://...foo"
images["medium"] = "http://...bar"
images["small"] = "http://...fuzz"

jayson["images"] = JAYSON(images)

let array = [1,2,3]
jayson["array"] = JAYSON(array)
jayson["dic"] = JAYSON(["a":"A"])

jayson.dictionary

print(jayson.source, "\n")

do {
    let data = try jayson.data(options: .prettyPrinted)
    print(String(data: data, encoding: .utf8)!)
} catch {
    print(error)
}


//: [Next](@next)
