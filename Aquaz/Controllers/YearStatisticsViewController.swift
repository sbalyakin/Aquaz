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

  var date: NSDate = NSDate() {
    didSet {
      updateUI(animated: true)
    }
  }
  
  private var statisticsBeginDate: NSDate!
  private var statisticsEndDate: NSDate!
  private var leftSwipeGestureRecognizer: UISwipeGestureRecognizer!
  private var rightSwipeGestureRecognizer: UISwipeGestureRecognizer!
  private var privateManagedObjectContext: NSManagedObjectContext { return CoreDataStack.privateContext }
  private var volumeObserver: SettingsObserver?

  private let shortMonthSymbols = NSCalendar.currentCalendar().shortMonthSymbols 
  
  override func viewDidLoad() {
    super.viewDidLoad()

    setupUI()
    setupNotificationsObservation()
    
    volumeObserver = Settings.sharedInstance.generalVolumeUnits.addObserver { [weak self] _ in
      self?.updateYearStatisticsView()
    }
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  private func setupUI() {
    yearStatisticsView.backgroundColor = StyleKit.pageBackgroundColor
    yearStatisticsView.backgroundDarkColor = UIColor.clearColor()
    yearStatisticsView.valuesChartLineColor = StyleKit.yearStatisticsChartStrokeColor
    yearStatisticsView.valuesChartFillColor = StyleKit.yearStatisticsChartFillColor
    yearStatisticsView.goalsChartColor = StyleKit.yearStatisticsGoalColor
    yearStatisticsView.scaleTextColor = UIColor.darkGrayColor()
    yearStatisticsView.gridColor = UIColor(red: 230/255, green: 231/255, blue: 232/255, alpha: 1.0)
    yearStatisticsView.pinsColor = UIColor.whiteColor()
    yearStatisticsView.titleFont = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
    yearStatisticsView.dataSource = self
    
    yearLabel.backgroundColor = StyleKit.pageBackgroundColor // remove blending
    
    updateUI(animated: false)
  }
  
  private func setupNotificationsObservation() {
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "preferredContentSizeChanged",
      name: UIContentSizeCategoryDidChangeNotification, object: nil)
    
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "managedObjectContextDidChange:",
      name: NSManagedObjectContextDidSaveNotification, object: privateManagedObjectContext)
    
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "managedObjectContextDidChange:",
      name: GlobalConstants.notificationManagedObjectContextWasMerged, object: privateManagedObjectContext)
    
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "fullVersionIsPurchased:",
      name: GlobalConstants.notificationFullVersionIsPurchased, object: nil)
  }
  
  func managedObjectContextDidChange(notification: NSNotification) {
    if Settings.sharedInstance.generalFullVersion.value {
      updateYearStatisticsView()
    }
  }

  func fullVersionIsPurchased(notification: NSNotification) {
    updateYearStatisticsView()
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "leftSwipeGestureIsRecognized:")
    leftSwipeGestureRecognizer.direction = .Left
    yearStatisticsView.addGestureRecognizer(leftSwipeGestureRecognizer)
    
    rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "rightSwipeGestureIsRecognized:")
    rightSwipeGestureRecognizer.direction = .Right
    yearStatisticsView.addGestureRecognizer(rightSwipeGestureRecognizer)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    checkHelpTip()
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    yearStatisticsView.removeGestureRecognizer(leftSwipeGestureRecognizer)
    yearStatisticsView.removeGestureRecognizer(rightSwipeGestureRecognizer)
    leftSwipeGestureRecognizer = nil
    rightSwipeGestureRecognizer = nil
  }

  func preferredContentSizeChanged() {
    yearLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
    yearStatisticsView.titleFont = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
    view.invalidateIntrinsicContentSize()
  }
  
  private func updateUI(animated animated: Bool) {
    computeStatisticsDateRange()
    updateYearLabel(animated: animated)
    updateYearStatisticsView()
  }
  
  @IBAction func switchToPreviousYear(sender: AnyObject) {
    switchToPreviousYear()
  }
  
  @IBAction func switchToNextYear(sender: AnyObject) {
    switchToNextYear()
  }

  func leftSwipeGestureIsRecognized(gestureRecognizer: UISwipeGestureRecognizer) {
    if gestureRecognizer.state == .Ended {
      switchToNextYear()
    }
  }
  
  func rightSwipeGestureIsRecognized(gestureRecognizer: UISwipeGestureRecognizer) {
    if gestureRecognizer.state == .Ended {
      switchToPreviousYear()
    }
  }
  
  private func switchToPreviousYear() {
    date = DateHelper.addToDate(date, years: -1, months: 0, days: 0)
  }
  
  private func switchToNextYear() {
    date = DateHelper.addToDate(date, years: 1, months: 0, days: 0)
  }

  private lazy var dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    let dateFormat = NSDateFormatter.dateFormatFromTemplate("yyyy", options: 0, locale: NSLocale.currentLocale())
    formatter.dateFormat = dateFormat
    return formatter
    }()

  private func updateYearLabel(animated animated: Bool) {
    let title = dateFormatter.stringFromDate(date)
    
    if animated {
      yearLabel.setTextWithAnimation(title)
    } else {
      yearLabel.text = title
    }
  }
  
  private func fetchStatisticsItems(beginDate beginDate: NSDate, endDate: NSDate) -> [YearStatisticsView.ItemType] {
    let amountPartsList = Intake.fetchIntakeAmountPartsGroupedBy(.Month,
      beginDate: beginDate,
      endDate: endDate,
      dayOffsetInHours: 0,
      aggregateFunction: .Average,
      managedObjectContext: privateManagedObjectContext)
    
    let waterGoals = WaterGoal.fetchWaterGoalAmountsGroupedByMonths(
      beginDate: beginDate,
      endDate: endDate,
      managedObjectContext: privateManagedObjectContext)
    
    Logger.logSevere(amountPartsList.count == waterGoals.count, Logger.Messages.inconsistentWaterIntakesAndGoals)
    
    var statisticsItems: [YearStatisticsView.ItemType] = []
    
    for (index, amountParts) in amountPartsList.enumerate() {
      let waterGoal = waterGoals[index] + amountParts.dehydration
      
      let displayedHydrationAmount = Units.sharedInstance.convertMetricAmountToDisplayed(metricAmount: amountParts.hydration, unitType: .Volume)
      let displayedGoal = Units.sharedInstance.convertMetricAmountToDisplayed(metricAmount: waterGoal, unitType: .Volume)
      
      let item: YearStatisticsView.ItemType = (value: CGFloat(displayedHydrationAmount), goal: CGFloat(displayedGoal))
      statisticsItems.append(item)
    }
    
    return statisticsItems
  }
  
  private func updateYearStatisticsView() {
    if Settings.sharedInstance.generalFullVersion.value {
      privateManagedObjectContext.performBlock {
        let date = self.date
        let statisticsItems = self.fetchStatisticsItems(beginDate: self.statisticsBeginDate, endDate: self.statisticsEndDate)
        dispatch_async(dispatch_get_main_queue()) {
          if self.date === date {
            self.yearStatisticsView.setItems(statisticsItems)
          }
        }
      }
    } else {
      // Demo mode
      var items: [YearStatisticsView.ItemType] = []
      
      for i in 0..<yearStatisticsView.monthsPerYear {
        let value = 1200 + cos(CGFloat(i + 4) / 2) * 700
        items.append((value: CGFloat(value), goal: 2000))
      }
      
      yearStatisticsView.setItems(items)
    }
  }
  
  private func computeStatisticsDateRange() {
    let calendar = NSCalendar.currentCalendar()
    let dateComponents = calendar.components([.Year, .Month, .Day, .TimeZone, .Calendar], fromDate: date)
    
    dateComponents.day = 1
    dateComponents.month = 1
    statisticsBeginDate = calendar.dateFromComponents(dateComponents)
    statisticsEndDate = DateHelper.addToDate(statisticsBeginDate, years: 1, months: 0, days: 0)
  }

  private func checkHelpTip() {
    if !Settings.sharedInstance.generalFullVersion.value || Settings.sharedInstance.uiYearStatisticsPageHelpTipIsShown.value {
      return
    }
    
    showHelpTip()
  }
  
  private func showHelpTip() {
    SystemHelper.executeBlockWithDelay(GlobalConstants.helpTipDelayToShow) {
      if self.view.window == nil {
        return
      }
      
      let text = NSLocalizedString("YSVC:Swipe left or right to switch year",
        value: "Swipe left or right to switch year",
        comment: "YearStatisticsViewController: Text for help tip about switching current year by swipe gesture")
      
      let point = CGPoint(x: self.yearStatisticsView.bounds.midX, y: self.yearStatisticsView.bounds.midY)
      let helpTip = JDFTooltipView(targetPoint: point, hostView: self.yearStatisticsView, tooltipText: text, arrowDirection: .Down, width: self.view.frame.width / 2)
      
      UIHelper.showHelpTip(helpTip)
      
      Settings.sharedInstance.uiYearStatisticsPageHelpTipIsShown.value = true
    }
  }

}

// MARK: YearStatisticsViewDataSource -

extension YearStatisticsViewController: YearStatisticsViewDataSource {
  
  func yearStatisticsViewGetTitleForHorizontalValue(value: CGFloat) -> String {
    let index = Int(value)
    
    if index < 0 || index >= shortMonthSymbols.count {
      assert(false)
      return ""
    }
    
    return shortMonthSymbols[index]
  }
  
  func yearStatisticsViewGetTitleForVerticalValue(value: CGFloat) -> String {
    let quantity = Quantity(unit: Settings.sharedInstance.generalVolumeUnits.value.unit, amount: Double(value))
    let title = quantity.getDescription(Settings.sharedInstance.generalVolumeUnits.value.decimals, displayUnits: true)

    return title
  }

}

private extension Units.Volume {
  var decimals: Int {
    switch self {
    case Millilitres: return 0
    case FluidOunces: return 1
    }
  }
}