//
//  AddDrinkViewController.swift
//  Water Me
//
//  Created by Sergey Balyakin on 12.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

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
  
  var predefinedAmounts: (small: Double, medium: Double, large: Double) {
    switch self {
    case Millilitres: return (small: 100.0, medium: 200.0, large: 500.0)
    case FluidOunces: return (small: 118.29411825, medium: 236.5882365 , large: 502.7500025625) // 4, 8 and 17 fl oz
    }
  }
}

class AddDrinkViewController: UIViewController {
  
  @IBOutlet weak var drinkNameLabel: UILabel!
  @IBOutlet weak var amountSlider: UISlider!
  @IBOutlet weak var amountLabel: UILabel!
  @IBOutlet weak var smallAmountButton: UIButton!
  @IBOutlet weak var mediumAmountButton: UIButton!
  @IBOutlet weak var largeAmountButton: UIButton!
  
  let predefinedAmounts = Settings.sharedInstance.generalVolumeUnits.value.predefinedAmounts
  
  var drink: Drink!
  var dayViewController: DayViewController!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    drinkNameLabel.text = drink.name

    let recentAmount = Double(drink.recentAmount.amount)
    setAmountLabel(recentAmount)
    amountSlider.value = Float(recentAmount)

    // Predefined amount is always non-fractional values, so we will format amount skipping fraction part
    smallAmountButton.setTitle(formatAmount(predefinedAmounts.small, precision: 1.0, decimals: 0), forState: .Normal)
    mediumAmountButton.setTitle(formatAmount(predefinedAmounts.medium, precision: 1.0, decimals: 0), forState: .Normal)
    largeAmountButton.setTitle(formatAmount(predefinedAmounts.large, precision: 1.0, decimals: 0), forState: .Normal)
  }
  
  @IBAction func amountSliderValueChanged(sender: AnyObject) {
    setAmountLabel(Double(amountSlider.value))
  }
  
  @IBAction func addCustomConsumption(sender: AnyObject) {
    addConsumption(Double(amountSlider.value))
  }
  
  @IBAction func addSmallConsumption(sender: AnyObject) {
    addConsumption(predefinedAmounts.small)
  }
  
  @IBAction func addMediumConsumption(sender: AnyObject) {
    addConsumption(predefinedAmounts.medium)
  }
  
  @IBAction func addLargeConsumption(sender: AnyObject) {
    addConsumption(predefinedAmounts.large)
  }
  
  @IBAction func cancelConsumption(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  private func addConsumption(amount: Double) {
    // Prepare amount for storing
    let precision = Settings.sharedInstance.generalVolumeUnits.value.precision
    let processedAmount = Units.sharedInstance.prepareAmountForStoring(amount: amount, unitType: .Volume, precision: precision)
    
    // Get current date from day view controller and replace time with the current
    let calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)!
    var currentDayComponents = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: dayViewController.currentDate)
    var nowComponents = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: NSDate())
    currentDayComponents.hour   = nowComponents.hour
    currentDayComponents.minute = nowComponents.minute
    currentDayComponents.second = nowComponents.second
    let date = calendar.dateFromComponents(currentDayComponents)!
    
    // Store the consumption into Core Data
    drink.recentAmount.amount = processedAmount
    Consumption.addEntity(drink: drink, amount: processedAmount, date: date, managedObjectContext: ModelHelper.sharedInstance.managedObjectContext)
    
    // Update day view controller
    dayViewController.addConsumption(drink, amount: processedAmount)
    
    dismissViewControllerAnimated(true, completion: nil)
  }

  private func formatAmount(amount: Double, precision: Double? = nil, decimals: Int? = nil) -> String {
    let finalPrecision = precision != nil ? precision! : amountPrecision
    let finalDecimals = decimals != nil ? decimals! : amountDecimals
    return Units.sharedInstance.formatAmountToText(amount: amount, unitType: .Volume, precision: finalPrecision, decimals: finalDecimals)
  }
  
  private func setAmountLabel(amount: Double) {
    amountLabel.text = formatAmount(amount)
  }

  private let amountPrecision = Settings.sharedInstance.generalVolumeUnits.value.precision
  private let amountDecimals = Settings.sharedInstance.generalVolumeUnits.value.decimals

}
