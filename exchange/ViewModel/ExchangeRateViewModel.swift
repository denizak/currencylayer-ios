//
//  ExchangeRateViewModel.swift
//  exchange
//
//  Created by Deni Zakya on 12/06/21.
//

import Foundation

final class ExchangeRateViewModel {
    private(set) var selectedCurrency = Currency(code: "USD", name: "United States Dollar")
    private(set) var availableCurrencies: [Currency] = []
    
    var onViewLoad: () -> () = { }
    var onValueLoaded: ([CurrencyValue]) -> () = { _ in }
    
    private let exchangeRateProvider: ExchangeRateProvider
    
    init(provider: ExchangeRateProvider) {
        self.exchangeRateProvider = provider
    }
    
    func select(at currencyIndex: Int) -> Currency? {
        guard currencyIndex < availableCurrencies.count else { return nil }
        selectedCurrency = availableCurrencies[currencyIndex]
        
        return selectedCurrency
    }
    
    func viewLoad() {
        self.exchangeRateProvider.load { [weak self] in
            self?.availableCurrencies = self?.exchangeRateProvider.availableCurrencies ?? []
            self?.onViewLoad()
        }
    }
    
    func load(value: String) {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.current
        if let number = numberFormatter.number(from: value) {
            exchangeRateProvider.fetchConvertedCurrencies(
                from: selectedCurrency,
                value: number.decimalValue) { [weak self] results in
                self?.onValueLoaded(results)
            }
        } else {
            onValueLoaded([])
        }
    }
}
