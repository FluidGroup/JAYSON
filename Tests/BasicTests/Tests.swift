import Foundation
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

    do {

      let j = try JAYSON(data: inData)
      let v = try j.next("tree1.tree2.tree3").next(0).next("index")
      XCTAssertEqual(v, "myvalue")
    } catch {
      XCTFail("\(error)")
    }
  }

  func testRemove() {
    let j = try! JAYSON(data: inData)
    let removed = j.removed("tree1")

    XCTAssert(j["tree1"] != nil)
    XCTAssert(removed["tree1"] == nil)

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

  func testJSONWritable() {

    var jayson = JAYSON()

    jayson["String"] = "String"
    jayson["NSString"] = JAYSON("NSString" as NSString)
    jayson["Int"] = 64
    jayson["Int8"] = JAYSON(8 as Int8)
    jayson["Int16"] = JAYSON(16 as Int16)
    jayson["Int32"] = JAYSON(32 as Int32)
    jayson["Int64"] = JAYSON(64 as Int64)

    jayson["UInt"] = JAYSON(64 as UInt)
    jayson["UInt8"] = JAYSON(8 as UInt8)
    jayson["UInt16"] = JAYSON(16 as UInt16)
    jayson["UInt32"] = JAYSON(32 as UInt32)
    jayson["UInt64"] = JAYSON(64 as UInt64)

    jayson["Bool_true"] = true
    jayson["Bool_false"] = false

    jayson["Float"] = JAYSON(1.0 / 3.0 as Float)
    jayson["Double"] = JAYSON(1.0 / 3.0 as Double)

    #if !os(Linux)
      jayson["CGFloat"] = JAYSON(1.0 / 3.0 as CGFloat)
      let answer = "{\"UInt8\":8,\"Int32\":32,\"UInt\":64,\"UInt16\":16,\"UInt32\":32,\"Int16\":16,\"Int\":64,\"String\":\"String\",\"CGFloat\":0.3333333333333333,\"Int8\":8,\"UInt64\":64,\"Float\":0.3333333,\"Double\":0.3333333333333333,\"Bool_true\":true,\"Int64\":64,\"Bool_false\":false,\"NSString\":\"NSString\"}"
      print(String(data: try! jayson.data(), encoding: .utf8))
      let value = String(data: try! jayson.data(), encoding: .utf8)!
      XCTAssert(answer == value)
    #else
      let answer = "{\"UInt8\":8,\"Int32\":32,\"UInt\":64,\"UInt16\":16,\"UInt32\":32,\"Int16\":16,\"Int\":64,\"String\":\"String\",\"Int8\":8,\"UInt64\":64,\"Float\":0.3333333,\"Double\":0.3333333333333333,\"Bool_true\":true,\"Int64\":64,\"Bool_false\":false,\"NSString\":\"NSString\"}"
      print(String(data: try! jayson.data(), encoding: .utf8))
      let value = String(data: try! jayson.data(), encoding: .utf8)!
      XCTAssert(answer == value)
    #endif

  }

  func testSourceType() {
    let data = Data(referencing: NSData(contentsOfFile: Bundle(for: Tests.self).path(forResource: "standard", ofType: "json")!)!)

    let jayson = try! JAYSON(data: data)

    print(jayson.source)

    XCTAssertEqual(jayson["string"].sourceType, .string)
    XCTAssertEqual(jayson["boolean"].sourceType, .bool)
    XCTAssertEqual(jayson["dictionary"].sourceType, .dictionary)
    XCTAssertEqual(jayson["array"].sourceType, .array)
    XCTAssertEqual(jayson["number"].sourceType, .number)
    XCTAssertEqual(jayson["null"].sourceType, .null)
  }
}
