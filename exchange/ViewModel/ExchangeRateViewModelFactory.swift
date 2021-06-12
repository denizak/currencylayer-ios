//
//  ExchangeRateViewModelFactory.swift
//  exchange
//
//  Created by Deni Zakya on 12/06/21.
//

import Foundation

func createExchangeRateViewModel() -> ExchangeRateViewModel {
    return ExchangeRateViewModel(provider: createExchangeRateProvider())
}
