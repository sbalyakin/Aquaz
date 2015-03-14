//
//  PickTimeViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 14.11.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class PickTimeViewController: StyledViewController {
  
  @IBOutlet weak var timePicker: UIDatePicker!
  @IBOutlet weak var chooseButton: RoundedButton!
  
  var time: NSDate!
  var intakeViewController: IntakeViewController!
  var drink: Drink! {
    return intakeViewController?.drink
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    setupTimePicker()
    applyColorScheme()
  }
  
  func setupTimePicker() {
    timePicker.setDate(time, animated: false)

    let today = NSDate()
    let isTodayTime = DateHelper.areDatesEqualByDays(date1: today, date2: time)
    if isTodayTime {
      timePicker.maximumDate = today
    }
  }
  
  private func applyColorScheme() {
    chooseButton.backgroundColor = drink?.darkColor
    navigationController?.navigationBar.barTintColor = drink?.mainColor
  }

  @IBAction func chooseButtonWasTapped(sender: AnyObject) {
    time = timePicker.date
    intakeViewController.changeTimeForCurrentDate(time)
    navigationController?.popViewControllerAnimated(true)
  }
  
  @IBAction func cancelButtonWasTapped(sender: AnyObject) {
    navigationController?.popViewControllerAnimated(true)
  }

}
