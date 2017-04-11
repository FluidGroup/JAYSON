//: [Previous](@previous)

import Foundation
import JAYSON

let dataPath = Bundle.main.path(forResource: "unsplash", ofType: "json")
let inData = Data(referencing: NSData(contentsOfFile: dataPath!)!)
let json = try JSON(data: inData)

print(json)

//: [Next](@next)
