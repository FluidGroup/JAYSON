//: Playground - noun: a place where people can play

import Foundation
import UIKit
import JAYSON

let dataPath = Bundle.main.path(forResource: "test", ofType: "json")
let data = Data(referencing: NSData(contentsOfFile: dataPath!)!)
let JSON = try! JSON(data)

let urlTransformer = Decoder<URL> { (JSON) throws -> URL in
    URL(string: try JSON.getString())!
}

do {
    
    let fooJSON = try JSON
        .next("tree1")
        .next("tree2")
        .next("tree3")
        .next(0)
        .next("index")
    
    let value = try fooJSON.getString()
    let path = fooJSON.currentPath()
    
    let url = try JSON
        .next("url")
        .get(with: urlTransformer)
    
    let null = try JSON.next("null")
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
    
    let fooJSON = try JSON
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


