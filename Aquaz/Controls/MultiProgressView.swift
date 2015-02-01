//
//  MultiProgressView.swift
//  Aquaz
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

  @IBInspectable var emptySectionColor: UIColor = UIColor(red: 241/255, green: 241/255, blue: 242/255, alpha: 1) {
    didSet {
      setNeedsDisplay()
    }
  }
  
  @IBInspectable var borderColor: UIColor = UIColor(red: 167/255, green: 169/255, blue: 171/255, alpha: 0.8) {
    didSet {
      setNeedsDisplay()
    }
  }
  
  @IBInspectable var borderWidth: CGFloat = 1.0 {
    didSet {
      setNeedsDisplay()
    }
  }
  
  @IBInspectable var sectionsPading: CGFloat = 4.0 {
    didSet {
      setNeedsDisplay()
    }
  }
  
  // 0.25 seconds is default animation time for iOS transitions
  @IBInspectable var animationDuration: Float = 0.25

  class Section {
    var factor: CGFloat = 0.0 {
      didSet {
        superLayer.setNeedsDisplay()
      }
    }
    
    var color: UIColor {
      didSet {
        layer.backgroundColor = color.CGColor
      }
    }
    
    
    init(color: UIColor, superLayer: CALayer) {
      self.color = color
      self.superLayer = superLayer

      layer = CALayer(layer: superLayer)
      layer.backgroundColor = color.CGColor
      superLayer.addSublayer(layer)
    }
    
    deinit {
      layer.removeFromSuperlayer()
    }
    
    func setFrame(rect: CGRect) {
      layer.frame = rect
    }

    private var superLayer: CALayer
    private var layer: CALayer
  }

  override init() {
    super.init()
    initSubLayers()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    initSubLayers()
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initSubLayers()
  }

  private func initSubLayers() {
    layer.borderColor = borderColor.CGColor
    layer.borderWidth = borderWidth
    
    let sectionsRect = calcSectionsRect(layer)
    emptySectionLayer = CAShapeLayer(layer: layer)
    emptySectionLayer.backgroundColor = emptySectionColor.CGColor
    emptySectionLayer.frame = sectionsRect
    emptySectionLayer.bounds = sectionsRect
    layer.addSublayer(emptySectionLayer)
  }
  
  override func layoutSublayersOfLayer(layer: CALayer!) {
    let sectionsRect = calcSectionsRect(layer)
    emptySectionLayer.frame = sectionsRect
    emptySectionLayer.bounds = sectionsRect
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
    let section = Section(color: color, superLayer: layer)
    sections.append(section)
    return section
  }
  
  func removeSection(#index: Int) {
    sections.removeAtIndex(index)
  }
  
  func getSection(#index: Int) -> Section {
    return sections[index]
  }
  
  override func displayLayer(layer: CALayer!) {
    let sectionsRect = calcSectionsRect(layer)
    displaySections(sectionsRect)
  }
  
  private func calcSectionsRect(layer: CALayer) -> CGRect {
    let rect = layer.bounds
    return rect.rectByInsetting(dx: borderWidth + sectionsPading, dy: borderWidth + sectionsPading)
  }
  
  private func displaySections(rect: CGRect) {
    let rectWidth = rect.width
    let rectRight = rect.maxX
    var left = rect.minX

    CATransaction.begin()
    
    if animationDuration <= 0 {
      CATransaction.setDisableActions(true)
    } else {
      CATransaction.setAnimationDuration(CFTimeInterval(animationDuration))
    }

    for section in sections {
      var width = trunc(section.factor / maximum * rectWidth)
      if left + width > rectRight {
        width = rectRight - left
      }
      
      let sectionRect = CGRect(x: left, y: rect.minY, width: width, height: rect.height)
      section.setFrame(sectionRect)

      left += width
    }
    
    CATransaction.commit()
  }

  private var sections: [Section] = []
  private var emptySectionLayer: CAShapeLayer!
}
