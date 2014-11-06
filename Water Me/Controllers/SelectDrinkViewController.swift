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
    let addDrinkViewController = storyboard!.instantiateViewControllerWithIdentifier("AddDrinkViewController") as AddDrinkViewController
    let drink = Drink.getDrinkByIndex(sender.tag)
    addDrinkViewController.drink = drink
    addDrinkViewController.dayViewController = dayViewController
    presentViewController(addDrinkViewController, animated: true, completion: nil)
  }
  
}
