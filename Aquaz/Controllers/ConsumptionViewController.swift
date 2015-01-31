//
//  ConsumptionViewController.swift
//  Aquaz
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

class ConsumptionViewController: StyledViewController {

  @IBOutlet weak var amountSlider: CustomSlider!
  @IBOutlet weak var amountLabel: UILabel!
  @IBOutlet weak var applyButton: UIButton!
  @IBOutlet weak var smallAmountButton: UIButton!
  @IBOutlet weak var mediumAmountButton: UIButton!
  @IBOutlet weak var largeAmountButton: UIButton!
  @IBOutlet weak var pickTimeButton: UIBarButtonItem!
  @IBOutlet weak var drinkView: DrinkView!
  
  var navigationTitleView: UIView!
  var navigationTitleLabel: UILabel!
  var navigationCurrentDayLabel: UILabel?

  var dayViewController: DayViewController!
  
  var currentDate: NSDate! {
    didSet {
      isCurrentDayToday = DateHelper.areDatesEqualByDays(date1: NSDate(), date2: currentDate)
    }
  }
  
  var drink: Drink!
  
  // Should be nil for add consumption mode, and not nil for edit consumption mode
  var consumption: Consumption? {
    didSet {
      if let consumption = consumption {
        drink = consumption.drink
        currentDate = consumption.date
        timeIsChoosen = true
      } else {
        timeIsChoosen = false
      }
    }
  }

  private var timeIsChoosen = false
  
  func changeTimeForCurrentDate(time: NSDate) {
    timeIsChoosen = true
    currentDate = DateHelper.dateByJoiningDateTime(datePart: currentDate, timePart: time)
    navigationCurrentDayLabel?.text = DateHelper.stringFromDateTime(currentDate, shortDateStyle: true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupPredefinedAmountButtons()
    setupAmountRelatedControlsWithInitialAmount()
    setupApplyButton()
    createCustomNavigationTitle()
    setupDrinkView()
    setupSlider()
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    if navigationTitleView != nil {
      navigationItem.titleView = navigationTitleView
    }
    
    applyColorScheme()
  }
  
  private func setupPredefinedAmountButtons() {
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
    return consumption?.amount.doubleValue ?? Double(drink.recentAmount.amount)
  }
  
  private func setupApplyButton() {
    let title = (viewMode == .Add)
      ? NSLocalizedString("CVC:Add", value: "Add", comment: "ConsumptionViewController: Title for Add button")
      : NSLocalizedString("CVC:Apply", value: "Apply", comment: "ConsumptionViewController: Title for Apply button")
    
    applyButton.setTitle(title, forState: .Normal)
  }

  private func applyColorScheme() {
    applyButton.backgroundColor = drink.darkColor
    smallAmountButton.backgroundColor = drink.darkColor
    mediumAmountButton.backgroundColor = drink.darkColor
    largeAmountButton.backgroundColor = drink.darkColor
    navigationController?.navigationBar.barTintColor = drink.mainColor
  }
  
  func cancelConsumption() {
    navigationController?.popViewControllerAnimated(true)
  }

  private func createCustomNavigationTitle() {
    var subtitleText: String
    
    if timeIsChoosen {
      subtitleText = DateHelper.stringFromDateTime(currentDate, shortDateStyle: true)
    } else {
      subtitleText = NSLocalizedString("CVC:Now", value: "Now", comment: "ConsumptionViewController: Subtitle of view if user adds consumption for today")
    }

    let titleParts = UIHelper.createNavigationTitleViewWithSubTitle(navigationController: navigationController!, titleText: drink.localizedName, subtitleText: subtitleText)
    
    navigationTitleView = titleParts.containerView
    navigationTitleLabel = titleParts.titleLabel
    navigationCurrentDayLabel = titleParts.subtitleLabel
    navigationItem.titleView = navigationTitleView
  }
  
  private func setupDrinkView() {
    drinkView.drink = drink
  }
  
  private func setupSlider() {
    amountSlider.tintColor = drink.mainColor
    amountSlider.maximumTrackTintColor = UIColor.blackColor().colorWithAlpha(0.2)
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
    let adjustedAmount = prepareAmountForStoring(amount)
    
    switch viewMode {
    case .Add: addConsumption(amount: adjustedAmount)
    case .Edit: updateConsumption(amount: adjustedAmount)
    }
    
    navigationController?.popViewControllerAnimated(true)
  }
  
  private func prepareAmountForStoring(amount: Double) -> Double {
    let precision = Settings.sharedInstance.generalVolumeUnits.value.precision
    return Units.sharedInstance.adjustMetricAmountForStoring(metricAmount: amount, unitType: .Volume, precision: precision)
  }
  
  private func addConsumption(#amount: Double) {
    var date: NSDate!
    if timeIsChoosen {
      date = currentDate
    } else {
      if isCurrentDayToday {
        date = NSDate()
      } else {
        date = DateHelper.dateByJoiningDateTime(datePart: currentDate, timePart: NSDate())
      }
    }
    
    drink.recentAmount.amount = amount
    let consumption = Consumption.addEntity(drink: drink, amount: amount, date: date)
    
    dayViewController.addConsumption(consumption)
  }
  
  private func updateConsumption(#amount: Double) {
    if let consumption = self.consumption {
      consumption.amount = amount
      consumption.date = currentDate
      ModelHelper.sharedInstance.save()
      
      dayViewController.consumptionsWereChanged(doSort: true)
    }
  }

  private func formatAmount(amount: Double, precision: Double? = nil, decimals: Int? = nil) -> String {
    let finalPrecision = precision ?? amountPrecision
    let finalDecimals = decimals ?? amountDecimals
    return Units.sharedInstance.formatMetricAmountToText(metricAmount: amount, unitType: .Volume, roundPrecision: finalPrecision, decimals: finalDecimals)
  }
  
  private func setAmountLabel(amount: Double) {
    amountLabel.text = formatAmount(amount)
  }

  private enum Mode {
    case Add, Edit
  }
  
  private var viewMode: Mode {
    return consumption == nil ? .Add : .Edit
  }
  
  private let predefinedAmounts = Settings.sharedInstance.generalVolumeUnits.value.predefinedAmounts
  private let amountPrecision = Settings.sharedInstance.generalVolumeUnits.value.precision
  private let amountDecimals = Settings.sharedInstance.generalVolumeUnits.value.decimals
  
  private var isCurrentDayToday: Bool = false

}
