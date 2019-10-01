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
  @IBOutlet weak var recentIntakesLabel: UILabel!
  @IBOutlet weak var drink1AmountLabel: UILabel!
  @IBOutlet weak var drink1View: DrinkView!
  @IBOutlet weak var drink1TitleLabel: UILabel!
  @IBOutlet weak var drink2AmountLabel: UILabel!
  @IBOutlet weak var drink2View: DrinkView!
  @IBOutlet weak var drink2TitleLabel: UILabel!
  @IBOutlet weak var drink3AmountLabel: UILabel!
  @IBOutlet weak var drink3View: DrinkView!
  @IBOutlet weak var drink3TitleLabel: UILabel!
  @IBOutlet weak var openApplicationButton: UIButton!
  
  fileprivate var drink1: Drink!
  fileprivate var drink2: Drink!
  fileprivate var drink3: Drink!
  
  fileprivate var multiProgressSections: [Int: MultiProgressView.Section] = [:]
  fileprivate var wormhole: MMWormhole!
  fileprivate var waterGoalAmount: Double = 0
  fileprivate var totalHydrationAmount: Double = 0
  fileprivate var hydrationAmounts = [DrinkType: Double]()

  private static let fabric = Fabric.with([Crashlytics()])
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
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
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
    // It's necessary to reset the managed object context in order to finalize background tasks correctly.
    CoreDataStack.performOnPrivateContext { privateContext in
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
    
    for drinkIndex in 0..<Drink.getDrinksCount() {
      if let drinkType = DrinkType(rawValue: drinkIndex) {
        let section = progressView.addSection(color: drinkType.mainColor)
        multiProgressSections[drinkIndex] = section
      } else {
        Logger.logError("Drink type with index(\(drinkIndex)) is not found.")
      }
    }
  }
  
  fileprivate func setupDrinksUI() {
    if #available(iOS 10, *) {
    } else {
      progressLabel.textColor = UIColor.lightGray
      recentIntakesLabel.textColor = UIColor.lightGray
      drink1AmountLabel.textColor = UIColor.white
      drink1TitleLabel.textColor = UIColor.white
      drink2AmountLabel.textColor = UIColor.white
      drink2TitleLabel.textColor = UIColor.white
      drink3AmountLabel.textColor = UIColor.white
      drink3TitleLabel.textColor = UIColor.white
      openApplicationButton.setTitleColor(UIColor.white, for: .normal)
    }
    
    drink1TitleLabel.text = " "
    drink1AmountLabel.text = " "
    
    drink2TitleLabel.text = " "
    drink2AmountLabel.text = " "
    
    drink3TitleLabel.text = " "
    drink3AmountLabel.text = " "
  }

  fileprivate func setupNotificationsObservation() {
    CoreDataStack.performOnPrivateContext { privateContext in
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(self.managedObjectContextDidSave(_:)),
        name: NSNotification.Name.NSManagedObjectContextDidSave,
        object: privateContext)
    }
  }
  
  @objc func managedObjectContextDidSave(_ notification: Notification) {
    // By unknown reason existance of "managedObjectContext" key produces an exception during passing massage object through wormhole
    var clearedNotification = notification
    _ = clearedNotification.userInfo?.removeValue(forKey: "managedObjectContext")

    wormhole.passMessageObject(clearedNotification as NSCoding?, identifier: GlobalConstants.wormholeMessageFromWidget)
  }
  
  fileprivate func fetchData(_ completion: @escaping () -> ()) {
    CoreDataStack.performOnPrivateContext { privateContext in
      if !Settings.sharedInstance.generalHasLaunchedOnce.value {
        CoreDataPrePopulation.prePopulateCoreData(managedObjectContext: privateContext, saveContext: true)
      }
    
      self.fetchDrinks(managedObjectContext: privateContext)
      self.fetchWaterIntakes(managedObjectContext: privateContext)
      completion()
    }
  }
  
  fileprivate func fetchDrinks(managedObjectContext: NSManagedObjectContext) {
    let entity = Intake.entityDescription(inManagedObjectContext: managedObjectContext)
    let request = NSFetchRequest<NSDictionary>()
    request.entity = entity
    request.resultType = .dictionaryResultType
    request.propertiesToFetch = ["drink.index"]
    request.propertiesToGroupBy = ["drink.index"]
    request.fetchLimit = 2
    request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
    request.predicate = NSPredicate(format: "%K != %d", "drink.index", DrinkType.water.rawValue)

    // The first drink should be always water
    var drinkIndexesToDisplay = [DrinkType.water.rawValue]
    var drinkIndexes = Array((DrinkType.water.rawValue + 1)..<Drink.getDrinksCount())
    
    if let fetch = try? managedObjectContext.fetch(request) {
      for drinkIndex in 0..<2 {
        if drinkIndex >= fetch.count {
          break
        }
        
        let entry = fetch[drinkIndex]
        
        guard let index = entry["drink.index"] as? NSNumber else {
          break
        }
        
        drinkIndexesToDisplay += [index.intValue]
        
        if let indexToRemove = drinkIndexes.firstIndex(of: index.intValue) {
          drinkIndexes.remove(at: indexToRemove)
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
    
    drink1 = drinks[drinkIndexesToDisplay[0]]
    drink2 = drinks[drinkIndexesToDisplay[1]]
    drink3 = drinks[drinkIndexesToDisplay[2]]
  }
  
  fileprivate func fetchWaterIntakes(managedObjectContext: NSManagedObjectContext) {
    let date = Date()
    
    waterGoalAmount = WaterGoal.fetchWaterGoalForDate(date, managedObjectContext: managedObjectContext)?.amount ?? 0
    
    let totalDehydrationAmount = Intake.fetchTotalDehydrationAmountForDay(date, dayOffsetInHours: 0, managedObjectContext: managedObjectContext)
    waterGoalAmount += totalDehydrationAmount
    
    hydrationAmounts = Intake.fetchHydrationAmountsGroupedByDrinksForDay(date, dayOffsetInHours: 0, managedObjectContext: managedObjectContext)
    
    totalHydrationAmount = hydrationAmounts.reduce(0, { (totalHydration, amount) -> Double in
      return totalHydration + amount.value
    })
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
    
    CoreDataStack.performOnPrivateContextAndWait { _ in
      drinksInfo = [
        (amount: self.drink1.recentAmount.amount, name: self.drink1.localizedName, drinkType: self.drink1.drinkType),
        (amount: self.drink2.recentAmount.amount, name: self.drink2.localizedName, drinkType: self.drink2.drinkType),
        (amount: self.drink3.recentAmount.amount, name: self.drink3.localizedName, drinkType: self.drink3.drinkType)]
    }
    
    return drinksInfo
  }

  fileprivate func updateIntakeHydrationAmounts(_ intakeHydrationAmounts: [DrinkType: Double]) {
    // Clear all drink sections
    for (_, section) in multiProgressSections {
      section.factor = 0.0
    }
    
    // Fill sections with fetched intakes and compute daily water intake
    for (drinkType, hydrationAmount) in intakeHydrationAmounts {
      if let section = multiProgressSections[drinkType.rawValue] {
        section.factor = CGFloat(hydrationAmount)
      }
    }
  }
  
  fileprivate func updateWaterIntakes(animated: Bool) {
    updateProgressView(animated: animated)
    updateProgressLabel(animated: animated)
  }
  
  fileprivate func updateProgressView(animated: Bool) {
    DispatchQueue.main.async {
      if animated {
        self.progressView.updateWithAnimation {
          self.updateIntakeHydrationAmounts(self.hydrationAmounts)
          self.progressView.maximum = CGFloat(self.waterGoalAmount)
        }
      } else {
        self.progressView.update {
          self.updateIntakeHydrationAmounts(self.hydrationAmounts)
          self.progressView.maximum = CGFloat(self.waterGoalAmount)
        }
      }
    }
  }
  
  fileprivate func updateProgressLabel(animated: Bool) {
    let intakeText: String
    
    if Settings.sharedInstance.uiDisplayDailyWaterIntakeInPercents.value {
      let formatter = NumberFormatter()
      formatter.numberStyle = .percent
      formatter.maximumFractionDigits = 0
      formatter.multiplier = 100
      let drinkedPart = totalHydrationAmount / waterGoalAmount
      intakeText = formatter.string(for: drinkedPart)!
    } else {
      intakeText = formatWaterVolume(totalHydrationAmount, displayUnits: false)
    }
    
    let waterGoalText = formatWaterVolume(waterGoalAmount)
    
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
      minimumFractionDigits: 0,
      maximumFractionDigits: Settings.sharedInstance.generalVolumeUnits.value.decimals,
      displayUnits: displayUnits)
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
    
    CoreDataStack.performOnPrivateContext { privateContext in
      _ = Intake.addEntity(
        drink: drink,
        amount: drink.recentAmount.amount,
        date: Date(),
        managedObjectContext: privateContext,
        saveImmediately: true)
    }

    fetchData {
      DispatchQueue.main.async {
        self.updateUI(animated: true)
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
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    if preferredContentSize.height == 240 {
      drink1View.setNeedsDisplay()
      drink2View.setNeedsDisplay()
      drink3View.setNeedsDisplay()
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
