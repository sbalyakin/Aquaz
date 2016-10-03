//
//  CalendarContentViewTitleCell.swift
//  OmegaCalendar
//
//  Created by Sergey Balyakin on 17.03.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import Foundation
import UIKit

class CalendarContentViewTitleCell: UICollectionViewCell {
  
  fileprivate var label: UILabel!
  
  override var backgroundColor: UIColor! {
    didSet {
      contentView.backgroundColor = backgroundColor
      backgroundView?.backgroundColor = backgroundColor
      label?.backgroundColor = backgroundColor
    }
  }

  func setText(_ text: String, calendarContentView: CalendarContentView) {
    if label == nil {
      label = UILabel(frame: contentView.bounds)
      label.backgroundColor = backgroundColor
      label.isUserInteractionEnabled = false
      label.font = calendarContentView.weekDayFont
      label.textAlignment = .center
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
