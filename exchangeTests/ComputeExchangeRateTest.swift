//
//  ComputeExchangeRateTest.swift
//  exchangeTests
//
//  Created by Deni Zakya on 11/06/21.
//

import XCTest

@testable import exchange
final class ComputeExchangeRateTest: XCTestCase {

    let gbp = Currency(code: "GBP", name: "British Pound Sterling")
    let usd = Currency(code: "USD", name: "United States Dollar")
    let eur = Currency(code: "EUR", name: "Euro")
    
    func testConvert() {
        let baseCurrency = usd
        let quotes = [
            Quote(left: usd,
                  right: gbp,
                  leftValue: 1, rightValue: 10),
            Quote(left: usd,
                  right: eur,
                  leftValue: 1, rightValue: 20),
            Quote(left: usd,
                  right: usd,
                  leftValue: 1, rightValue: 1)
        ]
        
        let computeExchangeRate = ComputeExchangeRate(quotes: quotes, baseCurrency: baseCurrency)
        
        let results = computeExchangeRate.convert(from: gbp, value: 100)
        
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].currency, eur)
        XCTAssertEqual(results[1].currency, usd)
        
        XCTAssertEqual(results[0].value, 200)
        XCTAssertEqual(results[1].value, 10)
    }
    
    func testConvertFromBaseCurrency() {
        let baseCurrency = usd
        let quotes = [
            Quote(left: usd,
                  right: gbp,
                  leftValue: 1, rightValue: 10),
            Quote(left: usd,
                  right: eur,
                  leftValue: 1, rightValue: 20),
            Quote(left: usd,
                  right: usd,
                  leftValue: 1, rightValue: 1)
        ]
        
        let computeExchangeRate = ComputeExchangeRate(quotes: quotes, baseCurrency: baseCurrency)
        
        let results = computeExchangeRate.convert(from: usd, value: 1)
        
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].currency, gbp)
        XCTAssertEqual(results[1].currency, eur)
        
        XCTAssertEqual(results[0].value, 10)
        XCTAssertEqual(results[1].value, 20)
    }

}
