//
//  TodayViewController.swift
//  Water Me
//
//  Created by Sergey Balyakin on 03.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class TodayViewController: UIViewController {
  
  var todayContainerViewController: TodayContainerViewController!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  @IBAction func drinkTapped(sender: AnyObject) {
    let drinkViewController = storyboard!.instantiateViewControllerWithIdentifier("DrinkViewController") as DrinkViewController
    let drink = Drink.getDrinkByIndex(sender.tag)
    drinkViewController.drink = drink
    drinkViewController.todayContainerViewController = todayContainerViewController
    presentViewController(drinkViewController, animated: true, completion: nil)
  }
  
}
