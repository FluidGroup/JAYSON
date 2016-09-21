import UIKit
import XCTest

@testable import JAYSON

class Tests: XCTestCase {
    
    let inData = Data(referencing: NSData(contentsOfFile: Bundle(for: Tests.self).path(forResource: "test", ofType: "json")!)!)
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    enum Enum {
        case a
        case b
        case c
        
        var jayson: JAYSON {
            switch self {
            case .a:
                return JAYSON("a")
            case .b:
                return JAYSON("b")
            case .c:
                return JAYSON("c")
            }
        }
    }
    
    func testEqualable() {
        
        let source: [String : JAYSON] = [
            "aaa":"AAA",
            "bbb":["BBB":"AAA"],
            "a":[1,2,3],
            "enum":Enum.a.jayson,
            ]
        
        let jayson = JAYSON(source)
        let jayson2 = JAYSON(source)
        
        XCTAssert(jayson == jayson2)                
    }
    
    func testDictionaryInit() {
        
        let dictionary: [AnyHashable : Any] = [
            "title" : "foo",
            "name" : "hiroshi",
            "age" : 25,
            "height" : 173,
        ]
        
        do {
            let jayson = try JAYSON(any: dictionary)
            let data = try jayson.data()
            _ = try JAYSON(data: data)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testIsArray() {
        
        let jayson = JAYSON([
            128,129,130,
            ])
        XCTAssert(jayson.isArray)
    }
    
    func testIsDictionary() {
        
        let jayson = JAYSON(
            [
                "aaa":"AAA",
                "bbb":["BBB":"AAA"],
                "a":[1,2,3],
                "enum":Enum.a.jayson,
            ]
        )
        XCTAssert(jayson.isDictionary)
    }
    
    func testNext() {
        do {
            let j = try JAYSON(data: inData)
            let v = j["a"]["b"][1]
            XCTAssert(v.isNull)
        } catch {
            XCTFail("\(error)")
        }
        
        do {
            let j = try JAYSON(data: inData)
            
            do {
                let v = try j.next("a").next("b").next("c")
                XCTFail()
            } catch {
                print("Success \(error)")
            }
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testImportExport() {
        
        do {
            let j = try JAYSON(data: inData)
            let data = try j.data()
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testBack() {
        
        do {
            let j = try JAYSON(data: inData)
            let value = try j
                .next("tree1")
                .next("tree2")
                .back()
                .next("tree2")
                .back()
                .back()
                .next("tree1")
                .next("tree2")
                .next("tree3")
                .next(0)
                .next("index")
                .getString()
            
            XCTAssertEqual(value, "myvalue")
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testBuild() {
        var j = JAYSON()
        j["number"] = 124
        j["text"] = "hooo"
        j["bool"] = true
        j["null"] = JAYSON.null
        j["tree1"] = JAYSON(
            [
                "tree2" : JAYSON(
                    [
                        "tree3" : JAYSON(
                            [
                                JAYSON(["index" : "myvalue"])
                            ]
                        )
                    ]
                )
            ]
        )
        
        do {
            let data = try j.data(options: .prettyPrinted)
            let text = String(data: data, encoding: .utf8)!
            print(text)
        } catch {
            print(j.source)
            XCTFail("\(error)")
        }
    }
}
