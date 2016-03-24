//
//  TodayViewController.swift
//  Widget
//
//  Created by Sergey Balyakin on 06.04.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit
import CoreData
import NotificationCenter
import Fabric
import Crashlytics

class TodayViewController: UIViewController, NCWidgetProviding {
  
  // MARK: Properties
  
  @IBOutlet weak var progressLabel: UILabel!
  @IBOutlet weak var progressView: MultiProgressView!
  @IBOutlet weak var drink1AmountLabel: UILabel!
  @IBOutlet weak var drink1View: DrinkView!
  @IBOutlet weak var drink1TitleLabel: UILabel!
  @IBOutlet weak var drink2AmountLabel: UILabel!
  @IBOutlet weak var drink2View: DrinkView!
  @IBOutlet weak var drink2TitleLabel: UILabel!
  @IBOutlet weak var drink3AmountLabel: UILabel!
  @IBOutlet weak var drink3View: DrinkView!
  @IBOutlet weak var drink3TitleLabel: UILabel!
  
  private var drink1: Drink!
  private var drink2: Drink!
  private var drink3: Drink!
  
  private var progressViewSection: MultiProgressView.Section!
  private var wormhole: MMWormhole!
  private var waterGoal: Double?
  private var hydration: Double?
  private var dehydration: Double?

  // Use a separate CoreDataStack instance for the today extension
  // in order to exclude synchronization problems for managed object contexts.
  private var coreDataStack = CoreDataStack()
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    Fabric.with([Crashlytics()])
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupDrinksUI()
    setupProgressView()
    setupCoreDataSynchronization()
    setupNotificationsObservation()
    
