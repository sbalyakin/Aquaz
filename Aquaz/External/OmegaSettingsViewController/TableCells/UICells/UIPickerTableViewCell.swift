//
//  UIPickerTableViewCell.swift
//  OmegaSettingsViewController
//
//  Created by Sergey Balyakin on 03.03.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

protocol UIPickerTableViewCellDataSource: class {
  func numberOfComponentsInPickerView(_ pickerView: UIPickerView) -> Int
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String!
  func pickerView(_ pickerView: UIPickerView, titleForComponent: Int) -> String?
}

protocol UIPickerTableViewCellDelegate: class {
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
  func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat?
}

enum UIPickerViewHeight: CGFloat {
  case small  = 162
  case medium = 180
  case large  = 216
}

class UIPickerTableViewCell: UITableViewCell {
  
  weak var pickerView: UIPickerView!
  
  weak var dataSource: UIPickerTableViewCellDataSource? {
    didSet {
      setupPickerView()
    }
  }
  
  weak var delegate: UIPickerTableViewCellDelegate?
  
  var pickerViewFont: UIFont? = nil {
    didSet {
      if pickerViewFont == nil {
        pickerViewDelegate = UIPickerTableViewCellInternalAttributedTitleDelegate(pickerTableViewCell: self)
      } else {
        pickerViewDelegate = UIPickerTableViewCellInternalCustomLabelDelegate(pickerTableViewCell: self)
      }
    }
  }
  
  fileprivate var pickerViewDelegate: UIPickerTableViewCellInternalBaseDelegate! {
    didSet {
      pickerView?.delegate = pickerViewDelegate
    }
  }
  
  fileprivate var fontForComponentTitle: UIFont {
    return pickerViewFont ?? UIFont.systemFont(ofSize: 21)
  }
  
  init(reuseIdentifier: String? = nil) {
    super.init(style: .default, reuseIdentifier: reuseIdentifier)
    baseInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    baseInit()
  }
  
  fileprivate func baseInit() {
    selectionStyle = .none
    layer.zPosition = -1

    if self.pickerView == nil {
      let pickerView = UIPickerView()
      self.pickerView = pickerView
      pickerView.backgroundColor = UIColor.clear
      pickerView.dataSource = self
      pickerViewDelegate = UIPickerTableViewCellInternalAttributedTitleDelegate(pickerTableViewCell: self)
      contentView.addSubview(pickerView)
      contentView.sendSubviewToBack(pickerView)
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    layoutPickerView()
  }
  
  func refresh() {
    pickerView.reloadAllComponents()
    setupPickerView()
  }
  
  fileprivate func setupPickerView() {
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
        titleLabel.font = fontForComponentTitle
        titleLabel.text = title
        titleLabel.textColor = UIColor.black
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.sizeToFit()
        pickerView.addSubview(titleLabel)
        componentTitleLabels.append(titleLabel)
      } else {
        componentTitleLabels.append(nil)
      }
    }
  }
  
  fileprivate func layoutPickerView() {
    pickerView.frame = bounds
    pickerView.setNeedsLayout()

    let totalComponentGaps = pickerViewGapBetweenComponents * CGFloat(pickerView.numberOfComponents - 1)
    let totalComponentWidths = calcTotalWidthOfComponents()
    var x = (pickerView.bounds.width - totalComponentGaps - totalComponentWidths) / 2
    let midY = pickerView.bounds.midY
    
    for component in 0..<pickerView.numberOfComponents {
      if let label = componentTitleLabels[component] {
        let componentTitle = dataSource?.pickerView(pickerView, titleForComponent: component) ?? ""
        let componentTitleSize = computeSizeForText(componentTitle, font: fontForComponentTitle)
        let componentSize = pickerView.rowSize(forComponent: component)
        let labelMinX = x + componentSize.width - componentTitleSize.width
        let labelMinY = midY - componentTitleSize.height / 2
        
        label.frame.origin = CGPoint(x: labelMinX, y: labelMinY)
        
        x += componentSize.width + pickerViewGapBetweenComponents
      } else {
        x += pickerViewGapBetweenComponents
      }
    }
  }

  fileprivate func composeAttributedTitleForPickerView(_ pickerView: UIPickerView, row: Int, component: Int) -> NSAttributedString {
    let rowTitle = dataSource?.pickerView(pickerView, titleForRow: row, forComponent: component) ?? ""
    let componentTitle: String
    if let title = dataSource?.pickerView(pickerView, titleForComponent: component) {
      componentTitle = " \(title)"
    } else {
      componentTitle = ""
    }
    
    let componentTitleWidth = computeSizeForText(componentTitle, font: fontForComponentTitle).width
    
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = componentTitle.isEmpty ? .center : .right
    paragraphStyle.tailIndent = -componentTitleWidth
    
    return NSAttributedString(string: rowTitle, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
  }
  
  fileprivate func computeSizeForText(_ text: String, font: UIFont) -> CGSize {
    let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
    let fontAttributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle: textStyle]
    let infiniteSize = CGSize(width: CGFloat.infinity, height: CGFloat.infinity)
    let rect = text.boundingRect(with: infiniteSize, options: .usesLineFragmentOrigin, attributes: fontAttributes, context: nil)
    return CGSize(width: ceil(rect.width), height: ceil(rect.height))
  }
  
  fileprivate func calcTotalWidthOfComponents() -> CGFloat {
    var totalWidth: CGFloat = 0
    for component in 0..<pickerView.numberOfComponents {
      totalWidth += pickerView.rowSize(forComponent: component).width
    }
    return totalWidth
  }

  fileprivate var componentTitleLabels: [UILabel?] = []
  fileprivate let pickerViewGapBetweenComponents: CGFloat = 5 // default gap between components for the picker view
  fileprivate let pickerViewMargin: CGFloat = 40 // overall margin for the picker view
  
}

