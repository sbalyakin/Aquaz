//
//  DiaryTableViewCell.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 17.01.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class DiaryTableViewCell: UITableViewCell {
  
  @IBOutlet weak var timeLabel: UILabel! {
    didSet {
      timeLabel.backgroundColor = StyleKit.pageBackgroundColor
    }
  }
  
  @IBOutlet weak var drinkLabel: UILabel! {
    didSet {
      drinkLabel.backgroundColor = StyleKit.pageBackgroundColor
    }
  }
  
  @IBOutlet weak var amountLabel: UILabel! {
    didSet {
      amountLabel.backgroundColor = StyleKit.pageBackgroundColor
    }
  }
  
  @IBOutlet weak var waterBalanceLabel: UILabel! {
    didSet {
      waterBalanceLabel.backgroundColor = StyleKit.pageBackgroundColor
    }
  }
  
  var intake: Intake! {
    didSet {
      if intake != nil {
        applyIntake()
      }
    }
  }
  
  func prepareCell() {
    timeLabel.text = ""
    drinkLabel.text = ""
    amountLabel.text = ""
    waterBalanceLabel.text = ""
  }
  
  private func applyIntake() {
    let intakeInfo = getIntakeInfo()
    
    dispatch_async(dispatch_get_main_queue()) {
      let drinkTitle = intakeInfo.drinkName
      let amountTitle = Units.sharedInstance.formatMetricAmountToText(metricAmount: intakeInfo.amount, unitType: .Volume, roundPrecision: self.amountPrecision, decimals: self.amountDecimals, displayUnits: true)
      let waterBalanceTitle = Units.sharedInstance.formatMetricAmountToText(metricAmount: intakeInfo.waterBalance, unitType: .Volume, roundPrecision: self.amountPrecision, decimals: self.amountDecimals, displayUnits: true)
      
      let formatter = NSDateFormatter()
      formatter.dateStyle = .NoStyle
      formatter.timeStyle = .ShortStyle
      let timeTitle = formatter.stringFromDate(intakeInfo.date)

      self.timeLabel.text = timeTitle
      self.drinkLabel.text = drinkTitle
      self.drinkLabel.textColor = intakeInfo.color
      self.amountLabel.text = amountTitle
      self.waterBalanceLabel.text = waterBalanceTitle
      
      self.updateFonts()
    }
  }
  
  private func getIntakeInfo() -> (drinkName: String, amount: Double, waterBalance: Double, date: NSDate, color: UIColor) {
    return (drinkName: self.intake.drink.localizedName,
            amount: self.intake.amount,
            waterBalance: self.intake.waterBalance,
            date: self.intake.date,
            color: self.intake.drink.darkColor)
  }
  
  func updateFonts() {
    drinkLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    timeLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
    amountLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
    invalidateIntrinsicContentSize()
  }
  
  private var amountPrecision: Double { return Settings.sharedInstance.generalVolumeUnits.value.precision }
  private var amountDecimals: Int { return Settings.sharedInstance.generalVolumeUnits.value.decimals }

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