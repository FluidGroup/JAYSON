//: [Previous](@previous)

import Foundation
@testable import JAYSON

let dataPath = Bundle.main.path(forResource: "Sample", ofType: "json")
let data = Data(referencing: NSData(contentsOfFile: dataPath!)!)
let json = try! JSON(data: data)

let urlDecoder = Decoder<URL> { (json) throws -> URL in
    URL(string: try json.getString())! // You can throw custom error.
}

struct Shot {
    let id: Int
    let title: String
    let width: Int
    let height: Int
    let hidpiImageURLString: URL?
    let normalImageURLString: URL
    let teaserImageURLString: URL
    
    init(json: JSON) throws {
        let imagesJayson = try json.next("images")
        
        id = try json.next("id").getInt()
        title = try json.next("title").getString()
        width = try json.next("width").getInt()
        height = try json.next("height").getInt()
        hidpiImageURLString = try? imagesJayson.next("hidpi").get(with: urlDecoder)
        normalImageURLString = try imagesJayson.next("normal").get(with: urlDecoder)
        teaserImageURLString = try imagesJayson.next("teaser").get(with: urlDecoder)
    }
}

do {
    let shots: [Shot] = try json.getArray().map(Shot.init(json: ))
    print(shots)
} catch {
    print(error)
}

//: [Next](@next)
