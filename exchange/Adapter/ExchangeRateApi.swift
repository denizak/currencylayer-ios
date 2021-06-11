//
//  ExchangeRateApi.swift
//  exchange
//
//  Created by Deni Zakya on 12/06/21.
//

import Foundation

struct ExchangeRateApi {
    let baseUrl = "http://api.currencylayer.com"
    let accessKey = "39d434a114eeceb94f0b4996307e8dcd"
    
    func getAvailableCurrencies(completion: @escaping ([Currency]) -> ()) {
        var urlComponents = URLComponents(string: baseUrl)
        urlComponents?.path = "/list"
        urlComponents?.queryItems = [.init(name: "format", value: "1"),
                                     .init(name: "access_key", value: accessKey)]
        guard let url = urlComponents?.url
        else { completion([]); return }
        
        let dataTask = URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data, error == nil {
                do {
                    let responseData = try JSONDecoder().decode(SupportedCurrencyResponse.self,
                                                                from: data)
                    let currencies = responseData.success ? currencies(from: responseData.currencies) : []
                    
                    completion(currencies)
                } catch {
                    completion([])
                }
            } else {
                completion([])
            }
        }
        dataTask.resume()
    }
    
    func getLiveData(source: String = "USD", completion: @escaping ([Quote], Currency?, Date?) -> ()) {
        var urlComponents = URLComponents(string: baseUrl)
        urlComponents?.path = "/live"
        urlComponents?.queryItems = [.init(name: "format", value: "1"),
                                     .init(name: "access_key", value: accessKey)]
        guard let url = urlComponents?.url
        else { completion([], nil, nil); return }
        
        let dataTask = URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data, error == nil {
                do {
                    let responseData = try JSONDecoder().decode(LiveDataResponse.self,
                                                                from: data)
                    
                    let quotes = responseData.success ? quotes(from: responseData.quotes) : []
                    
                    completion(quotes,
                               Currency(code: responseData.source, name: ""),
                               Date(timeIntervalSince1970: TimeInterval(responseData.timestamp)))
                } catch {
                    completion([], nil, nil)
                }
            } else {
                completion([], nil, nil)
            }
        }
        dataTask.resume()
    }
    
}

private func quotes(from values: [String: Decimal]) -> [Quote] {
    values.keys
        .filter { $0.count == 6 }
        .map {
            let left = String($0.prefix(3))
            let right = String($0.suffix(3))
            return Quote(left: Currency(code: left, name: ""),
                         right: Currency(code: right, name: ""),
                         leftValue: 1,
                         rightValue: values[$0]!)
        }
}

private func currencies(from values: [String: String]) -> [Currency] {
    values.keys
        .filter { values[$0] != nil }
        .map { Currency(code: $0, name: values[$0]!) }
}
