//
//  ExchangeRateViewModelTest.swift
//  exchangeTests
//
//  Created by Deni Zakya on 12/06/21.
//

import XCTest
import RxSwift
import RxRelay
import RxCocoa

@testable import exchange
final class ExchangeRateViewModelTest: XCTestCase {

    func testViewLoad() {
        let viewModel = ExchangeRateViewModel(provider: ExchangeRateProviderMock())

        viewModel.viewLoad()

        XCTAssertGreaterThan(viewModel.availableCurrencies.count, 0)
    }

    func testValueChanged() {
        let viewModel = ExchangeRateViewModel(provider: ExchangeRateProviderMock())
        let observer = BehaviorRelay<[CurrencyValue]>(value: [])
        let disposable = viewModel.values.drive(observer)
        defer { disposable.dispose() }
        viewModel.viewLoad()
        
        viewModel.numberValue.accept("1")

        XCTAssertGreaterThan(observer.value.count, 0)
    }

    func testLoadFailedParseValue() {
        let viewModel = ExchangeRateViewModel(provider: ExchangeRateProviderMock())
        let observer = BehaviorRelay<[CurrencyValue]>(value: [])
        let disposable = viewModel.values.drive(observer)
        defer { disposable.dispose() }
        viewModel.viewLoad()
        
        viewModel.numberValue.accept("")

        XCTAssertEqual(observer.value.count, 0)
    }

    func testLastFetchTimeDisplay() {
        let actualLastFetchTimeDisplay = BehaviorRelay<String>(value: "")
        let viewModel = ExchangeRateViewModel(provider: ExchangeRateProviderMock())
        
        let disposable = viewModel.lastFetchTimeDisplay.drive(actualLastFetchTimeDisplay)
        defer { disposable.dispose() }
        
        viewModel.viewLoad()
        viewModel.numberValue.accept("1")
        
        XCTAssertEqual(actualLastFetchTimeDisplay.value, "24-06-2021 14:09")
    }
}

final class ExchangeRateProviderMock: ExchangeRateProvider {
    var availableCurrencies: [Currency] = []
    
    func load() -> Observable<()> {
        availableCurrencies = [Currency(code: "USD", name: "")]
        return .just(())
    }
    
    func fetchConvertedCurrencies(from currency: Currency, value: Decimal) -> Observable<([CurrencyValue], Date?)> {
        .just(([
            CurrencyValue(currency: Currency(code: "AAA", name: ""),
                          value: 1)
        ],
        ISO8601DateFormatter().date(from: "2021-06-24T07:09:59Z")))
    }
}
