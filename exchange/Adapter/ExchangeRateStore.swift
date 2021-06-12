//
//  ExchangeRateStore.swift
//  exchange
//
//  Created by Deni Zakya on 12/06/21.
//

import Foundation

protocol ExchangeRateStore {
    var quotes: [Quote] { get }
    var timestamp: Date? { get }
    var source: Currency? { get }
    var currencies: [Currency] { get }
    
    func store(currencies: [Currency]) 
    func store(quotes: [Quote], timestamp: Date, source: Currency)
    func reset()
}

final class ExchangeRateStoreImpl: ExchangeRateStore {
    private(set) var quotes: [Quote] = []
    private(set) var currencies: [Currency] = []
    private(set) var timestamp: Date?
    private(set) var source: Currency?
    
    func store(currencies: [Currency]) {
        // We could replace this using SQLite or CoreData
        self.currencies = currencies
    }
    
    func store(quotes: [Quote], timestamp: Date, source: Currency) {
        // We could replace this using SQLite or CoreData
        self.quotes = quotes
        self.timestamp = timestamp
        self.source = source
    }
    
    func reset() {
        self.currencies = []
        self.quotes = []
        self.timestamp = nil
        self.source = nil
    }
}
