//
//  ExchangeRateStoreTest.swift
//  exchangeTests
//
//  Created by Deni Zakya on 12/06/21.
//

import XCTest

@testable import exchange
final class ExchangeRateStoreTest: XCTestCase {
    
    let usd = Currency(code: "USD", name: "United States Dollar")
    let eur = Currency(code: "EUR", name: "Euro")
    
    func testStore() {
        let expectedQuotes = [
            Quote(left: usd,
                  right: eur,
                  leftValue: 1, rightValue: 10)
        ]
        let storage = ExchangeRateStoreImpl()
        
        storage.store(
            quotes: [
                Quote(left: usd,
                      right: eur,
                      leftValue: 1, rightValue: 10)],
            timestamp: Date(),
            source: usd)
        
        XCTAssertEqual(storage.quotes, expectedQuotes)
        XCTAssertNotNil(storage.timestamp)
        XCTAssertNotNil(storage.source)
    }

}
