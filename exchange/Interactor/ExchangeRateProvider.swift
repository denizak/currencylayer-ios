//
//  ExchangeRateProvider.swift
//  exchange
//
//  Created by Deni Zakya on 11/06/21.
//

import Foundation
import RxSwift

enum ExchangeRateError: Error {
    case notExist
}

protocol ExchangeRateProvider {
    var availableCurrencies: [Currency] { get }
    func load() -> Observable<()>
    func fetchConvertedCurrencies(from currency: Currency, value: Decimal)
    -> Observable<([CurrencyValue], Date?)>
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
    
    func load() -> Observable<()> {
        let interval = storage.timestamp?.timeIntervalSinceNow
        guard interval == nil || abs(Int(interval!)) > 30.minute
        else { return .empty() }
        
        return Observable.zip(
            api.getLiveData()
                .do(onSuccess: { [weak self] quotes, currency, timestamp in
                    self?.storage.store(quotes: quotes, timestamp: timestamp, source: currency)
                })
                .asObservable(),
            api.getAvailableCurrencies()
                .do(onSuccess: { [weak self] currencies in
                    self?.storage.store(currencies: currencies)
                })
                .asObservable()
        )
        .map { _ in }
    }
    
    func fetchConvertedCurrencies(from currency: Currency, value: Decimal)
    -> Observable<([CurrencyValue], Date?)> {
        if let _ = storage.source, storage.quotes.count > 0 {
            let results = computeConversion(from: currency, value: value)
            return .just((results, storage.timestamp))
        } else {
            return load()
                .map { [weak self] _ in
                    guard let results = self?.computeConversion(from: currency, value: value)
                    else { throw ExchangeRateError.notExist }
                    return (results, self?.storage.timestamp)
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
