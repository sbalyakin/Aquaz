//
//  NotificationsIntervalPickerViewController.swift
//  Aquaz
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
    hoursLabel = UILabel()
    hoursLabel.font = pickerLabelFont
    hoursLabel.text = hoursTitle
    hoursLabel.textColor = UIColor.blackColor()
    hoursLabel.backgroundColor = UIColor.clearColor()
    hoursLabel.sizeToFit()
    pickerView.addSubview(hoursLabel)
    
    minutesLabel = UILabel()
    minutesLabel.font = pickerLabelFont
    minutesLabel.text = minutesTitle
    minutesLabel.textColor = UIColor.blackColor()
    minutesLabel.backgroundColor = UIColor.clearColor()
    minutesLabel.sizeToFit()
    pickerView.addSubview(minutesLabel)
  }

  override func viewDidLayoutSubviews() {
    layoutPickerView()
  }
  
  private func layoutPickerView() {
    let pickerMarginBetweenSections: CGFloat = 5 // standard margin between section for a picker view
    let midX = (pickerView.bounds.width - hoursComponentWidth - minutesComponentWidth) / 2 + minutesComponentWidth
    let center = CGPoint(x: midX, y: pickerView.bounds.midY)
    
    let hoursX = center.x - hoursLabel.frame.width - pickerMarginBetweenSections / 2
    let hoursY = center.y - hoursLabel.frame.height / 2
    let hoursLabelOrigin = CGPoint(x: ceil(hoursX), y: ceil(hoursY))
    hoursLabel.frame.origin = hoursLabelOrigin
    
    let minutesX = center.x + pickerMarginBetweenSections / 2 + hoursComponentWidth - minutesLabel.frame.width
    let minutesY = center.y - minutesLabel.frame.height / 2
    let minutesLabelOrigin = CGPoint(x: ceil(minutesX), y: ceil(minutesY))
    minutesLabel.frame.origin = minutesLabelOrigin
  }
  
  private func computeSizeForText(text: String, font: UIFont) -> CGSize {
    let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
    let fontAttributes = [NSFontAttributeName: font, NSParagraphStyleAttributeName: textStyle]
    let infiniteSize = CGSize(width: CGFloat.infinity, height: CGFloat.infinity)
    let rect = text.boundingRectWithSize(infiniteSize, options: .UsesLineFragmentOrigin, attributes: fontAttributes, context: nil)
    return CGSize(width: ceil(rect.width), height: ceil(rect.height))
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
    navigationController?.popViewControllerAnimated(true)
  }
  
  @IBAction func saveWasTapped(sender: AnyObject) {
    Settings.sharedInstance.notificationsInterval.value = getPickedTimeInterval()
    
    notificationsViewController.initControlsFromSettings()
    notificationsViewController.updateNotificationsFromSettings()

    navigationController?.popViewControllerAnimated(true)
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
  
  private let hoursComponentWidth: CGFloat = 100
  private let minutesComponentWidth: CGFloat = 100
  
  private let hoursTitle = " " + NSLocalizedString("NIPVC:hr", value: "hr", comment: "NotificationsIntervalPickerViewController: Contraction for hours")
  private let minutesTitle = " " + NSLocalizedString("NIPVC:min", value: "min", comment: "NotificationsIntervalPickerViewController: Contraction for minutes")

  private var hoursLabel: UILabel!
  private var minutesLabel: UILabel!

  private let pickerLabelFont = UIFont.systemFontOfSize(21)

}

// MARK: Data source and delegate for UIPickerView -
extension NotificationsIntervalPickerViewController {
  
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
  
  func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
    var title = ""
    var postfix = ""
    
    switch component {
    case Component.Hours.rawValue:
      let hours = getHoursForRow(row)
      title = "\(hours)"
      postfix = hoursTitle
      
    case Component.Minutes.rawValue:
      let minutes = getMinutesForRow(row)
      title = "\(minutes)"
      postfix = minutesTitle
      
    default:
      assert(false)
      return nil
    }
    
    let postfixSize = UIHelper.calcTextSize(postfix, font: pickerLabelFont)
    
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .Right
    paragraphStyle.tailIndent = -postfixSize.width
    
    return NSMutableAttributedString(string: title, attributes: [NSParagraphStyleAttributeName: paragraphStyle])
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
  
}