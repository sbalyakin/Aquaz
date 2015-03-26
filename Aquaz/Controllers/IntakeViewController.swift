//
//  IntakeViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 12.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit
import CoreData

class IntakeViewController: UIViewController {

  @IBOutlet weak var amountSlider: CustomSlider!
  @IBOutlet weak var amountLabel: UILabel!
  @IBOutlet weak var applyButton: UIButton!
  @IBOutlet weak var smallAmountButton: UIButton!
  @IBOutlet weak var mediumAmountButton: UIButton!
  @IBOutlet weak var largeAmountButton: UIButton!
  @IBOutlet weak var pickTimeButton: UIBarButtonItem!
  @IBOutlet weak var drinkView: DrinkView!
  @IBOutlet weak var navigationTitleLabel: UILabel!
  @IBOutlet weak var navigationDateLabel: UILabel!
  
  weak var dayViewController: DayViewController!
  
  var currentDate: NSDate! {
    didSet {
      isCurrentDayToday = DateHelper.areDatesEqualByDays(date1: NSDate(), date2: currentDate)
    }
  }
  
  var drink: Drink!
  
  // Should be nil for add intake mode, and not nil for edit intake mode
  var intake: Intake? {
    didSet {
      if let intake = intake {
        drink = intake.drink
        currentDate = intake.date
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
    navigationDateLabel?.text = DateHelper.stringFromDateTime(currentDate, shortDateStyle: true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupPredefinedAmountButtons()
    setupAmountRelatedControlsWithInitialAmount()
    setupApplyButton()
    createCustomNavigationTitle()
    setupDrinkView()
    setupSlider()
    
    UIHelper.applyStyle(self)
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
    return intake?.amount.doubleValue ?? Double(drink.recentAmount.amount)
  }
  
  private func setupApplyButton() {
    let title = (viewMode == .Add)
      ? NSLocalizedString("IVC:Add", value: "Add", comment: "IntakeViewController: Title for Add button")
      : NSLocalizedString("IVC:Apply", value: "Apply", comment: "IntakeViewController: Title for Apply button")
    
    applyButton.setTitle(title, forState: .Normal)
  }

  private func applyColorScheme() {
    applyButton.backgroundColor = drink.darkColor
    smallAmountButton.backgroundColor = drink.darkColor
    mediumAmountButton.backgroundColor = drink.darkColor
    largeAmountButton.backgroundColor = drink.darkColor
    navigationController?.navigationBar.barTintColor = drink.mainColor
    navigationTitleLabel.textColor = StyleKit.barTextColor
    navigationDateLabel.textColor = StyleKit.barTextColor
  }
  
  @IBAction func cancelIntake(sender: UIBarButtonItem) {
    navigationController?.dismissViewControllerAnimated(true, completion: nil)
  }
  
  private func createCustomNavigationTitle() {
    let dateText: String
    
    if timeIsChoosen {
      dateText = DateHelper.stringFromDateTime(currentDate, shortDateStyle: true)
    } else {
      dateText = NSLocalizedString("IVC:Now", value: "Now", comment: "IntakeViewController: Subtitle of view if user adds intake for today")
    }

    navigationTitleLabel.text = drink.localizedName
    navigationDateLabel.text = dateText
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
  
  @IBAction func applyCustomIntake(sender: AnyObject) {
    applyIntake(Double(amountSlider.value))
  }
  
  @IBAction func applySmallIntake(sender: AnyObject) {
    applyIntake(predefinedAmounts.small)
  }
  
  @IBAction func applyMediumIntake(sender: AnyObject) {
    applyIntake(predefinedAmounts.medium)
  }
  
  @IBAction func applyLargeIntake(sender: AnyObject) {
    applyIntake(predefinedAmounts.large)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "PickTime" {
      if let pickTimeViewController = segue.destinationViewController.contentViewController as? PickTimeViewController {
        pickTimeViewController.intakeViewController = self
        pickTimeViewController.time = currentDate
      }
    }
  }
  
  private func applyIntake(amount: Double) {
    let adjustedAmount = prepareAmountForStoring(amount)
    
    switch viewMode {
    case .Add: addIntake(amount: adjustedAmount)
    case .Edit: updateIntake(amount: adjustedAmount)
    }
    
    navigationController?.dismissViewControllerAnimated(true, completion: nil)
  }
  
  private func prepareAmountForStoring(amount: Double) -> Double {
    let precision = Settings.sharedInstance.generalVolumeUnits.value.precision
    return Units.sharedInstance.adjustMetricAmountForStoring(metricAmount: amount, unitType: .Volume, roundPrecision: precision)
  }
  
  private func addIntake(#amount: Double) {
    let date: NSDate
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
    if let intake = Intake.addEntity(drink: drink, amount: amount, date: date, managedObjectContext: managedObjectContext) {
      dayViewController.addIntake(intake)
    }
  }
  
  private func updateIntake(#amount: Double) {
    if let intake = intake {
      intake.amount = amount
      intake.date = currentDate
      ModelHelper.save(managedObjectContext: managedObjectContext)
      
      dayViewController.intakesWereChanged(doSort: true)
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
    return intake == nil ? .Add : .Edit
  }
  
  private let predefinedAmounts = Settings.sharedInstance.generalVolumeUnits.value.predefinedAmounts
  private let amountPrecision = Settings.sharedInstance.generalVolumeUnits.value.precision
  private let amountDecimals = Settings.sharedInstance.generalVolumeUnits.value.decimals
  
  private var isCurrentDayToday: Bool = false

  private lazy var managedObjectContext: NSManagedObjectContext? = {
    if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
      return appDelegate.managedObjectContext
    } else {
      return nil
    }
  }()

}

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