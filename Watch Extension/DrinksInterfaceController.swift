//
//  DrinksInterfaceController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 05.11.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import WatchKit
import Foundation


class DrinksInterfaceController: WKInterfaceController {
  
  // MARK: Properties
  
  @IBOutlet var picker: WKInterfacePicker!
  
  @IBOutlet var drinkLabel: WKInterfaceLabel!
  
  private var currentDrinkType: DrinkType!

  // MARK: Methods
  
  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    
    initPicker()
  }

  private func initPicker() {
    var pickerItems = [WKPickerItem]()
    
    for drinkIndex in 0..<DrinkType.count {
      let pickerItem = WKPickerItem()
      let drinkType = DrinkType(rawValue: drinkIndex)!
      pickerItem.caption = drinkType.localizedName
      pickerItem.contentImage = WKImage(imageName: drinkType.imageName)
      pickerItems += [pickerItem]
    }
    
    picker.setItems(pickerItems)
    
    let recentDrinkIndex = WatchSettings.sharedInstance.recentDrinkType.value.rawValue
    picker.setSelectedItemIndex(recentDrinkIndex)
  }
  
  @IBAction func pickerValueWasChanged(value: Int) {
    if let drinkType = DrinkType(rawValue: value) {
      currentDrinkType = drinkType
      drinkLabel.setTextColor(drinkType.mainColor)
      drinkLabel.setText(drinkType.localizedName)
    }
  }
  
  override func contextForSegueWithIdentifier(segueIdentifier: String) -> AnyObject? {
    WatchSettings.sharedInstance.recentDrinkType.value = currentDrinkType
    return currentDrinkType.rawValue
  }

}

// MARK: DrinkType extension

private extension DrinkType {
  
  var imageName: String {
    switch self {
    case Water:      return "DrinkWater"
    case Coffee:     return "DrinkCoffee"
    case Tea:        return "DrinkTea"
    case Soda:       return "DrinkSoda"
    case Juice:      return "DrinkJuice"
    case Milk:       return "DrinkMilk"
    case Sport:      return "DrinkSport"
    case Energy:     return "DrinkEnergy"
    case Beer:       return "DrinkBeer"
    case Wine:       return "DrinkWine"
    case HardLiquor: return "DrinkHardLiquor"
    }
  }
  
}
