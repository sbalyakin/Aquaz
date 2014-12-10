//
//  ConsumptionRateViewController.swift
//  Water Me
//
//  Created by Sergey Balyakin on 08.12.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class ConsumptionRateViewController: RevealedViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    cellsInfo = [
      [gender, height, weight, age, activity], // section 1
      [waterIntake]                            // section 2
    ]
    
    registerForKeyboardNotifications()
    
    let tap = UITapGestureRecognizer(target: self, action: "didTapOnTableView:")
    tableView.addGestureRecognizer(tap)
  }
  
  @IBAction func cancelButtonWasTapped(sender: AnyObject) {
    navigationController!.dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func doneButtonWasTapped(sender: AnyObject) {
    saveToSettings()
    navigationController!.dismissViewControllerAnimated(true, completion: nil)
  }
  
  private func saveToSettings() {
    for section in cellsInfo {
      for cellInfo in section {
        cellInfo.saveToSettings()
      }
    }
  }
  
  // MARK: - Table view data source
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return cellsInfo.count
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return cellsInfo[section].count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cellInfo = cellsInfo[indexPath.section][indexPath.row]
    let cellIdentifier = cellInfo.getIdentifier()
    let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell
    cellInfo.initCell(cell, tableView: tableView)
    return cell
  }

  func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    if tableView.indexPathForSelectedRow() == indexPath {
      deselectTableViewCell(indexPath)
      return nil
    }
    
    return indexPath
  }
  
  private func deselectTableViewCell(indexPath: NSIndexPath) {
    if let pickerView = pickerView {
      pickerView.removeFromSuperview()
      self.pickerView = nil
    }
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if let pickerView = pickerView {
      pickerView.removeFromSuperview()
    }

    selectedCellInfo = cellsInfo[indexPath.section][indexPath.row]
    
    if indexPath.section > 0 {
      return
    }

    // Picker view supports only three heights: 162.0, 180.0 and 216.0
    let rects = view.bounds.rectsByDividing(162, fromEdge: .MaxYEdge)
    pickerView = UIPickerView(frame: rects.slice)
    pickerView!.dataSource = self
    pickerView!.delegate = self
    pickerView!.backgroundColor = UIColor.whiteColor()
    pickerView!.selectRow(selectedCellInfo!.getValueIndexInAvailableValues(), inComponent: 0, animated: false)
    view.addSubview(pickerView!)
    view.bringSubviewToFront(pickerView!)
  }
  
  func didTapOnTableView(recognizer: UIGestureRecognizer) {
    let tapLocation = recognizer.locationInView(tableView)
    let indexPath = tableView.indexPathForRowAtPoint(tapLocation)
  
    if indexPath != nil { // we are in a tableview cell, let the gesture be handled by the view
      recognizer.cancelsTouchesInView = false
    } else {
      if let selectedIndexPath = tableView.indexPathForSelectedRow() {
        deselectTableViewCell(selectedIndexPath)
      }
    }
  }

  // MARK: - Picker view data source
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }

  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    assert(selectedCellInfo != nil)
    let titles = selectedCellInfo!.getTitlesForAvailableValues()
    return titles.count
  }

  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
    assert(selectedCellInfo != nil)
    let titles = selectedCellInfo!.getTitlesForAvailableValues()
    assert(row >= titles.startIndex && row <= titles.endIndex)
    let title = titles[row]
    return title
  }
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    assert(selectedCellInfo != nil)
    selectedCellInfo!.setValueByAvailableValueIndex(row)
    let indexPath = tableView.indexPathForSelectedRow()
    if let indexPath = indexPath {
      tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
      tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
    }
  }

  func registerForKeyboardNotifications() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeShown:", name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
  }

  func keyboardWillBeShown(notification: NSNotification) {
    let info: NSDictionary = notification.userInfo!
    let infoRect = info.objectForKey(UIKeyboardFrameBeginUserInfoKey)!.CGRectValue()
    let size = infoRect.size
    let contentInsets = UIEdgeInsetsMake(0, 0, size.height, 0)
    originalTableViewContentInset = tableView.contentInset
    tableView.contentInset = contentInsets
    tableView.scrollIndicatorInsets = contentInsets
  }
  
  func keyboardWillBeHidden(notification: NSNotification) {
    tableView.contentInset = originalTableViewContentInset
    tableView.scrollIndicatorInsets = originalTableViewContentInset
  }
  
  private var gender      = GenderCellInfo()
  private var height      = HeightCellInfo()
  private var weight      = WeightCellInfo()
  private var age         = AgeCellInfo()
  private var activity    = ActivityCellInfo()
  private var waterIntake = WaterIntakeCellInfo()
  
  private var cellsInfo: [[CellInfo]]!
  private var selectedCellInfo: CellInfo?
  
  private var pickerView: UIPickerView?
  private var originalTableViewContentInset: UIEdgeInsets = UIEdgeInsetsZero
}

private class CellInfo2<T> {
  let cellIdentifier: String
  let title: String
  var value: T
  
  init(cellIdentifier: String, title: String, setting: SettingsItemBase<T>) {
    self.cellIdentifier = cellIdentifier
    self.title = title
    self.setting = setting
    self.value = setting.value
  }

