//
//  NotificationsIntervalPickerViewController.swift
//  Water Me
//
//  Created by Sergey Balyakin on 23.12.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class NotificationsIntervalPickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
  
  @IBOutlet weak var pickerView: UIPickerView!
  
  var notificationsViewController: NotificationsViewController!

  override func viewDidLoad() {
    super.viewDidLoad()
    setupPickerView()
    selectTimeInterval(Settings.sharedInstance.notificationsInterval.value)
  }
  
  private func setupPickerView() {
    let pickerGap: CGFloat = 2 // Discovered gap for current picker view implementation

    let hoursSize = computeSizeForText(hoursTitle, font: pickerLabelFont)
    let hoursRect = CGRectMake(trunc(pickerView.bounds.midX) - hoursSize.width - pickerGap, trunc(pickerView.bounds.midY - hoursSize.height / 2), hoursSize.width, hoursSize.height)
    let hoursLabel = UILabel(frame: hoursRect)
    hoursLabel.font = pickerLabelFont
    hoursLabel.text = hoursTitle
    hoursLabel.backgroundColor = UIColor.clearColor()

    let minutesSize = computeSizeForText(minutesTitle, font: pickerLabelFont)
    let minutesRect = CGRectMake(trunc(pickerView.bounds.midX) + pickerGap + 1 + minutesComponentWidth - minutesSize.width, trunc(pickerView.bounds.midY - minutesSize.height / 2), minutesSize.width, minutesSize.height)
    let minutesLabel = UILabel(frame: minutesRect)
    minutesLabel.font = pickerLabelFont
    minutesLabel.text = minutesTitle
    minutesLabel.backgroundColor = UIColor.clearColor()

    pickerView.addSubview(hoursLabel)
    pickerView.addSubview(minutesLabel)
  }
  
  private func computeSizeForText(text: String, font: UIFont) -> CGSize {
    let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as NSMutableParagraphStyle
    let fontAttributes = [NSFontAttributeName: font, NSParagraphStyleAttributeName: textStyle]
    let size = text.boundingRectWithSize(CGSizeMake(CGFloat.infinity, CGFloat.infinity), options: .UsesLineFragmentOrigin, attributes: fontAttributes, context: nil).size
    return CGSizeMake(ceil(size.width), ceil(size.height))
  }

  private func selectTimeInterval(timeInterval: NSTimeInterval) {
    let overallSeconds = Int(timeInterval)
    var minutes = (overallSeconds / 60) % 60
    var hours = (overallSeconds / 3600)
    
    minutes = min(minutes, maximumMinutes)
    minutes = max(minutes, minimumMinutes)
    let minutesRow = Int((minutes - minimumMinutes) / minutesStep)

    hours = min(hours, maximumHours)
    hours = max(hours, minimumHours)
    let hoursRow = Int((hours - minimumHours) / hoursStep)

    pickerView.selectRow(hoursRow, inComponent: Component.Hours.rawValue, animated: false)
    pickerView.selectRow(minutesRow, inComponent: Component.Minutes.rawValue, animated: false)
  }
  
  @IBAction func cancelWasTapped(sender: AnyObject) {
    navigationController!.popViewControllerAnimated(true)
  }
  
  @IBAction func saveWasTapped(sender: AnyObject) {
    Settings.sharedInstance.notificationsInterval.value = getPickedTimeInterval()
    
    notificationsViewController.initControlsFromSettings()
    notificationsViewController.updateNotificationsFromSettings()

    navigationController!.popViewControllerAnimated(true)
  }

  private func getPickedTimeInterval() -> NSTimeInterval {
    let hoursRow = pickerView.selectedRowInComponent(Component.Hours.rawValue)
    let hours = getHoursForRow(hoursRow)
    
    let minutesRow = pickerView.selectedRowInComponent(Component.Minutes.rawValue)
    let minutes = getMinutesForRow(minutesRow)

    let timeInterval = NSTimeInterval(hours * 60 * 60 + minutes * 60)

    return timeInterval
  }
  
  private func getHoursForRow(row: Int) -> Int {
    return minimumHours + row * hoursStep
  }

  private func getMinutesForRow(row: Int) -> Int {
    return minimumMinutes + row * minutesStep
  }

  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 2
  }
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    switch component {
    case Component.Hours.rawValue:   return Int((maximumHours - minimumHours) / hoursStep + 1)
    case Component.Minutes.rawValue: return Int((maximumMinutes - minimumMinutes) / minutesStep + 1)
    default:
      assert(false)
      return 0
    }
  }

  func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
    if component == Component.Hours.rawValue {
      let hours = getHoursForRow(row)
      let title = getTitleForHours(hours)
      let hoursLabelSize = computeSizeForText(hoursTitle, font: pickerLabelFont)
      let labelWidth = hoursComponentWidth - hoursLabelSize.width - pickerTitleGap
      let view = createViewForPickerItem(title: title, labelWidth: labelWidth, componentWidth: hoursComponentWidth)
      return view
    } else {
      let minutes = getMinutesForRow(row)
      let title = getTitleForMinutes(minutes)
      let minutesLabelSize = computeSizeForText(minutesTitle, font: pickerLabelFont)
      let labelWidth = minutesComponentWidth - minutesLabelSize.width - pickerTitleGap
      let view = createViewForPickerItem(title: title, labelWidth: labelWidth, componentWidth: minutesComponentWidth)
      return view
    }
  }

  private func createViewForPickerItem(#title: String, labelWidth: CGFloat, componentWidth: CGFloat) -> UIView {
    let label = UILabel(frame: CGRectMake(0, 0, labelWidth, 33))
    label.textAlignment = .Right
    label.backgroundColor = UIColor.clearColor()
    label.text = title
    label.font = UIFont.systemFontOfSize(20)

    let view = UIView(frame: CGRectMake(0, 0, componentWidth, 33))
    view.backgroundColor = UIColor.clearColor()
    view.addSubview(label)
    
    return view
  }
  
  private func getTitleForHours(hours: Int) -> String {
    return "\(hours)"
  }

  private func getTitleForMinutes(minutes: Int) -> String {
    return "\(minutes)"
  }
  
  func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
    switch component {
    case Component.Hours.rawValue:   return hoursComponentWidth
    case Component.Minutes.rawValue: return minutesComponentWidth
    default:
      assert(false)
      return 0
    }
  }

  private enum Component: Int {
    case Hours = 0
    case Minutes
  }
  
  private let minimumHours = 1
  private let maximumHours = 5
  private let hoursStep = 1

  private let minimumMinutes = 0
  private let maximumMinutes = 59
  private let minutesStep = 5
  
  private let hoursComponentWidth: CGFloat = 80
  private let minutesComponentWidth: CGFloat = 80
  
  private let hoursTitle = "hr"
  private let minutesTitle = "min"

  private let pickerItemsFont = UIFont.systemFontOfSize(20)
  private let pickerLabelFont = UIFont.systemFontOfSize(18)
  
  private let pickerTitleGap: CGFloat = 5

}
