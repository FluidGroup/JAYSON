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

    let _data = try? data(options: .prettyPrinted)

    return
      [
        "SourceType: \(sourceType.description)",
        "Source:",
        "\(_data.flatMap { String(data: $0, encoding: .utf8) } ?? "<empty>")",
        ]
        .joined(separator: "\n")
  }

  public var debugDescription: String {
    return description
  }
}
