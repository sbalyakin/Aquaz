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
  
  fileprivate var currentDrinkType: DrinkType!

  // MARK: Methods
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    
    initPicker()
  }

  fileprivate func initPicker() {
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
    pickerValueWasChanged(recentDrinkIndex)
  }
  
  @IBAction func pickerValueWasChanged(_ value: Int) {
    if let drinkType = DrinkType(rawValue: value) {
      currentDrinkType = drinkType
      drinkLabel.setTextColor(drinkType.mainColor)
      drinkLabel.setText(drinkType.localizedName)
    }
  }
  
  override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
    WatchSettings.sharedInstance.recentDrinkType.value = currentDrinkType
    return currentDrinkType.rawValue
  }

}

// MARK: DrinkType extension

private extension DrinkType {
  
  var imageName: String {
    switch self {
    case .water:      return "DrinkWater"
    case .coffee:     return "DrinkCoffee"
    case .tea:        return "DrinkTea"
    case .soda:       return "DrinkSoda"
    case .juice:      return "DrinkJuice"
    case .milk:       return "DrinkMilk"
    case .sport:      return "DrinkSport"
    case .energy:     return "DrinkEnergy"
    case .beer:       return "DrinkBeer"
    case .wine:       return "DrinkWine"
    case .hardLiquor: return "DrinkHardLiquor"
    }
  }
  
}
