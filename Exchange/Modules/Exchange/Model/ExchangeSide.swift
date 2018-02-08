//
//  ExchangeSide.swift
//  Exchange
//
//  Created by t.galimov on 05/02/2018.
//

import Foundation

enum ExchangeSide {
    case from
    case to
    
    var opposite: ExchangeSide {
        switch self {
        case .from:
            return .to
        case .to:
            return .from
        }
    }
    
    var sign: String {
        switch self {
        case .from:
            return "-"
        case .to:
            return "+"
        }
    }
}
