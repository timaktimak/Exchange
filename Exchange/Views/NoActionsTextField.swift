//
//  NoActionsTextField.swift
//  Exchange
//
//  Created by t.galimov on 30/01/2018.
//

import UIKit

class NoActionsTextField: UITextField {

    // Disallow actions such as cut, paste, etc.
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
    // Disallow placing cursor anywhere other than the end of the text.
    override func closestPosition(to point: CGPoint) -> UITextPosition? {
        return endOfDocument
    }
}
