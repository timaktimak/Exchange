//
//  ExchangeCurrencyView.swift
//  Exchange
//
//  Created by t.galimov on 27/01/2018.
//

import UIKit

protocol ExchangeCurrencyViewDelegate: class {
    func currencyViewDidBeginEditing(_ view: ExchangeCurrencyView, text: String?)
    func currencyViewTextChanged(_ view: ExchangeCurrencyView, text: String?)
}

class ExchangeCurrencyView: UIView, UITextFieldDelegate {

    weak var delegate: ExchangeCurrencyViewDelegate?

    @IBOutlet private weak var currencyLabel: UILabel!
    @IBOutlet private weak var textField: NoActionsTextField!
    @IBOutlet private weak var amountLeftLabel: UILabel!
    @IBOutlet private weak var rateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        configureTextField()
    }
    
    var viewModel: ExchangeCurrencyViewModelProtocol! {
        didSet {
            if let viewModel = viewModel {
                updateUI(with: viewModel)
            }
        }
    }

    private func updateUI(with viewModel: ExchangeCurrencyViewModelProtocol) {
        currencyLabel.text = viewModel.currencyString
        amountLeftLabel.text = "You have \(viewModel.amountLeftString)"
        amountLeftLabel.textColor = viewModel.showInsufficientFunds ? .red : .darkGray
        rateLabel.text = viewModel.exchangeRateString
        textField.text = viewModel.exchangeAmountString
    }
    
    private func configureTextField() {
        textField.delegate = self
    }
    
    // MARK: UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let resultingText = viewModel.stringByReplacingIn(string: textField.text, range: range, replacementString: string)
        guard viewModel.validate(currentText: textField.text, resultingText: resultingText) else { return false }
        let textWithSign = viewModel.addSignIfNeededTo(string: resultingText)
        textField.text = textWithSign
        delegate?.currencyViewTextChanged(self, text: textWithSign)
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.currencyViewDidBeginEditing(self, text: textField.text)
    }
    
    // MARK: UIResponder

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var isFirstResponder: Bool {
        return textField.isFirstResponder
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        // From Docs: "If you override this method, you must call super
        // (the superclass implementation) at some point in your code."
        super.resignFirstResponder()
        return textField.resignFirstResponder()
    }
}