  func initCell(cell: UITableViewCell, tableView: UITableView) {
    // Initialize passed cell if it's necessary
  }
  
  func getStringValue() -> String {
    return "\(value)"
  }
  
  func saveToSettings() {
    setting.value = value
  }

  private let setting: SettingsItemBase<T>
}

private class PickerViewCellInfo<T>: CellInfo2<T> {
  init(title: String, setting: SettingsItemBase<T>, valuesGenerator: CellInfoValuesGenerator<T>) {
    self.valuesGenerator = valuesGenerator
    super.init(cellIdentifier: cellIdentifierRightDetailWithInfo, title: title, setting: setting)
  }
  
  override func initCell(cell: UITableViewCell, tableView: UITableView) {
    cell.textLabel?.text = title
    cell.detailTextLabel?.text = getStringValue()
  }
  
  func getAvailableValuesCount() -> Int {
    return 0
  }
  
  func getAvailableValueByIndex(index: Int) -> String {
    return ""
  }
  
  func setValueFromAvailableValueByIndex(index: Int) {
    
  }
  
  let valuesGenerator: CellInfoValuesGenerator<T>
}

private class CellInfoValuesGenerator<T> {
  func getAvailableValuesCount() -> Int {
    return 0
  }
  
  func getAvailableValueByIndex(index: Int) -> String {
    return ""
  }
  
  func getValueFromAvailableValueByIndex(index: Int) -> T? {
    return nil
  }
}

private class CellInfoOrdinalValuesGenerator<T: IntegerLiteralConvertible>: CellInfoValuesGenerator<T> {
  init(minimumValue: Int, maximumValue: Int) {
    self.minimumValue = minimumValue
    self.maximumValue = maximumValue
  }
  
  override func getAvailableValuesCount() -> Int {
    return maximumValue - minimumValue + 1
  }
  
  override func getAvailableValueByIndex(index: Int) -> String {
    return "\(minimumValue + index)"
  }
  
  override func getValueFromAvailableValueByIndex(index: Int) -> T? {
    let value = minimumValue + index
    // TODO: Error here
    return T(integerLiteral: value as T.IntegerLiteralType)
  }
  
  private let minimumValue: Int
  private let maximumValue: Int
}

private var a: CellInfoOrdinalValuesGenerator<Float> = CellInfoOrdinalValuesGenerator(minimumValue: 30, maximumValue: 40)

private let cellIdentifierRightDetail = "RightDetail"
private let cellIdentifierRightDetailWithInfo = "RightDetailWithInfo"
private let cellIdentifierEditable = "EditableCell"

private protocol CellInfo {
  func getIdentifier() -> String
  func initCell(cell: UITableViewCell, tableView: UITableView)
  func getTitle() -> String
  func getStringValue() -> String
  func getTitlesForAvailableValues() -> [String]
  func setValueByAvailableValueIndex(index: Int)
  func getValueIndexInAvailableValues() -> Int
  func saveToSettings()
}

private class GenderCellInfo : CellInfo {
  func getIdentifier() -> String {
    return cellIdentifierRightDetailWithInfo
  }
  
  func initCell(cell: UITableViewCell, tableView: UITableView) {
    cell.textLabel?.text = getTitle()
    cell.detailTextLabel?.text = getStringValue()
  }

  func getTitle() -> String {
    return "Gender"
  }
  
  func getStringValue() -> String {
    switch value {
    case .Male:   return "Male"
    case .Female: return "Female"
    }
  }

  func getTitlesForAvailableValues() -> [String] {
    return availableValuesTitles
  }
  
  func setValueByAvailableValueIndex(index: Int) {
    assert(index >= availableValues.startIndex && index <= availableValues.endIndex)
    value = availableValues[index]
  }

  func getValueIndexInAvailableValues() -> Int {
    return value.rawValue
  }

  func saveToSettings() {
    Settings.sharedInstance.userGender.value = value
  }

  private var value = Settings.sharedInstance.userGender.value
  private var availableValues: [Settings.Gender] = [.Male, .Female]
  private var availableValuesTitles = ["Male", "Female"]
}

private class HeightCellInfo : CellInfo {
  func getIdentifier() -> String {
    return cellIdentifierRightDetailWithInfo
  }
  
  func initCell(cell: UITableViewCell, tableView: UITableView) {
    cell.textLabel?.text = getTitle()
    cell.detailTextLabel?.text = getStringValue()
  }
  
  func getTitle() -> String {
    return "Height"
  }
  
  func getStringValue() -> String {
    return "\(Int(value))"
  }
  
  func getTitlesForAvailableValues() -> [String] {
    return availableValuesTitles
  }
  
  func setValueByAvailableValueIndex(index: Int) {
    assert(index >= availableValues.startIndex && index <= availableValues.endIndex)
    value = availableValues[index]
  }
  
  func getValueIndexInAvailableValues() -> Int {
    for (index, availableValue) in enumerate(availableValues) {
      if availableValue == value {
        return index
      }
    }
    
    return 0
  }

