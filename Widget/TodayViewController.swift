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
  
  private var mainManagedObjectContext: NSManagedObjectContext {
    return coreDataStack.mainContext
  }

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
    mainManagedObjectContext.reset()
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
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "managedObjectContextDidSave:",
      name: NSManagedObjectContextDidSaveNotification,
      object: mainManagedObjectContext)
  }
  
  func managedObjectContextDidSave(notification: NSNotification) {
    wormhole.passMessageObject(notification, identifier: GlobalConstants.wormholeMessageFromWidget)
  }
  
  private func fetchDrinks() {
    var drinkIndexesToDisplay = [Int]()
    var drinkIndexes = Array(0..<Drink.getDrinksCount())
    
    let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
    if let intake1: Intake = CoreDataHelper.fetchManagedObject(managedObjectContext: mainManagedObjectContext, predicate: nil, sortDescriptors: [sortDescriptor]) {
      let drinkIndex1 = intake1.drink.index.integerValue
      drinkIndexesToDisplay += [drinkIndex1]
      if let index = drinkIndexes.indexOf(drinkIndex1) {
        drinkIndexes.removeAtIndex(index)
      } else {
        assert(false)
      }
      
      let predicate2 = NSPredicate(format: "%K != %d", "drink.index", drinkIndex1)
      
      if let intake2: Intake = CoreDataHelper.fetchManagedObject(managedObjectContext: mainManagedObjectContext, predicate: predicate2, sortDescriptors: [sortDescriptor]) {
        let drinkIndex2 = intake2.drink.index.integerValue
        drinkIndexesToDisplay += [drinkIndex2]
        if let index = drinkIndexes.indexOf(drinkIndex2) {
          drinkIndexes.removeAtIndex(index)
        } else {
          assert(false)
        }
        
        let predicate3 = NSPredicate(format: "%K != %d AND %K != %d", "drink.index", drinkIndex1, "drink.index", drinkIndex2)
        
        if let intake3: Intake = CoreDataHelper.fetchManagedObject(managedObjectContext: mainManagedObjectContext, predicate: predicate3, sortDescriptors: [sortDescriptor]) {
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
    
    let drinks = Drink.fetchAllDrinksIndexed(managedObjectContext: mainManagedObjectContext)
    
    drink1 = drinks[drinkIndexesToDisplay[0]]
    drink2 = drinks[drinkIndexesToDisplay[1]]
    drink3 = drinks[drinkIndexesToDisplay[2]]
  }
  
  private func fetchWaterIntake() {
    let date = NSDate()
    
    waterGoal = WaterGoal.fetchWaterGoalForDate(date, managedObjectContext: mainManagedObjectContext)?.amount
    
    let amount = Intake.fetchIntakeAmountPartsGroupedBy(.Day,
      beginDate: date,
      endDate: DateHelper.addToDate(date, years: 0, months: 0, days: 1),
      dayOffsetInHours: 0,
      aggregateFunction: .Summary,
      managedObjectContext: mainManagedObjectContext).first!
    
    hydration = amount.hydration
    dehydration = amount.dehydration
  }
  
  private func fetchData(completion: () -> ()) {
    mainManagedObjectContext.performBlock {
      self.fetchDrinks()
      self.fetchWaterIntake()
      completion()
    }
  }
  
  private func updateUI(animated animated: Bool) {
    updateDrinks()
    updateWaterIntakes(animated: animated)
  }
  
  private func updateDrinks() {
    drink1AmountLabel.text = formatWaterVolume(drink1.recentAmount.amount)
    drink1TitleLabel.text = drink1.localizedName
    drink1View.drinkType = drink1.drinkType
    
    drink2AmountLabel.text = formatWaterVolume(drink2.recentAmount.amount)
    drink2TitleLabel.text = drink2.localizedName
    drink2View.drinkType = drink2.drinkType
    
    drink3AmountLabel.text = formatWaterVolume(drink3.recentAmount.amount)
    drink3TitleLabel.text = drink3.localizedName
    drink3View.drinkType = drink3.drinkType
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
    
    mainManagedObjectContext.performBlock {
      Intake.addEntity(
        drink: drink,
        amount: drink.recentAmount.amount,
        date: NSDate(),
        managedObjectContext: self.mainManagedObjectContext,
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