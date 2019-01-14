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
          self.date = intake.date
          self.timeIsChoosen = true
        } else {
          self.timeIsChoosen = false
        }
      }
    }
  }

  fileprivate var timeIsChoosen = false
  
  fileprivate struct Seques {
    static let pickTime = "PickTime"
    static let changePredefinedAmount = "ChangePredefinedAmount"
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
      name: UIContentSizeCategory.didChangeNotification,
      object: nil)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    checkHelpTip()
  }

  #if AQUAZLITE
  private func checkForShowAds() {
    if Settings.sharedInstance.generalFullVersion.value || Settings.sharedInstance.generalAdCounter.value > 0 {
      return
    }
    
    if Appodeal.isReadyForShow(with: .nonSkippableVideo) {
      Appodeal.showAd(.nonSkippableVideo, rootViewController: self.navigationController!)
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

  @objc func preferredContentSizeChanged() {
    amountLabel.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
    view.invalidateIntrinsicContentSize()
  }

  fileprivate func setupPredefinedAmountButtons() {
    smallAmountButton.setTitle(formatAmount(predefinedAmountSmall, minimumFractionDigits: 0), for: .normal)
    mediumAmountButton.setTitle(formatAmount(predefinedAmountMedium, minimumFractionDigits: 0), for: .normal)
    largeAmountButton.setTitle(formatAmount(predefinedAmountLarge, minimumFractionDigits: 0), for: .normal)
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
    applyButton.setTitle(title, for: UIControl.State())
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
    amountSlider.minimumValue = Float(Settings.sharedInstance.generalVolumeUnits.value.minimumAmount)
    amountSlider.maximumValue = Float(Settings.sharedInstance.generalVolumeUnits.value.maximumAmount)
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
    applyIntake(predefinedAmountSmall)
  }
  
  @IBAction func applyMediumIntake(_ sender: Any) {
    applyIntake(predefinedAmountMedium)
  }
  
  @IBAction func applyLargeIntake(_ sender: Any) {
    applyIntake(predefinedAmountLarge)
  }
  
  @IBAction func changePredefinedAmount(_ gestureRecognizer: UILongPressGestureRecognizer) {
    if gestureRecognizer.state == .began {
      performSegue(withIdentifier: "ChangePredefinedAmount", sender: gestureRecognizer.view)
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier! {
    case Seques.pickTime:
      if let pickTimeViewController = segue.destination.contentViewController as? PickTimeViewController {
        pickTimeViewController.intakeViewController = self
        pickTimeViewController.time = date
      }
      
    case Seques.changePredefinedAmount:
      if let navigationController = segue.destination as? UINavigationController,
         let viewController = navigationController.topViewController as? PredefinedAmountViewController,
         let popoverController = navigationController.popoverPresentationController
      {
        let senderView = sender as! UIView
        let predefinedAmountType = getPredefinedAmountType(buttonView: senderView)
        
        viewController.didSelectRowFunction = { amount in
          let button = sender as! RoundedButton
          let title = self.formatAmount(amount, minimumFractionDigits: 0)
          button.setTitle(title, for: .normal)
          Settings.sharedInstance.generalPredefinedAmounts[(predefinedAmountType, self.drinkType)] = amount
        }
        
        viewController.preferredContentSize = CGSize(width: 200, height: 216) // 216 is default height for UIPickerView
        viewController.amount = Settings.sharedInstance.generalPredefinedAmounts[(predefinedAmountType, drinkType)]
        popoverController.sourceView = senderView
        popoverController.sourceRect = senderView.bounds
        popoverController.delegate = self
      }
      
    default:
      break
    }
  }
  
  private func getPredefinedAmountType(buttonView: UIView!) -> Settings.PredefinedAmountType {
    switch buttonView {
    case smallAmountButton: return .small
    case mediumAmountButton: return .medium
    case largeAmountButton: return .large
    default:
      assertionFailure("Unexpected button for predefined amount type recognition")
      return .small
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
      drink.recentAmount.amount = amount

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

  fileprivate func formatAmount(_ amount: Double) -> String {
    return formatAmount(amount, minimumFractionDigits: amountDecimals)
  }
  
  fileprivate func formatAmount(_ amount: Double, minimumFractionDigits: Int) -> String {
    return Units.sharedInstance.formatMetricAmountToText(metricAmount: amount,
                                                         unitType: .volume,
                                                         roundPrecision: amountPrecision,
                                                         minimumFractionDigits: minimumFractionDigits,
                                                         maximumFractionDigits: amountDecimals,
                                                         displayUnits: true)
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

  fileprivate func checkHelpTip() {
    if Settings.sharedInstance.uiIntakeHelpTipIsShown.value || view.window == nil {
      return
    }
    
    showHelpTipForView(mediumAmountButton)
  }
  
  fileprivate func showHelpTipForView(_ view: UIView) {
    SystemHelper.executeBlockWithDelay(GlobalConstants.helpTipDelayToShow) {
      if self.view.window == nil {
        return
      }
      
      let text = NSLocalizedString("IVC:Use long press to adjust an amount",
                                   value: "Use long press to adjust an amount",
                                   comment: "IntakeViewController: Text for help tip about long press for predefined amounts buttons")
      
      if let helpTip = JDFTooltipView(targetView: view, hostView: self.view, tooltipText: text, arrowDirection: .down, width: self.view.frame.width / 2) {
        UIHelper.showHelpTip(helpTip)
        Settings.sharedInstance.uiIntakeHelpTipIsShown.value = true
      }
    }
  }

  fileprivate var predefinedAmountSmall: Double { return Settings.sharedInstance.generalPredefinedAmounts[(.small, drinkType)] }
  fileprivate var predefinedAmountMedium: Double { return Settings.sharedInstance.generalPredefinedAmounts[(.medium, drinkType)] }
  fileprivate var predefinedAmountLarge: Double { return Settings.sharedInstance.generalPredefinedAmounts[(.large, drinkType)] }

  fileprivate let amountPrecision = Settings.sharedInstance.generalVolumeUnits.value.precision
  fileprivate let amountDecimals = Settings.sharedInstance.generalVolumeUnits.value.decimals
  
  fileprivate var isCurrentDayToday: Bool = false

}

extension IntakeViewController: UIPopoverPresentationControllerDelegate {
  
  func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
    return .none
  }
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
  
  var minimumAmount: Double {
    switch self {
    case .millilitres: return 50
    case .fluidOunces: return Quantity.convert(amount: 1, unitFrom: FluidOunceUnit(), unitTo: MilliliterUnit())
    }
  }

  var maximumAmount: Double {
    switch self {
    case .millilitres: return 1000
    case .fluidOunces: return Quantity.convert(amount: 34, unitFrom: FluidOunceUnit(), unitTo: MilliliterUnit())
    }
  }
}