extension UIPickerTableViewCell: UIPickerViewDataSource {
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return dataSource?.numberOfComponentsInPickerView(pickerView) ?? 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return dataSource?.pickerView(pickerView, numberOfRowsInComponent: component) ?? 0
  }
  
}

class UIPickerTableViewCellInternalBaseDelegate: NSObject, UIPickerViewDelegate {
  
  weak var pickerTableViewCell: UIPickerTableViewCell!
  
  init(pickerTableViewCell: UIPickerTableViewCell) {
    self.pickerTableViewCell = pickerTableViewCell
    super.init()
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    pickerTableViewCell.delegate?.pickerView(pickerView, didSelectRow: row, inComponent: component)
  }
  
  func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
    if let width = pickerTableViewCell.delegate?.pickerView(pickerView, widthForComponent: component) {
      return width
    } else {
      let numberOfComponents = pickerTableViewCell.dataSource?.numberOfComponentsInPickerView(pickerView) ?? 1
      let totalGaps = CGFloat(numberOfComponents - 1) * pickerTableViewCell.pickerViewGapBetweenComponents
      let width = (pickerTableViewCell.bounds.width - pickerTableViewCell.pickerViewMargin - totalGaps) / CGFloat(numberOfComponents)
      return width
    }
  }

}

class UIPickerTableViewCellInternalAttributedTitleDelegate: UIPickerTableViewCellInternalBaseDelegate {

  func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
    return pickerTableViewCell.composeAttributedTitleForPickerView(pickerView, row: row, component: component)
  }
  
}

class UIPickerTableViewCellInternalCustomLabelDelegate: UIPickerTableViewCellInternalBaseDelegate {
  
  func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
    var pickerLabel = view as? UILabel
    if pickerLabel == nil {
      pickerLabel = UILabel()
      pickerLabel!.font = pickerTableViewCell.pickerViewFont
      pickerLabel!.backgroundColor = UIColor.clear
    }

    pickerLabel!.attributedText = pickerTableViewCell.composeAttributedTitleForPickerView(pickerView, row: row, component: component)

    return pickerLabel!
  }

}
