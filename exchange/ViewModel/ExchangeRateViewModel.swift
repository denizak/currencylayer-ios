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

extension CurrencyValue {
    func getFormattedValue(_ formatter: NumberFormatter = NumberFormatter()) -> String? {
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 4
        
        return formatter.string(from: value as NSDecimalNumber)
    }
}

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
    
    var lastFetchTimeDisplay: Driver<String> {
        lastFetchTime.asDriver(onErrorJustReturn: "-")
    }
    private let lastFetchTime = PublishRelay<String>()
    
    var showAlert: Driver<String> {
        alert.asDriver(onErrorJustReturn: "Unknown error")
    }
    private let alert = PublishRelay<String>()
    
    private let disposeBag = DisposeBag()
    private let fetchValueDisposable = SerialDisposable()
    
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
        } onError: { [weak self] error in
            self?.alert.accept(error.localizedDescription)
            self?.loadingVisibility.accept(false)
        } onCompleted: { [weak self] in
            self?.availableCurrencies = self?.exchangeRateProvider.availableCurrencies ?? []
            self?.loadingVisibility.accept(false)
        }.disposed(by: disposeBag)
        
        numberValue.map { [weak self] value in
            self?.load(value)
        }.subscribe().disposed(by: disposeBag)
    }
    
    private func load(_ value: String) {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.current
        if let number = numberFormatter.number(from: value) {
            fetchValueDisposable.disposable = exchangeRateProvider
                .fetchConvertedCurrencies(from: self.selectedCurrency,
                                          value: number.decimalValue)
                .subscribe { [weak self] values, timestamp in
                    guard let `self` = self else { return }
                    self.convertedValues.accept(values)
                    self.lastFetchTime.accept(self.formattedLastFetchTime(timestamp))
                } onError: { [weak self] error in
                    self?.alert.accept(error.localizedDescription)
                }
        } else {
            convertedValues.accept([])
            lastFetchTime.accept("")
            alert.accept("Invalid number")
        }
    }
    
    private func formattedLastFetchTime(_ value: Date?) -> String {
        guard let value = value else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        return formatter.string(from: value)
    }
}
