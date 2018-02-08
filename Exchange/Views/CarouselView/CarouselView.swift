//
//  CarouselView.swift
//  Exchange
//
//  Created by t.galimov on 05/02/2018.
//

import UIKit

protocol CarouselViewDelegate: class {
    func carouselViewDidBeginScrolling(_ carouselView: CarouselView)
    func carouselView(_ carouselView: CarouselView, didTransitionToIndex index: Int)
}

// Attempting to implement my own solution for the carousel view via
// UIPageViewController or UICollectionView with paging required
// some sort of hack in order to work properly. UIPageViewController required a workaround
// of async dispatching onto the next loop in order to make a UITextField become
// first responder or set an initial controller (http://www.openradar.me/23897240,
// https://stackoverflow.com/a/21069878/3445458 ). UICollectionView
// required returning a huge number of items from the dataSource,
// protecting against page boundary breaking on resize and others.

// So, I ended up using this third party solution that utilizes a
// custom UICollectionViewLayout. It seems to avoid using tough
// hacks and to work okay.

class CarouselView: UIView, FSPagerViewDataSource, FSPagerViewDelegate {
    
    private var pagerView: FSPagerView!

    private var pageControl: UIPageControl!
    private let pageControlHeight: CGFloat = 36
    
    private var views: [UIView]!
    
    weak var delegate: CarouselViewDelegate?
    
    // MARK: Public
    
    func setup(swipeableViews: [UIView], initialIndex: Int = 0) {
        assert(views == nil, "setup(swipeableViews:initialIndex:) can be called only once")
        assert(swipeableViews.count > 1, "swipeableViews.count must be greater than 1")
        assert(0 <= initialIndex, "initialIndex must be non-negative")
        assert(initialIndex < swipeableViews.count, "initialIndex must be less than swipeableViews.count")
        views = swipeableViews
        setupPagerView(currentIndex: initialIndex)
        setupPageControl(currentIndex: initialIndex)
    }
    
    func scrollToNextItem() {
        delegate?.carouselViewDidBeginScrolling(self)
        let newIndex = (pagerView.currentIndex + 1) % views.count
        pagerView.scrollToItem(at: newIndex, animated: true)
        // delegate's carouselView(_ carouselView:, didTransitionToIndex index: Int)
        // method is called in pagerViewDidEndScrollAnimation
    }
    
    // MARK: Setup
    
    private func setupPageControl(currentIndex: Int) {
        assert(views != nil)
        pageControl = UIPageControl()
        pageControl.frame = CGRect(x: 0, y: bounds.height - pageControlHeight, width: bounds.width, height: pageControlHeight)
        pageControl.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        addSubview(pageControl)
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .darkGray
        pageControl.numberOfPages = views.count
        pageControl.currentPage = currentIndex
    }
    
    private func setupPagerView(currentIndex: Int) {
        assert(views != nil)
        pagerView = FSPagerView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height - pageControlHeight))
        pagerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(pagerView)
        pagerView.isInfinite = true
        pagerView.register(CarouselCell.self)
        pagerView.delegate = self
        pagerView.dataSource = self
        pagerView.currentIndex = currentIndex
    }
    
    // MARK: FSPagerViewDataSource
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return views.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeue(CarouselCell.self, at: index)
        let view = views[index]
        if !cell.contains(view: view) {
            cell.removeView()
            cell.add(view: view)
        }
        return cell
    }
    
    // MARK: FSPagerViewDelegate
    
    func pagerViewWillBeginDragging(_ pagerView: FSPagerView) {
        delegate?.carouselViewDidBeginScrolling(self)
    }
    
    func pagerViewDidEndDecelerating(_ pagerView: FSPagerView) {
        updatePageControlAndNotifyOfTransition()
    }
    
    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        updatePageControlAndNotifyOfTransition()
    }
    
    private func updatePageControlAndNotifyOfTransition() {
        pageControl.currentPage = pagerView.currentIndex
        delegate?.carouselView(self, didTransitionToIndex: pagerView.currentIndex)
    }
}
