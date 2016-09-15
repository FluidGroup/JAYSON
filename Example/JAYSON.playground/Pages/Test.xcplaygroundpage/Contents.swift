//: Playground - noun: a place where people can play

import Foundation
import UIKit
import JAYSON

let dataPath = Bundle.main.path(forResource: "test", ofType: "json")
let data = Data(referencing: NSData(contentsOfFile: dataPath!)!)
let jayson = try! JAYSON(data)

let urlTransformer = Decoder<URL> { (jayson) -> URL in
    URL(string: try jayson.getString())!
}

do {
    
    let fooJayson = try jayson
        .next("tree1")
        .next("tree2")
        .next("tree3")
        .next(0)
        .next("index")
    
    let value = try fooJayson.getString()
    let path = fooJayson.currentPath()
    
    let url = try jayson
        .next("url")
        .get(with: urlTransformer)
    
    let null = try jayson.next("null")
    null.isNull
    
    do {
        try null.next("ahahaha!")
    } catch {
        print("whoa!!\n\(error)")
    }
    
} catch {
    
    print(error)
}

/*:
 ## Back
 */

do {
    
    let fooJayson = try jayson
        .next("tree1")
        .next("tree2")
        .back()
        .next("tree2")
        .next("tree3")
        .next(0)
        .next("index")
        .getString()
    
} catch {
    
}