  func saveToSettings() {
    Settings.sharedInstance.userHeight.value = value
  }

  init() {
    for i in 50...300 {
      availableValues.append(Double(i))
      availableValuesTitles.append("\(i)")
    }
  }
  
  private var value = Settings.sharedInstance.userHeight.value
  private var availableValues: [Double] = []
  private var availableValuesTitles: [String] = []
}

private class WeightCellInfo : CellInfo {
  func getIdentifier() -> String {
    return cellIdentifierRightDetailWithInfo
  }
  
  func initCell(cell: UITableViewCell, tableView: UITableView) {
    cell.textLabel?.text = getTitle()
    cell.detailTextLabel?.text = getStringValue()
  }
  
  func getTitle() -> String {
    return "Weight"
  }
  
  func getStringValue() -> String {
    return "\(Int(value))"
  }
  
  func getTitlesForAvailableValues() -> [String] {
    return availableValuesTitles
  }
  
  func setValueByAvailableValueIndex(index: Int) {
    assert(index >= availableValues.startIndex && index <= availableValues.endIndex)
    value = availableValues[index]
  }
  
  func getValueIndexInAvailableValues() -> Int {
    for (index, availableValue) in enumerate(availableValues) {
      if availableValue == value {
        return index
      }
    }
    
    return 0
  }
  
  init() {
    for i in 30...300 {
      availableValues.append(Double(i))
      availableValuesTitles.append("\(i)")
    }
  }
  
  func saveToSettings() {
    Settings.sharedInstance.userWeight.value = value
  }

  private var value = Settings.sharedInstance.userWeight.value
  private var availableValues: [Double] = []
  private var availableValuesTitles: [String] = []
}

private class AgeCellInfo : CellInfo {
  func getIdentifier() -> String {
    return cellIdentifierRightDetailWithInfo
  }
  
  func initCell(cell: UITableViewCell, tableView: UITableView) {
    cell.textLabel?.text = getTitle()
    cell.detailTextLabel?.text = getStringValue()
  }
  
  func getTitle() -> String {
    return "Age"
  }
  
  func getStringValue() -> String {
    return "\(value)"
  }
  
  func getTitlesForAvailableValues() -> [String] {
    return availableValuesTitles
  }
  
  func setValueByAvailableValueIndex(index: Int) {
    assert(index >= availableValues.startIndex && index <= availableValues.endIndex)
    value = availableValues[index]
  }
  
  func getValueIndexInAvailableValues() -> Int {
    for (index, availableValue) in enumerate(availableValues) {
      if availableValue == value {
        return index
      }
    }
    
    return 0
  }
  
  init() {
    for i in 1...100 {
      availableValues.append(i)
      availableValuesTitles.append("\(i)")
    }
  }
  
  func saveToSettings() {
    Settings.sharedInstance.userAge.value = value
  }

  private var value = Settings.sharedInstance.userAge.value
  private var availableValues: [Int] = []
  private var availableValuesTitles: [String] = []
}

private class ActivityCellInfo : CellInfo {
  func getIdentifier() -> String {
    return cellIdentifierRightDetailWithInfo
  }
  
  func initCell(cell: UITableViewCell, tableView: UITableView) {
    cell.textLabel?.text = getTitle()
    cell.detailTextLabel?.text = getStringValue()
  }
  
  func getTitle() -> String {
    return "Activity"
  }
  
  func getStringValue() -> String {
    switch value {
    case .Low:    return "Low"
    case .Medium: return "Medium"
    case .High:   return "High"
    }
  }
  
  func getTitlesForAvailableValues() -> [String] {
    return availableValuesTitles
  }
  
  func setValueByAvailableValueIndex(index: Int) {
    assert(index >= availableValues.startIndex && index <= availableValues.endIndex)
    value = availableValues[index]
  }

  func getValueIndexInAvailableValues() -> Int {
    return value.rawValue
  }
  
  func saveToSettings() {
    Settings.sharedInstance.userActivityLevel.value = value
  }

  private var value = Settings.sharedInstance.userActivityLevel.value
  private var availableValues: [Settings.ActivityLevel] = [.Low, .Medium, .High]
  private var availableValuesTitles = ["Low", "Medium", "High"]
}

private class WaterIntakeCellInfo : CellInfo {
  func getIdentifier() -> String {
    return cellIdentifierEditable
  }
  
  func initCell(cell: UITableViewCell, tableView: UITableView) {
    if let editableCell = cell as? EditableTableViewCell {
      editableCell.title.text = getTitle()
      editableCell.value.text = getStringValue()
      editableCell.tableView = tableView
    }
  }
  
  func getTitle() -> String {
    return "Water Intake"
  }
  
  func getStringValue() -> String {
    return "\(Int(value))"
  }
  
  func getTitlesForAvailableValues() -> [String] {
    return []
  }
  
  func setValueByAvailableValueIndex(index: Int) {
  }
  
  func getValueIndexInAvailableValues() -> Int {
    return 0
  }
  
  func saveToSettings() {
    Settings.sharedInstance.userDailyWaterIntake.value = value
  }

  private var value = Settings.sharedInstance.userDailyWaterIntake.value
}
