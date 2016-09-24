//: [Previous](@previous)

import Foundation
@testable import JAYSON

let dataPath = Bundle.main.path(forResource: "Sample", ofType: "json")
let data = Data(referencing: NSData(contentsOfFile: dataPath!)!)
let jayson = try! JAYSON(data: data)

let urlDecoder = Decoder<URL> { (jayson) throws -> URL in
    URL(string: try jayson.getString())! // You can throw custom error.
}

struct Shot {
    let id: Int
    let title: String
    let width: Int
    let height: Int
    let hidpiImageURLString: URL?
    let normalImageURLString: URL
    let teaserImageURLString: URL
    
    init(jayson: JAYSON) throws {
        let imagesJayson = try jayson.next("images")
        
        id = try jayson.next("id").getInt()
        title = try jayson.next("title").getString()
        width = try jayson.next("width").getInt()
        height = try jayson.next("height").getInt()
        hidpiImageURLString = try? imagesJayson.next("hidpi").get(with: urlDecoder)
        normalImageURLString = try imagesJayson.next("normal").get(with: urlDecoder)
        teaserImageURLString = try imagesJayson.next("teaser").get(with: urlDecoder)
    }
}

do {
    let shots: [Shot] = try jayson.getArray().map(Shot.init(jayson: ))
    print(shots)
} catch {
    print(error)
}

//: [Next](@next)
