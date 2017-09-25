//
//  AmountInterfaceController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 07.11.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import WatchKit
import Foundation


final class AmountInterfaceController: WKInterfaceController {

  // MARK: Types
  
  fileprivate struct Constants {
    static let minimumAmount = 50
    static let progressStep = 10
    static let imageStartIndex = minimumAmount / progressStep - 1
    static let imageEndIndex = 50
  }
  
  // MARK: Properties
  
  @IBOutlet var progressImage: WKInterfaceImage!
  
  @IBOutlet var textProgressGroup: WKInterfaceGroup!
  
  @IBOutlet var progressBackgroundGroup: WKInterfaceGroup!
  
  @IBOutlet var picker: WKInterfacePicker!
  
  fileprivate var drinkType: DrinkType!
  
  fileprivate var currentAmount: Double = 0
  
  fileprivate var amountPrecision: Double { return WatchSettings.sharedInstance.generalVolumeUnits.value.precision }
  
  fileprivate var amountDecimals: Int { return WatchSettings.sharedInstance.generalVolumeUnits.value.decimals }

  // MARK: Methods
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    
    if let drinkIndex = context as? Int {
      drinkType = DrinkType(rawValue: drinkIndex) ?? .water
    } else {
      drinkType = .water
    }
    
    progressImage.setTintColor(drinkType.mainColor)
    
    setupPicker()
  }
  
  fileprivate func setupPicker() {
    let pickerItems = [WKPickerItem](repeating: WKPickerItem(), count: Constants.imageEndIndex - Constants.imageStartIndex)
    
    picker.setItems(pickerItems)
    
    let pickerValue = pickerValueFromAmount(WatchSettings.sharedInstance.recentAmounts[drinkType].value)
    picker.setSelectedItemIndex(pickerValue)
    pickerValueWasChanged(pickerValue)
  }
  
  fileprivate func amountFromPickerValue(_ value: Int) -> Double {
    return Double(value * Constants.progressStep + Constants.minimumAmount)
  }
  
  fileprivate func pickerValueFromAmount(_ amount: Double) -> Int {
    var pickerValue = Int((amount - Double(Constants.minimumAmount)) / Double(Constants.progressStep))
    pickerValue = min(Constants.imageEndIndex, pickerValue)
    pickerValue = max(0, pickerValue)
    return pickerValue
  }
  
  fileprivate func stringFromMetricAmount(_ amount: Double) -> String {
    return Units.sharedInstance.formatMetricAmountToText(
      metricAmount: amount,
      unitType: .volume,
      roundPrecision: amountPrecision,
      fractionDigits: amountDecimals,
      displayUnits: false)
  }
  
  @IBAction func pickerValueWasChanged(_ value: Int) {
    currentAmount = amountFromPickerValue(value)
    
    let title = stringFromMetricAmount(currentAmount)
    let subTitle = drinkType.localizedName
    let upTitle = WatchSettings.sharedInstance.generalVolumeUnits.value.description
    let fontSizes = WKInterfaceDevice.currentResolution().fontSizes
    
    let titleItem    = ProgressHelper.TextProgressItem(text: title, color: UIColor.white, font: UIFont.systemFont(ofSize: fontSizes.title, weight: UIFont.Weight.medium))
    let subTitleItem = ProgressHelper.TextProgressItem(text: subTitle, color: drinkType.darkColor, font: UIFont.systemFont(ofSize: fontSizes.subTitle))
    let upTitleItem  = ProgressHelper.TextProgressItem(text: upTitle, color: UIColor.gray, font: UIFont.systemFont(ofSize: fontSizes.upTitle))

    let imageSize = WKInterfaceDevice.currentResolution().progressImageSize

    let backgroundImage = ProgressHelper.generateTextProgressImage(imageSize: imageSize, title: titleItem, subTitle: subTitleItem, upTitle: upTitleItem)

    textProgressGroup.setBackgroundImage(backgroundImage)
    progressImage.setImageNamed("Amount-\(value + 1 + Constants.imageStartIndex)")
  }
  
  @IBAction func saveWasTapped() {
    let adjustedCurrentAmount = Units.sharedInstance.adjustMetricAmountForStoring(metricAmount: currentAmount, unitType: .volume, roundPrecision: amountPrecision)

    let hydrationEffect = adjustedCurrentAmount * drinkType.hydrationFactor
    let dehydrationEffect = adjustedCurrentAmount * drinkType.dehydrationFactor
    
    WatchSettings.sharedInstance.recentAmounts[drinkType].value = adjustedCurrentAmount
    WatchSettings.sharedInstance.stateHydration.value += hydrationEffect
    WatchSettings.sharedInstance.stateWaterGoal.value += dehydrationEffect
    
    ConnectivityProvider.sharedInstance.addIntake(drinkType: drinkType, amount: adjustedCurrentAmount, date: Date())
    
    popToRootController()
  }

}

// MARK: WatchResolution extension

private extension WatchResolution {
  
  var progressImageSize: CGSize {
    switch self {
    case .watch38mm: return CGSize(width: 109, height: 109)
    case .watch42mm: return CGSize(width: 132, height: 132)
    case .unknown:   return CGSize(width: 132, height: 132)
    }
  }

  var fontSizes: (title: CGFloat, upTitle: CGFloat, subTitle: CGFloat) {
    switch self {
    case .watch38mm: return (title: 28, upTitle: 12, subTitle: 12)
    case .watch42mm: return (title: 34, upTitle: 15, subTitle: 15)
    case .unknown:   return (title: 34, upTitle: 15, subTitle: 15)
    }
  }

}

// MARK: Units.Volume extension

private extension Units.Volume {
  
  var precision: Double {
    switch self {
    case .millilitres: return 10.0
    case .fluidOunces: return 0.5
    }
  }
  
  var decimals: Int {
    switch self {
    case .millilitres: return 0
    case .fluidOunces: return 1
    }
  }
  
}
