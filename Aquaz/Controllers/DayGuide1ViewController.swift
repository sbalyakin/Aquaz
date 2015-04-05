//
//  DayGuide1ViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 05.04.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class DayGuide1ViewController: UIViewController {

  weak var dayViewController: DayViewController!
  
  @IBAction func viewWasTapped(sender: UITapGestureRecognizer) {
    dayViewController.continueGuide()
  }
  
}
