//: Playground - noun: a place where people can play

import Foundation
import UIKit
@testable import JAYSON

let dataPath = Bundle.main.path(forResource: "test", ofType: "json")
let data = Data(referencing: NSData(contentsOfFile: dataPath!)!)
let json = try! JSON.init(data: data)

var a = json
var b = json

type(of: a.source)

a["text"].string

type(of: a["text"].source)

type(of: a.source)

b["text"].string

type(of: b.source)

a["text"] = "abc"

type(of: a.source)

type(of: a["text"].source)

b["text"].string

type(of: b.source)
