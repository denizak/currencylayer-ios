//
//  LiveDataResponse.swift
//  exchange
//
//  Created by Deni Zakya on 12/06/21.
//

import Foundation

struct LiveDataResponse: Decodable {
    let success: Bool
    let timestamp: Int
    let source: String
    let quotes: [String: Decimal]
}
