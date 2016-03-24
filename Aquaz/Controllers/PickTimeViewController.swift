//
//  PickTimeViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 14.11.14.
//  Copyright © 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class PickTimeViewController: UIViewController {
  
  @IBOutlet weak var timePicker: UIDatePicker!
  @IBOutlet weak var chooseButton: RoundedButton!
  
  var time: NSDate!
  
  weak var intakeViewController: IntakeViewController!
  
  var drinkType: DrinkType? {
    return intakeViewController?.drinkType
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    setupTimePicker()
    applyStyle()
  }
  
  private func setupTimePicker() {
    timePicker.setDate(time, animated: false)

    let today = NSDate()
    let isTodayTime = DateHelper.areDatesEqualByDays(today, time)
    if isTodayTime {
      timePicker.maximumDate = today
    }
  }
  
  private func applyStyle() {
    UIHelper.applyStyleToViewController(self)
    chooseButton.backgroundColor = drinkType?.darkColor
    navigationController?.navigationBar.barTintColor = drinkType?.mainColor
  }

  @IBAction func chooseButtonWasTapped(sender: AnyObject) {
    time = timePicker.date
    intakeViewController.changeTimeForCurrentDate(time)
    navigationController?.dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func cancelButtonWasTapped(sender: AnyObject) {
    navigationController?.dismissViewControllerAnimated(true, completion: nil)
  }

}
