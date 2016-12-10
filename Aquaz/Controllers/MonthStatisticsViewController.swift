//
//  MonthStatisticsViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 05.12.14.
//  Copyright © 2014 Sergey Balyakin. All rights reserved.
//

import UIKit
import CoreData

class MonthStatisticsViewController: UIViewController {

  @IBOutlet weak var monthStatisticsView: MonthStatisticsView!
  @IBOutlet weak var monthLabel: UILabel!
  
  fileprivate var date: Date = DateHelper.startOfMonth(Date())

  fileprivate struct Constants {
    static let dayViewController = "DayViewController"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    setupUI()
    setupNotificationsObservation()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    checkHelpTip()
  }
  
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  fileprivate func setupUI() {
    monthStatisticsView.backgroundColor = StyleKit.pageBackgroundColor
    monthStatisticsView.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
    monthStatisticsView.weekDayFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
    monthStatisticsView.workDayTextColor = StyleKit.calendarWorkDayTextColor
    monthStatisticsView.workDayBackgroundColor = UIColor.white
    monthStatisticsView.weekendBackgroundColor = UIColor.white
    monthStatisticsView.weekendTextColor = StyleKit.calendarWeekendTextColor
    monthStatisticsView.weekDayTitleTextColor = StyleKit.calendarWeekDayTitleTextColor
    monthStatisticsView.selectedDayTextColor = StyleKit.calendarSelectedDayTextColor
    monthStatisticsView.selectedDayBackgroundColor = StyleKit.calendarSelectedDayBackgroundColor
    monthStatisticsView.todayBackgroundColor = UIColor.white
    monthStatisticsView.todayTextColor = StyleKit.calendarTodayTextColor
    monthStatisticsView.dayIntakeFullColor = StyleKit.monthStatisticsChartStrokeColor
    monthStatisticsView.dayIntakeColor = StyleKit.monthStatisticsChartStrokeColor
    monthStatisticsView.dayIntakeBackgroundColor = StyleKit.monthStatisticsChartBackgroundColor
    monthStatisticsView.todayTextColor = StyleKit.monthStatisticsTodayTextColor

    monthStatisticsView.resetToDisplayMonthDate(date)
    monthStatisticsView.dataSource = self
    monthStatisticsView.delegate = self

    monthLabel.backgroundColor = StyleKit.pageBackgroundColor // remove blending
    
    updateUI(animated: false)
  }
  
  fileprivate func setupNotificationsObservation() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(preferredContentSizeChanged),
      name: NSNotification.Name.UIContentSizeCategoryDidChange,
      object: nil)
    
    #if AQUAZLITE
    NotificationCenter.default.addObserver(self,
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

  func managedObjectContextDidChange(_ notification: Notification) {
    #if AQUAZLITE
    if !Settings.sharedInstance.generalFullVersion.value {
      return
    }
    #endif
    
    DispatchQueue.main.async {
      self.monthStatisticsView.refresh()
    }
  }
  
  func preferredContentSizeChanged() {
    monthLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
    monthStatisticsView.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
    monthStatisticsView.weekDayFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
    monthStatisticsView.refresh()
    view.invalidateIntrinsicContentSize()
  }

  #if AQUAZLITE
  func fullVersionIsPurchased(_ notification: NSNotification) {
    monthStatisticsView.refresh()
  }
  #endif
  
  fileprivate func updateUI(animated: Bool) {
    let title = dateFormatter.string(from: date)
    
    if animated {
      monthLabel.setTextWithAnimation(title)
    } else {
      monthLabel.text = title
    }
  }

  @IBAction func switchToPreviousMonth(_ sender: Any) {
    monthStatisticsView.switchToPreviousMonth()
    date = monthStatisticsView.getDisplayedMonthDate() as Date
    updateUI(animated: true) // Updating month label before scroll view animation is finished
  }
  
  @IBAction func switchToNextMonth(_ sender: Any) {
    monthStatisticsView.switchToNextMonth()
    date = monthStatisticsView.getDisplayedMonthDate() as Date
    updateUI(animated: true) // Updating month label before scroll view animation is finished
  }
  
  fileprivate func checkHelpTip() {
    #if AQUAZLITE
    if !Settings.sharedInstance.generalFullVersion.value  {
      return
    }
    #endif
    
    if Settings.sharedInstance.uiMonthStatisticsPageHelpTipIsShown.value  {
      return
    }
    
    showHelpTip()
  }
  
  fileprivate func showHelpTip() {
    SystemHelper.executeBlockWithDelay(GlobalConstants.helpTipDelayToShow) {
      if self.view.window == nil {
        return
      }
      
      let text = NSLocalizedString("MSVC:Tap an active day to see details",
        value: "Tap an active day to see details",
        comment: "MonthStatisticsViewController: Text for help tip about tapping an active day for details")
      
      let dayRectWidth = self.monthStatisticsView.frame.width / CGFloat(self.monthStatisticsView.daysPerWeek)
      let point = CGPoint(x: self.monthStatisticsView.frame.width / 2, y: dayRectWidth * 2 + 5)
      
      if let helpTip = JDFTooltipView(targetPoint: point, hostView: self.monthStatisticsView, tooltipText: text, arrowDirection: .up, width: self.view.frame.width / 2) {
        UIHelper.showHelpTip(helpTip)
        Settings.sharedInstance.uiMonthStatisticsPageHelpTipIsShown.value = true
      }
    }
  }

  fileprivate lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    let dateFormat = DateFormatter.dateFormat(fromTemplate: "MMMMyyyy", options: 0, locale: Locale.current)
    formatter.dateFormat = dateFormat
    return formatter
    }()

}

