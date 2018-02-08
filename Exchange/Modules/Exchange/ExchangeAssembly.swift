//
//  ExchangeAssembly.swift
//  Exchange
//
//  Created by t.galimov on 28/01/2018.
//

import Foundation

protocol ExchangeAssemblyProtocol {
    var viewModel: ExchangeViewModel { get }
}

class ExchangeAssembly: ExchangeAssemblyProtocol {
    
    var viewModel: ExchangeViewModel {
        let viewModel = ExchangeViewModel()
        viewModel.model = exchangeModel
        return viewModel
    }
    
    private var exchangeModel: ExchangeModelProtocol {
        let model = ExchangeModel()
        model.getRatesService = getRatesService
        return model
    }
    
    private var getRatesService: GetExchangeRatesServiceProtocol {
        let networkClient = NetworkClient()
        let parser = XMLRatesParser()
        let service = GetExchangeRatesService()
        service.networkClient = networkClient
        service.parser = parser
        return service
    }
}
