//
//  KeyboardObserver.swift
//  Exchange
//
//  Created by t.galimov on 27/01/2018.
//

import UIKit

class KeyboardObserver: NSObject {
    
    private let block: (CGFloat) -> Void

    // MARK: Public
    
    init(block: @escaping (CGFloat) -> Void) {
        self.block = block
    }
    
    func subscribe() {
        center.addObserver(self, selector: #selector(handle), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    func unsubscribe() {
        center.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    // MARK: Private
    
    private var center: NotificationCenter {
        return NotificationCenter.default
    }
    
    @objc
    private func handle(notification: NSNotification) {
        guard let frame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect else { return }
        let height = UIScreen.main.bounds.height - frame.minY
        // don't need animation for the purposes of this app
        block(height)
    }
}
