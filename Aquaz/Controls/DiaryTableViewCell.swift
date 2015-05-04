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
  @IBOutlet weak var waterAmountLabel: UILabel!
  
  var intake: Intake! {
    didSet {
      applyIntake()
    }
  }
  
  private func applyIntake() {
    let drinkTitle = intake.drink.localizedName
    let amountTitle = Units.sharedInstance.formatMetricAmountToText(metricAmount: intake.amount, unitType: .Volume, roundPrecision: amountPrecision, decimals: amountDecimals, displayUnits: true)
    let waterTitle = Units.sharedInstance.formatMetricAmountToText(metricAmount: intake.waterAmount, unitType: .Volume, roundPrecision: amountPrecision, decimals: amountDecimals, displayUnits: true)
    
    let formatter = NSDateFormatter()
    formatter.dateStyle = .NoStyle
    formatter.timeStyle = .ShortStyle
    let timeTitle = formatter.stringFromDate(intake.date)

    timeLabel.text = timeTitle
    drinkLabel.text = drinkTitle
    drinkLabel.textColor = intake.drink.darkColor
    amountLabel.text = amountTitle
    waterAmountLabel.text = waterTitle
    
    updateFonts()
  }
  
  private func updateFonts() {
    drinkLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    timeLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
    amountLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
    invalidateIntrinsicContentSize()
  }
  
  private var amountPrecision: Double { return Settings.generalVolumeUnits.value.precision }
  private var amountDecimals: Int { return Settings.generalVolumeUnits.value.decimals }

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