//
//  CalendarContentView.swift
//  OmegaCalendar
//
//  Created by Sergey Balyakin on 17.03.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import Foundation
import UIKit

protocol CalendarViewContentDataSource: class {
  func createCalendarViewDaysInfoForMonth(calendarContentView: CalendarContentView, monthDate: Date) -> [CalendarViewDayInfo]
}

class CalendarContentView: UIView {
  
  var font: UIFont = UIFont.systemFont(ofSize: 16)
  var weekDayTitleTextColor: UIColor = UIColor.black
  var weekDayTitlesHeightScale: CGFloat = 1
  var weekDayFont: UIFont = UIFont.systemFont(ofSize: 14)
  var workDayTextColor: UIColor = UIColor.black
  var workDayBackgroundColor: UIColor = UIColor.clear
  var weekendTextColor: UIColor = UIColor.red
  var weekendBackgroundColor: UIColor = UIColor.clear
  var todayTextColor: UIColor = UIColor.white
  var todayBackgroundColor: UIColor = UIColor.red
  var selectedDayTextColor: UIColor = UIColor.blue
  var selectedDayBackgroundColor: UIColor = UIColor.clear
  var anotherMonthTransparency: CGFloat = 0.4
  var futureDaysTransparency: CGFloat = 0.4
  var futureDaysEnabled: Bool = false
  var dayRowHeightScale: CGFloat = 1
  var markSelectedDay: Bool = true

  var selectedDate: Date? { didSet { collectionView?.reloadData() } }
  
  var date: Date = Date() {
    didSet {
      daysInfo = dataSource?.createCalendarViewDaysInfoForMonth(calendarContentView: self, monthDate: date) ?? []
      collectionView?.reloadData()
    }
  }
  
  weak var dataSource: CalendarViewContentDataSource?
  weak var delegate: CalendarViewDelegate?
  
  var collectionView: UICollectionView!
  var daysInfo = [CalendarViewDayInfo]()
  
  fileprivate let calendar = Calendar.current
  fileprivate let daysPerWeek = DateHelper.daysPerWeek()
  fileprivate let dayTitles = Calendar.current.veryShortWeekdaySymbols
  
  fileprivate struct Constants {
    static let cellIdentifier = "Cell"
    static let titleCellIdentifier = "Title Cell"
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
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 0
    layout.minimumInteritemSpacing = 0

    collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.backgroundColor = UIColor.clear
    collectionView.register(CalendarContentViewCell.self, forCellWithReuseIdentifier: Constants.cellIdentifier)
    collectionView.register(CalendarContentViewTitleCell.self, forCellWithReuseIdentifier: Constants.titleCellIdentifier)
    
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

  // Moved here from extension CalendarContentView: UICollectionViewDataSource because
  // this method is overriden in descendants. It's prohibited to override methods declared in extensions.
  func getCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as! CalendarContentViewCell
    
    cell.backgroundColor = backgroundColor // remove blending
    cell.setDayInfo(daysInfo[(indexPath as NSIndexPath).row], calendarContentView: self)
    
    return cell
  }
  
}

extension CalendarContentView: UICollectionViewDataSource {
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 2
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    switch section {
    case 0: return dayTitles.count
    case 1: return daysInfo.count
    default:
      assert(false)
      return 0
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    switch (indexPath as NSIndexPath).section {
    case 0: return getTitleCell(collectionView: collectionView, indexPath: indexPath)
    case 1: return getCell(collectionView: collectionView, indexPath: indexPath)
    default:
      assert(false)
      return UICollectionViewCell()
    }
  }
  
  func getTitleCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.titleCellIdentifier, for: indexPath) as! CalendarContentViewTitleCell
    
    let weekDayIndex = ((indexPath as NSIndexPath).row + calendar.firstWeekday - 1) % daysPerWeek

    cell.backgroundColor = backgroundColor // remove blending
    cell.setText(dayTitles[weekDayIndex], calendarContentView: self)
    
    return cell
  }

}

extension CalendarContentView: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let layout = collectionViewLayout as! UICollectionViewFlowLayout
    let contentWidth = collectionView.bounds.width - layout.minimumInteritemSpacing * CGFloat(daysPerWeek - 1)
    let cellWidth = trunc(contentWidth / CGFloat(daysPerWeek))
    let cellHeight = cellWidth * ((indexPath as NSIndexPath).section == 0 ? weekDayTitlesHeightScale : dayRowHeightScale)
    let size = CGSize(width: cellWidth, height: cellHeight)
    return size
  }
  
}

extension CalendarContentView: UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if let cell = collectionView.cellForItem(at: indexPath) as? CalendarContentViewCell {
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
