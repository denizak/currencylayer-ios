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
        
        let (convertedCurrency, convertedValue) = quote.convert(from: usd, value: 10)!
        
        XCTAssertEqual(jpy, convertedCurrency)
        XCTAssertEqual(1094.40996, convertedValue)
    }
    
    func testConvertLeft() {
        let usd = Currency(code: "USD", name: "United States dollar")
        let bzd = Currency(code: "BZD", name: "Belize Dollar")
        
        let quote = Quote(left: usd, right: bzd, leftValue: 1, rightValue: 2)
        
        let (convertedCurrency, convertedValue) = quote.convert(from: bzd, value: 10)!
        
        XCTAssertEqual(usd, convertedCurrency)
        XCTAssertEqual(5, convertedValue)
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
