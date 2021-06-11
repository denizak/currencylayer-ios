//
//  QuoteTest.swift
//  exchangeTests
//
//  Created by Deni Zakya on 11/06/21.
//

import XCTest

@testable import exchange

final class QuoteTest: XCTestCase {

    func testConvert() {
        let usd = Currency(code: "USD", name: "United States dollar")
        let jpy = Currency(code: "JPY", name: "Japanese Yen")
        
        let quote = Quote(left: usd, right: jpy, leftValue: 1, rightValue: 109.440996)
        
        let (convertedCurrency, convertedValue) = quote.convert(from: usd, value: 10)
        
        XCTAssertEqual(jpy, convertedCurrency)
        XCTAssertEqual(1094.40996, convertedValue)
    }

}
