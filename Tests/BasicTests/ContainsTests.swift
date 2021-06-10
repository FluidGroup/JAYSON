
import Foundation
import XCTest

import JAYSON

final class ContainsTests: XCTestCase {

  func testIfKeyIsUndefined() throws {

    let json = try JSON(jsonString: """
    {
    }
    """)

   XCTAssertFalse(json.contains("name"))

  }

  func testIfKeyIsNull() throws {

    let json = try JSON(jsonString: """
    {
      "name": null
    }
    """)

    XCTAssertTrue(json.contains("name"))

  }

  func testIfKeyExsits() throws {

    let json = try JSON(jsonString: """
    {
      "name": "muukii"
    }
    """)

    XCTAssertTrue(json.contains("name"))

  }

}

final class ContainsNestingTests: XCTestCase {

  func testIfKeyIsNull() throws {

    let json = try JSON(jsonString: """
    {
      "a" : {
        "b": null
      }
    }
    """)

    XCTAssertTrue(json.contains("a", "b"))

  }

  func testIfKeyExsits() throws {

    let json = try JSON(jsonString: """
    {
      "a" : [1, 2, 3]
    }
    """)
    XCTAssertFalse(json.contains("a", "b"))

  }

}