// MARK: CalendarViewDelegate -

extension MonthStatisticsViewController: CalendarViewDelegate {

  func calendarViewDaySelected(_ dayInfo: CalendarViewDayInfo) {
    if !dayInfo.isCurrentMonth {
      return
    }

    // Unfortunately Show seque does not work properly in iOS 7, so straight pushViewController() method is used instead.

    if let dayViewController: DayViewController = LoggedActions.instantiateViewController(storyboard: storyboard, storyboardID: "DayViewController") {
      dayViewController.mode = .statistics
      dayViewController.setCurrentDate(dayInfo.date)
      
      navigationController?.pushViewController(dayViewController, animated: true)
    }
  }

  func calendarViewDayWasSwitched(_ date: Date) {
    self.date = date
    updateUI(animated: true)
  }

}

// MARK: MonthStatisticsViewDataSource -

extension MonthStatisticsViewController: MonthStatisticsViewDataSource {
  
  func monthStatisticsGetValuesForDateInterval(beginDate: Date, endDate: Date, calendarContentView: CalendarContentView) -> [Double] {
    #if AQUAZLITE
    if !Settings.sharedInstance.generalFullVersion.value {
      // Demo mode
      var index = 0
      var values = [Double]()
      var date = beginDate
      
      while date.isEarlierThan(endDate) {
        let value = sin(Double(index % 28) / 28 * M_PI)
        values.append(value)
        index += 1
        date = DateHelper.nextDayFrom(date)
      }
    
      return values
    }
    #endif
    
    CoreDataStack.performOnPrivateContext { privateContext in
      weak var requestingMonthStatisticsContentView = (calendarContentView as! MonthStatisticsContentView)
      let hydrationFractions = self.fetchHydrationFractions(beginDate: beginDate, endDate: endDate, privateContext: privateContext)
      DispatchQueue.main.async {
        if let contentView = requestingMonthStatisticsContentView {
          contentView.updateValues(hydrationFractions)
        } else {
          assert(false, "Calendar content view is null now")
        }
      }
    }

    return []
  }
  
  fileprivate func fetchHydrationFractions(beginDate: Date, endDate: Date, privateContext: NSManagedObjectContext) -> [Double] {
    let amountPartsList = Intake.fetchIntakeAmountPartsGroupedBy(.day,
      beginDate: beginDate,
      endDate: endDate,
      dayOffsetInHours: 0,
      aggregateFunction: .average,
      managedObjectContext: privateContext)
    
    let waterGoals = WaterGoal.fetchWaterGoalAmounts(
      beginDate: beginDate,
      endDate: endDate,
      managedObjectContext: privateContext)
    
    Logger.logSevere(amountPartsList.count == waterGoals.count, Logger.Messages.inconsistentWaterIntakesAndGoals)
    
    var hydrationFractions = [Double]()
    
    for (index, amountParts) in amountPartsList.enumerated() {
      let waterGoal = waterGoals[index] + amountParts.dehydration
      let hydrationFraction: Double
      if waterGoal > 0 {
        hydrationFraction = amountParts.hydration / waterGoal
      } else {
        Logger.logError("Wrong water goal", logDetails: ["goal": "\(waterGoal)"])
        hydrationFraction = 0
      }
      hydrationFractions.append(hydrationFraction)
    }
    
    return hydrationFractions
  }

}
