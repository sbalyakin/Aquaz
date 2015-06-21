//
//  MonthStatisticsViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 05.12.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit
import CoreData

class MonthStatisticsViewController: UIViewController {

  @IBOutlet weak var monthStatisticsView: MonthStatisticsView!
  @IBOutlet weak var monthLabel: UILabel!
  
  private var date: NSDate = DateHelper.startDateFromDate(NSDate(), calendarUnit: .CalendarUnitMonth)

  private var managedObjectContext: NSManagedObjectContext { return CoreDataStack.privateContext }

  private struct Constants {
    static let showDaySegue = "Show Day"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    setupUI()
    setupNotificationsObservation()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    checkHelpTip()
  }
  
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  private func setupUI() {
    monthStatisticsView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    monthStatisticsView.weekDayFont = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
    monthStatisticsView.workDayTextColor = StyleKit.calendarWorkDayTextColor
    monthStatisticsView.workDayBackgroundColor = UIColor.whiteColor()
    monthStatisticsView.weekendBackgroundColor = UIColor.whiteColor()
    monthStatisticsView.weekendTextColor = StyleKit.calendarWeekendTextColor
    monthStatisticsView.weekDayTitleTextColor = StyleKit.calendarWeekDayTitleTextColor
    monthStatisticsView.selectedDayTextColor = StyleKit.calendarSelectedDayTextColor
    monthStatisticsView.selectedDayBackgroundColor = StyleKit.calendarSelectedDayBackgroundColor
    monthStatisticsView.todayBackgroundColor = UIColor.whiteColor()
    monthStatisticsView.todayTextColor = StyleKit.calendarTodayTextColor
    monthStatisticsView.dayIntakeFullColor = StyleKit.monthStatisticsChartStrokeColor
    monthStatisticsView.dayIntakeColor = StyleKit.monthStatisticsChartStrokeColor
    monthStatisticsView.dayIntakeBackgroundColor = StyleKit.monthStatisticsChartBackgroundColor
    monthStatisticsView.todayTextColor = StyleKit.monthStatisticsTodayTextColor

    monthStatisticsView.resetToDisplayMonthDate(date)
    monthStatisticsView.dataSource = self
    monthStatisticsView.delegate = self

    updateUI(animated: false)
  }
  
  private func setupNotificationsObservation() {
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "preferredContentSizeChanged",
      name: UIContentSizeCategoryDidChangeNotification, object: nil)
    
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "managedObjectContextDidChange:",
      name: NSManagedObjectContextDidSaveNotification, object: nil)
    
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "managedObjectContextDidChange:",
      name: GlobalConstants.notificationManagedObjectContextWasMerged, object: nil)
    
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "fullVersionIsPurchased:",
      name: GlobalConstants.notificationFullVersionIsPurchased, object: nil)
  }

  func managedObjectContextDidChange(notification: NSNotification) {
    if Settings.generalFullVersion.value {
      dispatch_async(dispatch_get_main_queue()) {
        self.monthStatisticsView.refresh()
      }
    }
  }
  
  func preferredContentSizeChanged() {
    monthLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    monthStatisticsView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    monthStatisticsView.weekDayFont = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
    monthStatisticsView.refresh()
    view.invalidateIntrinsicContentSize()
  }

  func fullVersionIsPurchased(notification: NSNotification) {
    monthStatisticsView.refresh()
  }

  private func updateUI(#animated: Bool) {
    let title = dateFormatter.stringFromDate(date)
    
    if animated {
      monthLabel.setTextWithAnimation(title)
    } else {
      monthLabel.text = title
    }
  }

  @IBAction func switchToPreviousMonth(sender: AnyObject) {
    monthStatisticsView.switchToPreviousMonth()
    date = monthStatisticsView.getDisplayedMonthDate()
    updateUI(animated: true) // Updating month label before scroll view animation is finished
  }
  
  @IBAction func switchToNextMonth(sender: AnyObject) {
    monthStatisticsView.switchToNextMonth()
    date = monthStatisticsView.getDisplayedMonthDate()
    updateUI(animated: true) // Updating month label before scroll view animation is finished
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == Constants.showDaySegue {
      if let viewController = segue.destinationViewController.contentViewController as? DayViewController, date = sender as? NSDate {
        viewController.mode = .Statistics
        viewController.setCurrentDate(date)
      }
    }
  }
  
  private func checkHelpTip() {
    if !Settings.generalFullVersion.value || Settings.uiMonthStatisticsPageHelpTipIsShown.value  {
      return
    }
    
    showHelpTip()
  }
  
  private func showHelpTip() {
    SystemHelper.executeBlockWithDelay(GlobalConstants.helpTipDelayToShow) {
      if self.view.window == nil {
        return
      }
      
      let text = NSLocalizedString("MSVC:Tap an active day to see details",
        value: "Tap an active day to see details",
        comment: "MonthStatisticsViewController: Text for help tip about tapping an active day for details")
      
      let dayRectWidth = self.monthStatisticsView.frame.width / CGFloat(self.monthStatisticsView.daysPerWeek)
      let point = CGPoint(x: self.monthStatisticsView.frame.width / 2, y: dayRectWidth * 2 + 5)
      let helpTip = JDFTooltipView(targetPoint: point, hostView: self.monthStatisticsView, tooltipText: text, arrowDirection: .Up, width: self.view.frame.width / 2)
      
      UIHelper.showHelpTip(helpTip)
      
      Settings.uiMonthStatisticsPageHelpTipIsShown.value = true
    }
  }

  private lazy var dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    let dateFormat = NSDateFormatter.dateFormatFromTemplate("MMMMyyyy", options: 0, locale: NSLocale.currentLocale())
    formatter.dateFormat = dateFormat
    return formatter
    }()

}

