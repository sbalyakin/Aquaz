//
//  PickTimeViewController.swift
//  Water Me
//
//  Created by Sergey Balyakin on 14.11.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class PickTimeViewController: UIViewController {
  
  @IBOutlet weak var timePicker: UIDatePicker!
  
  var time: NSDate!
  var consumptionViewController: ConsumptionViewController!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    setupTimePicker()
  }
  
  func setupTimePicker() {
    timePicker.setDate(time, animated: false)

    let today = NSDate()
    let isTodayTime = DateHelper.areDatesEqualByDays(date1: today, date2: time)
    if isTodayTime {
      timePicker.maximumDate = today
    }
  }
  
  @IBAction func chooseButtonWasTapped(sender: AnyObject) {
    time = timePicker.date
    consumptionViewController.changeTimeForCurrentDate(time)
    navigationController!.popViewControllerAnimated(true)
  }
  
  @IBAction func cancelButtonWasTapped(sender: AnyObject) {
    navigationController!.popViewControllerAnimated(true)
  }

}
