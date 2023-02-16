//
//  Extensions+Decodable.swift
//  dIM
//
//  Created by Kasper Munch on 15/02/2023.
//

import Foundation

extension Decodable {
    static func decode(
        data: Data?,
        decoder: JSONDecoder = JSONDecoder()
    ) throws -> Self {
        try decoder.decode(Self.self, from: data ?? Data())
    }
}
