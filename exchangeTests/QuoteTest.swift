//
//  QuoteTest.swift
//  exchangeTests
//
//  Created by Deni Zakya on 11/06/21.
//

import XCTest

@testable import exchange

final class QuoteTest: XCTestCase {

    func testConvertRight() {
        let usd = Currency(code: "USD", name: "United States dollar")
        let jpy = Currency(code: "JPY", name: "Japanese Yen")
        
        let quote = Quote(left: usd, right: jpy, leftValue: 1, rightValue: 109.440996)
        
        let convertedCurrencyValue = quote.convert(from: usd, value: 10)!
        
        XCTAssertEqual(jpy, convertedCurrencyValue.currency)
        XCTAssertEqual(1094.40996, convertedCurrencyValue.value)
    }
    
    func testConvertLeft() {
        let usd = Currency(code: "USD", name: "United States dollar")
        let bzd = Currency(code: "BZD", name: "Belize Dollar")
        
        let quote = Quote(left: usd, right: bzd, leftValue: 1, rightValue: 2)
        
        let convertedCurrencyValue = quote.convert(from: bzd, value: 10)!
        
        XCTAssertEqual(usd, convertedCurrencyValue.currency)
        XCTAssertEqual(5, convertedCurrencyValue.value)
    }
    
    func testConvertFailed() {
        let usd = Currency(code: "USD", name: "United States dollar")
        let bzd = Currency(code: "BZD", name: "Belize Dollar")
        let invalidCurrency = Currency(code: "INV", name: "invalid currency")
        
        let quote = Quote(left: usd, right: bzd, leftValue: 1, rightValue: 2)
        
        let result = quote.convert(from: invalidCurrency, value: 10)
        
        XCTAssertNil(result)
    }

}
