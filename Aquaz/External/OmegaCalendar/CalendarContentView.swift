//
//  CalendarContentView.swift
//  OmegaCalendar
//
//  Created by Sergey Balyakin on 17.03.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import Foundation
import UIKit

protocol CalendarViewContentDataSource: class {
  func createCalendarViewDaysInfoForMonth(#calendarContentView: CalendarContentView, monthDate: NSDate) -> [CalendarViewDayInfo]
}

class CalendarContentView: UIView {
  
  var font: UIFont = UIFont.systemFontOfSize(16)
  var weekDayTitleTextColor: UIColor = UIColor.blackColor()
  var weekDayTitlesHeightScale: CGFloat = 1
  var weekDayFont: UIFont = UIFont.systemFontOfSize(14)
  var workDayTextColor: UIColor = UIColor.blackColor()
  var workDayBackgroundColor: UIColor = UIColor.clearColor()
  var weekendTextColor: UIColor = UIColor.redColor()
  var weekendBackgroundColor: UIColor = UIColor.clearColor()
  var todayTextColor: UIColor = UIColor.whiteColor()
  var todayBackgroundColor: UIColor = UIColor.redColor()
  var selectedDayTextColor: UIColor = UIColor.blueColor()
  var selectedDayBackgroundColor: UIColor = UIColor.clearColor()
  var anotherMonthTransparency: CGFloat = 0.4
  var futureDaysTransparency: CGFloat = 0.4
  var futureDaysEnabled: Bool = false
  var dayRowHeightScale: CGFloat = 1
  var markSelectedDay: Bool = true

  var selectedDate: NSDate? { didSet { collectionView?.reloadData() } }
  
  var date: NSDate = NSDate() {
    didSet {
      daysInfo = dataSource?.createCalendarViewDaysInfoForMonth(calendarContentView: self, monthDate: date) ?? []
      collectionView?.reloadData()
    }
  }
  
  weak var dataSource: CalendarViewContentDataSource?
  weak var delegate: CalendarViewDelegate?
  
  var collectionView: UICollectionView!
  var daysInfo = [CalendarViewDayInfo]()
  
  private let calendar = NSCalendar.currentCalendar()
  private let daysPerWeek = NSCalendar.currentCalendar().maximumRangeOfUnit(.CalendarUnitWeekday).length
  private let dayTitles = NSCalendar.currentCalendar().veryShortWeekdaySymbols as! [String]
  
  private struct Constants {
    static let cellIdentifier = "Cell"
    static let titleCellIdentifier = "Title Cell"
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
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 0
    layout.minimumInteritemSpacing = 0

    collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.backgroundColor = UIColor.clearColor()
    collectionView.registerClass(CalendarContentViewCell.self, forCellWithReuseIdentifier: Constants.cellIdentifier)
    collectionView.registerClass(CalendarContentViewTitleCell.self, forCellWithReuseIdentifier: Constants.titleCellIdentifier)
    
    addSubview(collectionView)
  }
  
  deinit {
    // It prevents EXC_BAD_ACCESS on deferred reloading the collection view
    collectionView?.delegate = nil
    collectionView?.dataSource = nil
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    collectionView?.frame = bounds
  }
  
}

extension CalendarContentView: UICollectionViewDataSource {
  
  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 2
  }

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    switch section {
    case 0: return dayTitles.count
    case 1: return daysInfo.count
    default:
      assert(false)
      return 0
    }
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    switch indexPath.section {
    case 0: return getTitleCell(collectionView: collectionView, indexPath: indexPath)
    case 1: return getCell(collectionView: collectionView, indexPath: indexPath)
    default:
      assert(false)
      return UICollectionViewCell()
    }
  }
  
  func getCell(#collectionView: UICollectionView, indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.cellIdentifier, forIndexPath: indexPath) as! CalendarContentViewCell

    cell.backgroundColor = backgroundColor // remove blending
    cell.setDayInfo(daysInfo[indexPath.row], calendarContentView: self)

    return cell
  }

  func getTitleCell(#collectionView: UICollectionView, indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.titleCellIdentifier, forIndexPath: indexPath) as! CalendarContentViewTitleCell
    
    let weekDayIndex = (indexPath.row + calendar.firstWeekday - 1) % daysPerWeek

    cell.backgroundColor = backgroundColor // remove blending
    cell.setText(dayTitles[weekDayIndex], calendarContentView: self)
    
    return cell
  }

}

extension CalendarContentView: UICollectionViewDelegateFlowLayout {
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    let layout = collectionViewLayout as! UICollectionViewFlowLayout
    let contentWidth = collectionView.bounds.width - layout.minimumInteritemSpacing * CGFloat(daysPerWeek - 1)
    let cellWidth = trunc(contentWidth / CGFloat(daysPerWeek))
    let cellHeight = cellWidth * (indexPath.section == 0 ? weekDayTitlesHeightScale : dayRowHeightScale)
    let size = CGSize(width: cellWidth, height: cellHeight)
    return size
  }
  
}

extension CalendarContentView: UICollectionViewDelegate {
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? CalendarContentViewCell {
      let dayInfo = cell.getDayInfo()
      
      if !futureDaysEnabled && dayInfo.isFuture {
        return
      }
      
      if markSelectedDay {
        selectedDate = dayInfo.date
      }
      
      delegate?.calendarViewDaySelected(dayInfo)
      
      if markSelectedDay {
        collectionView.reloadData()
      }
    }
  }

}
