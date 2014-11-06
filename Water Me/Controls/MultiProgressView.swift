//
//  MultiProgressView.swift
//  Water Me
//
//  Created by Sergey Balyakin on 06.11.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

@IBDesignable class MultiProgressView: UIView {
  
  @IBInspectable var maximum: CGFloat = 1.0
  
  class Section {
    var factor: CGFloat = 0.0
    var color: UIColor
    
    init(color: UIColor) {
      self.color = color
    }
  }

  func addSection(#color: UIColor) -> Section {
    let section = Section(color: color)
    sections.append(section)
    return section
  }
  
  func removeSection(#index: Int) {
    sections.removeAtIndex(index)
  }
  
  func getSection(#index: Int) -> Section {
    return sections[index]
  }
  
  override func drawRect(rect: CGRect) {
    var left: CGFloat = rect.minX
    var isLast: Bool = false
    
    // Draw the background
    if backgroundColor != nil {
      let backgroundPath = UIBezierPath(rect: rect)
      backgroundColor!.setFill()
      backgroundPath.fill()
    }
    
    for section in sections {
      // Compute section bounds
      var width = section.factor / maximum * rect.width
      if left + width > rect.maxX {
        width = rect.maxX - left
        isLast = true
      }
      
      // Draw section
      let sectionPath = UIBezierPath(rect: CGRectMake(left, rect.minY, width, rect.maxY))
      section.color.setFill()
      sectionPath.fill()
      
      if isLast {
        break
      }
      
      left += width
    }
  }
  
  private var sections: [Section] = []
  
}
