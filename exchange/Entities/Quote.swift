//
//  Quote.swift
//  exchange
//
//  Created by Deni Zakya on 11/06/21.
//

import Foundation

struct Quote {
    let left: Currency
    let right: Currency
    let leftValue: Decimal
    let rightValue: Decimal
}

extension Quote: Equatable {}

extension Quote {
    func convert(from: Currency, value: Decimal) -> CurrencyValue? {
        if from == left {
            let convertedValue = value / leftValue * rightValue
            return CurrencyValue(currency: right, value: convertedValue)
        } else if from == right {
            let convertedValue = value / rightValue * leftValue
            return CurrencyValue(currency: left, value: convertedValue)
        } else {
            return nil
        }
    }
}
