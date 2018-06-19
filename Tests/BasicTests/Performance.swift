//
//  Performance.swift
//  JAYSON
//
//  Created by muukii on 6/20/18.
//  Copyright © 2018 muukii. All rights reserved.
//

import Foundation

import XCTest

@testable import JAYSON

class PerformanceTests : XCTestCase {

  let sourceData = Data(referencing: NSData(contentsOfFile: Bundle(for: Tests.self).path(forResource: "big", ofType: "json")!)!)

  func testLoad() {

    measure {
      try! JSON(data: sourceData)
    }
  }

}
