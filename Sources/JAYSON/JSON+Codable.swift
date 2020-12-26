//
//  JSON+Codable.swift
//  JAYSON
//
//  Created by Muukii on 2020/12/26.
//  Copyright © 2020 muukii. All rights reserved.
//

import Foundation

extension JSON: Codable {

  public func encode(to encoder: Swift.Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(data())
  }

  public init(from decoder: Swift.Decoder) throws {
    let data = try decoder.singleValueContainer().decode(Data.self)
    try self = .init(data: data)
  }

}
