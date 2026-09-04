import Foundation
import XCTest

@testable import JAYSON

private enum RequestIDEnvironmentKey: JSONEnvironmentKey {
  typealias Value = String
}

private extension JSONEnvironment {
  var requestID: String? {
    get { self[RequestIDEnvironmentKey.self] }
    set { self[RequestIDEnvironmentKey.self] = newValue }
  }
}

final class EnvironmentTests: XCTestCase {

  private let document = Data(#"{"object":{"value":"text"},"items":[{"value":"item"}]}"#.utf8)

  private func makeEnvironment(requestID: String = "request-42") -> JSONEnvironment {
    var environment = JSONEnvironment()
    environment.requestID = requestID
    return environment
  }

  func testApplicationDefinedEnvironmentKeyCanBeReadUpdatedAndRemoved() {
    var environment = JSONEnvironment()

    XCTAssertNil(environment.requestID)

    environment.requestID = "request-42"
    XCTAssertEqual(environment.requestID, "request-42")

    environment.requestID = nil
    XCTAssertNil(environment.requestID)
  }

  func testParsedDocumentAndChildValuesPreserveEnvironment() throws {
    let environment = makeEnvironment()
    let json = try JSON(data: document, environment: environment)

    XCTAssertEqual(json.environment.requestID, "request-42")
    XCTAssertEqual(json["object"]?.environment.requestID, "request-42")
    XCTAssertEqual(json["items"]?[0]?.environment.requestID, "request-42")
    XCTAssertEqual(try json.next("object").environment.requestID, "request-42")
    XCTAssertEqual(try json.next("items").next(0).environment.requestID, "request-42")
    XCTAssertEqual(try json.getDictionary()["object"]?.environment.requestID, "request-42")
    XCTAssertEqual(try json.next("items").getArray().first?.environment.requestID, "request-42")
    XCTAssertEqual(json.removed("object").environment.requestID, "request-42")
  }

  func testIndexedSubscriptFallbackPreservesEnvironment() throws {
    let json = try JSON(data: document, environment: makeEnvironment())
    let items = try json.next("items")
    let object = try json.next("object")

    let outOfBounds = try XCTUnwrap(items[99])
    XCTAssertTrue(outOfBounds.isNull)
    XCTAssertEqual(outOfBounds.environment.requestID, "request-42")
    XCTAssertEqual(outOfBounds.currentPath(), #"["items"][99]"#)

    let negativeIndex = try XCTUnwrap(items[-1])
    XCTAssertTrue(negativeIndex.isNull)
    XCTAssertEqual(negativeIndex.environment.requestID, "request-42")
    XCTAssertEqual(negativeIndex.currentPath(), #"["items"][-1]"#)

    let nonArray = try XCTUnwrap(object[0])
    XCTAssertTrue(nonArray.isNull)
    XCTAssertEqual(nonArray.environment.requestID, "request-42")
    XCTAssertEqual(nonArray.currentPath(), #"["object"][0]"#)

    do {
      _ = try outOfBounds.getString()
      XCTFail("Expected getting a string from null to fail")
    } catch {
      XCTAssertEqual(error.environment?.requestID, "request-42")
    }
  }

  func testErrorsWithJSONValuesExposeTheirEnvironment() throws {
    let json = try JSON(data: document, environment: makeEnvironment())
    let decodeError = NSError(domain: "EnvironmentTests", code: 1)
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
      XCTAssertEqual(error.environment?.requestID, "request-42")
    }

    XCTAssertNil(JSONError.failedToInitializeFromJSONString("invalid").environment)
    XCTAssertNil(JSONError.invalidJSONObject.environment)
  }

  func testParseFailurePreservesExplicitEnvironment() {
    let invalidDocument = Data(#"{"incomplete":true"#.utf8)

    do {
      _ = try JSON(data: invalidDocument, environment: makeEnvironment())
      XCTFail("Expected parsing to fail")
    } catch {
      XCTAssertEqual(error.environment?.requestID, "request-42")
    }

    do {
      _ = try JSON(data: invalidDocument)
      XCTFail("Expected parsing to fail")
    } catch {
      XCTAssertNil(error.environment?.requestID)
    }
  }

  func testExistingInitializersHaveEmptyEnvironment() throws {
    XCTAssertNil(try JSON(data: document).environment.requestID)
    XCTAssertNil(try JSON(any: ["value": "text"]).environment.requestID)
  }

  func testEnvironmentDoesNotAffectEqualityHashingOrSerialization() throws {
    let first = try JSON(data: document, environment: makeEnvironment(requestID: "first"))
    let second = try JSON(data: document, environment: makeEnvironment(requestID: "second"))

    XCTAssertEqual(first, second)
    XCTAssertEqual(Set([first, second]).count, 1)
    XCTAssertEqual(try first.data(), try second.data())
  }

  func testCombiningJSONValuesUsesExplicitOrReceiverEnvironment() throws {
    let json = try JSON(data: document, environment: makeEnvironment())
    let object = try json.next("object")
    let items = try json.next("items")
    let item = try items.next(0)
    let other = try JSON(data: document, environment: makeEnvironment(requestID: "other"))

    XCTAssertNil(JSON([object, items]).environment.requestID)
    XCTAssertNil(JSON(["object": object, "items": items]).environment.requestID)
    XCTAssertEqual(
      JSON([object, items], environment: json.environment).environment.requestID,
      "request-42"
    )
    XCTAssertEqual(
      JSON(
        ["object": object, "items": items],
        environment: json.environment
      ).environment.requestID,
      "request-42"
    )

    var appendedFromSameEnvironment = object
    appendedFromSameEnvironment.append(item)
    XCTAssertEqual(appendedFromSameEnvironment.environment.requestID, "request-42")

    var assignedFromSameEnvironment = object
    assignedFromSameEnvironment["items"] = items
    XCTAssertEqual(assignedFromSameEnvironment.environment.requestID, "request-42")

    var appended = object
    appended.append(other)
    XCTAssertEqual(appended.environment.requestID, "request-42")

    var assigned = object
    assigned["other"] = other
    XCTAssertEqual(assigned.environment.requestID, "request-42")
  }
}
