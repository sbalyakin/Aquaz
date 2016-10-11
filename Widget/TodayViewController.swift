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
import MMWormhole

class TodayViewController: UIViewController {
  
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
  
  fileprivate var drink1: Drink!
  fileprivate var drink2: Drink!
  fileprivate var drink3: Drink!
  
  fileprivate var progressViewSection: MultiProgressView.Section!
  fileprivate var wormhole: MMWormhole!
  fileprivate var waterGoal: Double?
  fileprivate var hydration: Double?
  fileprivate var dehydration: Double?

  // Use a separate CoreDataStack instance for the today extension
  // in order to exclude synchronization problems for managed object contexts.
  fileprivate var coreDataStack = CoreDataStack()
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    Fabric.with([Crashlytics()])
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if #available(iOSApplicationExtension 10.0, *) {
      extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
    
    setupDrinksUI()
    setupProgressView()
    setupCoreDataSynchronization()
    setupNotificationsObservation()
    
    if #available(iOSApplicationExtension 9.0, *) {
      setupHeathKitSynchronization()
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    fetchData {
      DispatchQueue.main.async {
        self.updateUI(animated: false)
      }
    }
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
    // It's necessary to reset the managed object context in order to finalize background tasks correctly.
    coreDataStack.performOnPrivateContext { privateContext in
      privateContext.reset()
    }
  }

  fileprivate func setupCoreDataSynchronization() {
    wormhole = MMWormhole(applicationGroupIdentifier: GlobalConstants.appGroupName, optionalDirectory: GlobalConstants.wormholeOptionalDirectory)
    
    wormhole.listenForMessage(withIdentifier: GlobalConstants.wormholeMessageFromAquaz) { [weak self] messageObject in
      if let notification = messageObject as? Notification {
        CoreDataStack.mergeAllContextsWithNotification(notification)
        self?.wormhole.clearMessageContents(forIdentifier: GlobalConstants.wormholeMessageFromWidget)
      }
    }
  }

  fileprivate func setupProgressView() {
    progressView.animationDuration = 0.7
    progressViewSection = progressView.addSection(color: StyleKit.waterColor)
  }
  
  fileprivate func setupDrinksUI() {
    drink1TitleLabel.text = " "
    drink1AmountLabel.text = " "
    
    drink2TitleLabel.text = " "
    drink2AmountLabel.text = " "
    
    drink3TitleLabel.text = " "
    drink3AmountLabel.text = " "
  }

  fileprivate func setupNotificationsObservation() {
    coreDataStack.performOnPrivateContext { privateContext in
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(self.managedObjectContextDidSave(_:)),
        name: NSNotification.Name.NSManagedObjectContextDidSave,
        object: privateContext)
    }
  }
  
  @available(iOSApplicationExtension 9.0, *)
  fileprivate func setupHeathKitSynchronization() {
    coreDataStack.performOnPrivateContext { privateContext in
      HealthKitProvider.sharedInstance.initSynchronizationForManagedObjectContext(privateContext)
    }
  }

  func managedObjectContextDidSave(_ notification: Notification) {
    // By unknown reason existance of "managedObjectContext" key produces an exception during passing massage object through wormhole
    var clearedNotification = notification
    _ = clearedNotification.userInfo?.removeValue(forKey: "managedObjectContext")

    wormhole.passMessageObject(clearedNotification as NSCoding?, identifier: GlobalConstants.wormholeMessageFromWidget)
  }
  
  fileprivate func fetchDrinks(managedObjectContext: NSManagedObjectContext) {
    var drinkIndexesToDisplay = [Int]()
    var drinkIndexes = Array(0..<Drink.getDrinksCount())
    
    let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
    if let intake1 = Intake.fetchManagedObject(managedObjectContext: managedObjectContext, predicate: nil, sortDescriptors: [sortDescriptor]) {
      let drinkIndex1 = intake1.drink.index.intValue
      drinkIndexesToDisplay += [drinkIndex1]
      if let index = drinkIndexes.index(of: drinkIndex1) {
        drinkIndexes.remove(at: index)
      } else {
        assert(false)
      }
      
      let predicate2 = NSPredicate(format: "%K != %d", "drink.index", drinkIndex1)
      
      if let intake2 = Intake.fetchManagedObject(managedObjectContext: managedObjectContext, predicate: predicate2, sortDescriptors: [sortDescriptor]) {
        let drinkIndex2 = intake2.drink.index.intValue
        drinkIndexesToDisplay += [drinkIndex2]
        if let index = drinkIndexes.index(of: drinkIndex2) {
          drinkIndexes.remove(at: index)
        } else {
          assert(false)
        }
        
        let predicate3 = NSPredicate(format: "%K != %d AND %K != %d", "drink.index", drinkIndex1, "drink.index", drinkIndex2)
        
        if let intake3 = Intake.fetchManagedObject(managedObjectContext: managedObjectContext, predicate: predicate3, sortDescriptors: [sortDescriptor]) {
          drinkIndexesToDisplay += [intake3.drink.index.intValue]
        }
      }
    }
    
    if drinkIndexesToDisplay.count < 1 {
      drinkIndexesToDisplay += [drinkIndexes.remove(at: 0)]
    }
    
    if drinkIndexesToDisplay.count < 2 {
      drinkIndexesToDisplay += [drinkIndexes.remove(at: 0)]
    }
    
    if drinkIndexesToDisplay.count < 3 {
      drinkIndexesToDisplay += [drinkIndexes.remove(at: 0)]
    }
    
    drinkIndexesToDisplay.sort(by: <)
    
    let drinks = Drink.fetchAllDrinksIndexed(managedObjectContext: managedObjectContext)
    
    self.drink1 = drinks[drinkIndexesToDisplay[0]]
    self.drink2 = drinks[drinkIndexesToDisplay[1]]
    self.drink3 = drinks[drinkIndexesToDisplay[2]]
  }
  
  fileprivate func fetchWaterIntake(managedObjectContext: NSManagedObjectContext) {
    let date = Date()
    
    self.waterGoal = WaterGoal.fetchWaterGoalForDate(date, managedObjectContext: managedObjectContext)?.amount
    
    let amount = Intake.fetchIntakeAmountPartsGroupedBy(.day,
      beginDate: date,
      endDate: DateHelper.nextDayFrom(date),
      dayOffsetInHours: 0,
      aggregateFunction: .summary,
      managedObjectContext: managedObjectContext).first!
    
    self.hydration = amount.hydration
    self.dehydration = amount.dehydration
  }
  
  fileprivate func fetchData(_ completion: @escaping () -> ()) {
    coreDataStack.performOnPrivateContext { privateContext in
      if !Settings.sharedInstance.generalHasLaunchedOnce.value {
        CoreDataPrePopulation.prePopulateCoreData(managedObjectContext: privateContext, saveContext: true)
      }
    
      self.fetchDrinks(managedObjectContext: privateContext)
      self.fetchWaterIntake(managedObjectContext: privateContext)
      completion()
    }
  }
  
  fileprivate func updateUI(animated: Bool) {
    updateDrinks()
    updateWaterIntakes(animated: animated)
  }
  
  fileprivate func updateDrinks() {
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
  
  fileprivate func getDrinksInfo() -> [(amount: Double, name: String, drinkType: DrinkType)] {
    var drinksInfo: [(amount: Double, name: String, drinkType: DrinkType)]!
    
    coreDataStack.performOnPrivateContextAndWait { _ in
      drinksInfo = [
        (amount: self.drink1.recentAmount.amount, name: self.drink1.localizedName, drinkType: self.drink1.drinkType),
        (amount: self.drink2.recentAmount.amount, name: self.drink2.localizedName, drinkType: self.drink2.drinkType),
        (amount: self.drink3.recentAmount.amount, name: self.drink3.localizedName, drinkType: self.drink3.drinkType)]
    }
    
    return drinksInfo
  }

  fileprivate func updateWaterIntakes(animated: Bool) {
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
  
  fileprivate func updateProgressView(waterGoal: Double, overallWaterIntake: Double, animated: Bool) {
    let newFactor = CGFloat(overallWaterIntake / waterGoal)
    if progressViewSection.factor != newFactor {
      if animated {
        progressViewSection.setFactorWithAnimation(newFactor)
      } else {
        progressViewSection.factor = newFactor
      }
    }
  }
  
  fileprivate func updateProgressLabel(waterGoal: Double, overallWaterIntake: Double, animated: Bool) {
    let intakeText: String
    
    if Settings.sharedInstance.uiDisplayDailyWaterIntakeInPercents.value {
      let formatter = NumberFormatter()
      formatter.numberStyle = .percent
      formatter.maximumFractionDigits = 0
      formatter.multiplier = 100
      let drinkedPart = overallWaterIntake / waterGoal
      intakeText = formatter.string(for: drinkedPart)!
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
  
  fileprivate func formatWaterVolume(_ value: Double, displayUnits: Bool = true) -> String {
    return Units.sharedInstance.formatMetricAmountToText(
      metricAmount: value,
      unitType: .volume,
      roundPrecision: Settings.sharedInstance.generalVolumeUnits.value.precision,
      decimals: Settings.sharedInstance.generalVolumeUnits.value.decimals)
  }
  
  @IBAction func drink1WasTapped(_ sender: UITapGestureRecognizer) {
    addIntakeForDrink(drink1)
  }
  
  @IBAction func drink2WasTapped(_ sender: UITapGestureRecognizer) {
    addIntakeForDrink(drink2)
  }
  
  @IBAction func drink3WasTapped(_ sender: UITapGestureRecognizer) {
    addIntakeForDrink(drink3)
  }
  
  fileprivate func addIntakeForDrink(_ drink: Drink!) {
    if drink == nil {
      return
    }
    
    coreDataStack.performOnPrivateContext { privateContext in
      _ = Intake.addEntity(
        drink: drink,
        amount: drink.recentAmount.amount,
        date: Date(),
        managedObjectContext: privateContext,
        saveImmediately: true)

      self.fetchData {
        DispatchQueue.main.async {
          self.updateUI(animated: true)
        }
      }
    }
  }
  
  @IBAction func openApplicationWasTapped() {
    let url = URL(string: GlobalConstants.applicationSchemeURL)
    extensionContext?.open(url!, completionHandler: nil)
  }
}

extension TodayViewController : NCWidgetProviding {
  
  func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
    fetchData {
      DispatchQueue.main.async {
        self.updateUI(animated: false)
        completionHandler(.newData)
      }
    }
  }
  
  func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
    return UIEdgeInsets.zero
  }

  @available(iOSApplicationExtension 10.0, *)
  func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
    if activeDisplayMode == .compact {
      preferredContentSize = maxSize
    } else {
      preferredContentSize = CGSize(width: maxSize.width, height: 240)
    }
  }
}

private extension Units.Volume {
  var precision: Double {
    switch self {
    case .millilitres: return 1.0
    case .fluidOunces: return 0.1
    }
  }
  
  var decimals: Int {
    switch self {
    case .millilitres: return 0
    case .fluidOunces: return 1
    }
  }
}
