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
                    let currencies = responseData.success ?
                        responseData.currencies.keys
                        .filter { responseData.currencies[$0] != nil }
                        .map { Currency(code: $0, name: responseData.currencies[$0]!) } : []
                    
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
    
}
