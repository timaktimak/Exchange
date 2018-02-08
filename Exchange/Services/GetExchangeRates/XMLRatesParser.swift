//
//  XMLParser.swift
//  Exchange
//
//  Created by t.galimov on 27/01/2018.
//

import Foundation

protocol RatesParserProtocol {
    /// Synchronously parse data.
    func parse(data: Data) -> [ExchangeRate]?
}

/// The state is cleaned up after each call of `parse(date:)`,
/// so its safe to reuse an `XMLRatesParser` instance multiple times in single thread.
class XMLRatesParser: NSObject, RatesParserProtocol, XMLParserDelegate {

    private let tag = "Cube"
    private let currencyKey = "currency"
    private let rateKey = "rate"
    
    private var rates: [ExchangeRate] = []
    
    func parse(data: Data) -> [ExchangeRate]? {
        return parse(xmlData: data)
    }

    private func parse(xmlData: Data) -> [ExchangeRate]? {
        let parser = XMLParser(data: xmlData)
        parser.delegate = self
        defer { rates.removeAll() }
        guard parser.parse() else { return nil }
        return rates
    }
    
    // MARK: XMLParserDelegate
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {

        guard elementName == tag else { return }
        guard let currencyIdentifier = attributeDict[currencyKey],
            let currency = Currency(identifier: currencyIdentifier) else { return }
        guard let rateString = attributeDict[rateKey],
            let rate = Decimal(string: rateString) else { return }
        
        let exchangeRate = ExchangeRate(from: .EUR, to: currency, rate: rate)
        rates.append(exchangeRate)
    }
}
