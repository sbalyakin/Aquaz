//
//  MonthStatisticsViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 05.12.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit
import CoreData

class MonthStatisticsViewController: StyledViewController, MonthStatisticsViewDataSource, CalendarViewDelegate {

  @IBOutlet weak var monthStatisticsView: MonthStatisticsView!
  @IBOutlet weak var monthLabel: UILabel!
  
  private var date: NSDate = DateHelper.startDateFromDate(Settings.sharedInstance.uiMonthStatisticsDate.value, calendarUnit: .CalendarUnitMonth) {
    didSet {
      Settings.sharedInstance.uiMonthStatisticsDate.value = date
    }
  }
  
  var monthDate: NSDate {
    return monthStatisticsView.displayedMonthDate
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    initMonthStatisticsView()
    initMonthLabel()
  }

  private func initMonthStatisticsView() {
    monthStatisticsView.resetToDisplayMonthDate(date)
    monthStatisticsView.dataSource = self
    monthStatisticsView.delegate = self
  }
  
  private func initMonthLabel() {
    monthLabel.text = dateFormatter.stringFromDate(monthDate)
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    monthStatisticsView.refresh()
  }
  
  func monthStatisticsGetValuesForDateInterval(#beginDate: NSDate, endDate: NSDate) -> [Double] {
    return fetchIntakeFractions(beginDate: beginDate, endDate: endDate)
  }

  @IBAction func switchToPreviousMonth(sender: AnyObject) {
    monthStatisticsView.switchToPreviousMonth()
    date = monthStatisticsView.displayedMonthDate
  }
  
  @IBAction func switchToNextMonth(sender: AnyObject) {
    monthStatisticsView.switchToNextMonth()
    date = monthStatisticsView.displayedMonthDate
  }
  
  private lazy var dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    let dateFormat = NSDateFormatter.dateFormatFromTemplate("MMMMyyyy", options: 0, locale: NSLocale.currentLocale())
    formatter.dateFormat = dateFormat
    return formatter
    }()

  private func fetchIntakeFractions(#beginDate: NSDate, endDate: NSDate) -> [Double] {
    let waterIntakes = Intake.fetchGroupedWaterAmounts(beginDate: beginDate, endDate: endDate, dayOffsetInHours: 0, groupingUnit: .Day, aggregateFunction: .Average, managedObjectContext: managedObjectContext)
    
    let goals = WaterGoal.fetchWaterGoalAmounts(beginDate: beginDate, endDate: endDate, managedObjectContext: managedObjectContext)
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

//  Another version with fetching in another queue. Unfortunately it works with noticeable blink
//  between month switch and statistics fetching. Because animation is off it looks ugly.
  
//  private func initMonthStatisticsView() {
//    intakeFractions = []
//    monthStatisticsView.switchToMonth(date)
//
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
//      let fetchedDate = self.date
//      let intakeFractions = self.fetchIntakeFractions(beginDate: self.statisticsBeginDate, endDate: self.statisticsEndDate)
//      dispatch_async(dispatch_get_main_queue()) {
//        if self.date === fetchedDate {
//          self.intakeFractions = intakeFractions
//          self.monthStatisticsView.updateCalendar()
//        }
//      }
//    }
//  }

  func calendarViewDaySelected(dayInfo: CalendarViewDayInfo) {
    if !dayInfo.isCurrentMonth {
      return
    }
    
    if let dayViewController: DayViewController = LoggedActions.instantiateViewController(storyboard: storyboard, storyboardID: "DayViewController") {
      dayViewController.mode = .Statistics
      dayViewController.setCurrentDate(dayInfo.date)
      dayViewController.initializesRevealControls = false
      navigationController?.pushViewController(dayViewController, animated: true)
    }
  }
  
  private lazy var managedObjectContext: NSManagedObjectContext? = {
    if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
      return appDelegate.managedObjectContext
    } else {
      return nil
    }
  }()

}
