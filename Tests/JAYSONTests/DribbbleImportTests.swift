import Foundation
import XCTest

@testable import JAYSON

final class DribbbleImportTests: XCTestCase {
  struct Shot {
    let id: Int
    let title: String
    let width: Int
    let height: Int
    let hidpiImageURLString: String?
    let normalImageURLString: String
    let teaserImageURLString: String
  }

  let data = try! Data.init(
    contentsOf: Bundle.module
      .url(forResource: "Fixtures/Sample", withExtension: "json")!
  )

  func testImport() {
    do {
      let json = try JSON(data: data)

      let shots: [Shot] = try json.getArray().map { json -> Shot in

        let imagesJayson = try json.next("images")

        return Shot(
          id: try json.next("id").getInt(),
          title: try json.next("title").getString(),
          width: try json.next("width").getInt(),
          height: try json.next("height").getInt(),
          hidpiImageURLString: try? imagesJayson.next("hidpi").getString(),
          normalImageURLString: try imagesJayson.next("normal").getString(),
          teaserImageURLString: try imagesJayson.next("teaser").getString()
        )
      }

    } catch {
      XCTFail("\(error)")
    }
  }

  func testPerformance() {
    if #available(iOS 13.0, *) {
      measure(metrics: [
        XCTMemoryMetric(),
        XCTCPUMetric(),
      ]) {
        do {
          let json = try JSON(data: data)

          let _: [Shot] = try json.getArray().map { json -> Shot in

            let imagesJayson = try json.next("images")

            return Shot(
              id: try json.next("id").getInt(),
              title: try json.next("title").getString(),
              width: try json.next("width").getInt(),
              height: try json.next("height").getInt(),
              hidpiImageURLString: try? imagesJayson.next("hidpi").getString(),
              normalImageURLString: try imagesJayson.next("normal").getString(),
              teaserImageURLString: try imagesJayson.next("teaser").getString()
            )
          }
        } catch {
          XCTFail()
        }
      }
    } else {
      // Fallback on earlier versions
    }
  }
}
