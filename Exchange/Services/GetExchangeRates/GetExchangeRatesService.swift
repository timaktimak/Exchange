//
//  GetExchangeRatesService.swift
//  Exchange
//
//  Created by t.galimov on 27/01/2018.
//

import Foundation

protocol GetExchangeRatesServiceProtocol {
    func getRates(completion: @escaping ([ExchangeRate]?, Error?) -> Void)
}

class GetExchangeRatesService: GetExchangeRatesServiceProtocol {
    
    var networkClient: NetworkClientProtocol!
    var parser: RatesParserProtocol!
    
    private let url = "http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml"
    
    func getRates(completion: @escaping ([ExchangeRate]?, Error?) -> Void) {
        networkClient.get(url) { [weak self] (data, error) in
            guard let `self` = self else { return }
            guard let data = data, error == nil else {
                return completion(nil, error)
            }
            // Since the completion handler is executed on a serial
            // queue, its safe to do parsing here synchronously without
            // dispatching onto a separate queue.
            // If the queue wasn't serial, the parser could potentially
            // appear in a state when it parses two responses at the same moment,
            // which would break it up, because it has internal state.
            
            // In a bigger app it might be a good idea to do
            // all parsing on a separate queue, but to keep things
            // simple, lets just parse here.
            let rates = self.parser.parse(data: data)
            completion(rates, nil)
        }
    }
}
