//
//  ExchangeViewController.swift
//  Exchange
//
//  Created by t.galimov on 27/01/2018.
//

import UIKit

class ExchangeViewController: UIViewController, CarouselViewDelegate, ExchangeCurrencyViewDelegate, UIKeyInput, UITextInputTraits {
    
    var viewModel: ExchangeViewModelProtocol!
    
    @IBOutlet private weak var carouselViewFrom: CarouselView!
    @IBOutlet private weak var carouselViewTo: CarouselView!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!

    private var exchangeBarButtonItem: UIBarButtonItem!
    private var retryBarButtonItem: UIBarButtonItem!
    private var activityIndicator: UIActivityIndicatorView!

    private var keyboardObserver: KeyboardObserver!

    private var fromViews: [ExchangeCurrencyView]!
    private var toViews: [ExchangeCurrencyView]!

    private var timer: Timer?
    private let timerInterval: TimeInterval = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(viewModel != nil)
        
        activityIndicator = createActivityIndicator()
        keyboardObserver = createKeyboardObserver()

        configureNavigationBar()
        
        setupNavigationBarItems()
        setupCurrencyViews()
        setupCarouselViews()
        setupTimer()
        
        loadExchangeRates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardObserver.subscribe()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardObserver.unsubscribe()
    }
    
    deinit {
        invalidateTimer()
    }
    
    // MARK: Timer

    private func setupTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { [weak self] _ in
            self?.loadExchangeRates()
        }
        if let timer = timer {
            // The timer needs to run even if the user
            // is scrolling, otherwise the user can
            // scroll the carousel view for a while
            // and then exchane with an old exchange rate.
            RunLoop.main.add(timer, forMode: .commonModes)
        }
    }
    
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func loadExchangeRates() {
        viewModel.loadExchangeRates { [weak self] _ in
            self?.updateUI()
        }
        updateUI()
    }
    
    // MARK: Actions
    
    @objc
    private func exchangeButtonPressed() {
        let success = viewModel.performExchange()
        assert(success)
        updateUI()
    }

    @objc
    private func retryButtonPressed() {
        invalidateTimer()
        setupTimer()
        loadExchangeRates()
    }
    
    // MARK: Initial configuration and setup
    
    private func setupNavigationBarItems() {
        exchangeBarButtonItem = UIBarButtonItem(title: "Exchange", style: .done, target: self, action: #selector(exchangeButtonPressed))
        navigationItem.rightBarButtonItem = exchangeBarButtonItem
        retryBarButtonItem = UIBarButtonItem(title: "Retry", style: .plain, target: self, action: #selector(retryButtonPressed))
    }
    
    private func setupCurrencyViews() {
        fromViews = viewModel.currencies.map { _ in ExchangeCurrencyView.loadFromNib() }
        fromViews.forEach { $0.delegate = self }
        toViews = viewModel.currencies.map { _ in ExchangeCurrencyView.loadFromNib() }
        toViews.forEach { $0.delegate = self }
    }
    
    private func setupCarouselViews() {
        carouselViewFrom.delegate = self
        carouselViewTo.delegate = self
        let indexFrom = viewModel.currentCurrencyIndexOf(side: .from)
        carouselViewFrom.setup(swipeableViews: fromViews, initialIndex: indexFrom)
        let indexTo = viewModel.currentCurrencyIndexOf(side: .to)
        carouselViewTo.setup(swipeableViews: toViews, initialIndex: indexTo)
        fromViews[indexFrom].becomeFirstResponder()
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func createKeyboardObserver() -> KeyboardObserver {
        let observer = KeyboardObserver(block: { [weak self] height in
            self?.bottomConstraint.constant = height
        })
        return observer
    }
    
    private func createActivityIndicator() -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicator.startAnimating()
        return indicator
    }
    
    // MARK: ExchangeCurrencyViewDelegate
    
    func currencyViewTextChanged(_ view: ExchangeCurrencyView, text: String?) {
        guard let side = exchangeSide(of: view) else { return }
        viewModel.editedAmountOf(side: side, text: text)
        updateUI()
    }

    func currencyViewDidBeginEditing(_ view: ExchangeCurrencyView, text: String?) {
        guard let side = exchangeSide(of: view) else { return }
        viewModel.startedEditingAmountOf(side: side, text: text)
    }
    
    // MARK: CarouselViewDelegate
    
    func carouselViewDidBeginScrolling(_ carouselView: CarouselView) {
        // To make sure that keyboard doesn't accidentally get dismissed,
        // and that the carousel view doesn't have glitches because
        // the first reponder textfield got swiped off the screen,
        // make viewController the first responder when scrolling,
        // if the first responder view is getting swiped away.
        guard let side = exchangeSide(of: carouselView) else { return }
        if side == viewModel.currentlyEditedSide {
            _ = becomeFirstResponder()
        }
    }
    
    func carouselView(_ carouselView: CarouselView, didTransitionToIndex index: Int) {
        guard let side = exchangeSide(of: carouselView) else { return }
        viewModel.transitionedToCurrencyAt(index: index, side: side)
        
        if viewModel.isExchangingSameCurrency {
            carouselView.scrollToNextItem()
        } else {
            updateUI()
            // If the first responder view has been swiped, the newly appeared currency view
            // should become the first responder. Otherwise, the first responder shouldn't
            // have resigned.
            let currentlyEditedSide = viewModel.currentlyEditedSide
            let editedViews = currencyViews(of: currentlyEditedSide)
            let editedViewIndex = viewModel.currentCurrencyIndexOf(side: currentlyEditedSide)
            let currencyView = editedViews[editedViewIndex]
            if !currencyView.isFirstResponder {
                currencyView.becomeFirstResponder()
            }
        }
    }
    
    // MARK: Update UI
    
    private func updateUI() {
        updateNavigationBar()
        updateCurrencyViews()
    }
    
    private func updateCurrencyViews() {
        update(views: fromViews, side: .from)
        update(views: toViews, side: .to)
    }
    
    private func update(views: [ExchangeCurrencyView], side: ExchangeSide) {
        for (index, view) in views.enumerated() {
            let currency = viewModel.currencies[index]
            let currencyViewModel = viewModel.currencyViewModelFor(currency: currency, side: side)
            view.viewModel = currencyViewModel
        }
    }

    private func updateNavigationBar() {
        updateLeftBarButtonItem()
        updateTitleView()
        updateExchangeBarButtonItem()
    }
    
    private func updateExchangeBarButtonItem() {
        exchangeBarButtonItem.isEnabled = viewModel.canExchange
    }
    
    private func updateLeftBarButtonItem() {
        navigationItem.leftBarButtonItem = viewModel.isLoadingError ? retryBarButtonItem : nil
    }
    
    private func updateTitleView() {
        navigationItem.titleView = viewModel.isLoading ? activityIndicator : nil
        if viewModel.isLoading {
            navigationItem.title = nil
        } else if viewModel.isLoadingError {
            navigationItem.title = "Loading error"
        } else {
            navigationItem.title = viewModel.exchangeRateString
        }
    }
    
    // MARK: UIKeyInput
    
    // Show the same type of keyboard as for the exchange amount textFields.
    var keyboardType: UIKeyboardType = .decimalPad
    
    // MARK: UITextInputTraits

    public var hasText: Bool {
        return false
    }

    public func insertText(_ text: String) {
        // empty
    }

    public func deleteBackward() {
        // emtpy
    }

    // MARK: UIResponder

    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: Private

    private func currencyViews(of side: ExchangeSide) -> [ExchangeCurrencyView] {
        switch side {
        case .from:
            return fromViews
        case .to:
            return toViews
        }
    }
    
    private func exchangeSide(of view: CarouselView) -> ExchangeSide? {
        if view === carouselViewFrom {
            return .from
        } else if view === carouselViewTo {
            return .to
        } else {
            assertionFailure()
            return nil
        }
    }

    private func exchangeSide(of view: ExchangeCurrencyView) -> ExchangeSide? {
        if fromViews.contains(view) {
            return .from
        } else if toViews.contains(view) {
            return .to
        } else {
            assertionFailure()
            return nil
        }
    }
}
