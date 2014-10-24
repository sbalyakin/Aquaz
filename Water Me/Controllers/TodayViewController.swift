//
//  TodayViewController.swift
//  Water Me
//
//  Created by Sergey Balyakin on 03.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class TodayViewController: UIViewController {
  
  @IBOutlet weak var consumptionProgressView: UIProgressView!
  @IBOutlet weak var consumptionLabel: UILabel!
  
  var todayConsumption: Float = 0.0 {
    didSet {
      setTodayConsumption(todayConsumption, maximum: Float(Settings.User.waterPerDay))
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    todayConsumption = 0.0
  }
  
  @IBAction func drinkTapped(sender: AnyObject) {
    let drinkViewController = storyboard!.instantiateViewControllerWithIdentifier("DrinkViewController") as DrinkViewController
    let drink = Drink.getDrinkByIndex(sender.tag)
    drinkViewController.drink = drink
    drinkViewController.todayViewController = self
    presentViewController(drinkViewController, animated: true, completion: nil)
  }
  
  func setTodayConsumption(amount: Float, maximum: Float) {
    assert(maximum > 0, "Maximum of recommended consumption is specified to 0")
    let progress = amount / maximum
    consumptionProgressView.progress = progress

    let consumptionText = "\(Int(amount)) ml"
    consumptionLabel.text = consumptionText
  }
  
  func addConsumptionForToday(drink: Drink, amount: Float) {
    todayConsumption += amount
  }
}
