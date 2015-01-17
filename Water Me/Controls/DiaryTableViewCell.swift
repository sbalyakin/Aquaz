//
//  DiaryTableViewCell.swift
//  Water Me
//
//  Created by Sergey Balyakin on 17.01.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

private extension Units.Volume {
  var precision: Double {
    switch self {
    case Millilitres: return 1.0
    case FluidOunces: return 0.1
    }
  }
  
  var decimals: Int {
    switch self {
    case Millilitres: return 0
    case FluidOunces: return 1
    }
  }
}


class DiaryTableViewCell: UITableViewCell {
  
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var drinkLabel: UILabel!
  @IBOutlet weak var amountLabel: UILabel!
  
  var consumption: Consumption! {
    didSet {
      applyConsumption()
    }
  }
  
  private func findDefaultAccessoryView() -> UIView? {
    for subview in subviews {
      if let subview = subview as? UIButton {
        if subview != backgroundView &&
           subview != contentView &&
           subview != selectedBackgroundView &&
           subview != multipleSelectionBackgroundView {
          return subview
        }
      }
    }

    return nil
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    
    // Adjust amount label
    var maxX: CGFloat = 0
    
    if let defaultAccessoryView = findDefaultAccessoryView() {
      maxX = defaultAccessoryView.frame.minX
    } else {
      maxX = bounds.width - 23
    }
    
    maxX -= 8
    
    var frame = amountLabel.frame
    frame.origin.x = maxX - frame.width
    amountLabel.frame = frame
    
    // Adjust drink label
    drinkLabel.frame.size.width = amountLabel.frame.minX - 8 - drinkLabel.frame.minX
    
    // Adjust time label
    let drinkFontHeight = calcTextHeight(font: drinkLabel.font)
    let timeFontHeight = calcTextHeight(font: timeLabel.font)

    let drinkLabelBaseline = drinkLabel.frame.height + drinkLabel.font.descender - (drinkLabel.frame.height - drinkFontHeight) / 2
    let timeLabelBaseline = timeLabel.frame.height + timeLabel.font.descender - (timeLabel.frame.height - timeFontHeight) / 2
    timeLabel.frame.origin.y = drinkLabel.frame.minY + drinkLabelBaseline - timeLabelBaseline
  }
  
  private func calcTextHeight(#font: UIFont) -> CGFloat {
    let scale = UIScreen.mainScreen().scale
    let rawHeight = "0".sizeWithAttributes([NSFontAttributeName: font]).height
    let height = ceil(rawHeight * scale) / scale
    return height
  }
  
  private func applyConsumption() {
    let drinkTitle = consumption.drink.localizedName
    let amountTitle = Units.sharedInstance.formatMetricAmountToText(metricAmount: consumption.amount.doubleValue, unitType: .Volume, roundPrecision: amountPrecision, decimals: amountDecimals, displayUnits: false)
    let waterTitle = Units.sharedInstance.formatMetricAmountToText(metricAmount: consumption.waterIntake, unitType: .Volume, roundPrecision: amountPrecision, decimals: amountDecimals, displayUnits: false)
    
    let formatter = NSDateFormatter()
    formatter.dateStyle = .NoStyle
    formatter.timeStyle = .ShortStyle
    let timeTitle = formatter.stringFromDate(consumption.date)

    timeLabel.text = timeTitle
    drinkLabel.text = drinkTitle
    drinkLabel.textColor = consumption.drink.darkColor
    
    let amountTitleAt = NSAttributedString(string: amountTitle, attributes: [
      NSForegroundColorAttributeName: amountLabel.textColor,
      NSFontAttributeName: amountLabel.font])

    let separatorTitleAt = NSAttributedString(string: " / ", attributes: [
      NSForegroundColorAttributeName: UIColor.lightGrayColor(),
      NSFontAttributeName: amountLabel.font])
    
    let waterTitleAt = NSAttributedString(string: "\(waterTitle) ", attributes: [
      NSForegroundColorAttributeName: Drink.getDrinkByIndex(Drink.DrinkType.Water.rawValue)!.darkColor,
      NSFontAttributeName: amountLabel.font])

    let unit = Settings.sharedInstance.generalVolumeUnits.value.unit.contraction
    let unitsTitleAt = NSAttributedString(string: unit, attributes: [
      NSForegroundColorAttributeName: Drink.getDrinkByIndex(Drink.DrinkType.Water.rawValue)!.darkColor,
      NSFontAttributeName: amountLabel.font])
    

    let title = NSMutableAttributedString()
    title.appendAttributedString(amountTitleAt)
    title.appendAttributedString(separatorTitleAt)
    title.appendAttributedString(waterTitleAt)
    title.appendAttributedString(unitsTitleAt)

//    amountLabel.text = amountTitle
    amountLabel.attributedText = title

  }
  
  private let amountPrecision = Settings.sharedInstance.generalVolumeUnits.value.precision
  private let amountDecimals = Settings.sharedInstance.generalVolumeUnits.value.decimals

}
