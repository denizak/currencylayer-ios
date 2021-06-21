//
//  ExchangeRateProviderTest.swift
//  exchangeTests
//
//  Created by Deni Zakya on 12/06/21.
//

import XCTest
import RxSwift

@testable import exchange
final class ExchangeRateProviderTest: XCTestCase {

    func testLoad() {
        let storage = StorageSpy()
        let api = APISpy()
        let provider = ExchangeRateProviderImpl(storage: storage, api: api)
        
        let disposable = provider.load().subscribe()
        defer { disposable.dispose() }
        
        XCTAssertGreaterThan(storage.currencies.count, 0)
        XCTAssertGreaterThan(storage.quotes.count, 0)
        XCTAssertNotNil(storage.source)
        XCTAssertNotNil(storage.timestamp)
        XCTAssertEqual(api.source, "USD")
    }
    
    func testFetchConvertedCurrenciesFromCache() throws {
        let api = APISpy()
        let storage = StorageSpy()
        storage.source = Currency(code: "BBB", name: "")
        storage.quotes = [Quote(left: Currency(code: "BBB", name: ""),
                                right: Currency(code: "AAA", name: ""),
                                leftValue: 1,
                                rightValue: 1)]
        let provider = ExchangeRateProviderImpl(storage: storage, api: api)
        
        let results = try provider.fetchConvertedCurrencies(from: Currency(code: "BBB", name: ""),
                                          value: 1).toBlocking().first()!
        
        XCTAssertGreaterThan(results.count, 0)
        XCTAssertFalse(api.getLiveDataCalled)
    }
    
    func testFetchConvertedCurrenciesFromApi() throws {
        let api = APISpy()
        let storage = StorageSpy()
        let provider = ExchangeRateProviderImpl(storage: storage, api: api)
        
        let results = try provider.fetchConvertedCurrencies(from: Currency(code: "AAA", name: ""),
                                                            value: 1).toBlocking().first()!
        
        XCTAssertGreaterThan(results.count, 0)
        XCTAssertTrue(api.getLiveDataCalled)
    }
    
    func testAvailableCurrencies() {
        let storage = StorageSpy()
        storage.currencies = [Currency(code: "AAA", name: "")]
        let provider = ExchangeRateProviderImpl(storage: storage, api: APIDummy())
        
        let actualCurrencies = provider.availableCurrencies
        
        XCTAssertGreaterThan(actualCurrencies.count, 0)
    }

}

final class StorageSpy: ExchangeRateStore {
    var quotes: [Quote] = []
    var timestamp: Date? = nil
    var source: Currency? = nil
    var currencies: [Currency] = []
    
    func store(currencies: [Currency]) {
        self.currencies = currencies
    }
    
    func store(quotes: [Quote], timestamp: Date, source: Currency) {
        self.quotes = quotes
        self.timestamp = timestamp
        self.source = source
    }
    
    func reset() {
        self.currencies = []
        self.quotes = []
        self.timestamp = nil
        self.source = nil
    }
}

final class APISpy: ExchangeRateApi {
    var source = ""
    var getLiveDataCalled = false
    func getLiveData(source: String) -> Single<([Quote], Currency, Date)> {
        self.source = source
        self.getLiveDataCalled = true
        let quotes = [Quote(left: Currency(code: "AAA", name: ""),
                            right: Currency(code: "BBB", name: ""),
                            leftValue: 1, rightValue: 1)]
        return .just((quotes, Currency(code: "AAA", name: ""), Date()))
    }
    
    func getAvailableCurrencies() -> Single<[Currency]> {
        .just([Currency(code: "AAA", name: "")])
    }
}

final class APIDummy: ExchangeRateApi {
    func getLiveData(source: String) -> Single<([Quote], Currency, Date)> { .never() }
    func getAvailableCurrencies() -> Single<[Currency]> { .never() }
}
