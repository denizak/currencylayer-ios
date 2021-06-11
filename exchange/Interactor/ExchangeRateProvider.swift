//
//  ExchangeRateProvider.swift
//  exchange
//
//  Created by Deni Zakya on 11/06/21.
//

import Foundation

struct ExchangeRateProvider {
    private let baseCurrency = Currency(code: "USD", name: "United States Dollar")
    
    var availableCurrencies: [Currency] {
        [
            Currency(code: "EUR", name: "Euro"),
            Currency(code: "GBP", name: "British Pound Sterling"),
            Currency(code: "USD", name: "United States Dollar")
        ]
    }
    
    func getConvertedCurrencies(from currency: Currency, value: Decimal) -> [CurrencyValue] {
        let compute = ComputeExchangeRate(
            quotes: [
                Quote(left: baseCurrency,
                      right: Currency(code: "EUR", name: "Euro"),
                      leftValue: 1,
                      rightValue: 10),
                Quote(left: baseCurrency,
                      right: Currency(code: "GBP", name: "British Pound Sterling"),
                      leftValue: 1,
                      rightValue: 20),
                Quote(left: baseCurrency,
                      right: baseCurrency,
                      leftValue: 1,
                      rightValue: 1),
            ],
            baseCurrency: baseCurrency)
        
        return compute.convert(from: currency, value: value)
    }
}
