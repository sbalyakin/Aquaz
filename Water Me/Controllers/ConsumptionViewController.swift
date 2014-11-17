//
//  ConsumptionViewController.swift
//  Water Me
//
//  Created by Sergey Balyakin on 12.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

private extension Units.Volume {
  var precision: Double {
    switch self {
    case Millilitres: return 10.0
    case FluidOunces: return 0.5
    }
  }
  
  var decimals: Int {
    switch self {
    case Millilitres: return 0
    case FluidOunces: return 1
    }
  }
  
  var predefinedAmounts: (small: Double, medium: Double, large: Double) {
    switch self {
    case Millilitres: return (small: 100.0, medium: 200.0, large: 500.0)
    case FluidOunces: return (small: 118.29411825, medium: 236.5882365 , large: 502.7500025625) // 4, 8 and 17 fl oz
    }
  }
}

class ConsumptionViewController: UIViewController {
  
  @IBOutlet weak var amountSlider: UISlider!
  @IBOutlet weak var amountLabel: UILabel!
  @IBOutlet weak var applyButton: UIButton!
  @IBOutlet weak var smallAmountButton: UIButton!
  @IBOutlet weak var mediumAmountButton: UIButton!
  @IBOutlet weak var largeAmountButton: UIButton!
  
  var navigationTitleView: UIView!
  var navigationTitleLabel: UILabel!
  var navigationCurrentDayLabel: UILabel?

  var dayViewController: DayViewController!
  
  var currentDate: NSDate!
  var drink: Drink!
  
  // Should be nil for add consumption mode, and not nil for edit consumption mode
  var consumption: Consumption? {
    didSet {
      if let existingConsumption = consumption {
        drink = existingConsumption.drink
        currentDate = existingConsumption.date
      }
    }
  }
  
