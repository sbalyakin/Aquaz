//
//  MultiProgressView.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 06.11.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

@IBDesignable class MultiProgressView: UIView {
  
  @IBInspectable var maximum: CGFloat = 1.0 { didSet { setNeedsDisplay() } }

  @IBInspectable var emptySectionColor: UIColor = UIColor.lightGrayColor() { didSet { emptySectionLayer.backgroundColor = emptySectionColor.CGColor } }
  
  @IBInspectable var borderColor: UIColor = UIColor.lightGrayColor() { didSet { layer.borderColor = borderColor.CGColor } }
  
  @IBInspectable var borderWidth: CGFloat = 0.5 { didSet { layer.borderWidth = borderWidth } }
  
  @IBInspectable var sectionsPadding: CGFloat = 2.0 { didSet { setNeedsDisplay() } }
  
  /// If sections' factor total is more than maximum, auto scale will be used
  @IBInspectable var autoOverloadScale: Bool = true { didSet { setNeedsDisplay() } }
  
  // 0.25 seconds is default animation time for iOS transitions
  @IBInspectable var animationDuration: Float = 0.25

  
  class Section {
    var factor: CGFloat = 0.0 { didSet { superLayer.setNeedsDisplay() } }
    var color: UIColor { didSet { layer.backgroundColor = color.CGColor } }
    
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

  override init(frame: CGRect) {
    super.init(frame: frame)
    baseInit()
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    baseInit()
  }

  private func baseInit() {
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
    super.prepareForInterfaceBuilder()

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
    return rect.rectByInsetting(dx: borderWidth + sectionsPadding, dy: borderWidth + sectionsPadding)
  }
  
  private func displaySections(rect: CGRect) {
    CATransaction.begin()
    
    if animationDuration <= 0 {
      CATransaction.setDisableActions(true)
    } else {
      CATransaction.setAnimationDuration(CFTimeInterval(animationDuration))
    }

    var displayedMaximum = maximum
    
    if autoOverloadScale {
      var factorsTotal: CGFloat = 0
      for section in sections {
        factorsTotal += section.factor
      }
      
      if factorsTotal > displayedMaximum {
        displayedMaximum = factorsTotal
      }
    }
    
    var factorsTotal: CGFloat = 0
    let scaleX = 1 / displayedMaximum * rect.width
    
    for (index, section) in enumerate(sections) {
      var x = rect.minX + trunc(factorsTotal * scaleX)
      var width = ceil(section.factor * scaleX)
      factorsTotal += section.factor

      if x > rect.maxX {
        x = rect.maxX
      }
      
      if x + width > rect.maxX {
        width = rect.maxX - x
      }
      
      let sectionRect = CGRect(x: x, y: rect.minY, width: width, height: rect.height)
      section.setFrame(sectionRect)
    }
    
    CATransaction.commit()
  }

  private var sections: [Section] = []
  private var emptySectionLayer: CAShapeLayer!
}
