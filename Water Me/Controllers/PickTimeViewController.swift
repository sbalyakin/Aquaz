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
    createCustomNavigationTitle()
  }
  
  func setupTimePicker() {
    timePicker.setDate(time, animated: false)

    let today = NSDate()
    let isTodayTime = DateHelper.areDatesEqualByDays(date1: today, date2: time)
    if isTodayTime {
      timePicker.maximumDate = today
    }
  }
  
  func createCustomNavigationTitle() {
    // TODO: Remove magical 100 value and find another way to calculate proper rectangle for the title view
    let titleViewRect = navigationController!.navigationBar.frame.rectByInsetting(dx: 100, dy: 0)

    // Container view is used for adjusting inner label by offsetting inside it
    // without changing global titleVerticalPositionAdjustmentForBarMetrics,
    // because if change it on view appearing/disappearing there will be noticable title item jumping.
    let titleView = UIView(frame: titleViewRect)
    
    let verticalAdjustment = navigationController!.navigationBar.titleVerticalPositionAdjustmentForBarMetrics(.Default)
    let titleLabelRect = titleView.bounds.rectByOffsetting(dx: 0, dy: -verticalAdjustment)
    let titleLabel = UILabel(frame: titleLabelRect)
    titleLabel.autoresizingMask = .FlexibleWidth
    titleLabel.backgroundColor = UIColor.clearColor()
    titleLabel.text = navigationItem.title
    titleLabel.font = UIFont.boldSystemFontOfSize(18)
    titleLabel.textAlignment = .Center
    titleView.addSubview(titleLabel)
    
    navigationItem.titleView = titleView
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
