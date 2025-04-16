//
//  File.swift
//  JAYSON
//
//  Created by Muukii on 2020/12/26.
//  Copyright © 2020 muukii. All rights reserved.
//

import Foundation

import JAYSON

private class Dummy {}

enum Mocks {
  static let sampleJSON = try! JSON(data: try! Data(contentsOf: Bundle.module.url(forResource: "Fixtures/Sample", withExtension: "json")!))
}
