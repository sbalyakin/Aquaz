//
//  TodayViewController.swift
//  Widget
//
//  Created by Admin on 06.04.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit
import CoreData
import NotificationCenter
import Aquaz

class TodayViewController: UIViewController, NCWidgetProviding {
        
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
  
  private var drink1: Drink! {
    didSet {
      drink1AmountLabel.text = formatWaterVolume(drink1.recentAmount.amount)
      drink1TitleLabel.text = drink1.localizedName
      drink1View.drink = drink1
    }
  }
  
  private var drink2: Drink! {
    didSet {
      drink2AmountLabel.text = formatWaterVolume(drink2.recentAmount.amount)
      drink2TitleLabel.text = drink2.localizedName
      drink2View.drink = drink2
    }
  }

  private var drink3: Drink! {
    didSet {
      drink3AmountLabel.text = formatWaterVolume(drink3.recentAmount.amount)
      drink3TitleLabel.text = drink3.localizedName
      drink3View.drink = drink3
    }
  }
  
  private var progressViewSection: MultiProgressView.Section!
  private var wormhole: MMWormhole!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupCoreDataSynchronization()
    setupProgressView()
    updateWaterIntakeForDate(NSDate())
    updateDrinks()
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "contextDidSave:", name: NSManagedObjectContextDidSaveNotification, object: nil)
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  func contextDidSave(notification: NSNotification) {
    WormholeHelper.ManageObjectContextDidSaveMessage.pass(wormhole, context: .Widget)
  }

  private func setupCoreDataSynchronization() {
    wormhole = WormholeHelper.createWormhole()
    
    WormholeHelper.ManageObjectContextDidSaveMessage.listen(wormhole) { context in
      if context != .Widget { // Skip our own messages
        self.updateWaterIntakeForDate(NSDate())
        self.updateDrinks()
      }
    }
  }

  private func updateDrinks() -> Bool {
    var drinkIndexesToDisplay = [Int]()
    var drinkIndexes = Array(0..<Drink.getDrinksCount())

    if let
      managedObjectContext = CoreDataProvider.sharedInstance.managedObjectContext,
      entityDescription = LoggedActions.entityDescriptionForEntity(Intake.self, inManagedObjectContext: managedObjectContext)
    {
      let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
      if let intake1: Intake = ModelHelper.fetchManagedObject(managedObjectContext: managedObjectContext, predicate: nil, sortDescriptors: [sortDescriptor]) {
        let drinkIndex1 = intake1.drink.index.integerValue
        drinkIndexesToDisplay += [drinkIndex1]
        drinkIndexes.removeAtIndex(drinkIndex1)
        
        let predicate2 = NSPredicate(format: "%K != %d", "drink.index", drinkIndex1)
        
        if let intake2: Intake = ModelHelper.fetchManagedObject(managedObjectContext: managedObjectContext, predicate: predicate2, sortDescriptors: [sortDescriptor]) {
          let drinkIndex2 = intake2.drink.index.integerValue
          drinkIndexesToDisplay += [drinkIndex2]
          drinkIndexes.removeAtIndex(drinkIndex2)
          
          let predicate3 = NSPredicate(format: "%K != %d AND %K != %d", "drink.index", drinkIndex1, "drink.index", drinkIndex2)
          
          if let intake3: Intake = ModelHelper.fetchManagedObject(managedObjectContext: managedObjectContext, predicate: predicate3, sortDescriptors: [sortDescriptor]) {
            drinkIndexesToDisplay += [intake3.drink.index.integerValue]
          }
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

    drinkIndexesToDisplay.sort(<)
    
    let newDrink1 = Drink.getDrinkByIndex(drinkIndexesToDisplay[0], managedObjectContext: CoreDataProvider.sharedInstance.managedObjectContext)!
    let newDrink2 = Drink.getDrinkByIndex(drinkIndexesToDisplay[1], managedObjectContext: CoreDataProvider.sharedInstance.managedObjectContext)!
    let newDrink3 = Drink.getDrinkByIndex(drinkIndexesToDisplay[2], managedObjectContext: CoreDataProvider.sharedInstance.managedObjectContext)!
    
    let noChanges = drinksAreEqual(drink1, newDrink1) && drinksAreEqual(drink2, newDrink2) && drinksAreEqual(drink3, newDrink3)
    
    if noChanges {
      return false
    }
    
    drink1 = newDrink1
    drink2 = newDrink2
    drink3 = newDrink3
    return true
  }
  
  private func drinksAreEqual(drink1: Drink!, _ drink2: Drink!) -> Bool {
    if drink1 == nil || drink2 == nil {
      return false
    }
    
    return drink1.index == drink2.index && drink1.recentAmount.amount == drink2.recentAmount.amount
  }
  
  private func setupProgressView() {
    progressViewSection = progressView.addSection(color: StyleKit.waterColor)
  }
  
  private func updateWaterIntakeForDate(date: NSDate) -> Bool {
    if let
      waterGoal = WaterGoal.fetchWaterGoalForDate(date, managedObjectContext: CoreDataProvider.sharedInstance.managedObjectContext)?.amount,
      waterIntake = Intake.fetchGroupedWaterAmounts(
        beginDate: date,
        endDate: DateHelper.addToDate(date, years: 0, months: 0, days: 1),
        dayOffsetInHours: 0,
        groupingUnit: .Day,
        aggregateFunction: .Summary,
        managedObjectContext: CoreDataProvider.sharedInstance.managedObjectContext).first
    {
      let newFactor = CGFloat(waterIntake / waterGoal)
      if progressViewSection.factor != newFactor {
        progressViewSection.setFactorWithAnimation(newFactor)
        updateProgressLabel(waterGoal: waterGoal, waterIntake: waterIntake)
        return true
      } else {
        return false
      }
    } else {
      return false
    }
  }
  
  private func updateProgressLabel(#waterGoal: Double, waterIntake: Double) {
    let intakeText: String
    
    if Settings.uiDisplayDailyWaterIntakeInPercents.value {
      let formatter = NSNumberFormatter()
      formatter.numberStyle = .PercentStyle
      formatter.maximumFractionDigits = 0
      formatter.multiplier = 100
      let drinkedPart = waterIntake / waterGoal
      intakeText = formatter.stringFromNumber(drinkedPart)!
    } else {
      intakeText = formatWaterVolume(waterIntake, displayUnits: false)
    }
    
    let waterGoalText = formatWaterVolume(waterGoal)
    
    let template = NSLocalizedString("TodayExtension:%1$@ of %2$@", value: "%1$@ of %2$@",
      comment: "TodayExtension: Current daily water intake of water intake goal")
    let text = String.localizedStringWithFormat(template, intakeText, waterGoalText)
    progressLabel.setTextWithAnimation(text)
  }
  
  private func formatWaterVolume(value: Double, displayUnits: Bool = true) -> String {
    return Units.sharedInstance.formatMetricAmountToText(
      metricAmount: value,
      unitType: .Volume,
      roundPrecision: Settings.generalVolumeUnits.value.precision,
      decimals: Settings.generalVolumeUnits.value.decimals)
  }
  
  func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
    let intakeDidChange = updateWaterIntakeForDate(NSDate())
    let drinksDidChange = updateDrinks()
    
    if intakeDidChange || drinksDidChange {
      completionHandler(.NewData)
    } else {
      completionHandler(.NoData)
    }
  }
  
  func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
    return UIEdgeInsetsMake(0, 16, 0, 16)
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
    if drink != nil {
      let intake = Intake.addEntity(drink: drink, amount: drink.recentAmount.amount, date: NSDate(), managedObjectContext: CoreDataProvider.sharedInstance.managedObjectContext, saveImmediately: true)
      updateWaterIntakeForDate(NSDate())
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