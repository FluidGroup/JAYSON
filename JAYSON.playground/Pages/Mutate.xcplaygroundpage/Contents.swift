//: [Previous](@previous)

import Foundation

import JAYSON

var j = JSON()
j["abc"] = "abc"

j["abc"].string

var a = j

a["abc"] = "hoo"

j["abc"].string
a["abc"].string


//: [Next](@next)
