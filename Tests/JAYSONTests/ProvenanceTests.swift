import Foundation
import XCTest

@testable import JAYSON

final class ProvenanceTests: XCTestCase {

  private let provenance = JSONProvenance(id: .init(rawValue: "request-42"))
  private let document = Data(#"{"object":{"value":"text"},"items":[{"value":"item"}]}"#.utf8)

  func testProvenanceIsIdentifiable() {
    XCTAssertEqual(provenance.id.rawValue, "request-42")
  }

  func testParsedDocumentAndChildValuesPreserveProvenance() throws {
    let json = try JSON(data: document, provenance: provenance)

    XCTAssertEqual(json.provenance, provenance)
    XCTAssertEqual(json["object"]?.provenance, provenance)
    XCTAssertEqual(json["items"]?[0]?.provenance, provenance)
    XCTAssertEqual(try json.next("object").provenance, provenance)
    XCTAssertEqual(try json.next("items").next(0).provenance, provenance)
    XCTAssertEqual(try json.getDictionary()["object"]?.provenance, provenance)
    XCTAssertEqual(try json.next("items").getArray().first?.provenance, provenance)
    XCTAssertEqual(json.removed("object").provenance, provenance)
  }

  func testIndexedSubscriptFallbackPreservesProvenance() throws {
    let json = try JSON(data: document, provenance: provenance)
    let items = try json.next("items")
    let object = try json.next("object")

    let outOfBounds = try XCTUnwrap(items[99])
    XCTAssertTrue(outOfBounds.isNull)
    XCTAssertEqual(outOfBounds.provenance, provenance)
    XCTAssertEqual(outOfBounds.currentPath(), #"["items"][99]"#)

    let negativeIndex = try XCTUnwrap(items[-1])
    XCTAssertTrue(negativeIndex.isNull)
    XCTAssertEqual(negativeIndex.provenance, provenance)
    XCTAssertEqual(negativeIndex.currentPath(), #"["items"][-1]"#)

    let nonArray = try XCTUnwrap(object[0])
    XCTAssertTrue(nonArray.isNull)
    XCTAssertEqual(nonArray.provenance, provenance)
    XCTAssertEqual(nonArray.currentPath(), #"["object"][0]"#)

    do {
      _ = try outOfBounds.getString()
      XCTFail("Expected getting a string from null to fail")
    } catch {
      XCTAssertEqual(error.provenance, provenance)
    }
  }

  func testErrorsWithJSONValuesExposeTheirProvenance() throws {
    let json = try JSON(data: document, provenance: provenance)
    let decodeError = NSError(domain: "ProvenanceTests", code: 1)
    let errors: [JSONError] = [
      .notFoundKey(key: "missing", json: json),
      .notFoundIndex(index: 1, json: json),
      .failedToGetString(json: json),
      .failedToGetBool(json: json),
      .failedToGetNumber(json: json),
      .failedToGetArray(json: json),
      .failedToGetDictionary(json: json),
      .failedToParseURL(json: json),
      .decodeError(json: json, decodeError: decodeError),
    ]

    for error in errors {
      XCTAssertEqual(error.provenance, provenance)
    }

    XCTAssertNil(JSONError.failedToInitializeFromJSONString("invalid").provenance)
    XCTAssertNil(JSONError.invalidJSONObject.provenance)
  }

  func testParseFailurePreservesExplicitProvenance() {
    let invalidDocument = Data(#"{"incomplete":true"#.utf8)

    do {
      _ = try JSON(data: invalidDocument, provenance: provenance)
      XCTFail("Expected parsing to fail")
    } catch {
      XCTAssertEqual(error.provenance, provenance)
    }

    do {
      _ = try JSON(data: invalidDocument)
      XCTFail("Expected parsing to fail")
    } catch {
      XCTAssertNil(error.provenance)
    }
  }

  func testExistingInitializersRemainProvenanceFree() throws {
    XCTAssertNil(try JSON(data: document).provenance)
    XCTAssertNil(try JSON(any: ["value": "text"]).provenance)
  }

  func testProvenanceDoesNotAffectEqualityHashingOrSerialization() throws {
    let first = try JSON(
      data: document,
      provenance: JSONProvenance(id: .init(rawValue: "first"))
    )
    let second = try JSON(
      data: document,
      provenance: JSONProvenance(id: .init(rawValue: "second"))
    )

    XCTAssertEqual(first, second)
    XCTAssertEqual(Set([first, second]).count, 1)
    XCTAssertEqual(try first.data(), try second.data())
  }

  func testCombiningJSONValuesKeepsOnlySharedDocumentIdentity() throws {
    let json = try JSON(data: document, provenance: provenance)
    let object = try json.next("object")
    let items = try json.next("items")
    let item = try items.next(0)
    let other = try JSON(
      data: document,
      provenance: provenance
    )

    XCTAssertEqual(JSON([object, items]).provenance, provenance)
    XCTAssertEqual(JSON(["object": object, "items": items]).provenance, provenance)
    XCTAssertNil(JSON([object, other]).provenance)
    XCTAssertNil(JSON(["object": object, "other": other]).provenance)

    var appendedFromSameDocument = object
    appendedFromSameDocument.append(item)
    XCTAssertEqual(appendedFromSameDocument.provenance, provenance)

    var assignedFromSameDocument = object
    assignedFromSameDocument["items"] = items
    XCTAssertEqual(assignedFromSameDocument.provenance, provenance)

    var appended = object
    appended.append(other)
    XCTAssertNil(appended.provenance)

    var assigned = object
    assigned["other"] = other
    XCTAssertNil(assigned.provenance)
  }
}
