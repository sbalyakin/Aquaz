//
//  DrinkViewController.swift
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
    case FluidOunces: return 1.0
    }
  }
  
  var predefinedAmounts: (small: Double, medium: Double, large: Double) {
    switch self {
    case Millilitres: return (small: 100.0, medium: 200.0, large: 500.0)
    case FluidOunces: return (small: 118.29411825, medium: 236.5882365 , large: 502.7500025625) // 4, 8 and 17 fl oz
    }
  }
}

class DrinkViewController: UIViewController {
  
  @IBOutlet weak var drinkName: UILabel!
  @IBOutlet weak var amountSlider: UISlider!
  @IBOutlet weak var amountLabel: UILabel!
  @IBOutlet weak var smallAmountButton: UIButton!
  @IBOutlet weak var mediumAmountButton: UIButton!
  @IBOutlet weak var largeAmountButton: UIButton!
  
  let amountRoundPrecision = Settings.sharedInstance.generalVolumeUnits.value.precision
  let predefinedAmounts = Settings.sharedInstance.generalVolumeUnits.value.predefinedAmounts
  
  var drink: Drink!
  var todayViewController: TodayViewController!
  
  var roundedSliderValue: Double {
    return roundAmount(Double(amountSlider.value))
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    drinkName.text = drink.name

    let recentAmount = roundAmount(Double(drink.recentAmount.amount))
    setAmountLabel(recentAmount)
    amountSlider.value = Float(recentAmount)

    smallAmountButton.setTitle(formatAmount(predefinedAmounts.small), forState: .Normal)
    mediumAmountButton.setTitle(formatAmount(predefinedAmounts.medium), forState: .Normal)
    largeAmountButton.setTitle(formatAmount(predefinedAmounts.large), forState: .Normal)
  }
  
  @IBAction func amountSliderValueChanged(sender: AnyObject) {
    setAmountLabel(roundedSliderValue)
  }
  
  @IBAction func addCustomConsumption(sender: AnyObject) {
    addConsumption(roundedSliderValue)
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
  
  func addConsumption(amount: Double) {
    // Store the consumption into Core Data
    drink.recentAmount.amount = amount
    Consumption.addEntity(drink: drink, amount: amount, date: NSDate(), managedObjectContext: ModelHelper.sharedInstance.managedObjectContext)
    
    // Update parent controller
    todayViewController.addConsumptionForToday(drink, amount: amount)
    
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func roundAmount(amount: Double) -> Double {
    return round(amount / amountRoundPrecision) * amountRoundPrecision
  }
  
  func formatAmount(amount: Double) -> String {
    return Units.sharedInstance.formatAmountToText(amount: amount, unitType: .Volume)
  }
  
  func setAmountLabel(amount: Double) {
    amountLabel.text = formatAmount(amount)
  }
}
