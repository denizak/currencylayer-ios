//
//  ExchangeRateStore.swift
//  exchange
//
//  Created by Deni Zakya on 12/06/21.
//

import Foundation

final class ExchangeRateStore {
    private(set) var quotes: [Quote] = []
    private(set) var timestamp: Date?
    private(set) var source: Currency?
    
    func store(quotes: [Quote], timestamp: Date, source: Currency) {
        // We could replace this using SQLite or CoreData
        self.quotes = quotes
        self.timestamp = timestamp
        self.source = source
    }
    
    func reset() {
        self.quotes = []
        self.timestamp = nil
        self.source = nil
    }
}