// MARK: CalendarViewDelegate -

extension MonthStatisticsViewController: CalendarViewDelegate {

  func calendarViewDaySelected(dayInfo: CalendarViewDayInfo) {
    if dayInfo.isCurrentMonth {
      performSegueWithIdentifier(Constants.showDaySegue, sender: dayInfo.date)
    }
  }

  func calendarViewDayWasSwitched(date: NSDate) {
    self.date = date
    updateUI(animated: true)
  }

}

// MARK: MonthStatisticsViewDataSource -

extension MonthStatisticsViewController: MonthStatisticsViewDataSource {
  
  func monthStatisticsGetValuesForDateInterval(#beginDate: NSDate, endDate: NSDate, calendarContentView: CalendarContentView) -> [Double] {
    if Settings.generalFullVersion.value {
      managedObjectContext.performBlock {
        weak var requestingMonthStatisticsContentView = (calendarContentView as! MonthStatisticsContentView)
        let hydrationFractions = self.fetchHydrationFractions(beginDate: beginDate, endDate: endDate)
        dispatch_async(dispatch_get_main_queue()) {
          if let contentView = requestingMonthStatisticsContentView {
            contentView.updateValues(hydrationFractions)
          } else {
            assert(false, "Calendar content view is null now")
          }
        }
      }

      return []
    } else {
      // Demo mode
      var index = 0
      var values = [Double]()
      for var date = beginDate; date.isEarlierThan(endDate); date = date.getNextDay() {
        let value = sin(Double(index % 28) / 28 * M_PI)
        values.append(value)
        index++
      }
      
      return values
    }
  }
  
  private func fetchHydrationFractions(#beginDate: NSDate, endDate: NSDate) -> [Double] {
    let amountPartsList = Intake.fetchIntakeAmountPartsGroupedBy(.Day,
      beginDate: beginDate,
      endDate: endDate,
      dayOffsetInHours: 0,
      aggregateFunction: .Average,
      managedObjectContext: managedObjectContext)
    
    let waterGoals = WaterGoal.fetchWaterGoalAmounts(
      beginDate: beginDate,
      endDate: endDate,
      managedObjectContext: managedObjectContext)
    
    Logger.logSevere(amountPartsList.count == waterGoals.count, Logger.Messages.inconsistentWaterIntakesAndGoals)
    
    var hydrationFractions = [Double]()
    
    for (index, amountParts) in enumerate(amountPartsList) {
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