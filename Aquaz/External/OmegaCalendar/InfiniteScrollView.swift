//
//  InfiniteScrollView.swift
//  OmegaCalendar
//
//  Created by Sergey Balyakin on 15.03.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import Foundation
import UIKit


protocol InfiniteScrollViewDataSource: class {
  
  func infiniteScrollViewNeedsPage(index: Int) -> UIView
  
}

protocol InfiniteScrollViewDelegate: class {
  
  func infiniteScrollViewPageCanBeRemoved(index: Int, view: UIView?)
  
  func infiniteScrollViewPageWasSwitched(pageIndex: Int)
  
}

class InfiniteScrollView: UIView {

  weak var dataSource: InfiniteScrollViewDataSource? {
    didSet {
      initPages()
      layoutPages()
    }
  }
  
  weak var delegate: InfiniteScrollViewDelegate?

  /// Number of side pages laying next to current page
  var sidePagesCount = 5 {
    didSet {
      initPages()
      layoutPages()
    }
  }
  
  /// Number of side pages laying next to current page, which are always loaded
  var loadedSidePagesCount = 1 {
    didSet {
      initPages()
      layoutPages()
    }
  }
  
  var pagesCount: Int {
    return 1 + sidePagesCount * 2
  }

  fileprivate var scrollView: UIScrollView!
  fileprivate var pages = [Int: UIView]()
  fileprivate var currentIndex: Int = 0 {
    didSet {
      delegate?.infiniteScrollViewPageWasSwitched(pageIndex: currentIndex)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    baseInit()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    baseInit()
  }
  
  fileprivate func baseInit() {
    scrollView = UIScrollView()
    scrollView.backgroundColor = UIColor.clear
    scrollView.scrollsToTop = false
    scrollView.isPagingEnabled = true
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.showsVerticalScrollIndicator = false
    scrollView.bounces = false
    scrollView.delegate = self
    addSubview(scrollView)
  }

  deinit {
    // It prevents EXC_BAD_ACCESS on deferred animation
    scrollView?.delegate = nil
  }
  
  func refresh() {
    removePages()
    initPages()
    layoutPages()
  }
  
  func switchToIndex(_ index: Int, animated: Bool) {
    if index == currentIndex {
      return
    }
    
    if abs(index - currentIndex) <= loadedSidePagesCount {
      let contentOffset = calcContentOffsetByIndex(index)
      scrollView.setContentOffset(contentOffset, animated: animated)
    } else {
      currentIndex = index
      initPages()
      setNeedsLayout()
    }
  }
  
  func switchForward(pageNumbers: Int, animated: Bool) {
    switchToIndex(currentIndex + pageNumbers, animated: animated)
  }
  
  func switchToNextPage(animated: Bool) {
    switchToIndex(currentIndex + 1, animated: animated)
  }
  
  func switchToPreviousPage(animated: Bool) {
    switchToIndex(currentIndex - 1, animated: animated)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    scrollView.frame = bounds
    scrollView.contentSize = CGSize(width: bounds.width * CGFloat(pagesCount), height: bounds.height)
    
    layoutPages()
    
    adjustContentOffsetToCurrentIndex()
  }
  
  fileprivate func layoutPages() {
    for (index, view) in pages {
      layoutPageWithIndex(index, view: view)
    }
    
    adjustContentOffsetToCurrentIndex()
  }
  
  fileprivate func layoutPageWithIndex(_ index: Int, view: UIView) {
    let origin = calcContentOffsetByIndex(index)
    let rect = CGRect(origin: origin, size: scrollView.frame.size)
    view.frame = rect
  }

  fileprivate func calcContentOffsetByIndex(_ index: Int) -> CGPoint {
    let offsetIndex = index - currentIndex + sidePagesCount
    return CGPoint(x: CGFloat(offsetIndex) * scrollView.frame.width, y: 0)
  }
  
  fileprivate func adjustContentOffsetToCurrentIndex() {
    // Setting contentOffset affects calling scrollViewDidScroll, so reset scroll view's delegate temporarily to avoid that
    scrollView.delegate = nil
    scrollView.contentOffset = CGPoint(x: scrollView.frame.width * CGFloat(sidePagesCount), y: 0)
    scrollView.delegate = self
  }
  
  fileprivate func obtainPageByIndex(_ index: Int) -> UIView? {
    return dataSource?.infiniteScrollViewNeedsPage(index: index)
  }
  
  fileprivate func calcPageIndexFromContentOffset(_ contentOffset: CGPoint) -> Int {
    let orderIndex = Int(contentOffset.x / scrollView.frame.width)
    return orderIndex - sidePagesCount + currentIndex
  }
  
  fileprivate func initPages() {
    var newPages = [Int: UIView]()
    
    for index in currentIndex - loadedSidePagesCount ... currentIndex + loadedSidePagesCount {
      var page = pages.removeValue(forKey: index)
      if page == nil {
        page = obtainPageByIndex(index)
      }
      
      if let page = page {
        scrollView.addSubview(page)
        newPages[index] = page
      }
    }
    
    // Remove rest of views from the scroll view
    removePages()
    
    pages = newPages
  }
  
  fileprivate func removePages() {
    for (index, page) in pages {
      delegate?.infiniteScrollViewPageCanBeRemoved(index: index, view: page)
      page.removeFromSuperview()
    }
    
    pages.removeAll(keepingCapacity: false)
  }
  
}

extension InfiniteScrollView: UIScrollViewDelegate {

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    var pageIndex = calcPageIndexFromContentOffset(scrollView.contentOffset)
    
    let velocity = scrollView.panGestureRecognizer.velocity(in: scrollView).x
    if velocity < 0 {
      pageIndex += 1
    }
    
    if pages[pageIndex] == nil {
      if let page = obtainPageByIndex(pageIndex) {
        pages[pageIndex] = page
        layoutPageWithIndex(pageIndex, view: page)
        scrollView.layer.addSublayer(page.layer)
      }
    }
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let deltaIndex = Int(scrollView.contentOffset.x / scrollView.frame.width) - sidePagesCount
    
    if deltaIndex == 0 {
      adjustContentOffsetToCurrentIndex()
      return
    }
    
    currentIndex += deltaIndex
    
    initPages()
    layoutPages()
  }
  
  func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    let deltaIndex = Int(scrollView.contentOffset.x / scrollView.frame.width) - sidePagesCount
    
    if deltaIndex == 0 {
      adjustContentOffsetToCurrentIndex()
      return
    }
    
    currentIndex += deltaIndex
    
    initPages()
    layoutPages()
  }
}
