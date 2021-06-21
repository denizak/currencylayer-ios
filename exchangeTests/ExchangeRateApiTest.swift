//
//  ExchangeRateApiTest.swift
//  exchangeTests
//
//  Created by Deni Zakya on 12/06/21.
//

import XCTest
import RxSwift
import RxBlocking

@testable import exchange

final class ExchangeRateApiTest: XCTestCase {

    func testGetAvailableCurrencies() throws {
        let api = ExchangeRateApiImpl()
        
        let results = try api.getAvailableCurrencies().toBlocking().first()!
        
        XCTAssertGreaterThan(results.count, 0)
    }
    
    func testGetLiveData() throws {
        let api = ExchangeRateApiImpl()
        
        let (quotes, source, timestamp) = try api.getLiveData().toBlocking().first()!
        
        XCTAssertGreaterThan(quotes.count, 0)
        XCTAssertEqual(source.code, "USD")
        XCTAssertNotNil(timestamp)
    }

}
