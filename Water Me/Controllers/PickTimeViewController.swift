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
    
    // Do any additional setup after loading the view.
    timePicker.setDate(time, animated: false)
    
    setupNavigationBar()
  }
  
  func setupNavigationBar() {
    // Customize navigation bar
    let titleViewRect = navigationController!.navigationBar.frame.rectByInsetting(dx: 100, dy: 0)
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

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func chooseButtonWasTapped(sender: AnyObject) {
    time = timePicker.date
    consumptionViewController.changeTime(time)
    navigationController!.popViewControllerAnimated(true)
  }
  
  @IBAction func cancelButtonWasTapped(sender: AnyObject) {
    navigationController!.popViewControllerAnimated(true)
  }

}
