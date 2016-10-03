//
//  CalendarViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 11.11.14.
//  Copyright © 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController {

  var date: Date!
  
  weak var dayViewController: DayViewController!
  
  @IBOutlet weak var calendarView: CalendarView!
  @IBOutlet weak var currentMonthLabel: UILabel!

  fileprivate lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    let dateFormat = DateFormatter.dateFormat(fromTemplate: "MMMMyyyy", options: 0, locale: Locale.current)
    formatter.dateFormat = dateFormat
    return formatter
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.preferredContentSizeChanged),
      name: NSNotification.Name.UIContentSizeCategoryDidChange,
      object: nil)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  fileprivate func setupUI() {
    UIHelper.applyStyleToViewController(self)

    calendarView.backgroundColor = StyleKit.pageBackgroundColor
    calendarView.workDayTextColor = StyleKit.calendarWorkDayTextColor
    calendarView.weekendBackgroundColor = StyleKit.calendarWeekendBackgroundColor
    calendarView.weekendTextColor = StyleKit.calendarWeekendTextColor
    calendarView.weekDayTitleTextColor = StyleKit.calendarWeekDayTitleTextColor
    calendarView.selectedDayTextColor = StyleKit.calendarSelectedDayTextColor
    calendarView.selectedDayBackgroundColor = StyleKit.calendarSelectedDayBackgroundColor
    calendarView.todayBackgroundColor = StyleKit.calendarTodayBackgroundColor
    calendarView.todayTextColor = StyleKit.calendarTodayTextColor
    calendarView.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
    calendarView.weekDayFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
    calendarView.futureDaysTransparency = 0.1
    calendarView.resetToDisplayMonthDate(date)
    calendarView.selectedDate = date
    calendarView.delegate = self
    
    currentMonthLabel.backgroundColor = StyleKit.pageBackgroundColor // remove blending
    
    updateUI(initial: true)
  }
  
  func preferredContentSizeChanged() {
    currentMonthLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
    calendarView.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
    calendarView.weekDayFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
    calendarView.refresh()
    view.invalidateIntrinsicContentSize()
  }
  
  fileprivate func updateUI(initial: Bool) {
    let title = dateFormatter.string(from: date)
    
    if initial {
      currentMonthLabel.text = title
    } else {
      currentMonthLabel.setTextWithAnimation(title)
    }
  }

  @IBAction func switchToNextMonth(_ sender: AnyObject) {
    date = DateHelper.nextMonthFrom(date)
    calendarView.switchToNextMonth()
    updateUI(initial: false) // Updating month label before scroll view animation is finished
  }
  
  @IBAction func switchToPreviousMonth(_ sender: AnyObject) {
    date = DateHelper.previousMonthBefore(date)
    calendarView.switchToPreviousMonth()
    updateUI(initial: false) // Updating month label before scroll view animation is finished
  }
  
  @IBAction func todayDidSelected(_ sender: AnyObject) {
    let date = DateHelper.dateByJoiningDateTime(datePart: Date(), timePart: dayViewController.getCurrentDate())
    dayViewController.setCurrentDate(date)
    navigationController?.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func cancelWasTapped(_ sender: UIBarButtonItem) {
    navigationController?.dismiss(animated: true, completion: nil)
  }
}

extension CalendarViewController: CalendarViewDelegate {

  func calendarViewDaySelected(_ dayInfo: CalendarViewDayInfo) {
    dayViewController.setCurrentDate(dayInfo.date)
    navigationController?.dismiss(animated: true, completion: nil)
  }

  func calendarViewDayWasSwitched(_ date: Date) {
    self.date = date
    updateUI(initial: false)
  }

}
