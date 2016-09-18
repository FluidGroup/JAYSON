//: [Previous](@previous)

import Foundation

@testable import JAYSON

let dataPath = Bundle.main.path(forResource: "test", ofType: "json")
let inData = Data(referencing: NSData(contentsOfFile: dataPath!)!)
let source = try JSONSerialization.jsonObject(with: inData, options: .allowFragments)

do {
    print(source)
    let j = try JAYSON(data: inData)
    print(j.source)
    JSONSerialization.isValidJSONObject(j.source)
    JSONSerialization.isValidJSONObject(source)
    
//    let a = try j.data()
} catch {
    print(error)
}

JSONSerialization.isValidJSONObject(source)

try JSONSerialization.data(withJSONObject: source, options: [])

