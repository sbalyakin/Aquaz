//
//  DiaryTableViewCell.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 17.01.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class DiaryTableViewCell: UITableViewCell {
  
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var drinkLabel: UILabel!
  @IBOutlet weak var amountLabel: UILabel!
  
  var intake: Intake! {
    didSet {
      applyIntake()
    }
  }
  
  private func applyIntake() {
    let drinkTitle = intake.drink.localizedName
    let amountTitle = Units.sharedInstance.formatMetricAmountToText(metricAmount: intake.amount, unitType: .Volume, roundPrecision: amountPrecision, decimals: amountDecimals, displayUnits: false)
    let waterTitle = Units.sharedInstance.formatMetricAmountToText(metricAmount: intake.waterAmount, unitType: .Volume, roundPrecision: amountPrecision, decimals: amountDecimals, displayUnits: false)
    
    let formatter = NSDateFormatter()
    formatter.dateStyle = .NoStyle
    formatter.timeStyle = .ShortStyle
    let timeTitle = formatter.stringFromDate(intake.date)

    timeLabel.text = timeTitle
    drinkLabel.text = drinkTitle
    drinkLabel.textColor = intake.drink.darkColor
    
    let amountTitleAt = NSAttributedString(string: amountTitle, attributes: [
      NSForegroundColorAttributeName: amountLabel.textColor,
      NSFontAttributeName: amountLabel.font])

    let separatorTitleAt = NSAttributedString(string: " / ", attributes: [
      NSForegroundColorAttributeName: UIColor.lightGrayColor(),
      NSFontAttributeName: amountLabel.font])

    let waterColor = Drink.getDarkColorFromDrinkColor(StyleKit.waterColor)
    
    let waterTitleAt = NSAttributedString(string: "\(waterTitle) ", attributes: [
      NSForegroundColorAttributeName: waterColor,
      NSFontAttributeName: amountLabel.font])

    let unit = Settings.generalVolumeUnits.value.unit.contraction
    let unitsTitleAt = NSAttributedString(string: unit, attributes: [
      NSForegroundColorAttributeName: waterColor,
      NSFontAttributeName: amountLabel.font])
    

    let title = NSMutableAttributedString()
    title.appendAttributedString(amountTitleAt)
    title.appendAttributedString(separatorTitleAt)
    title.appendAttributedString(waterTitleAt)
    title.appendAttributedString(unitsTitleAt)

    amountLabel.attributedText = title
    
    updateFonts()
  }
  
  private func updateFonts() {
    drinkLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    timeLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
    amountLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
    invalidateIntrinsicContentSize()
  }
  
  private let amountPrecision = Settings.generalVolumeUnits.value.precision
  private let amountDecimals = Settings.generalVolumeUnits.value.decimals

}

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