    if #available(iOSApplicationExtension 9.0, *) {
      setupHeathKitSynchronization()
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    fetchData {
      dispatch_async(dispatch_get_main_queue()) {
        self.updateUI(animated: false)
      }
    }
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
    // It's necessary to reset the managed object context in order to finalize background tasks correctly.
    coreDataStack.inPrivateContext { privateContext in
      privateContext.reset()
    }
  }

  private func setupCoreDataSynchronization() {
    wormhole = MMWormhole(applicationGroupIdentifier: GlobalConstants.appGroupName, optionalDirectory: GlobalConstants.wormholeOptionalDirectory)
  }

  private func setupProgressView() {
    progressView.animationDuration = 0.7
    progressViewSection = progressView.addSection(color: StyleKit.waterColor)
  }
  
  private func setupDrinksUI() {
    drink1TitleLabel.text = " "
    drink1AmountLabel.text = " "
    
    drink2TitleLabel.text = " "
    drink2AmountLabel.text = " "
    
    drink3TitleLabel.text = " "
    drink3AmountLabel.text = " "
  }

  private func setupNotificationsObservation() {
    coreDataStack.inPrivateContext { privateContext in
      NSNotificationCenter.defaultCenter().addObserver(
        self,
        selector: #selector(self.managedObjectContextDidSave(_:)),
        name: NSManagedObjectContextDidSaveNotification,
        object: privateContext)
    }
  }
  
  @available(iOSApplicationExtension 9.0, *)
  private func setupHeathKitSynchronization() {
    coreDataStack.inPrivateContext { privateContext in
      HealthKitProvider.sharedInstance.initSynchronizationForManagedObjectContext(privateContext)
    }
  }

  func managedObjectContextDidSave(notification: NSNotification) {
    wormhole.passMessageObject(notification, identifier: GlobalConstants.wormholeMessageFromWidget)
  }
  
  private func fetchDrinks(managedObjectContext managedObjectContext: NSManagedObjectContext) {
    var drinkIndexesToDisplay = [Int]()
    var drinkIndexes = Array(0..<Drink.getDrinksCount())
    
    let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
    if let intake1: Intake = CoreDataHelper.fetchManagedObject(managedObjectContext: managedObjectContext, predicate: nil, sortDescriptors: [sortDescriptor]) {
      let drinkIndex1 = intake1.drink.index.integerValue
      drinkIndexesToDisplay += [drinkIndex1]
      if let index = drinkIndexes.indexOf(drinkIndex1) {
        drinkIndexes.removeAtIndex(index)
      } else {
        assert(false)
      }
      
      let predicate2 = NSPredicate(format: "%K != %d", "drink.index", drinkIndex1)
      
      if let intake2: Intake = CoreDataHelper.fetchManagedObject(managedObjectContext: managedObjectContext, predicate: predicate2, sortDescriptors: [sortDescriptor]) {
        let drinkIndex2 = intake2.drink.index.integerValue
        drinkIndexesToDisplay += [drinkIndex2]
        if let index = drinkIndexes.indexOf(drinkIndex2) {
          drinkIndexes.removeAtIndex(index)
        } else {
          assert(false)
        }
        
        let predicate3 = NSPredicate(format: "%K != %d AND %K != %d", "drink.index", drinkIndex1, "drink.index", drinkIndex2)
        
        if let intake3: Intake = CoreDataHelper.fetchManagedObject(managedObjectContext: managedObjectContext, predicate: predicate3, sortDescriptors: [sortDescriptor]) {
          drinkIndexesToDisplay += [intake3.drink.index.integerValue]
        }
      }
    }
    
    if drinkIndexesToDisplay.count < 1 {
      drinkIndexesToDisplay += [drinkIndexes.removeAtIndex(0)]
    }
    
    if drinkIndexesToDisplay.count < 2 {
      drinkIndexesToDisplay += [drinkIndexes.removeAtIndex(0)]
    }
    
    if drinkIndexesToDisplay.count < 3 {
      drinkIndexesToDisplay += [drinkIndexes.removeAtIndex(0)]
    }
    
    drinkIndexesToDisplay.sortInPlace(<)
    
    let drinks = Drink.fetchAllDrinksIndexed(managedObjectContext: managedObjectContext)
    
    self.drink1 = drinks[drinkIndexesToDisplay[0]]
    self.drink2 = drinks[drinkIndexesToDisplay[1]]
    self.drink3 = drinks[drinkIndexesToDisplay[2]]
  }
  
  private func fetchWaterIntake(managedObjectContext managedObjectContext: NSManagedObjectContext) {
    let date = NSDate()
    
    self.waterGoal = WaterGoal.fetchWaterGoalForDate(date, managedObjectContext: managedObjectContext)?.amount
    
    let amount = Intake.fetchIntakeAmountPartsGroupedBy(.Day,
      beginDate: date,
      endDate: DateHelper.addToDate(date, years: 0, months: 0, days: 1),
      dayOffsetInHours: 0,
      aggregateFunction: .Summary,
      managedObjectContext: managedObjectContext).first!
    
    self.hydration = amount.hydration
    self.dehydration = amount.dehydration
  }
  
  private func fetchData(completion: () -> ()) {
    coreDataStack.inPrivateContext { privateContext in
      if !Settings.sharedInstance.generalHasLaunchedOnce.value {
        CoreDataPrePopulation.prePopulateCoreData(managedObjectContext: privateContext, saveContext: true)
      }
    
      self.fetchDrinks(managedObjectContext: privateContext)
      self.fetchWaterIntake(managedObjectContext: privateContext)
      completion()
    }
  }
  
  private func updateUI(animated animated: Bool) {
    updateDrinks()
    updateWaterIntakes(animated: animated)
  }
  
  private func updateDrinks() {
    let drinksInfo = getDrinksInfo()
    
    drink1AmountLabel.text = formatWaterVolume(drinksInfo[0].amount)
    drink1TitleLabel.text = drinksInfo[0].name
    drink1View.drinkType = drinksInfo[0].drinkType
    
    drink2AmountLabel.text = formatWaterVolume(drinksInfo[1].amount)
    drink2TitleLabel.text = drinksInfo[1].name
    drink2View.drinkType = drinksInfo[1].drinkType
    
    drink3AmountLabel.text = formatWaterVolume(drinksInfo[2].amount)
    drink3TitleLabel.text = drinksInfo[2].name
    drink3View.drinkType = drinksInfo[2].drinkType
  }
  
  private func getDrinksInfo() -> [(amount: Double, name: String, drinkType: DrinkType)] {
    let dispatchGroup = dispatch_group_create()
    dispatch_group_enter(dispatchGroup)

    var drinksInfo: [(amount: Double, name: String, drinkType: DrinkType)]!
    
    coreDataStack.inPrivateContext { _ in
      drinksInfo = [
        (amount: self.drink1.recentAmount.amount, name: self.drink1.localizedName, drinkType: self.drink1.drinkType),
        (amount: self.drink2.recentAmount.amount, name: self.drink2.localizedName, drinkType: self.drink2.drinkType),
        (amount: self.drink3.recentAmount.amount, name: self.drink3.localizedName, drinkType: self.drink3.drinkType)]
      
      dispatch_group_leave(dispatchGroup)
    }
    
    dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER)
    
    return drinksInfo
  }

  private func updateWaterIntakes(animated animated: Bool) {
    if let waterGoal = waterGoal,
       let hydration = hydration,
       let dehydration = dehydration
    {
      updateProgressView(waterGoal: waterGoal + dehydration, overallWaterIntake: hydration, animated: animated)
      updateProgressLabel(waterGoal: waterGoal + dehydration, overallWaterIntake: hydration, animated: animated)
    } else {
      progressViewSection.factor = 0
      progressLabel.text = NSLocalizedString("TodayExtension:Updating...", value: "Updating...", comment: "TodayExtension: Temporary text for amount label")
    }
  }
  
  private func updateProgressView(waterGoal waterGoal: Double, overallWaterIntake: Double, animated: Bool) {
    let newFactor = CGFloat(overallWaterIntake / waterGoal)
    if progressViewSection.factor != newFactor {
      if animated {
        progressViewSection.setFactorWithAnimation(newFactor)
      } else {
        progressViewSection.factor = newFactor
      }
    }
  }
  
  private func updateProgressLabel(waterGoal waterGoal: Double, overallWaterIntake: Double, animated: Bool) {
    let intakeText: String
    
    if Settings.sharedInstance.uiDisplayDailyWaterIntakeInPercents.value {
      let formatter = NSNumberFormatter()
      formatter.numberStyle = .PercentStyle
      formatter.maximumFractionDigits = 0
      formatter.multiplier = 100
      let drinkedPart = overallWaterIntake / waterGoal
      intakeText = formatter.stringFromNumber(drinkedPart)!
    } else {
      intakeText = formatWaterVolume(overallWaterIntake, displayUnits: false)
    }
    
    let waterGoalText = formatWaterVolume(waterGoal)
    
    let template = NSLocalizedString("TodayExtension:%1$@ of %2$@", value: "%1$@ of %2$@",
      comment: "TodayExtension: Current daily water intake of water intake goal")
    let text = String.localizedStringWithFormat(template, intakeText, waterGoalText)
    
    if animated {
      progressLabel.setTextWithAnimation(text)
    } else {
      progressLabel.text = text
    }
  }
  
  private func formatWaterVolume(value: Double, displayUnits: Bool = true) -> String {
    return Units.sharedInstance.formatMetricAmountToText(
      metricAmount: value,
      unitType: .Volume,
      roundPrecision: Settings.sharedInstance.generalVolumeUnits.value.precision,
      decimals: Settings.sharedInstance.generalVolumeUnits.value.decimals)
  }
  
  func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
    fetchData {
      dispatch_async(dispatch_get_main_queue()) {
        self.updateUI(animated: false)
        completionHandler(.NewData)
      }
    }
  }
  
  func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
    return UIEdgeInsetsZero
  }

  @IBAction func drink1WasTapped(sender: UITapGestureRecognizer) {
    addIntakeForDrink(drink1)
  }
  
  @IBAction func drink2WasTapped(sender: UITapGestureRecognizer) {
    addIntakeForDrink(drink2)
  }
  
  @IBAction func drink3WasTapped(sender: UITapGestureRecognizer) {
    addIntakeForDrink(drink3)
  }
  
  private func addIntakeForDrink(drink: Drink!) {
    if drink == nil {
      return
    }
    
    coreDataStack.inPrivateContext { privateContext in
      Intake.addEntity(
        drink: drink,
        amount: drink.recentAmount.amount,
        date: NSDate(),
        managedObjectContext: privateContext,
        saveImmediately: true)

      self.fetchData {
        dispatch_async(dispatch_get_main_queue()) {
          self.updateUI(animated: true)
        }
      }
    }
  }
  
  @IBAction func openApplicationWasTapped() {
    let url = NSURL(string: GlobalConstants.applicationSchemeURL)
    extensionContext?.openURL(url!, completionHandler: nil)
  }
}

private extension Units.Volume {
  var precision: Double {
    switch self {
    case Millilitres: return 1.0
    case FluidOunces: return 0.1
    }
  }
  
  var decimals: Int {
    switch self {
    case Millilitres: return 0
    case FluidOunces: return 1
    }
  }
}