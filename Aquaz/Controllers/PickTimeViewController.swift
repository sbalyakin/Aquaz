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
  
  var time: Date!
  
  weak var intakeViewController: IntakeViewController!
  
  var drinkType: DrinkType? {
    return intakeViewController?.drinkType
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    setupTimePicker()
    applyStyle()
  }
  
  fileprivate func setupTimePicker() {
    timePicker.setDate(time, animated: false)

    let today = Date()
    let isTodayTime = DateHelper.areEqualDays(today, time)
    if isTodayTime {
      timePicker.maximumDate = today
    }
  }
  
  fileprivate func applyStyle() {
    UIHelper.applyStyleToViewController(self)
    chooseButton.backgroundColor = drinkType?.darkColor
    navigationController?.navigationBar.barTintColor = drinkType?.mainColor
  }

  @IBAction func chooseButtonWasTapped(_ sender: Any) {
    time = timePicker.date
    intakeViewController.changeTimeForCurrentDate(time)
    navigationController?.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func cancelButtonWasTapped(_ sender: Any) {
    navigationController?.dismiss(animated: true, completion: nil)
  }

}
