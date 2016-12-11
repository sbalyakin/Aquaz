//
//  IntakeViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 12.10.14.
//  Copyright © 2014 Sergey Balyakin. All rights reserved.
//

import UIKit
import CoreData

#if AQUAZLITE
import Appodeal
#endif

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
  
  fileprivate struct LocalizedStrings {
    
    lazy var addButtonTitle: String = NSLocalizedString("IVC:Add", value: "Add", comment: "IntakeViewController: Title for Add button")
    
    lazy var applyButtonTitle: String = NSLocalizedString("IVC:Apply", value: "Apply", comment: "IntakeViewController: Title for Apply button")
    
    lazy var nowNavigationSubtitle: String = NSLocalizedString("IVC:Now", value: "Now", comment: "IntakeViewController: Subtitle of view if user adds intake for today")
    
    lazy var alcoholicDrinkInformation: String = NSLocalizedString(
      "IVC:Alcoholic drinks cause dehydration by requiring more water to metabolize and by acting as diuretics.",
      value: "Alcoholic drinks cause dehydration by requiring more water to metabolize and by acting as diuretics.",
      comment: "IntakeViewController: Information about alcoholic drinks")
    
  }
  
  fileprivate var localizedStrings = LocalizedStrings()
  
  var date: Date! {
    didSet {
      isCurrentDayToday = DateHelper.areEqualDays(Date(), date)
    }
  }
  
  var drinkType: DrinkType!
  
  fileprivate var drink: Drink!
  
  // Should be nil for add intake mode, and not nil for edit intake mode
  var intake: Intake? {
    didSet {
      CoreDataStack.performOnPrivateContextAndWait { _ in
        if let intake = self.intake {
          self.drinkType = intake.drink.drinkType
          self.drink = intake.drink
          self.date = intake.date as Date!
          self.timeIsChoosen = true
        } else {
          self.timeIsChoosen = false
        }
      }
    }
  }

  fileprivate var timeIsChoosen = false
  
  fileprivate struct Constants {
    static let pickTimeSegue = "PickTime"
  }
  
  func changeTimeForCurrentDate(_ time: Date) {
    timeIsChoosen = true
    date = DateHelper.dateByJoiningDateTime(datePart: date, timePart: time)
    navigationDateLabel?.text = DateHelper.stringFromDateTime(date, shortDateStyle: true)
    UIHelper.adjustNavigationTitleViewSize(navigationItem)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    #if AQUAZLITE
    checkForShowAds()
    #endif
    
    fetchDrink()
    
    setupUI()
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.preferredContentSizeChanged),
      name: NSNotification.Name.UIContentSizeCategoryDidChange,
      object: nil)
  }

  #if AQUAZLITE
  private func checkForShowAds() {
    if Settings.sharedInstance.generalFullVersion.value || Settings.sharedInstance.generalAdCounter.value > 0 {
      return
    }
    
    if Appodeal.isReadyForShow(with: .skippableVideo) {
      Appodeal.showAd(.skippableVideo, rootViewController: self.navigationController)
      Settings.sharedInstance.generalAdCounter.value = GlobalConstants.numberOfIntakesToShowAd
    }
  }
  #endif
  
  fileprivate func fetchDrink() {
    if let _ = drink {
      return
    }
    
    CoreDataStack.performOnPrivateContextAndWait { privateContext in
      self.drink = Drink.fetchDrinkByType(self.drinkType, managedObjectContext: privateContext)
    }
  }

  fileprivate func setupUI() {
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
    NotificationCenter.default.removeObserver(self)
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
    amountLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
    view.invalidateIntrinsicContentSize()
  }

  fileprivate func setupPredefinedAmountButtons() {
    // Predefined amount is always non-fractional values, so we will format amount skipping fraction part
    smallAmountButton.setTitle(formatAmount(predefinedAmounts.small, precision: 1.0, decimals: 0), for: UIControlState())
    mediumAmountButton.setTitle(formatAmount(predefinedAmounts.medium, precision: 1.0, decimals: 0), for: UIControlState())
    largeAmountButton.setTitle(formatAmount(predefinedAmounts.large, precision: 1.0, decimals: 0), for: UIControlState())
  }
  
  fileprivate func setupAmountRelatedControlsWithInitialAmount() {
    let amount = getInitialAmount()
    setAmountLabel(amount)
    amountSlider.value = Float(amount)
  }
  
  fileprivate func getInitialAmount() -> Double {
    var amount: Double!
    
    CoreDataStack.performOnPrivateContextAndWait { _ in
      amount = self.intake?.amount ?? self.drink.recentAmount.amount
    }
    
    return amount
  }
  
  fileprivate func setupApplyButton() {
    let title = (viewMode == .add) ? localizedStrings.addButtonTitle : localizedStrings.applyButtonTitle
    applyButton.setTitle(title, for: UIControlState())
  }

  fileprivate func applyColorScheme() {
    applyButton.backgroundColor = drinkType.darkColor
    smallAmountButton.backgroundColor = drinkType.darkColor
    mediumAmountButton.backgroundColor = drinkType.darkColor
    largeAmountButton.backgroundColor = drinkType.darkColor
    navigationController?.navigationBar.barTintColor = drinkType.mainColor
    navigationTitleLabel.textColor = StyleKit.barTextColor
    navigationDateLabel.textColor = StyleKit.barTextColor
  }
  
  fileprivate func setupNavigationTitle() {
    let dateText: String
    
    if timeIsChoosen || !isCurrentDayToday {
      dateText = DateHelper.stringFromDateTime(date, shortDateStyle: true)
    } else {
      dateText = localizedStrings.nowNavigationSubtitle
    }

    navigationTitleLabel.text = drinkType.localizedName
    navigationDateLabel.text = dateText
  }
  
  fileprivate func setupDrinkView() {
    drinkView.drinkType = drinkType
  }
  
  fileprivate func setupSlider() {
    amountSlider.tintColor = drinkType.mainColor
    amountSlider.maximumTrackTintColor = UIColor(white: 0.8, alpha: 1)
  }
  
  fileprivate func setupDrinkInformation() {
    if drinkType.dehydrationFactor > 0 {
      drinkInformationLabel.text = localizedStrings.alcoholicDrinkInformation
      drinkInformationLabel.isHidden = false
    } else {
      drinkInformationLabel.isHidden = true
      drinkInformationLabel.text = ""
    }
  }
  
  @IBAction func cancelIntake(_ sender: UIBarButtonItem) {
    navigationController?.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func amountSliderValueChanged(_ sender: Any) {
    setAmountLabel(Double(amountSlider.value))
  }
  
  @IBAction func applyCustomIntake(_ sender: Any) {
    applyIntake(Double(amountSlider.value))
  }
  
  @IBAction func applySmallIntake(_ sender: Any) {
    applyIntake(predefinedAmounts.small)
  }
  
  @IBAction func applyMediumIntake(_ sender: Any) {
    applyIntake(predefinedAmounts.medium)
  }
  
  @IBAction func applyLargeIntake(_ sender: Any) {
    applyIntake(predefinedAmounts.large)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Constants.pickTimeSegue {
      if let pickTimeViewController = segue.destination.contentViewController as? PickTimeViewController {
        pickTimeViewController.intakeViewController = self
        pickTimeViewController.time = date
      }
    }
  }
  
  fileprivate func applyIntake(_ amount: Double) {
    let adjustedAmount = self.prepareAmountForStoring(amount)
    
    switch self.viewMode {
    case .add: self.addIntake(amount: adjustedAmount)
    case .edit: self.updateIntake(amount: adjustedAmount)
    }
  }
  
  fileprivate func prepareAmountForStoring(_ amount: Double) -> Double {
    let precision = Settings.sharedInstance.generalVolumeUnits.value.precision
    return Units.sharedInstance.adjustMetricAmountForStoring(metricAmount: amount, unitType: .volume, roundPrecision: precision)
  }
  
  fileprivate func computeIntakeDate() -> Date {
    if timeIsChoosen || !isCurrentDayToday {
      return date
    } else {
      return isCurrentDayToday ? Date() : DateHelper.dateByJoiningDateTime(datePart: date, timePart: Date())
    }
  }
  
  fileprivate func addIntake(amount: Double) {
    CoreDataStack.performOnPrivateContext { privateContext in
      let drink = try! privateContext.existingObject(with: self.drink.objectID) as! Drink
      _ = Intake.addEntity(drink: drink, amount: amount, date: self.computeIntakeDate(), managedObjectContext: privateContext)
    }
    
    navigationController?.dismiss(animated: true, completion: nil)
  }
  
  fileprivate func updateIntake(amount: Double) {
    if let intake = intake {
      CoreDataStack.performOnPrivateContext { privateContext in
        let drink = try! privateContext.existingObject(with: self.drink.objectID) as! Drink
        drink.recentAmount.amount = amount

        intake.amount = amount
        intake.date = self.date
        
        CoreDataStack.saveContext(privateContext)
      }
    }
    
    navigationController?.dismiss(animated: true, completion: nil)
  }

  fileprivate func formatAmount(_ amount: Double, precision: Double? = nil, decimals: Int? = nil) -> String {
    let finalPrecision = precision ?? amountPrecision
    let finalDecimals = decimals ?? amountDecimals
    return Units.sharedInstance.formatMetricAmountToText(metricAmount: amount, unitType: .volume, roundPrecision: finalPrecision, decimals: finalDecimals)
  }
  
  fileprivate func setAmountLabel(_ amount: Double) {
    amountLabel.text = formatAmount(amount)
  }

  fileprivate enum Mode {
    case add, edit
  }
  
  fileprivate var viewMode: Mode {
    return intake == nil ? .add : .edit
  }
  
  fileprivate var predefinedAmounts: (small: Double, medium: Double, large: Double) { return Settings.sharedInstance.generalVolumeUnits.value.predefinedAmounts }
  fileprivate var amountPrecision: Double { return Settings.sharedInstance.generalVolumeUnits.value.precision }
  fileprivate var amountDecimals: Int { return Settings.sharedInstance.generalVolumeUnits.value.decimals }
  
  fileprivate var isCurrentDayToday: Bool = false

}

// MARK: Units.Volume extension -
private extension Units.Volume {
  var precision: Double {
    switch self {
    case .millilitres: return 10.0
    case .fluidOunces: return 0.5
    }
  }
  
  var decimals: Int {
    switch self {
    case .millilitres: return 0
    case .fluidOunces: return 1
    }
  }
  
  var predefinedAmounts: (small: Double, medium: Double, large: Double) {
    switch self {
    case .millilitres: return (small: 200.0, medium: 330.0, large: 500.0)
    case .fluidOunces: return (small: 236.5882365, medium: 354.8821875 , large: 502.7500025625) // 8, 12 and 17 fl oz
    }
  }
}
