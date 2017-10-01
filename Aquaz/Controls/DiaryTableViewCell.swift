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
    backgroundColor = StyleKit.pageBackgroundColor
  }

  fileprivate func applyIntake() {
    let intakeInfo = getIntakeInfo()
    
    DispatchQueue.main.async {
      let drinkTitle = intakeInfo.drinkName
      let amountTitle = Units.sharedInstance.formatMetricAmountToText(metricAmount: intakeInfo.amount, unitType: .volume, roundPrecision: self.amountPrecision, fractionDigits: self.amountDecimals, displayUnits: true)
      let waterBalanceTitle = Units.sharedInstance.formatMetricAmountToText(metricAmount: intakeInfo.waterBalance, unitType: .volume, roundPrecision: self.amountPrecision, fractionDigits: self.amountDecimals, displayUnits: true)
      
      let formatter = DateFormatter()
      formatter.dateStyle = .none
      formatter.timeStyle = .short
      let timeTitle = formatter.string(from: intakeInfo.date)

      self.timeLabel.text = timeTitle
      self.drinkLabel.text = drinkTitle
      self.drinkLabel.textColor = intakeInfo.color
      self.amountLabel.text = amountTitle
      self.waterBalanceLabel.text = waterBalanceTitle
      
      self.updateFonts()
    }
  }
  
  fileprivate func getIntakeInfo() -> (drinkName: String, amount: Double, waterBalance: Double, date: Date, color: UIColor) {
    return (drinkName: self.intake.drink.localizedName,
            amount: self.intake.amount,
            waterBalance: self.intake.waterBalance,
            date: self.intake.date as Date,
            color: self.intake.drink.darkColor)
  }
  
  func updateFonts() {
    drinkLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
    timeLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.footnote)
    amountLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
    invalidateIntrinsicContentSize()
  }
  
  fileprivate var amountPrecision: Double { return Settings.sharedInstance.generalVolumeUnits.value.precision }
  fileprivate var amountDecimals: Int { return Settings.sharedInstance.generalVolumeUnits.value.decimals }

}

private extension Units.Volume {
  
  var precision: Double {
    switch self {
    case .millilitres: return 1.0
    case .fluidOunces: return 0.1
    }
  }
  
  var decimals: Int {
    switch self {
    case .millilitres: return 0
    case .fluidOunces: return 1
    }
  }
}
