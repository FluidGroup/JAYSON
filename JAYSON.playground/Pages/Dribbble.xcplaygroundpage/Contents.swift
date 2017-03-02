//: [Previous](@previous)

import Foundation
@testable import JAYSON

var json1 = JSON()

json1["a"] = JSON("a")
json1["b"] = JSON("b")

print(json1)


var json2 = JSON()

json2["c"] = JSON("a")
json2["d"] = JSON("b")

json1.append(json2)

print(json1)



//: [Next](@next)
