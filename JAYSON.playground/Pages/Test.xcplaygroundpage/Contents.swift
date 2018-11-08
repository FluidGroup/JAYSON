//: Playground - noun: a place where people can play

import UIKit
import JAYSON

let dataPath = Bundle.main.path(forResource: "test", ofType: "json")
let data = Data(referencing: NSData(contentsOfFile: dataPath!)!)
let json = try! JSON.init(data: data)

do {
    
    let fooJSON = try json
        .next("tree1")
        .next("tree2")
        .next("tree3")
        .next(0)
        .next("index")
    
    let value = try fooJSON.getString()
    let path = fooJSON.currentPath()
    
    let url = try json
        .next("url")

    let null = try json.next("null")
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
    
    let fooJSON = try json
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

do {
  let value = try json["a"]?["b"]?.getString()
} catch {
  print(error)
}

do {
  json["a"]?["b"]?.get {
    URL.init(string: try $0.getString())
  }
} catch {

}
