//
//  IntakeViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 12.10.14.
//  Copyright © 2014 Sergey Balyakin. All rights reserved.
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
  @IBOutlet weak var drinkInformationLabel: UILabel!
  @IBOutlet weak var navigationTitleLabel: UILabel!
  @IBOutlet weak var navigationDateLabel: UILabel!
  
  private struct LocalizedStrings {
    
    lazy var addButtonTitle: String = NSLocalizedString("IVC:Add", value: "Add", comment: "IntakeViewController: Title for Add button")
    
    lazy var applyButtonTitle: String = NSLocalizedString("IVC:Apply", value: "Apply", comment: "IntakeViewController: Title for Apply button")
    
    lazy var nowNavigationSubtitle: String = NSLocalizedString("IVC:Now", value: "Now", comment: "IntakeViewController: Subtitle of view if user adds intake for today")
    
    lazy var alcoholicDrinkInformation: String = NSLocalizedString(
      "IVC:Alcoholic drinks cause dehydration by requiring more water to metabolize and by acting as diuretics.",
      value: "Alcoholic drinks cause dehydration by requiring more water to metabolize and by acting as diuretics.",
      comment: "IntakeViewController: Information about alcoholic drinks")
    
  }
  
  private var localizedStrings = LocalizedStrings()
  
  var date: NSDate! {
    didSet {
      isCurrentDayToday = DateHelper.areDatesEqualByDays(NSDate(), date)
    }
  }
  
  var drinkType: DrinkType!
  
  private var drink: Drink!
  
  // Should be nil for add intake mode, and not nil for edit intake mode
  var intake: Intake? {
    didSet {
      let dispatchGroup = dispatch_group_create()
      dispatch_group_enter(dispatchGroup)
      
      CoreDataStack.inPrivateContext { _ in
        if let intake = self.intake {
          self.drinkType = intake.drink.drinkType
          self.drink = intake.drink
          self.date = intake.date
          self.timeIsChoosen = true
        } else {
          self.timeIsChoosen = false
        }
        dispatch_group_leave(dispatchGroup)
      }
      
      dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER)
    }
  }

  private var timeIsChoosen = false
  
  private struct Constants {
    static let pickTimeSegue = "PickTime"
  }
  
  func changeTimeForCurrentDate(time: NSDate) {
    timeIsChoosen = true
    date = DateHelper.dateByJoiningDateTime(datePart: date, timePart: time)
    navigationDateLabel?.text = DateHelper.stringFromDateTime(date, shortDateStyle: true)
    UIHelper.adjustNavigationTitleViewSize(navigationItem)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    fetchDrink()
    
    setupUI()
    
    NSNotificationCenter.defaultCenter().addObserver(
      self,
      selector: #selector(self.preferredContentSizeChanged),
      name: UIContentSizeCategoryDidChangeNotification,
      object: nil)
  }

  private func fetchDrink() {
    if let _ = drink {
      return
    }
    
    let dispatchGroup = dispatch_group_create()
    dispatch_group_enter(dispatchGroup)
    
    CoreDataStack.inPrivateContext { privateContext in
      self.drink = Drink.fetchDrinkByType(self.drinkType, managedObjectContext: privateContext)
      dispatch_group_leave(dispatchGroup)
    }
    
    dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER)
  }

  private func setupUI() {
    setupPredefinedAmountButtons()
    setupAmountRelatedControlsWithInitialAmount()
    setupApplyButton()
    setupNavigationTitle()
    setupDrinkView()
    setupSlider()
    setupDrinkInformation()
    
    UIHelper.applyStyleToViewController(self)
    applyColorScheme()
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    UIHelper.adjustNavigationTitleViewSize(navigationItem)
    
    // If the navigation item contains a custom title view with children views,
    // on view controller dismissing the status bar is not taken into account
    // when the view is layouted.
    // It's a quite ugly solution, but now I don't have a better one.
    let deltaY = navigationController!.navigationBar.frame.maxY - view.frame.origin.y
    view.frame.origin.y += deltaY
    view.frame.size.height -= deltaY
  }

  func preferredContentSizeChanged() {
    amountLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    view.invalidateIntrinsicContentSize()
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
    var amount: Double!
    
    let dispatchGroup = dispatch_group_create()
    dispatch_group_enter(dispatchGroup)

    CoreDataStack.inPrivateContext { _ in
      amount = self.intake?.amount ?? self.drink.recentAmount.amount
      dispatch_group_leave(dispatchGroup)
    }
    
    dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER)
    
    return amount
  }
  
  private func setupApplyButton() {
    let title = (viewMode == .Add) ? localizedStrings.addButtonTitle : localizedStrings.applyButtonTitle
    applyButton.setTitle(title, forState: .Normal)
  }

  private func applyColorScheme() {
    applyButton.backgroundColor = drinkType.darkColor
    smallAmountButton.backgroundColor = drinkType.darkColor
    mediumAmountButton.backgroundColor = drinkType.darkColor
    largeAmountButton.backgroundColor = drinkType.darkColor
    navigationController?.navigationBar.barTintColor = drinkType.mainColor
    navigationTitleLabel.textColor = StyleKit.barTextColor
    navigationDateLabel.textColor = StyleKit.barTextColor
  }
  
  private func setupNavigationTitle() {
    let dateText: String
    
    if timeIsChoosen || !isCurrentDayToday {
      dateText = DateHelper.stringFromDateTime(date, shortDateStyle: true)
    } else {
      dateText = localizedStrings.nowNavigationSubtitle
    }

    navigationTitleLabel.text = drinkType.localizedName
    navigationDateLabel.text = dateText
  }
  
  private func setupDrinkView() {
    drinkView.drinkType = drinkType
  }
  
  private func setupSlider() {
    amountSlider.tintColor = drinkType.mainColor
    amountSlider.maximumTrackTintColor = UIColor(white: 0.8, alpha: 1)
  }
  
  private func setupDrinkInformation() {
    if drinkType.dehydrationFactor > 0 {
      drinkInformationLabel.text = localizedStrings.alcoholicDrinkInformation
      drinkInformationLabel.hidden = false
    } else {
      drinkInformationLabel.hidden = true
      drinkInformationLabel.text = ""
    }
  }
  
  @IBAction func cancelIntake(sender: UIBarButtonItem) {
    navigationController?.dismissViewControllerAnimated(true, completion: nil)
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
    if segue.identifier == Constants.pickTimeSegue {
      if let pickTimeViewController = segue.destinationViewController.contentViewController as? PickTimeViewController {
        pickTimeViewController.intakeViewController = self
        pickTimeViewController.time = date
      }
    }
  }
  
  private func applyIntake(amount: Double) {
    let adjustedAmount = self.prepareAmountForStoring(amount)
    
    switch self.viewMode {
    case .Add: self.addIntake(amount: adjustedAmount)
    case .Edit: self.updateIntake(amount: adjustedAmount)
    }
  }
  
  private func prepareAmountForStoring(amount: Double) -> Double {
    let precision = Settings.sharedInstance.generalVolumeUnits.value.precision
    return Units.sharedInstance.adjustMetricAmountForStoring(metricAmount: amount, unitType: .Volume, roundPrecision: precision)
  }
  
  private func computeIntakeDate() -> NSDate {
    if timeIsChoosen || !isCurrentDayToday {
      return date
    } else {
      return isCurrentDayToday ? NSDate() : DateHelper.dateByJoiningDateTime(datePart: date, timePart: NSDate())
    }
  }
  
  private func addIntake(amount amount: Double) {
    CoreDataStack.inPrivateContext { privateContext in
      let drink = try! privateContext.existingObjectWithID(self.drink.objectID) as! Drink
      
      IntakeHelper.addIntakeWithHealthKitChecks(
        amount: amount,
        drink: drink,
        intakeDate: self.computeIntakeDate(),
        viewController: self,
        managedObjectContext: privateContext,
        actionBeforeAddingIntakeToCoreData: {
          dispatch_async(dispatch_get_main_queue()) {
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
          }
        },
        actionAfterAddingIntakeToCoreData: nil)
    }
  }
  
  private func updateIntake(amount amount: Double) {
    if let intake = intake {
      CoreDataStack.inPrivateContext { privateContext in
        intake.amount = amount
        intake.date = self.date
        CoreDataStack.saveContext(privateContext)
      }
    }
    
    navigationController?.dismissViewControllerAnimated(true, completion: nil)
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
  
  private var predefinedAmounts: (small: Double, medium: Double, large: Double) { return Settings.sharedInstance.generalVolumeUnits.value.predefinedAmounts }
  private var amountPrecision: Double { return Settings.sharedInstance.generalVolumeUnits.value.precision }
  private var amountDecimals: Int { return Settings.sharedInstance.generalVolumeUnits.value.decimals }
  
  private var isCurrentDayToday: Bool = false

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
    case Millilitres: return (small: 200.0, medium: 330.0, large: 500.0)
    case FluidOunces: return (small: 236.5882365, medium: 354.8821875 , large: 502.7500025625) // 8, 12 and 17 fl oz
    }
  }
}