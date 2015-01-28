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

  @IBInspectable var emptySectionColor: UIColor = UIColor(red: 241/255, green: 241/255, blue: 242/255, alpha: 1)
  @IBInspectable var borderColor: UIColor = UIColor(red: 167/255, green: 169/255, blue: 171/255, alpha: 0.8)
  @IBInspectable var borderWidth: CGFloat = 1.0
  @IBInspectable var sectionsPading: CGFloat = 4.0
  
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

  override func prepareForInterfaceBuilder() {
    // Initialize values with some predefined values in order to show in Interface Builder
    let section1 = addSection(color: UIColor.redColor())
    section1.factor = 0.2
    let section2 = addSection(color: UIColor.greenColor())
    section2.factor = 0.3
    let section3 = addSection(color: UIColor.blueColor())
    section3.factor = 0.4
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
    drawBackground(rect)

    let sectionsRect = rect.rectByInsetting(dx: borderWidth + sectionsPading, dy: borderWidth + sectionsPading)
    drawSections(sectionsRect)
  }
  
  private func drawBackground(rect: CGRect) {
    // Draw the background
    let backgroundPath = UIBezierPath(rect: rect)
    backgroundColor!.setFill()
    backgroundPath.fill()
    backgroundPath.lineWidth = borderWidth
    borderColor.setStroke()
    backgroundPath.stroke()
  }
  
  private func drawSections(rect: CGRect) {
    let rectWidth = rect.width
    let rectRight = rect.maxX
    var left = rect.minX
    var isLast = false

    for section in sections {
      // Compute section bounds
      var width = trunc(section.factor / maximum * rectWidth)
      if left + width > rectRight {
        width = rectRight - left
        isLast = true
      }
      
      // Draw section
      let sectionRect = CGRect(x: left, y: rect.minY, width: width, height: rect.height)
      let sectionPath = UIBezierPath(rect: sectionRect)
      section.shapeLayer.frame = sectionRect
      section.shapeLayer.bounds = sectionRect
      transformShape(section.shapeLayer, path: sectionPath.CGPath, useAnimation: true)
      
      if isLast {
        break
      }
      
      left += width
    }

    // Draw empty section if it's necessary
    if left < rectRight {
      let width = rectRight - left
      let rect = CGRect(x: left, y: rect.minY, width: width, height: rect.height)
      let path = UIBezierPath(rect: rect)
      emptySectionColor.setFill()
      path.fill()
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