  func changeTimeForCurrentDate(time: NSDate) {
    currentDate = DateHelper.dateByJoiningDateTime(datePart: currentDate, timePart: time)
    if let dayLabel = navigationCurrentDayLabel {
      dayLabel.text = DateHelper.stringFromDateTime(currentDate)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupPredefinedAmountLabels()
    setupAmountRelatedControlsWithInitialAmount()
    setupApplyButton()
    createCustomNavigationTitle()
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    if navigationTitleView != nil {
      navigationItem.titleView = navigationTitleView
    }
  }
  
  private func setupPredefinedAmountLabels() {
    // Predefined amount is always non-fractional values, so we will format amount skipping fraction part
    smallAmountButton.setTitle(formatAmount(predefinedAmounts.small, precision: 1.0, decimals: 0), forState: .Normal)
    mediumAmountButton.setTitle(formatAmount(predefinedAmounts.medium, precision: 1.0, decimals: 0), forState: .Normal)
    largeAmountButton.setTitle(formatAmount(predefinedAmounts.large, precision: 1.0, decimals: 0), forState: .Normal)
  }
  
  private func setupAmountRelatedControlsWithInitialAmount() {
    let amount = getInitialAmount()
    setAmountLabel(amount)
    amountSlider.value = Float(amount)
  }
  
  private func getInitialAmount() -> Double {
    var amount = 0.0
    if let consumption = self.consumption {
      amount = consumption.amount.doubleValue
    } else {
      amount = Double(drink.recentAmount.amount)
    }
    
    return amount
  }
  
  private func setupApplyButton() {
    let title = (mode == .Add) ? "Add" : "Apply"
    applyButton.setTitle(title, forState: .Normal)
  }
  
  private func createCustomNavigationTitle() {
    let isToday = DateHelper.areDatesEqualByDays(date1: NSDate(), date2: currentDate)
    let date = (isToday && mode == .Add) ? "" : DateHelper.stringFromDateTime(currentDate)

    // TODO: Remove magical 100 value and find another way to calculate proper rectangle for the title view
    let navigationTitleViewRect = navigationController!.navigationBar.frame.rectByInsetting(dx: 100, dy: 0)
    navigationTitleView = UIView(frame: navigationTitleViewRect)
    
    var titleLabelRect = navigationTitleView.bounds
    if date.isEmpty {
      // Adjust inner label by offsetting inside its parent
      // without changing global titleVerticalPositionAdjustmentForBarMetrics,
      // because if change it on view appearing/disappearing there will be noticable title item jumping.
      let verticalAdjustment = navigationController!.navigationBar.titleVerticalPositionAdjustmentForBarMetrics(.Default)
      titleLabelRect.offset(dx: 0, dy: -verticalAdjustment)
    }
    
    navigationTitleLabel = UILabel(frame: titleLabelRect)
    navigationTitleLabel.autoresizingMask = .FlexibleWidth
    navigationTitleLabel.backgroundColor = UIColor.clearColor()
    navigationTitleLabel.text = drink.name
    let fontSize: CGFloat = date.isEmpty ? 18 : 16
    navigationTitleLabel.font = UIFont.boldSystemFontOfSize(fontSize)
    navigationTitleLabel.textAlignment = .Center
    navigationTitleView.addSubview(navigationTitleLabel)
    
    if !date.isEmpty {
      let currentDayLabelRect = navigationTitleView.bounds.rectByOffsetting(dx: 0, dy: 16)
      navigationCurrentDayLabel = UILabel(frame: currentDayLabelRect)
      navigationCurrentDayLabel!.autoresizingMask = navigationTitleLabel.autoresizingMask
      navigationCurrentDayLabel!.backgroundColor = UIColor.clearColor()
      navigationCurrentDayLabel!.font = UIFont.systemFontOfSize(12)
      navigationCurrentDayLabel!.textAlignment = .Center
      navigationCurrentDayLabel!.text = date
      navigationTitleView.addSubview(navigationCurrentDayLabel!)
    }
    
    navigationItem.titleView = navigationTitleView
  }
  
  @IBAction func amountSliderValueChanged(sender: AnyObject) {
    setAmountLabel(Double(amountSlider.value))
  }
  
  @IBAction func applyCustomConsumption(sender: AnyObject) {
    applyConsumption(Double(amountSlider.value))
  }
  
  @IBAction func applySmallConsumption(sender: AnyObject) {
    applyConsumption(predefinedAmounts.small)
  }
  
  @IBAction func applyMediumConsumption(sender: AnyObject) {
    applyConsumption(predefinedAmounts.medium)
  }
  
  @IBAction func applyLargeConsumption(sender: AnyObject) {
    applyConsumption(predefinedAmounts.large)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "PickTime" {
      if let pickTimeViewController = segue.destinationViewController as? PickTimeViewController {
        pickTimeViewController.consumptionViewController = self
        pickTimeViewController.time = currentDate
      }
    }
  }
  
  private func applyConsumption(amount: Double) {
    // Prepare amount for storing
    let precision = Settings.sharedInstance.generalVolumeUnits.value.precision
    let processedAmount = Units.sharedInstance.prepareAmountForStoring(amount: amount, unitType: .Volume, precision: precision)
    
    if let consumption = self.consumption {
      // Edit mode
      consumption.amount = processedAmount
      consumption.date = currentDate
      ModelHelper.sharedInstance.save()
      
      dayViewController.updateConsumptions()
    } else {
      // Add mode
      let date = DateHelper.dateByJoiningDateTime(datePart: currentDate, timePart: NSDate())
      
      // Store the consumption into Core Data
      drink.recentAmount.amount = processedAmount
      let consumption = Consumption.addEntity(drink: drink, amount: processedAmount, date: date, managedObjectContext: ModelHelper.sharedInstance.managedObjectContext)
      
      // Update day view controller
      dayViewController.addConsumption(consumption)
    }

    navigationController!.popViewControllerAnimated(true)
  }

  private func formatAmount(amount: Double, precision: Double? = nil, decimals: Int? = nil) -> String {
    let finalPrecision = precision != nil ? precision! : amountPrecision
    let finalDecimals = decimals != nil ? decimals! : amountDecimals
    return Units.sharedInstance.formatAmountToText(amount: amount, unitType: .Volume, precision: finalPrecision, decimals: finalDecimals)
  }
  
  private func setAmountLabel(amount: Double) {
    amountLabel.text = formatAmount(amount)
  }

  private enum Mode {
    case Add, Edit
  }
  
  private var mode: Mode {
    return consumption == nil ? .Add : .Edit
  }
  
  private let predefinedAmounts = Settings.sharedInstance.generalVolumeUnits.value.predefinedAmounts
  private let amountPrecision = Settings.sharedInstance.generalVolumeUnits.value.precision
  private let amountDecimals = Settings.sharedInstance.generalVolumeUnits.value.decimals

}
