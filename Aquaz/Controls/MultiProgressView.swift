//
//  MultiProgressView.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 06.11.14.
//  Copyright © 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

@IBDesignable
@objc(MultiProgressView)
class MultiProgressView: UIView {
  
  @IBInspectable var maximum: CGFloat = 1.0 { didSet { layoutSections() } }

  @IBInspectable var emptySectionColor: UIColor = UIColor.lightGrayColor() { didSet { emptySectionLayer?.backgroundColor = emptySectionColor.CGColor } }
  
  @IBInspectable var borderColor: UIColor = UIColor.lightGrayColor() { didSet { layer.borderColor = borderColor.CGColor } }
  
  @IBInspectable var borderWidth: CGFloat = 0.5 {
    didSet {
      layer.borderWidth = borderWidth
      setNeedsLayout()
    }
  }
  
  @IBInspectable var sectionsPadding: CGFloat = 2.0 { didSet { setNeedsLayout() } }
  
  /// If sections' factor total is more than maximum, auto scale will be used
  @IBInspectable var autoOverloadScale: Bool = true { didSet { setNeedsLayout() } }
  
  // 0.25 seconds is default animation time for iOS transitions
  @IBInspectable var animationDuration: Float = 0.25

  
  class Section {
    var factor: CGFloat = 0.0 { didSet { multiProgressView?.layoutSections() } }

    var color: UIColor {
      didSet {
        view.backgroundColor = color
      }
    }

    private weak var multiProgressView: MultiProgressView!
    private var view: UIView

    init(color: UIColor, multiProgressView: MultiProgressView) {
      self.color = color
      self.multiProgressView = multiProgressView

      view = UIView()
      view.backgroundColor = color
      multiProgressView.addSubview(view)
    }
    
    deinit {
      view.removeFromSuperview()
    }

    func setFactorWithAnimation(factor: CGFloat) {
      multiProgressView?.updateWithAnimation {
        self.factor = factor
      }
    }

    func setFrame(rect: CGRect) {
      view.frame = rect
    }

  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    baseInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    baseInit()
  }

  private func baseInit() {
    clipsToBounds = true
    translatesAutoresizingMaskIntoConstraints = false
    layer.borderColor = borderColor.CGColor
    layer.borderWidth = borderWidth
    setupEmptySection()
  }
  
  private func setupEmptySection() {
    emptySectionLayer = CALayer()
    emptySectionLayer.backgroundColor = emptySectionColor.CGColor
    layer.addSublayer(emptySectionLayer)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    layoutEmptySection()
    layoutSections()
  }

  private func layoutEmptySection() {
    let sectionsRect = calcSectionsRect(bounds)
    emptySectionLayer.frame = sectionsRect
    emptySectionLayer.bounds = sectionsRect
  }
  
  private func layoutSections() {
    if isBulkUpdating {
      return
    }

    let rect = calcSectionsRect(bounds)
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
    
    for section in sections {
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
  }
  
  @available(iOS 8.0, *)
  override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()

    // Initialize values with some predefined values in order to show in Interface Builder
    update {
      self.addSection(color: UIColor.redColor()).factor = 0.2
      self.addSection(color: UIColor.greenColor()).factor = 0.3
      self.addSection(color: UIColor.blueColor()).factor = 0.4
    }
  }

  func addSection(color color: UIColor) -> Section {
    let section = Section(color: color, multiProgressView: self)
    sections.append(section)
    setNeedsLayout()
    return section
  }
  
  func removeSection(index index: Int) {
    sections.removeAtIndex(index)
    setNeedsLayout()
  }
  
  func getSection(index index: Int) -> Section {
    return sections[index]
  }

  func update(updateFunction: () -> Void) {
    if isBulkUpdating {
      updateFunction()
      return
    }

    isBulkUpdating = true
    updateFunction()
    isBulkUpdating = false
    layoutSections()
  }

  func updateWithAnimation(updateFunction: () -> Void) {
    if isBulkUpdating {
      updateFunction()
      return
    }
    
    isBulkUpdating = true
    updateFunction()
    isBulkUpdating = false
    
    UIView.animateWithDuration(NSTimeInterval(animationDuration),
      delay: 0,
      usingSpringWithDamping: 0.5,
      initialSpringVelocity: 0,
      options: [],
      animations: {
        self.layoutSections()
      }, completion: nil)

  }
  
  private func calcSectionsRect(rect: CGRect) -> CGRect {
    return rect.insetBy(dx: borderWidth + sectionsPadding, dy: borderWidth + sectionsPadding)
  }
  
  private var isBulkUpdating = false
  private var sections: [Section] = []
  private var emptySectionLayer: CALayer!
}
