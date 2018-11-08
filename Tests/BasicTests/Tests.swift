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

    var json: JSON {
      switch self {
      case .a:
        return JSON("a")
      case .b:
        return JSON("b")
      case .c:
        return JSON("c")
      }
    }
  }

  func testEqualable() {

    let source: [String : JSON] = [
      "aaa":"AAA",
      "bbb":["BBB":"AAA"],
      "a":[1,2,3],
      "enum":Enum.a.json,
      ]

    let json = JSON(source)
    let json2 = JSON(source)

    XCTAssert(json == json2)
  }

  func testDictionaryInit() {

    let dictionary: [AnyHashable : Any] = [
      "title" : "foo",
      "name" : "hiroshi",
      "age" : 25,
      "height" : 173,
      ]

    do {
      let json = try JSON(any: dictionary)
      let data = try json.data()
      _ = try JSON(data: data)
    } catch {
      XCTFail("\(error)")
    }
  }

  func testIsArray() {

    let json = JSON([
      128,129,130,
      ])
    XCTAssert(json.isArray)
  }

  func testIsDictionary() {

    let json = JSON(
      [
        "aaa":"AAA",
        "bbb":["BBB":"AAA"],
        "a":[1,2,3],
        "enum":Enum.a.json,
        ]
    )
    XCTAssert(json.isDictionary)
  }

  func testExists() {

    let j = try! JSON(data: inData)

    XCTAssert(j.exists(13) == false)
    XCTAssert(j.exists("a") == false)
    XCTAssert(j.exists("b") == false)
    XCTAssert(j.exists("a.b.c") == false)
    XCTAssert(j.exists("tree1.tree2") == true)
    XCTAssert(j.exists("tree1", "tree2") == true)
    XCTAssert(j.exists("tree1") == true)

  }

  func testNext() {
    do {
      let j = try JSON(data: inData)
      let v = j["a"]?["b"]?[1]
      XCTAssert(v == nil)
    } catch {
      XCTFail("\(error)")
    }

    do {
      let j = try JSON(data: inData)

      do {
        _ = try j.next("a").next("b").next("c")
        XCTFail()
      } catch {
        print("Success \(error)")
      }
    } catch {
      XCTFail("\(error)")
    }

    do {

      let j = try JSON(data: inData)
      let v = try j.next("tree1.tree2.tree3").next(0).next("index")
      XCTAssertEqual(v, "myvalue")
    } catch {
      XCTFail("\(error)")
    }
  }

  func testRemove() {
    let j = try! JSON(data: inData)
    let removed = j.removed("tree1")

    XCTAssert(j["tree1"] != nil)
    XCTAssert(removed["tree1"] == nil)

  }

  func testImportExport() {

    do {
      let j = try JSON(data: inData)
      _ = try j.data()
    } catch {
      XCTFail("\(error)")
    }
  }

  func testBack() {

    do {
      let j = try JSON(data: inData)
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
    var j = JSON()
    j["number"] = 124
    j["text"] = "hooo"
    j["bool"] = true
    j["null"] = JSON.null
    j["tree1"] = JSON(
      [
        "tree2" : JSON(
          [
            "tree3" : JSON(
              [
                JSON(["index" : "myvalue"])
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

  func testMutation() {

    var j = try! JSON(data: inData)

    XCTAssertNotNil(j["number"])
    j["number"] = nil
    XCTAssertNil(j["number"])

  }

  /*
  func testJSONWritable() {

    var json = JSON()

    json["String"] = "String"
    json["NSString"] = JSON("NSString" as NSString)
    json["Int"] = 64
    json["Int8"] = JSON(8 as Int8)
    json["Int16"] = JSON(16 as Int16)
    json["Int32"] = JSON(32 as Int32)
    json["Int64"] = JSON(64 as Int64)

    json["UInt"] = JSON(64 as UInt)
    json["UInt8"] = JSON(8 as UInt8)
    json["UInt16"] = JSON(16 as UInt16)
    json["UInt32"] = JSON(32 as UInt32)
    json["UInt64"] = JSON(64 as UInt64)

    json["Bool_true"] = true
    json["Bool_false"] = false

    json["Float"] = JSON(1.0 / 3.0 as Float)
    json["Double"] = JSON(1.0 / 3.0 as Double)

    #if !os(Linux)
      json["CGFloat"] = JSON(1.0 / 3.0 as CGFloat)
      let answer = "{\"UInt8\":8,\"Int32\":32,\"UInt\":64,\"UInt16\":16,\"UInt32\":32,\"Int16\":16,\"Int\":64,\"String\":\"String\",\"CGFloat\":0.3333333333333333,\"Int8\":8,\"UInt64\":64,\"Float\":0.3333333,\"Double\":0.3333333333333333,\"Bool_true\":true,\"Int64\":64,\"Bool_false\":false,\"NSString\":\"NSString\"}"
      print(String(data: try! json.data(), encoding: .utf8))
      let value = String(data: try! json.data(), encoding: .utf8)!
      XCTAssert(answer == value)
    #else
      let answer = "{\"UInt8\":8,\"Int32\":32,\"UInt\":64,\"UInt16\":16,\"UInt32\":32,\"Int16\":16,\"Int\":64,\"String\":\"String\",\"Int8\":8,\"UInt64\":64,\"Float\":0.3333333,\"Double\":0.3333333333333333,\"Bool_true\":true,\"Int64\":64,\"Bool_false\":false,\"NSString\":\"NSString\"}"
      print(String(data: try! json.data(), encoding: .utf8))
      let value = String(data: try! json.data(), encoding: .utf8)!
      XCTAssert(answer == value)
    #endif

  }
 */
}
