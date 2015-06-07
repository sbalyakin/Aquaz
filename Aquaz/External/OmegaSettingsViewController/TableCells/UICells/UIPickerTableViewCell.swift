//
//  UIPickerTableViewCell.swift
//  OmegaSettingsViewController
//
//  Created by Sergey Balyakin on 03.03.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

protocol UIPickerTableViewCellDataSource {
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String!
  func pickerView(pickerView: UIPickerView, titleForComponent: Int) -> String?
}

protocol UIPickerTableViewCellDelegate {
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
  func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat?
}

enum UIPickerViewHeight: CGFloat {
  case Small  = 162
  case Medium = 180
  case Large  = 216
}

class UIPickerTableViewCell: UITableViewCell {
  
  weak var pickerView: UIPickerView!
  
  var dataSource: UIPickerTableViewCellDataSource? {
    didSet {
      setupPickerView()
    }
  }
  
  var delegate: UIPickerTableViewCellDelegate?
  
  var pickerViewFont: UIFont = UIFont.systemFontOfSize(21) {
    didSet {
      setNeedsDisplay()
    }
  }
  
  init(reuseIdentifier: String? = nil) {
    super.init(style: .Default, reuseIdentifier: reuseIdentifier)
    baseInit()
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    baseInit()
  }
  
  private func baseInit() {
    selectionStyle = .None
    
    layer.zPosition = -1
    if self.pickerView == nil {
      let pickerView = UIPickerView()
      pickerView.backgroundColor = UIColor.clearColor()
      pickerView.dataSource = self
      pickerView.delegate = self
      contentView.addSubview(pickerView)
      contentView.sendSubviewToBack(pickerView)
      self.pickerView = pickerView
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    layoutPickerView()
  }
  
  private func setupPickerView() {
    for label in componentTitleLabels {
      label?.removeFromSuperview()
    }
    
    componentTitleLabels = []
    
    if dataSource == nil {
      return
    }
    
    for component in 0..<pickerView.numberOfComponents {
      let title = dataSource?.pickerView(pickerView, titleForComponent: component) ?? ""
      if !title.isEmpty {
        let titleLabel = UILabel()
        titleLabel.font = pickerViewFont
        titleLabel.text = title
        titleLabel.textColor = UIColor.blackColor()
        titleLabel.backgroundColor = UIColor.clearColor()
        titleLabel.sizeToFit()
        pickerView.addSubview(titleLabel)
        componentTitleLabels.append(titleLabel)
      } else {
        componentTitleLabels.append(nil)
      }
    }
  }
  
  private func layoutPickerView() {
    pickerView.frame = bounds
    pickerView.setNeedsLayout()

    let totalComponentGaps = pickerViewGapBetweenComponents * CGFloat(pickerView.numberOfComponents - 1)
    let totalComponentWidths = calcTotalWidthOfComponents()
    var x = (pickerView.bounds.width - totalComponentGaps - totalComponentWidths) / 2
    let midY = pickerView.bounds.midY
    
    for component in 0..<pickerView.numberOfComponents {
      if let label = componentTitleLabels[component] {
        let componentTitle = dataSource?.pickerView(pickerView, titleForComponent: component) ?? ""
        let componentTitleSize = computeSizeForText(componentTitle, font: pickerViewFont)
        let componentSize = pickerView.rowSizeForComponent(component)
        let labelMinX = x + componentSize.width - componentTitleSize.width
        let labelMinY = midY - componentTitleSize.height / 2
        
        label.frame.origin = CGPoint(x: labelMinX, y: labelMinY)
        
        x += componentSize.width + pickerViewGapBetweenComponents
      } else {
        x += pickerViewGapBetweenComponents
      }
    }
  }

  private func computeSizeForText(text: String, font: UIFont) -> CGSize {
    let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
    let fontAttributes = [NSFontAttributeName: font, NSParagraphStyleAttributeName: textStyle]
    let infiniteSize = CGSize(width: CGFloat.infinity, height: CGFloat.infinity)
    let rect = text.boundingRectWithSize(infiniteSize, options: .UsesLineFragmentOrigin, attributes: fontAttributes, context: nil)
    return CGSize(width: ceil(rect.width), height: ceil(rect.height))
  }
  
  private func calcTotalWidthOfComponents() -> CGFloat {
    var totalWidth: CGFloat = 0
    for component in 0..<pickerView.numberOfComponents {
      totalWidth += pickerView.rowSizeForComponent(component).width
    }
    return totalWidth
  }

  private var componentTitleLabels: [UILabel?] = []
  private let pickerViewGapBetweenComponents: CGFloat = 5 // default gap between components for the picker view
  private let pickerViewMargin: CGFloat = 40 // overall margin for the picker view
  
}

extension UIPickerTableViewCell: UIPickerViewDataSource {
  
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return dataSource?.numberOfComponentsInPickerView(pickerView) ?? 1
  }
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return dataSource?.pickerView(pickerView, numberOfRowsInComponent: component) ?? 0
  }
  
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
    return dataSource?.pickerView(pickerView, titleForRow: row, forComponent: component) ?? ""
  }
  
  func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
    if dataSource == nil {
      return nil
    }
    
    let rowTitle = dataSource?.pickerView(pickerView, titleForRow: row, forComponent: component) ?? ""
    let componentTitle: String
    if let title = dataSource?.pickerView(pickerView, titleForComponent: component) {
      componentTitle = " \(title)"
    } else {
      componentTitle = ""
    }
    
    let componentTitleWidth = computeSizeForText(componentTitle, font: pickerViewFont).width
    
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = componentTitle.isEmpty ? .Center : .Right
    paragraphStyle.tailIndent = -componentTitleWidth
    
    return NSAttributedString(string: rowTitle, attributes: [NSParagraphStyleAttributeName: paragraphStyle])
  }

}

extension UIPickerTableViewCell: UIPickerViewDelegate {
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    delegate?.pickerView(pickerView, didSelectRow: row, inComponent: component)
  }
  
  func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
    if let width = delegate?.pickerView(pickerView, widthForComponent: component) {
      return width
    } else {
      let numberOfComponents = dataSource?.numberOfComponentsInPickerView(pickerView) ?? 1
      let totalGaps = CGFloat(numberOfComponents - 1) * pickerViewGapBetweenComponents
      let width = (bounds.width - pickerViewMargin - totalGaps) / CGFloat(numberOfComponents)
      return width
    }
  }

}
