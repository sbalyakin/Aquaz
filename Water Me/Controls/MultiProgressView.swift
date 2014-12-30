//
//  MultiProgressView.swift
//  Water Me
//
//  Created by Sergey Balyakin on 06.11.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

@IBDesignable class MultiProgressView: UIView {
  
  @IBInspectable var maximum: CGFloat = 1.0 {
    didSet {
      setNeedsDisplay()
    }
  }

  var animationDuration = 0.2

  class Section {
    var factor: CGFloat = 0.0
    var color: UIColor
    private var layer: CALayer
    
    init(color: UIColor, layer: CALayer) {
      self.color = color
      self.layer = layer
    }
    
    private var _shapeLayer: CAShapeLayer!
    private var shapeLayer: CAShapeLayer {
      if _shapeLayer == nil {
        createShapeLayer()
      }
      return _shapeLayer
    }

    private func createShapeLayer() {
      _shapeLayer = CAShapeLayer(layer: layer)
      _shapeLayer.fillColor = color.CGColor
      _shapeLayer.lineWidth = 0
      layer.addSublayer(_shapeLayer)
    }
  }

  func addSection(#color: UIColor) -> Section {
    let section = Section(color: color, layer: layer)
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
    let rectWidth = rect.width
    let rectRight = rect.maxX
    var left = rect.minX
    var isLast = false
    
    // Draw the background
    if backgroundColor != nil {
      let backgroundPath = UIBezierPath(rect: rect)
      backgroundColor!.setFill()
      backgroundPath.fill()
    }
    
    for section in sections {
      // Compute section bounds
      var width = trunc(section.factor / maximum * rectWidth)
      if left + width > rectRight {
        width = rectRight - left
        isLast = true
      }
      
      // Draw section
      let sectionRect = CGRectMake(left, rect.minY, width, rect.maxY)
      let sectionPath = UIBezierPath(rect: sectionRect)
      section.shapeLayer.frame = sectionRect
      section.shapeLayer.bounds = sectionRect
      transformShape(section.shapeLayer, path: sectionPath.CGPath, useAnimation: true)
      
      if isLast {
        break
      }
      
      left += width
    }
  }
  
  private func transformShape(shape: CAShapeLayer, path: CGPath, useAnimation: Bool) {
    if useAnimation {
      let animation = CABasicAnimation(keyPath: "path")
      animation.duration = animationDuration
      animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
      animation.fromValue = shape.path
      shape.path = path
      animation.toValue = shape.path
      shape.addAnimation(animation, forKey: nil)
    } else {
      shape.path = path
    }
  }

  private var sections: [Section] = []
  
}
