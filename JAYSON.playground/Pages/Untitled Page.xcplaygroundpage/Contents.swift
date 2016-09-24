//: [Previous](@previous)

import Foundation
@testable import JAYSON

let dataPath = Bundle.main.path(forResource: "unsplash", ofType: "json")
let inData = Data(referencing: NSData(contentsOfFile: dataPath!)!)
let jayson = try JAYSON(data: inData)

//print(jayson)
//debugPrint(jayson)

do {
    let urlString: String = try jayson
        .next("shots")
        .next(0)
        .next("user")
        .next("profile_image")
        .next("large")
        .getString()
    
    let shots = try jayson.next("shots").getArray().map { try $0.next("id").getString() }
    print(shots)
} catch {
    print(error)
}

let urlString: String? = jayson["shots"][0]["user"]["profile_image"]["large"].string

let shots = jayson["shots"].array?.map { $0["id"].string }

let large = jayson["shots"][0]["user"]["profile_image"]["large"]
print(large.currentPath())


print(shots)


let urlDecoder = Decoder<URL> { (jayson) throws -> URL in
    URL(string: try jayson.getString())!
}

try! jayson
    .next("shots")
    .next(0)
    .next("user")
    .next("profile_image")
    .next("large")
    .get(with: urlDecoder)


try! jayson
    .next("shots")
    .next(0)
    .next("user")
    .next("profile_image")
    .next("large")
    .get { (jayson) throws -> URL in
        URL(string: try jayson.getString())!
}


