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
  
  override var backgroundColor: UIColor! {
    didSet {
      contentView.backgroundColor = backgroundColor
      backgroundView?.backgroundColor = backgroundColor
      label?.backgroundColor = backgroundColor
    }
  }

  func setText(text: String, calendarContentView: CalendarContentView) {
    if label == nil {
      label = UILabel(frame: contentView.bounds)
      label.backgroundColor = backgroundColor
      label.userInteractionEnabled = false
      label.font = calendarContentView.weekDayFont
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