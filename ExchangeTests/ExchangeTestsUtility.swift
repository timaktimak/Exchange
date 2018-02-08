//
//  ExchangeTestsUtility.swift
//  ExchangeTests
//
//  Created by t.galimov on 08/02/2018.
//

import Foundation
@testable import Exchange

extension Data {
    
    init(xmlFileName: String) {
        let bundle = Bundle(for: GetExchangeRatesServiceMock.self)
        let path = bundle.path(forResource: xmlFileName, ofType: "xml")!
        let urlString = "file://" + path
        let url = URL(string: urlString)!
        try! self.init(contentsOf: url)
    }
}

/// Provides rates data from a file.
private class GetExchangeRatesServiceMock: GetExchangeRatesServiceProtocol {
    
    private let parser: RatesParserProtocol
    private let fileName: String
    
    init(fileName: String, parser: RatesParserProtocol) {
        self.parser = parser
        self.fileName = fileName
    }
    
    func getRates(completion: @escaping ([ExchangeRate]?, Error?) -> Void) {
        DispatchQueue.global().async {
            let data = Data(xmlFileName: self.fileName)
            let rates = self.parser.parse(data: data)
            DispatchQueue.main.async {
                completion(rates, nil)
            }
        }
    }
}

class ExchangeTestsAssembly {
    
    static var model: ExchangeModelProtocol {
        let parser = XMLRatesParser()
        let fileName = "rates_valid"
        let model = ExchangeModel()
        model.getRatesService = GetExchangeRatesServiceMock(fileName: fileName, parser: parser)
        return model
    }
    
    static var viewModel: ExchangeViewModelProtocol {
        let viewModel = ExchangeViewModel()
        viewModel.model = model
        return viewModel
    }
}
