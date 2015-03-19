//
//  CalendarContentViewTitleCell.swift
//  OmegaCalendar
//
//  Created by Sergey Balyakin on 17.03.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import Foundation
import UIKit

class CalendarContentViewTitleCell: UICollectionViewCell {
  
  private var label: UILabel!
  
  func setText(text: String, calendarContentView: CalendarContentView) {
    if label == nil {
      label = UILabel(frame: contentView.bounds)
      label.backgroundColor = UIColor.clearColor()
      label.userInteractionEnabled = false
      label.font = calendarContentView.font
      label.textAlignment = .Center
      label.textColor = calendarContentView.weekDayTitleTextColor
      contentView.addSubview(label)
    }
    
    label?.text = text
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    label?.frame = contentView.bounds
  }
  
}