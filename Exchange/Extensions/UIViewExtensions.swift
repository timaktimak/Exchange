//
//  UIViewExtensions.swift
//  Exchange
//
//  Created by t.galimov on 27/01/2018.
//

import UIKit

protocol NibLoadable {
}

extension UIView: NibLoadable {
}

extension NibLoadable where Self: UIView {

    static func loadFromNib() -> Self {
        let bundle = Bundle(for: self)
        let name = String(describing: self)
        let view = bundle.loadNibNamed(name, owner: self, options: nil)!.first as! Self
        return view
    }
}
