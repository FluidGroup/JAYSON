//: Playground - noun: a place where people can play

import Foundation

public struct JAYSON {
    
    let source: Any?
    
    private let breadcrumb: Breadcrumb?
    
    public init(source: Any?) {
        self.init(source: source, breadcrumb: nil)
    }
    
    init(source: Any?, breadcrumb: Breadcrumb?) {
        self.source = source
        self.breadcrumb = breadcrumb
    }
    
    public subscript (key: String) -> JAYSON? {
        return (source as? [AnyHashable : Any])
            .flatMap { $0[key] }
            .map { JAYSON(source: $0, breadcrumb: Breadcrumb(jayson: self, key: key)) }
    }
    
    public subscript (index: Int) -> JAYSON? {
        return (source as? [Any])
            .flatMap { $0[index] }
            .map { JAYSON(source: $0, breadcrumb: Breadcrumb(jayson: self, index: index)) }
    }
    
    final class Breadcrumb {
        
        let jayson: JAYSON
        let path: String
        
        init(jayson: JAYSON, key: String) {
            self.jayson = jayson
            self.path = "[\"\(key)\"]"
        }
        
        init(jayson: JAYSON, index: Int) {
            self.jayson = jayson
            self.path = "[\(index)]"
        }
    }
    
    func currentPath() -> String {
        
        var path: String = ""
        
        var currentBreadcrumb: Breadcrumb? = breadcrumb
        
        while currentBreadcrumb != nil {
            path = currentBreadcrumb!.path + path
            currentBreadcrumb = currentBreadcrumb!.jayson.breadcrumb
        }
        
        return path
    }
}

// Candidate1
extension JAYSON {
    
}

// Candidate2
extension JAYSON {
    
    public func next(_ key: String) throws -> JAYSON {
        guard let jayson = self[key] else {
            throw JAYSONError.NotFoundKey(key, self)
        }
        return jayson
    }
    
    public func next(_ index: Int) throws -> JAYSON {
        guard let jayson = self[index] else {
            throw JAYSONError.NotFoundIndex(index, self)
        }
        return jayson
    }
    
    public var number: NSNumber? {
        return source as? NSNumber
    }
    
    public var int: Int? {
        return (source as? NSNumber)?.intValue
    }
    
    public var int32: Int32? {
        return (source as? NSNumber)?.int32Value
    }
    
    public var int64: Int64? {
        return (source as? NSNumber)?.int64Value
    }
    
    public var string: String? {
        return source as? String
    }
    
    public var bool: Bool? {
        return source as? Bool
    }
    
    public func transform<T>(_ s: (JAYSON) throws -> T) rethrows -> T {
        return try s(self)
    }
    
    public func transform<T>(_ t: Transformer<T>) throws -> T {
        return try t.closure(self)
    }
}

public struct Transformer<T> {
    
    let closure: (JAYSON) throws -> T
    
    init(_ s: @escaping (JAYSON) throws -> T) {
        self.closure = s
    }
}

public enum JAYSONError: Error {
    case NotFoundKey(String, JAYSON)
    case NotFoundIndex(Int, JAYSON)
}

//infix operator |> { associativity left }
//infix operator ~> { associativity left }
//
//func |> (lhs: JAYSON, key: String) throws -> JAYSON {
//    guard let jayson = lhs[key] else {
//        throw JAYSONError.NotFoundKey(key, lhs)
//    }
//    return jayson
//}
//
//func |> (lhs: JAYSON, index: Int) throws -> JAYSON {
//    guard let jayson = lhs[index] else {
//        throw JAYSONError.NotFoundIndex(index, lhs)
//    }
//    return jayson
//}

let dataPath = Bundle.main.path(forResource: "test", ofType: "json")
let data = Data(referencing: NSData(contentsOfFile: dataPath!)!)
let json = try? JSONSerialization.jsonObject(with: data, options: [])

let jayson = JAYSON(source: json)

let urlTransformer = Transformer<NSURL> { (jayson) -> NSURL in
    NSURL(string: jayson.string!)!
}

jayson["text"]?.string
jayson["bool"]?.bool
try? jayson["url"]?.transform(urlTransformer)
jayson["null"]
jayson["number"]?.number
jayson["tree1"]?["tree2"]?["tree3"]?[0]?.currentPath()

do {
    
    try jayson
        .next("tree1")
        .next("tree2")
        .next(4)
        .next("tree4")
        .next(0)
} catch {
    
    print(error)
}


