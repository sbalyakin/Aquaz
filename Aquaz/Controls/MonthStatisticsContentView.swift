//
//  MonthStatisticsContentView.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 17.03.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import Foundation
import UIKit

class MonthStatisticsContentView: CalendarContentView {
  
  var dayIntakeColor: UIColor = UIColor.orangeColor()
  var dayIntakeFullColor: UIColor = UIColor(red: 80/255, green: 184/255, blue: 187/255, alpha: 1.0)
  var dayIntakeBackgroundColor: UIColor = UIColor(red: 80/255, green: 184/255, blue: 187/255, alpha: 0.1)
  var dayIntakeLineWidth: CGFloat = 4

  private struct Constants {
    static let statisticsCellIdentifier = "Statistics Cell"
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
    collectionView.registerClass(MonthStatisticsContentViewCell.self, forCellWithReuseIdentifier: Constants.statisticsCellIdentifier)
  }
  
  override func getCell(#collectionView: UICollectionView, indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.statisticsCellIdentifier, forIndexPath: indexPath) as! MonthStatisticsContentViewCell

    cell.backgroundColor = backgroundColor // remove blending
    cell.setDayInfo(daysInfo[indexPath.row], calendarContentView: self)
    
    return cell
  }
  
  func updateValues(values: [Double]) {
    for dayInfo in daysInfo {
      if dayInfo.isCurrentMonth {
        let dayIndex = dayInfo.dayOfCurrentMonth - 1
        if dayIndex < values.count {
          dayInfo.userData = values[dayIndex]
        } else {
          assert(false)
        }
      }
    }
    
    collectionView.reloadData()
  }
}
