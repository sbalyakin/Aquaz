//
//  SelectDrinkViewController.swift
//  Water Me
//
//  Created by Sergey Balyakin on 03.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class SelectDrinkViewController: UIViewController {
  
  var dayViewController: DayViewController!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  @IBAction func drinkTapped(sender: AnyObject) {
    let consumptionViewController = storyboard!.instantiateViewControllerWithIdentifier("ConsumptionViewController") as ConsumptionViewController
    let drink = Drink.getDrinkByIndex(sender.tag)
    consumptionViewController.drink = drink
    consumptionViewController.currentDate = dayViewController.getCurrentDate()
    consumptionViewController.dayViewController = dayViewController
    navigationController!.pushViewController(consumptionViewController, animated: true)
  }
  
}
