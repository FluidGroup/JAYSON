//: [Previous](@previous)

import Foundation
import JAYSON

let dataPath = Bundle.main.path(forResource: "Sample", ofType: "json")
let data = Data(referencing: NSData(contentsOfFile: dataPath!)!)
let jayson = try! JAYSON(data)

struct Shot {
    let id: Int
    let title: String
    let width: Int
    let height: Int
    let hidpiImageURLString: String?
    let normalImageURLString: String
    let teaserImageURLString: String
}

do {
    let shots: [Shot] = try jayson.getArray().map { jayson -> Shot in
        
        let imagesJayson = try jayson.next("images")
        
//        print(try jayson.next("images", "normal").getString())
        
        return Shot(
            id: try jayson.next("id").getInt(),
            title: try jayson.next("title").getString(),
            width: try jayson.next("width").getInt(),
            height: try jayson.next("height").getInt(),
            hidpiImageURLString: try? imagesJayson.next("hidpi").getString(),
            normalImageURLString: try imagesJayson.next("normal").getString(),
            teaserImageURLString: try imagesJayson.next("teaser").getString()
        )
    }
    print(shots)
} catch {
    print(error)
}

//: [Next](@next)
