//
//  MonthStatisticsContentView.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 17.03.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import Foundation
import UIKit

class MonthStatisticsContentView: CalendarContentView {
  
  var dayIntakeColor: UIColor = UIColor.orange
  var dayIntakeFullColor: UIColor = UIColor(red: 80/255, green: 184/255, blue: 187/255, alpha: 1.0)
  var dayIntakeBackgroundColor: UIColor = UIColor(red: 80/255, green: 184/255, blue: 187/255, alpha: 0.1)
  var dayIntakeLineWidth: CGFloat = 4

  fileprivate struct Constants {
    static let statisticsCellIdentifier = "Statistics Cell"
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
    collectionView.register(MonthStatisticsContentViewCell.self, forCellWithReuseIdentifier: Constants.statisticsCellIdentifier)
  }
  
  override func getCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.statisticsCellIdentifier, for: indexPath) as! MonthStatisticsContentViewCell

    cell.backgroundColor = backgroundColor // remove blending
    cell.setDayInfo(daysInfo[(indexPath as NSIndexPath).row], calendarContentView: self)
    
    return cell
  }
  
  func updateValues(_ values: [Double]) {
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
