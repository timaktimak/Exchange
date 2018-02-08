//
//  FSPagerViewExtensions.swift
//  Exchange
//
//  Created by t.galimov on 05/02/2018.
//

import Foundation

extension FSPagerView {
    
    func dequeue<T: FSPagerViewCell>(_ type: T.Type, at index: Int) -> T {
        let identifier = String(describing: type)
        return dequeueReusableCell(withReuseIdentifier: identifier, at: index) as! T
    }
    
    func register<T: FSPagerViewCell>(_ type: T.Type) {
        let identifier = String(describing: type)
        register(type, forCellWithReuseIdentifier: identifier)
    }
}
