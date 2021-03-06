//
//  Currency.swift
//  exchange
//
//  Created by Deni Zakya on 11/06/21.
//

import Foundation

struct Currency {
    let code: String
    let name: String
}

extension Currency: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.code == rhs.code
    }
}
