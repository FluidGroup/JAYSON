//: [Previous](@previous)

import Foundation
@testable import JSON

let dataPath = Bundle.main.path(forResource: "unsplash", ofType: "json")
let inData = Data(referencing: NSData(contentsOfFile: dataPath!)!)
let JSON = try JSON(data: inData)

//print(JSON)
//debugPrint(JSON)

do {
    let urlString: String = try JSON
        .next("shots")
        .next(0)
        .next("user")
        .next("profile_image")
        .next("large")
        .getString()
    
    let shots = try JSON.next("shots").getArray().map { try $0.next("id").getString() }
    print(shots)
} catch {
    print(error)
}

let urlString: String? = JSON["shots"][0]["user"]["profile_image"]["large"].string

let shots = JSON["shots"].array?.map { $0["id"].string }

let large = JSON["shots"][0]["user"]["profile_image"]["large"]
print(large.currentPath())


print(shots)


let urlDecoder = Decoder<URL> { (JSON) throws -> URL in
    URL(string: try JSON.getString())!
}

try! JSON
    .next("shots")
    .next(0)
    .next("user")
    .next("profile_image")
    .next("large")
    .get(with: urlDecoder)


try! JSON
    .next("shots")
    .next(0)
    .next("user")
    .next("profile_image")
    .next("large")
    .get { (JSON) throws -> URL in
        URL(string: try JSON.getString())!
}

do {
    let urlString: String = try JSON
        .next("shots")
        .next(0)
        .next("user")
        .next("profile_image")
        .next("foo")
        .getString()
} catch {
    print(error)
}


