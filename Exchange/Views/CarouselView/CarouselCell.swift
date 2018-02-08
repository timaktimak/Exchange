//
//  CarouselCell.swift
//  Exchange
//
//  Created by t.galimov on 05/02/2018.
//

import UIKit

class CarouselCell: FSPagerViewCell {
    
    private var containedView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    // MARK: Public
    
    func add(view: UIView) {
        guard containedView == nil else {
            assertionFailure("Can't add a second view")
            return
        }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(view)
        containedView = view
    }

    func contains(view: UIView) -> Bool {
        return containedView == view
    }
    
    func removeView() {
        containedView?.removeFromSuperview()
        containedView = nil
    }

    // MARK: Private
    
    private func commonInit() {
        configureShadow()
    }
    
    private func configureShadow() {
        // drop default library settings
        contentView.layer.shadowRadius = 0
        contentView.layer.shadowOpacity = 0
    }
}
