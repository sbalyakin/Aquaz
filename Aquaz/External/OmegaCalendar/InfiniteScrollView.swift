//
//  InfiniteScrollView.swift
//  OmegaCalendar
//
//  Created by Sergey Balyakin on 15.03.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import Foundation
import UIKit


protocol InfiniteScrollViewDataSource: class {
  
  func infiniteScrollViewNeedsPage(#index: Int) -> UIView
  
}

protocol InfiniteScrollViewDelegate: class {
  
  func infiniteScrollViewPageCanBeRemoved(#index: Int, view: UIView?)
  
  func infinteScrollViewPageWasSwitched(#pageIndex: Int)
  
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

  private var scrollView: UIScrollView!
  private var pages = [Int: UIView]()
  private var currentIndex: Int = 0 {
    didSet {
      delegate?.infinteScrollViewPageWasSwitched(pageIndex: currentIndex)
    }
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    baseInit()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    baseInit()
  }
  
  private func baseInit() {
    scrollView = UIScrollView()
    scrollView.backgroundColor = UIColor.clearColor()
    scrollView.scrollsToTop = false
    scrollView.pagingEnabled = true
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.showsVerticalScrollIndicator = false
    scrollView.bounces = false
    scrollView.delegate = self
    addSubview(scrollView)
  }

  func refresh() {
    removePages()
    initPages()
    layoutPages()
  }
  
  func switchToIndex(index: Int, animated: Bool) {
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
  
  func switchForward(#pageNumbers: Int, animated: Bool) {
    switchToIndex(currentIndex + pageNumbers, animated: animated)
  }
  
  func switchToNextPage(#animated: Bool) {
    switchToIndex(currentIndex + 1, animated: animated)
  }
  
  func switchToPreviousPage(#animated: Bool) {
    switchToIndex(currentIndex - 1, animated: animated)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    scrollView.frame = bounds
    scrollView.contentSize = CGSize(width: bounds.width * CGFloat(pagesCount), height: bounds.height)
    
    layoutPages()
    
    adjustContentOffsetToCurrentIndex()
  }
  
  private func layoutPages() {
    for (index, view) in pages {
      layoutPageWithIndex(index, view: view)
    }
    
    adjustContentOffsetToCurrentIndex()
  }
  
  private func layoutPageWithIndex(index: Int, view: UIView) {
    let origin = calcContentOffsetByIndex(index)
    let rect = CGRect(origin: origin, size: scrollView.frame.size)
    view.frame = rect
  }

  private func calcContentOffsetByIndex(index: Int) -> CGPoint {
    let offsetIndex = index - currentIndex + sidePagesCount
    return CGPoint(x: CGFloat(offsetIndex) * scrollView.frame.width, y: 0)
  }
  
  private func adjustContentOffsetToCurrentIndex() {
    // Setting contentOffset affects calling scrollViewDidScroll, so reset scroll view's delegate temporarily to avoid that
    scrollView.delegate = nil
    scrollView.contentOffset = CGPoint(x: scrollView.frame.width * CGFloat(sidePagesCount), y: 0)
    scrollView.delegate = self
  }
  
  private func obtainPageByIndex(index: Int) -> UIView? {
    return dataSource?.infiniteScrollViewNeedsPage(index: index)
  }
  
  private func calcPageIndexFromContentOffset(contentOffset: CGPoint) -> Int {
    let orderIndex = Int(contentOffset.x / scrollView.frame.width)
    return orderIndex - sidePagesCount + currentIndex
  }
  
  private func initPages() {
    var newPages = [Int: UIView]()
    
    for index in currentIndex - loadedSidePagesCount ... currentIndex + loadedSidePagesCount {
      var page = pages.removeValueForKey(index)
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
  
  private func removePages() {
    for (index, page) in pages {
      delegate?.infiniteScrollViewPageCanBeRemoved(index: index, view: page)
      page.removeFromSuperview()
    }
    
    pages.removeAll(keepCapacity: false)
  }
  
}

extension InfiniteScrollView: UIScrollViewDelegate {

  func scrollViewDidScroll(scrollView: UIScrollView) {
    var pageIndex = calcPageIndexFromContentOffset(scrollView.contentOffset)
    
    let velocity = scrollView.panGestureRecognizer.velocityInView(scrollView).x
    if velocity < 0 {
      pageIndex++
    }
    
    if pages[pageIndex] == nil {
      if let page = obtainPageByIndex(pageIndex) {
        pages[pageIndex] = page
        layoutPageWithIndex(pageIndex, view: page)
        scrollView.layer.addSublayer(page.layer)
      }
    }
  }
  
  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    let deltaIndex = Int(scrollView.contentOffset.x / scrollView.frame.width) - sidePagesCount
    
    if deltaIndex == 0 {
      adjustContentOffsetToCurrentIndex()
      return
    }
    
    currentIndex += deltaIndex
    
    initPages()
    layoutPages()
  }
  
  func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
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