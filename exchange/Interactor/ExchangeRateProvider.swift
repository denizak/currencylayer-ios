//
//  ExchangeRateProvider.swift
//  exchange
//
//  Created by Deni Zakya on 11/06/21.
//

import Foundation

protocol ExchangeRateProvider {
    var availableCurrencies: [Currency] { get }
    func load(onComplete: @escaping () -> ())
    func fetchConvertedCurrencies(from currency: Currency, value: Decimal,
                                  completion: @escaping ([CurrencyValue]) -> ())
}

final class ExchangeRateProviderImpl: ExchangeRateProvider {
    
    private let storage: ExchangeRateStore
    private let api: ExchangeRateApi

    init(storage: ExchangeRateStore, api: ExchangeRateApi) {
        self.storage = storage
        self.api = api
    }
    
    var availableCurrencies: [Currency] {
        storage.currencies.sorted { lhs, rhs in
            lhs.code < rhs.code
        }
    }
    
    func load(onComplete: @escaping () -> ()) {
        var isLiveDataComplete = false
        var isAvailableCurrenciesComplete = false
        func completeApiCall() {
            if isLiveDataComplete && isAvailableCurrenciesComplete {
                onComplete()
            }
        }
        
        let interval = storage.timestamp?.timeIntervalSinceNow
        guard interval == nil || abs(Int(interval!)) > 30.minute
        else { return }
        
        api.getLiveData { [weak self] quotes, currency, timestamp in
            guard let currency = currency, let timestamp = timestamp else { return }
            self?.storage.store(quotes: quotes, timestamp: timestamp, source: currency)
            
            isLiveDataComplete = true
            completeApiCall()
        }
        
        api.getAvailableCurrencies { [weak self] currencies in
            self?.storage.store(currencies: currencies)
            
            isAvailableCurrenciesComplete = true
            completeApiCall()
        }
    }
    
    func fetchConvertedCurrencies(from currency: Currency, value: Decimal,
                                  completion: @escaping ([CurrencyValue]) -> ()) {
        if let _ = storage.source, storage.quotes.count > 0 {
            let results = computeConversion(from: currency, value: value)
            completion(results)
        } else {
            load { [weak self] in
                guard let results = self?.computeConversion(from: currency, value: value)
                else { return }
                completion(results)
            }
        }
    }
    
    private func computeConversion(from currency: Currency, value: Decimal) -> [CurrencyValue] {
        guard let source = self.storage.source else { return [] }
        let quotes = storage.quotes
        let compute = ComputeExchangeRate(quotes: quotes, baseCurrency: source)
        
        return compute.convert(from: currency, value: value)
            .sorted { lhs, rhs in
                lhs.currency.code < rhs.currency.code
            }
    }
}

extension Int {
    var minute: Int { self * 60 }
}
