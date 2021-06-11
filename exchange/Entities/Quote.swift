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

extension Quote {
    func convert(from: Currency, value: Decimal) -> (Currency, Decimal)? {
        if from == left {
            let convertedValue = value / leftValue * rightValue
            return (right, convertedValue)
        } else if from == right {
            let convertedValue = value / rightValue * leftValue
            return (left, convertedValue)
        } else {
            return nil
        }
    }
}
