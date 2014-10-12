//
//  TodayViewController.swift
//  Water Me
//
//  Created by Sergey Balyakin on 03.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class TodayViewController: UIViewController {
  
  @IBAction func drinkTapped(sender: AnyObject) {
    let drinkController = storyboard!.instantiateViewControllerWithIdentifier("DrinkViewController") as DrinkViewController
    let drink = Drink.getDrinkByIndex(sender.tag)
    drinkController.drink = drink
    presentViewController(drinkController, animated: true, completion: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}
