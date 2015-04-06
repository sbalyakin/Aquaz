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
  
  private var isShowingDay = false
  
  private var date: NSDate = DateHelper.startDateFromDate(NSDate(), calendarUnit: .CalendarUnitMonth)
  
  private struct Constants {
    static let showDaySegue = "Show Day"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    initMonthStatisticsView()
    updateUI(initial: true)
    applyStyle()
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "preferredContentSizeChanged", name: UIContentSizeCategoryDidChangeNotification, object: nil)
  }
  
  func preferredContentSizeChanged() {
    monthLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    monthStatisticsView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    monthStatisticsView.weekDayFont = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
    monthStatisticsView.refresh()
    view.invalidateIntrinsicContentSize()
  }

  private func initMonthStatisticsView() {
    monthStatisticsView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    monthStatisticsView.weekDayFont = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
    monthStatisticsView.resetToDisplayMonthDate(date)
    monthStatisticsView.dataSource = self
    monthStatisticsView.delegate = self
  }
  
  private func updateUI(#initial: Bool) {
    let title = dateFormatter.stringFromDate(date)
    
    if initial {
      monthLabel.text = title
    } else {
      monthLabel.setTextWithAnimation(title)
    }
  }

  private func applyStyle() {
    monthStatisticsView.weekendBackgroundColor = StyleKit.calendarWeekendBackgroundColor
    monthStatisticsView.weekendTextColor = StyleKit.calendarWeekendTextColor
    monthStatisticsView.weekDayTitleTextColor = StyleKit.calendarWeekDayTitleTextColor
    monthStatisticsView.selectedDayTextColor = StyleKit.calendarSelectedDayTextColor
    monthStatisticsView.selectedDayBackgroundColor = StyleKit.calendarSelectedDayBackgroundColor
    monthStatisticsView.todayBackgroundColor = StyleKit.calendarTodayBackgroundColor
    monthStatisticsView.todayTextColor = StyleKit.calendarTodayTextColor
    monthStatisticsView.dayIntakeFullColor = StyleKit.monthStatisticsDayIntakeFullColor
    monthStatisticsView.dayIntakeColor = StyleKit.monthStatisticsDayIntakeColor
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    if isShowingDay {
      monthStatisticsView.refresh()
      isShowingDay = false
    }
  }
  
  @IBAction func switchToPreviousMonth(sender: AnyObject) {
    monthStatisticsView.switchToPreviousMonth()
    date = monthStatisticsView.getDisplayedMonthDate()
    updateUI(initial: false) // Updating month label before scroll view animation is finished
  }
  
  @IBAction func switchToNextMonth(sender: AnyObject) {
    monthStatisticsView.switchToNextMonth()
    date = monthStatisticsView.getDisplayedMonthDate()
    updateUI(initial: false) // Updating month label before scroll view animation is finished
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == Constants.showDaySegue {
      if let viewController = segue.destinationViewController.contentViewController as? DayViewController, date = sender as? NSDate {
        viewController.mode = .Statistics
        viewController.setCurrentDate(date)
      }
    }
  }
  
  private lazy var dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    let dateFormat = NSDateFormatter.dateFormatFromTemplate("MMMMyyyy", options: 0, locale: NSLocale.currentLocale())
    formatter.dateFormat = dateFormat
    return formatter
    }()

}

extension MonthStatisticsViewController: CalendarViewDelegate {

  func calendarViewDaySelected(dayInfo: CalendarViewDayInfo) {
    if dayInfo.isCurrentMonth {
      performSegueWithIdentifier(Constants.showDaySegue, sender: dayInfo.date)
      isShowingDay = true
    }
  }

  func calendarViewDayWasSwitched(date: NSDate) {
    self.date = date
    updateUI(initial: false)
  }

}

extension MonthStatisticsViewController: MonthStatisticsViewDataSource {
  
  func monthStatisticsGetValuesForDateInterval(#beginDate: NSDate, endDate: NSDate, calendarContentView: CalendarContentView) -> [Double] {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
      weak var requestingMonthStatisticsContentView = (calendarContentView as! MonthStatisticsContentView)
      let intakeFractions = self.fetchIntakeFractions(beginDate: beginDate, endDate: endDate)
      dispatch_async(dispatch_get_main_queue()) {
        if requestingMonthStatisticsContentView != nil {
          requestingMonthStatisticsContentView?.updateValues(intakeFractions)
        } else {
          println("Calendar content view is null now")
        }
      }
    }

    return []
  }
  
  private func fetchIntakeFractions(#beginDate: NSDate, endDate: NSDate) -> [Double] {
    let waterIntakes = Intake.fetchGroupedWaterAmounts(beginDate: beginDate, endDate: endDate, dayOffsetInHours: 0, groupingUnit: .Day, aggregateFunction: .Average, managedObjectContext: CoreDataProvider.sharedInstance.managedObjectContext)
    
    let goals = WaterGoal.fetchWaterGoalAmounts(beginDate: beginDate, endDate: endDate, managedObjectContext: CoreDataProvider.sharedInstance.managedObjectContext)
    Logger.logSevere(waterIntakes.count == goals.count, Logger.Messages.inconsistentWaterIntakesAndGoals)
    
    var intakeFractions = [Double]()
    
    for (index, waterIntake) in enumerate(waterIntakes) {
      let goal = goals[index]
      let intakeFraction: Double
      if goal > 0 {
        intakeFraction = waterIntake / goal
      } else {
        Logger.logError("Wrong water goal", logDetails: ["goal": "\(goal)"])
        intakeFraction = 0
      }
      intakeFractions.append(intakeFraction)
    }
    
    return intakeFractions
  }

}