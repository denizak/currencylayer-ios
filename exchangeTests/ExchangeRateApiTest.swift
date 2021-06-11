//
//  ExchangeRateApiTest.swift
//  exchangeTests
//
//  Created by Deni Zakya on 12/06/21.
//

import XCTest

@testable import exchange

final class ExchangeRateApiTest: XCTestCase {

    func testGetAvailableCurrencies() {
        let getAvailableCurrencyExpectation = expectation(description: #function)
        let api = ExchangeRateApi()
        
        api.getAvailableCurrencies { currencies in
            XCTAssertGreaterThan(currencies.count, 0)
            getAvailableCurrencyExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testGetLiveData() {
        let getLiveDataExpectation = expectation(description: #function)
        let api = ExchangeRateApi()
        
        api.getLiveData { quotes, sourceCurrency, timestamp in
            XCTAssertGreaterThan(quotes.count, 0)
            XCTAssertEqual(sourceCurrency?.code, "USD")
            XCTAssertNotNil(timestamp)
            getLiveDataExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }

}
