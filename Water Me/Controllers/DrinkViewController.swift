//
//  DrinkViewController.swift
//  Water Me
//
//  Created by Sergey Balyakin on 12.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class DrinkViewController: UIViewController {
  
  @IBOutlet weak var drinkName: UILabel!
  @IBOutlet weak var amountSlider: UISlider!
  @IBOutlet weak var amountLabel: UILabel!
  
  let amountSliderMultiplier: Double = 10.0
  let smallAmount: Double = 100.0
  let mediumAmount: Double = 200.0
  let largeAmount: Double = 500.0
  
  var drink: Drink!
  var todayViewController: TodayViewController!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    drinkName.text = drink.name
    setAmount(Double(drink.recentAmount.amount))
  }
  
  @IBAction func amountSliderValueChanged(sender: AnyObject) {
    setAmountLabel(amountSlider.value * amountSliderMultiplier)
  }
  
  func addConsumption(amount: Double) {
    // Store the consumption into Core Data
    drink.recentAmount.amount = amount
    Consumption.addEntity(drink: drink, amount: amount, date: NSDate(), managedObjectContext: ModelHelper.sharedInstance.managedObjectContext)
    
    // Update parent controller
    todayViewController.addConsumptionForToday(drink, amount: amount)
    
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func addCustomConsumption(sender: AnyObject) {
    let amount = Double(amountSlider.value * amountSliderMultiplier)
    addConsumption(amount)
  }
  
  @IBAction func addSmallConsumption(sender: AnyObject) {
    addConsumption(smallAmount)
  }
  
  @IBAction func addMediumConsumption(sender: AnyObject) {
    addConsumption(mediumAmount)
  }
  
  @IBAction func addLargeConsumption(sender: AnyObject) {
    addConsumption(largeAmount)
  }
  
  @IBAction func cancelConsumption(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func setAmountLabel(amount: Double) {
    amountLabel.text = "\(Int(amount)) ml"
  }
  
  func setAmount(amount: Double) {
    setAmountLabel(amount)
    amountSlider.value = amount / amountSliderMultiplier
  }
}
