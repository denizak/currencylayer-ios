//
//  SupportedCurrencyResponse.swift
//  exchange
//
//  Created by Deni Zakya on 12/06/21.
//

import Foundation
struct SupportedCurrencyResponse: Decodable {
    let success: Bool
    let currencies: [String: String]
}
