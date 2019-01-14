//
//  YearStatisticsViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 05.12.14.
//  Copyright © 2014 Sergey Balyakin. All rights reserved.
//

import UIKit
import CoreData

class YearStatisticsViewController: UIViewController {

  @IBOutlet weak var yearStatisticsView: YearStatisticsView!
  @IBOutlet weak var yearLabel: UILabel!

  var date: Date = Date() {
    didSet {
      updateUI(animated: true)
    }
  }
  
  fileprivate var statisticsBeginDate: Date!
  fileprivate var statisticsEndDate: Date!
  fileprivate var leftSwipeGestureRecognizer: UISwipeGestureRecognizer!
  fileprivate var rightSwipeGestureRecognizer: UISwipeGestureRecognizer!
  fileprivate var volumeObserver: SettingsObserver?

  fileprivate let shortMonthSymbols = Calendar.current.shortMonthSymbols 
  
  override func viewDidLoad() {
    super.viewDidLoad()

    setupUI()
    setupNotificationsObservation()
    
    volumeObserver = Settings.sharedInstance.generalVolumeUnits.addObserver { [weak self] _ in
      self?.updateYearStatisticsView()
    }
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  fileprivate func setupUI() {
    yearStatisticsView.backgroundColor = StyleKit.pageBackgroundColor
    yearStatisticsView.backgroundDarkColor = UIColor.clear
    yearStatisticsView.valuesChartLineColor = StyleKit.yearStatisticsChartStrokeColor
    yearStatisticsView.valuesChartFillColor = StyleKit.yearStatisticsChartFillColor
    yearStatisticsView.goalsChartColor = StyleKit.yearStatisticsGoalColor
    yearStatisticsView.scaleTextColor = UIColor.darkGray
    yearStatisticsView.gridColor = UIColor(red: 230/255, green: 231/255, blue: 232/255, alpha: 1.0)
    yearStatisticsView.pinsColor = UIColor.white
    yearStatisticsView.titleFont = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
    yearStatisticsView.dataSource = self
    
    yearLabel.backgroundColor = StyleKit.pageBackgroundColor // remove blending
    
    updateUI(animated: false)
  }
  
  fileprivate func setupNotificationsObservation() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.preferredContentSizeChanged),
      name: UIContentSizeCategory.didChangeNotification,
      object: nil)
    
    #if AQUAZLITE
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(fullVersionIsPurchased(_:)),
        name: NSNotification.Name(rawValue: GlobalConstants.notificationFullVersionIsPurchased), object: nil)
    #endif
    
    CoreDataStack.performOnPrivateContext { privateContext in
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(self.managedObjectContextDidChange(_:)),
        name: NSNotification.Name.NSManagedObjectContextDidSave,
        object: privateContext)
      
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(self.managedObjectContextDidChange(_:)),
        name: NSNotification.Name(rawValue: GlobalConstants.notificationManagedObjectContextWasMerged),
        object: privateContext)
    }
  }
  
  @objc func managedObjectContextDidChange(_ notification: Notification) {
    #if AQUAZLITE
      if !Settings.sharedInstance.generalFullVersion.value {
        return
      }
    #endif
    
    updateYearStatisticsView()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.leftSwipeGestureIsRecognized(_:)))
    leftSwipeGestureRecognizer.direction = .left
    yearStatisticsView.addGestureRecognizer(leftSwipeGestureRecognizer)
    
    rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.rightSwipeGestureIsRecognized(_:)))
    rightSwipeGestureRecognizer.direction = .right
    yearStatisticsView.addGestureRecognizer(rightSwipeGestureRecognizer)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    checkHelpTip()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    yearStatisticsView.removeGestureRecognizer(leftSwipeGestureRecognizer)
    yearStatisticsView.removeGestureRecognizer(rightSwipeGestureRecognizer)
    leftSwipeGestureRecognizer = nil
    rightSwipeGestureRecognizer = nil
  }

  @objc func preferredContentSizeChanged() {
    yearLabel.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
    yearStatisticsView.titleFont = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
    view.invalidateIntrinsicContentSize()
  }
  
  #if AQUAZLITE
  @objc func fullVersionIsPurchased(_ notification: NSNotification) {
    updateYearStatisticsView()
  }
  #endif

  fileprivate func updateUI(animated: Bool) {
    computeStatisticsDateRange()
    updateYearLabel(animated: animated)
    updateYearStatisticsView()
  }
  
  @IBAction func switchToPreviousYear(_ sender: Any) {
    switchToPreviousYear()
  }
  
  @IBAction func switchToNextYear(_ sender: Any) {
    switchToNextYear()
  }

  @objc func leftSwipeGestureIsRecognized(_ gestureRecognizer: UISwipeGestureRecognizer) {
    if gestureRecognizer.state == .ended {
      switchToNextYear()
    }
  }
  
  @objc func rightSwipeGestureIsRecognized(_ gestureRecognizer: UISwipeGestureRecognizer) {
    if gestureRecognizer.state == .ended {
      switchToPreviousYear()
    }
  }
  
  fileprivate func switchToPreviousYear() {
    date = DateHelper.previousYearBefore(date)
  }
  
  fileprivate func switchToNextYear() {
    date = DateHelper.nextYearFrom(date)
  }

  fileprivate lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    let dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy", options: 0, locale: Locale.current)
    formatter.dateFormat = dateFormat
    return formatter
    }()

  fileprivate func updateYearLabel(animated: Bool) {
    let title = dateFormatter.string(from: date)
    
    if animated {
      yearLabel.setTextWithAnimation(title)
    } else {
      yearLabel.text = title
    }
  }
  
  fileprivate func fetchStatisticsItems(beginDate: Date, endDate: Date, privateContext: NSManagedObjectContext) -> [YearStatisticsView.ItemType] {
    let amountPartsList = Intake.fetchIntakeAmountPartsGroupedBy(.month,
      beginDate: beginDate,
      endDate: endDate,
      dayOffsetInHours: 0,
      aggregateFunction: .average,
      managedObjectContext: privateContext)
    
    let waterGoals = WaterGoal.fetchWaterGoalAmountsGroupedByMonths(
      beginDate: beginDate,
      endDate: endDate,
      managedObjectContext: privateContext)
    
    Logger.logSevere(amountPartsList.count == waterGoals.count, Logger.Messages.inconsistentWaterIntakesAndGoals)
    
    var statisticsItems: [YearStatisticsView.ItemType] = []
    
    for (index, amountParts) in amountPartsList.enumerated() {
      let waterGoal = waterGoals[index] + amountParts.dehydration
      
      let displayedHydrationAmount = Units.sharedInstance.convertMetricAmountToDisplayed(metricAmount: amountParts.hydration, unitType: .volume)
      let displayedGoal = Units.sharedInstance.convertMetricAmountToDisplayed(metricAmount: waterGoal, unitType: .volume)
      
      let item: YearStatisticsView.ItemType = (value: CGFloat(displayedHydrationAmount), goal: CGFloat(displayedGoal))
      statisticsItems.append(item)
    }
    
    return statisticsItems
  }
  
  fileprivate func updateYearStatisticsView() {
    #if AQUAZLITE
    if !Settings.sharedInstance.generalFullVersion.value {
      // Demo mode
      var items: [YearStatisticsView.ItemType] = []
      
      for i in 0..<yearStatisticsView.monthsPerYear {
        let value = 1200 + cos(CGFloat(i + 4) / 2) * 700
        items.append((value: CGFloat(value), goal: 2000))
      }
      
      yearStatisticsView.setItems(items)
      return
    }
    #endif
    
    CoreDataStack.performOnPrivateContext { privateContext in
      let date = self.date
      let statisticsItems = self.fetchStatisticsItems(beginDate: self.statisticsBeginDate, endDate: self.statisticsEndDate, privateContext: privateContext)
      
      DispatchQueue.main.async {
        if self.date == date {
          self.yearStatisticsView.setItems(statisticsItems)
        }
      }
    }
  }
  
  fileprivate func computeStatisticsDateRange() {
    statisticsBeginDate = DateHelper.startOfYear(date)
    statisticsEndDate = DateHelper.nextYearFrom(statisticsBeginDate)
  }

  fileprivate func checkHelpTip() {
    #if AQUAZLITE
    if !Settings.sharedInstance.generalFullVersion.value {
      return
    }
    #endif
    
    
    if Settings.sharedInstance.uiYearStatisticsPageHelpTipIsShown.value {
      return
    }
    
    showHelpTip()
  }
  
  fileprivate func showHelpTip() {
    SystemHelper.executeBlockWithDelay(GlobalConstants.helpTipDelayToShow) {
      if self.view.window == nil {
        return
      }
      
      let text = NSLocalizedString("YSVC:Swipe left or right to switch year",
        value: "Swipe left or right to switch year",
        comment: "YearStatisticsViewController: Text for help tip about switching current year by swipe gesture")
      
      let point = CGPoint(x: self.yearStatisticsView.bounds.midX, y: self.yearStatisticsView.bounds.midY)
      
      if let helpTip = JDFTooltipView(targetPoint: point, hostView: self.yearStatisticsView, tooltipText: text, arrowDirection: .down, width: self.view.frame.width / 2) {
        UIHelper.showHelpTip(helpTip)
        Settings.sharedInstance.uiYearStatisticsPageHelpTipIsShown.value = true
      }
    }
  }

}

// MARK: YearStatisticsViewDataSource -

extension YearStatisticsViewController: YearStatisticsViewDataSource {
  
  func yearStatisticsViewGetTitleForHorizontalValue(_ value: CGFloat) -> String {
    let index = Int(value)
    
    if index < 0 || index >= shortMonthSymbols.count {
      assert(false)
      return ""
    }
    
    return shortMonthSymbols[index]
  }
  
  func yearStatisticsViewGetTitleForVerticalValue(_ value: CGFloat) -> String {
    let quantity = Quantity(unit: Settings.sharedInstance.generalVolumeUnits.value.unit, amount: Double(value))
    let title = quantity.getDescription(fractionDigits: Settings.sharedInstance.generalVolumeUnits.value.decimals, displayUnits: true)

    return title
  }

}

private extension Units.Volume {
  var decimals: Int {
    switch self {
    case .millilitres: return 0
    case .fluidOunces: return 1
    }
  }
}
