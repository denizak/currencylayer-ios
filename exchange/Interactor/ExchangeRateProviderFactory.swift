//
//  ExchangeRateProviderFactory.swift
//  exchange
//
//  Created by Deni Zakya on 12/06/21.
//

import Foundation

func createExchangeRateProvider() -> ExchangeRateProvider {
    ExchangeRateProvider(storage: ExchangeRateStoreImpl(), api: ExchangeRateApiImpl())
}
