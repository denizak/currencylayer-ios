//
//  ExchangeRateViewModelTest.swift
//  exchangeTests
//
//  Created by Deni Zakya on 12/06/21.
//

import XCTest

@testable import exchange
final class ExchangeRateViewModelTest: XCTestCase {

    func testViewLoad() {
        let expectationLoad = expectation(description: #function)
        let viewModel = ExchangeRateViewModel(provider: ExchangeRateProviderMock())
        
        viewModel.onViewLoad = {
            XCTAssertGreaterThan(viewModel.availableCurrencies.count, 0)
            expectationLoad.fulfill()
        }
        
        viewModel.viewLoad()
        
        wait(for: [expectationLoad], timeout: 1)
    }
    
    func testLoad() {
        let expectationLoad = expectation(description: #function)
        let viewModel = ExchangeRateViewModel(provider: ExchangeRateProviderMock())
        
        viewModel.onValueLoaded = { results in
            XCTAssertGreaterThan(results.count, 0)
            expectationLoad.fulfill()
        }
        
        viewModel.load(value: "1")
        
        wait(for: [expectationLoad], timeout: 1)
    }
    
    func testLoadFailedParseValue() {
        let expectationLoad = expectation(description: #function)
        let viewModel = ExchangeRateViewModel(provider: ExchangeRateProviderMock())
        
        viewModel.onValueLoaded = { results in
            XCTAssertEqual(results.count, 0)
            expectationLoad.fulfill()
        }
        
        viewModel.load(value: "")
        
        wait(for: [expectationLoad], timeout: 1)
    }

}

final class ExchangeRateProviderMock: ExchangeRateProvider {
    var availableCurrencies: [Currency] = [Currency(code: "USD", name: "")]
    
    func load(onComplete: @escaping () -> ()) {
        onComplete()
    }
    
    func fetchConvertedCurrencies(from currency: Currency, value: Decimal, completion: @escaping ([CurrencyValue]) -> ()) {
        completion(
            [
                CurrencyValue(currency: Currency(code: "AAA", name: ""),
                              value: 1)
            ])
    }
    
    
}
