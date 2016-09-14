//: Playground - noun: a place where people can play

import Foundation

/*:
 # JAYSON
 */

public struct JAYSON {
    
    let source: Any?
    
    fileprivate let breadcrumb: Breadcrumb?
    
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

extension JAYSON {
    
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
    
    /**
     */
    public func back() -> JAYSON {
        return breadcrumb?.jayson ?? self
    }
    
    public func getNumber() throws -> NSNumber {
        guard let value = source as? NSNumber else {
            throw JAYSONError.FailedToGetNumber
        }
        return value
    }
    
    public func getInt() throws -> Int {
        return try getNumber().intValue
    }
    
    public func getString() throws -> String {
        guard let value = source as? String else {
            throw JAYSONError.FailedToGetString
        }
        return value
    }
    
    public func getBool() throws -> Bool {
        guard let value = source as? Bool else {
            throw JAYSONError.FailedToGetBool
        }
        return value
    }
    
    public var isNull: Bool {
        return source is NSNull
    }
    
    public func get<T>(_ s: (JAYSON) throws -> T) rethrows -> T {
        return try s(self)
    }
    
    public func get<T>(with transformer: Transformer<T>) throws -> T {
        return try transformer.transform(self)
    }
}

public struct Transformer<T> {
    
    let transform: (JAYSON) throws -> T
    
    init(_ s: @escaping (JAYSON) throws -> T) {
        self.transform = s
    }
}

public enum JAYSONError: Error {
    case NotFoundKey(String, JAYSON)
    case NotFoundIndex(Int, JAYSON)
    case FailedToGetString
    case FailedToGetBool
    case FailedToGetNumber
}

let dataPath = Bundle.main.path(forResource: "test", ofType: "json")
let data = Data(referencing: NSData(contentsOfFile: dataPath!)!)
let json = try? JSONSerialization.jsonObject(with: data, options: [])
let jayson = JAYSON(source: json)

let urlTransformer = Transformer<NSURL> { (jayson) -> NSURL in
    NSURL(string: try jayson.getString())!
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


