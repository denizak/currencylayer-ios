//
//  ExchangeRateViewModel.swift
//  exchange
//
//  Created by Deni Zakya on 12/06/21.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

final class ExchangeRateViewModel {
    private(set) var selectedCurrency = Currency(code: "USD", name: "United States Dollar")
    private(set) var availableCurrencies: [Currency] = []
    
    let numberValue = BehaviorRelay<String>(value: "")
    var loadingVisible: Driver<Bool> {
        loadingVisibility.asDriver(onErrorJustReturn: false)
    }
    private let loadingVisibility = PublishRelay<Bool>()
    
    var values: Driver<[CurrencyValue]> {
        convertedValues.asDriver(onErrorJustReturn: [])
    }
    private let convertedValues = PublishRelay<[CurrencyValue]>()
    
    private let disposeBag = DisposeBag()
    
    private let exchangeRateProvider: ExchangeRateProvider
    
    init(provider: ExchangeRateProvider) {
        self.exchangeRateProvider = provider
    }
    
    func select(at currencyIndex: Int) -> Currency? {
        guard currencyIndex < availableCurrencies.count else { return nil }
        selectedCurrency = availableCurrencies[currencyIndex]
        load(numberValue.value)
        
        return selectedCurrency
    }
    
    func viewLoad() {
        loadingVisibility.accept(true)
        
        exchangeRateProvider.load().subscribe { [weak self] _ in
            self?.loadingVisibility.accept(false)
        } onCompleted: { [weak self] in
            self?.availableCurrencies = self?.exchangeRateProvider.availableCurrencies ?? []
        }.disposed(by: disposeBag)
        
        numberValue.map { [weak self] value in
            self?.load(value)
        }
        .subscribe().disposed(by: disposeBag)
    }
    
    private func load(_ value: String) {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.current
        if let number = numberFormatter.number(from: value) {
            exchangeRateProvider.fetchConvertedCurrencies(from: self.selectedCurrency,
                                                          value: number.decimalValue)
                .subscribe { [weak self] values in
                    self?.convertedValues.accept(values)
                }
                .disposed(by: self.disposeBag)
        } else {
            convertedValues.accept([])
        }
    }
}
