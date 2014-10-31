//
//  TodayViewController.swift
//  Water Me
//
//  Created by Sergey Balyakin on 03.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

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

class TodayViewController: UIViewController {
  
  @IBOutlet weak var consumptionProgressView: UIProgressView!
  @IBOutlet weak var consumptionLabel: UILabel!
  
  var todayConsumption: Double = 0.0 {
    didSet {
      setTodayConsumption(todayConsumption, maximum: Double(Settings.sharedInstance.userDailyWaterIntake.value))
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    todayConsumption = getTodayConsumption()
  }
  
  @IBAction func drinkTapped(sender: AnyObject) {
    let drinkViewController = storyboard!.instantiateViewControllerWithIdentifier("DrinkViewController") as DrinkViewController
    let drink = Drink.getDrinkByIndex(sender.tag)
    drinkViewController.drink = drink
    drinkViewController.todayViewController = self
    presentViewController(drinkViewController, animated: true, completion: nil)
  }
  
  func addConsumptionForToday(drink: Drink, amount: Double) {
    todayConsumption += amount
  }
  
  private func setTodayConsumption(amount: Double, maximum: Double) {
    assert(maximum > 0, "Maximum of recommended consumption is specified to 0")
    let progress = amount / maximum
    consumptionProgressView.progress = Float(progress)
    
    let consumptionText = Units.sharedInstance.formatAmountToText(amount: amount, unitType: .Volume, precision: amountPrecision, decimals: amountDecimals)
    consumptionLabel.text = consumptionText
  }
  
  private func getTodayConsumption() -> Double {
    if let consumptions = ModelHelper.sharedInstance.computeDrinkAmountsForDay(NSDate()) {
      var overallAmount = 0.0
      for (drink, amount) in consumptions {
        overallAmount += amount
      }
      return overallAmount
    } else {
      return 0.0
    }
  }
  
  private let amountPrecision = Settings.sharedInstance.generalVolumeUnits.value.precision
  private let amountDecimals = Settings.sharedInstance.generalVolumeUnits.value.decimals

}
