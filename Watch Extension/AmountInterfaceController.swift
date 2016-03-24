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
  
  private struct Constants {
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
  
  private var drinkType: DrinkType!
  
  private var currentAmount: Double = 0
  
  private var amountPrecision: Double { return WatchSettings.sharedInstance.generalVolumeUnits.value.precision }
  
  private var amountDecimals: Int { return WatchSettings.sharedInstance.generalVolumeUnits.value.decimals }

  // MARK: Methods
  
  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    
    if let drinkIndex = context as? Int {
      drinkType = DrinkType(rawValue: drinkIndex) ?? .Water
    } else {
      drinkType = .Water
    }
    
    progressImage.setTintColor(drinkType.mainColor)
    
    setupPicker()
  }

  private func setupPicker() {
    let pickerItems = [WKPickerItem](count: Constants.imageEndIndex - Constants.imageStartIndex, repeatedValue: WKPickerItem())
    
    picker.setItems(pickerItems)
    
    let pickerValue = pickerValueFromAmount(WatchSettings.sharedInstance.recentAmounts[drinkType].value)
    picker.setSelectedItemIndex(pickerValue)
  }
  
  private func amountFromPickerValue(value: Int) -> Double {
    return Double(value * Constants.progressStep + Constants.minimumAmount)
  }
  
  private func pickerValueFromAmount(amount: Double) -> Int {
    var pickerValue = Int((amount - Double(Constants.minimumAmount)) / Double(Constants.progressStep))
    pickerValue = min(Constants.imageEndIndex, pickerValue)
    pickerValue = max(0, pickerValue)
    return pickerValue
  }
  
  private func stringFromMetricAmount(amount: Double) -> String {
    return Units.sharedInstance.formatMetricAmountToText(
      metricAmount: amount,
      unitType: .Volume,
      roundPrecision: amountPrecision,
      decimals: amountDecimals,
      displayUnits: false)
  }
  
  @IBAction func pickerValueWasChanged(value: Int) {
    currentAmount = amountFromPickerValue(value)
    
    let title = stringFromMetricAmount(currentAmount)
    let subTitle = drinkType.localizedName
    let upTitle = WatchSettings.sharedInstance.generalVolumeUnits.value.description
    let fontSizes = WKInterfaceDevice.currentResolution().fontSizes
    
    let titleItem    = ProgressHelper.TextProgressItem(text: title, color: UIColor.whiteColor(), font: UIFont.systemFontOfSize(fontSizes.title, weight: UIFontWeightMedium))
    let subTitleItem = ProgressHelper.TextProgressItem(text: subTitle, color: drinkType.darkColor, font: UIFont.systemFontOfSize(fontSizes.subTitle))
    let upTitleItem  = ProgressHelper.TextProgressItem(text: upTitle, color: UIColor.grayColor(), font: UIFont.systemFontOfSize(fontSizes.upTitle))

    let imageSize = WKInterfaceDevice.currentResolution().progressImageSize

    let backgroundImage = ProgressHelper.generateTextProgressImage(imageSize: imageSize, title: titleItem, subTitle: subTitleItem, upTitle: upTitleItem)

    textProgressGroup.setBackgroundImage(backgroundImage)
    progressImage.setImageNamed("Amount-\(value + 1 + Constants.imageStartIndex)")
  }
  
  @IBAction func saveWasTapped() {
    let adjustedCurrentAmount = Units.sharedInstance.adjustMetricAmountForStoring(metricAmount: currentAmount, unitType: .Volume, roundPrecision: amountPrecision)

    let hydrationEffect = adjustedCurrentAmount * drinkType.hydrationFactor
    let dehydrationEffect = adjustedCurrentAmount * drinkType.dehydrationFactor
    
    WatchSettings.sharedInstance.recentAmounts[drinkType].value = adjustedCurrentAmount
    WatchSettings.sharedInstance.stateHydration.value += hydrationEffect
    WatchSettings.sharedInstance.stateWaterGoal.value += dehydrationEffect
    
    let addIntakeInfo = ConnectivityMessageAddIntake(drinkType: drinkType, amount: adjustedCurrentAmount, date: NSDate())
    NSNotificationCenter.defaultCenter().postNotificationName(GlobalConstants.notificationWatchAddIntake, object: addIntakeInfo)
    
    popToRootController()
  }

}

// MARK: WatchResolution extension

private extension WatchResolution {
  
  var progressImageSize: CGSize {
    switch self {
    case .Watch38mm: return CGSize(width: 109, height: 109)
    case .Watch42mm: return CGSize(width: 132, height: 132)
    case .Unknown:   return CGSize(width: 132, height: 132)
    }
  }

  var fontSizes: (title: CGFloat, upTitle: CGFloat, subTitle: CGFloat) {
    switch self {
    case .Watch38mm: return (title: 28, upTitle: 13, subTitle: 13)
    case .Watch42mm: return (title: 34, upTitle: 16, subTitle: 16)
    case .Unknown:   return (title: 34, upTitle: 16, subTitle: 16)
    }
  }

}

// MARK: Units.Volume extension

private extension Units.Volume {
  
  var precision: Double {
    switch self {
    case Millilitres: return 10.0
    case FluidOunces: return 0.5
    }
  }
  
  var decimals: Int {
    switch self {
    case Millilitres: return 0
    case FluidOunces: return 1
    }
  }
  
}
