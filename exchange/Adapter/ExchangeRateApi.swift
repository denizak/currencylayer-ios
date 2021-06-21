//
//  ExchangeRateApi.swift
//  exchange
//
//  Created by Deni Zakya on 12/06/21.
//

import Foundation
import RxSwift
import RxCocoa

private func getAPIKey() -> String {
    ProcessInfo.processInfo.environment["api_key"]!
}

enum APIError: Error {
    case URLError
}

protocol ExchangeRateApi {
    func getAvailableCurrencies() -> Single<[Currency]>
    func getLiveData(source: String) -> Single<([Quote], Currency, Date)>
}

extension ExchangeRateApi {
    func getLiveData() -> Single<([Quote], Currency, Date)> {
        getLiveData(source: "USD")
    }
}

struct ExchangeRateApiImpl: ExchangeRateApi {
    let baseUrl = "http://apilayer.net/api"
    let accessKey = getAPIKey()
    
    func getAvailableCurrencies() -> Single<[Currency]> {
        var urlComponents = URLComponents(string: baseUrl)
        urlComponents?.path = "/list"
        urlComponents?.queryItems = [.init(name: "format", value: "1"),
                                     .init(name: "access_key", value: accessKey)]
        guard let url = urlComponents?.url
        else { return .error(APIError.URLError) }
        
        return URLSession.shared.rx.data(request: URLRequest(url: url))
            .map { data in
                let responseData = try JSONDecoder().decode(SupportedCurrencyResponse.self,
                                                            from: data)
                return responseData.success ? currencies(from: responseData.currencies) : []
            }
            .take(1)
            .asSingle()
    }
    
    func getLiveData(source: String) -> Single<([Quote], Currency, Date)> {
        var urlComponents = URLComponents(string: baseUrl)
        urlComponents?.path = "/live"
        urlComponents?.queryItems = [.init(name: "format", value: "1"),
                                     .init(name: "access_key", value: accessKey)]
        guard let url = urlComponents?.url
        else { return .error(APIError.URLError) }
        
        return URLSession.shared.rx.data(request: URLRequest(url: url))
            .map { data -> ([Quote], Currency, Date) in
                let responseData = try JSONDecoder().decode(LiveDataResponse.self,
                                                            from: data)
                
                let quotes = responseData.success ? quotes(from: responseData.quotes) : []
                return (quotes,
                        Currency(code: responseData.source, name: ""),
                        Date(timeIntervalSince1970: TimeInterval(responseData.timestamp)))
            }
            .take(1)
            .asSingle()
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
