//
//  JSON.swift
//  JAYSON
//
//  Created by muukii on 4/11/17.
//  Copyright © 2017 muukii. All rights reserved.
//

import Foundation

extension JSON: CustomStringConvertible, CustomDebugStringConvertible {

  public var description: String {
    return
      [
        "Path: \(currentPath().description)",
        "SourceType: \(sourceType.description)",
        "Source:",
        "\(String(data: try! data(options: .prettyPrinted), encoding: .utf8) ?? "")",
        ]
        .joined(separator: "\n")
  }

  public var debugDescription: String {
    return description
  }
}
