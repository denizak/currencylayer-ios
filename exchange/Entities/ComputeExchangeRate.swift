//
//  ComputeExchangeRate.swift
//  exchange
//
//  Created by Deni Zakya on 11/06/21.
//

import Foundation

struct ComputeExchangeRate {
    let quotes: [Quote]
    let baseCurrency: Currency
    
    func convert(from currency: Currency, value: Decimal) -> [CurrencyValue] {
        guard let intermediate = getBaseCurrencyValue(from: currency, value: value)
        else { return [] }
        
        return quotes
            .compactMap { $0.convert(from: intermediate.currency, value: intermediate.value) }
            .filter { convertedCurrencyValue in
                currency != convertedCurrencyValue.currency
            }
    }
    
    private func getBaseCurrencyValue(from currency: Currency, value: Decimal)
    -> CurrencyValue? {
        if currency == baseCurrency { return CurrencyValue(currency: currency, value: value) }
        
        for quote in quotes {
            if let result = quote.convert(from: currency, value: value) {
                return result
            }
        }
        
        return nil
    }
}
