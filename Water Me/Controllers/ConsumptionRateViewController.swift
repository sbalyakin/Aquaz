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
    
    gender = SelectableEnumCellInfo<Settings.Gender>(
      viewController: self,
      title: "Gender",
      setting: Settings.sharedInstance.userGender)
    
    height = SelectableCellInfo<Double>(
      viewController: self,
      title: "Height",
      setting: Settings.sharedInstance.userHeight,
      minimumValue: 30,
      maximumValue: 300)
    
    weight = SelectableCellInfo<Double>(
      viewController: self,
      title: "Weight",
      setting: Settings.sharedInstance.userWeight,
      minimumValue: 30,
      maximumValue: 300)
    
    age = SelectableCellInfo<Int>(
      viewController: self,
      title: "Age",
      setting: Settings.sharedInstance.userAge,
      minimumValue: 1,
      maximumValue: 100)
    
    activity = SelectableEnumCellInfo<Settings.ActivityLevel>(
      viewController: self,
      title: "Activity Level",
      setting: Settings.sharedInstance.userActivityLevel)
    
    waterIntake = EditableCellInfo<Double>(
      title: "Water Intake",
      setting: Settings.sharedInstance.userDailyWaterIntake,
      stringToValueFunction: stringToDouble)
    
    gender.valueChangedFunction = cellValueWasChanged
    height.valueChangedFunction = cellValueWasChanged
    weight.valueChangedFunction = cellValueWasChanged
    age.valueChangedFunction = cellValueWasChanged
    activity.valueChangedFunction = cellValueWasChanged
    waterIntake.valueChangedFunction = cellValueWasChanged
    
    cellsInfo = [
      [gender, height, weight, age, activity], // section 1
      [waterIntake]                            // section 2
    ]
    
    registerForKeyboardNotifications()
    
    let tap = UITapGestureRecognizer(target: self, action: "didTapOnTableView:")
    tableView.addGestureRecognizer(tap)
  }
  
  @IBAction func cancelButtonWasTapped(sender: AnyObject) {
    view.endEditing(true)
    navigationController!.popViewControllerAnimated(true)
  }
  
  @IBAction func doneButtonWasTapped(sender: AnyObject) {
    if let selectedIndexPath = tableView.indexPathForSelectedRow() {
      tableView.deselectRowAtIndexPath(selectedIndexPath, animated: false)
    }
    view.endEditing(true)
    saveToSettings()
    navigationController!.popViewControllerAnimated(true)
  }
  
  private func saveToSettings() {
    for section in cellsInfo {
      for cellInfo in section {
        cellInfo.saveToSettings()
      }
    }
  }
  
  private func cellValueWasChanged(cellInfo: CellInfoBase) {
    let selectedInfoPath = tableView.indexPathForSelectedRow()
    
    tableView.reloadRowsAtIndexPaths([cellInfo.indexPath], withRowAnimation: .None)
    
    if let selected = selectedInfoPath {
      tableView.selectRowAtIndexPath(selected, animated: false, scrollPosition: .None)
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
    let cellIdentifier = cellInfo.getCellIdentifier()
    let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell
    cellInfo.initCell(cell, tableView: tableView, indexPath: indexPath)
    return cell
  }

  func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    if tableView.indexPathForSelectedRow() == indexPath {
      deselectTableViewCell(indexPath)
      return nil
    }
    
    return indexPath
  }
  
  func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
    let cellInfo = cellsInfo[indexPath.section][indexPath.row]
    cellInfo.setSelected(false)
    selectedCellInfo = nil
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if let cellInfo = selectedCellInfo {
      cellInfo.setSelected(false)
    }
    
    selectedCellInfo = cellsInfo[indexPath.section][indexPath.row]
    selectedCellInfo!.setSelected(true)
  }

  private func deselectTableViewCell(indexPath: NSIndexPath) {
    let cellInfo = cellsInfo[indexPath.section][indexPath.row]
    cellInfo.setSelected(false)
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
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
    if let cellInfo = selectedCellInfo {
      return cellInfo.getAvailableValuesCount()
    }
    assert(false)
    return 0
  }
  
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
    if let cellInfo = selectedCellInfo {
      return cellInfo.getValueTitleByIndex(row)
    }
    assert(false)
    return ""
  }
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    if let cellInfo = selectedCellInfo {
      return cellInfo.setValueFromAvailableValueByIndex(row)
    }
    assert(false)
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
  
  private var gender: CellInfo<Settings.Gender>!
  private var height: CellInfo<Double>!
  private var weight: CellInfo<Double>!
  private var age: CellInfo<Int>!
  private var activity: CellInfo<Settings.ActivityLevel>!
  private var waterIntake: CellInfo<Double>!
  
  private var cellsInfo: [[CellInfoBase]]!
  private var selectedCellInfo: CellInfoBase?
  
  private var originalTableViewContentInset: UIEdgeInsets = UIEdgeInsetsZero
}

class EditableTableViewCell: UITableViewCell {
  
  @IBOutlet weak var title: UILabel!
  @IBOutlet weak var value: UITextField!
  
  var tableView: UITableView!
  private var cellInfo: CellInfoBase!
  
  @IBAction func valueEditingDidBegin(sender: AnyObject) {
    if let indexPath = tableView.indexPathForCell(self) {
      if indexPath == tableView.indexPathForSelectedRow() {
        return
      }
      
      if let newIndexPath = tableView.delegate!.tableView!(tableView, willSelectRowAtIndexPath: indexPath) {
        tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: newIndexPath)
      }
    }
  }
  
  @IBAction func valueEditingDidEnd(sender: AnyObject) {
    cellInfo.setValueFromString(value.text)
  }
}

private class CellInfoBase {
  let cellIdentifier: String
  let title: String
  var indexPath: NSIndexPath!
  var valueChangedFunction: CellValueWasChangedFunction?

  typealias CellValueWasChangedFunction = (CellInfoBase) -> Void

  init(cellIdentifier: String, title: String) {
    self.cellIdentifier = cellIdentifier
    self.title = title
  }

  func getCellIdentifier() -> String {
    return cellIdentifier
  }
  
  func getTitle() -> String {
    return title
  }
  
  func initCell(cell: UITableViewCell, tableView: UITableView, indexPath: NSIndexPath) {
    self.indexPath = indexPath
  }
  
  func setSelected(selected: Bool) {
    // Must implemented in subclasses
  }
  
  func getStringValue() -> String {
    // Must implemented in subclasses
    return ""
  }
  
  func saveToSettings() {
    // Must implemented in subclasses
  }

  // Only for editable cells
  func setValueFromString(stringValue: String) {
    assert(false)
  }
  
  // Only for selectable cells
  func getAvailableValuesCount() -> Int {
    assert(false)
    return 0
  }
  
  func getValueTitleByIndex(index: Int) -> String {
      assert(false)
    return ""
  }
  
  func setValueFromAvailableValueByIndex(index: Int) {
    assert(false)
  }

}

private class CellInfo<T>: CellInfoBase {
  var value: T {
    didSet {
      if let function = valueChangedFunction {
        function(self)
      }
    }
  }

  init(cellIdentifier: String, title: String, setting: SettingsItemBase<T>) {
    self.setting = setting
    self.value = setting.value
    super.init(cellIdentifier: cellIdentifier, title: title)
  }

  override func getStringValue() -> String {
    return "\(value)"
  }
  
  override func saveToSettings() {
    setting.value = value
  }

  private let setting: SettingsItemBase<T>
}

private class SelectableCellInfo<T>: CellInfo<T> {
  init(viewController: ConsumptionRateViewController, title: String, setting: SettingsItemBase<T>, minimumValue: Int, maximumValue: Int) {
    self.viewController = viewController
    self.minimumValue = minimumValue
    self.maximumValue = maximumValue
    super.init(cellIdentifier: cellIdentifierRightDetailWithInfo, title: title, setting: setting)
  }
  
  override func initCell(cell: UITableViewCell, tableView: UITableView, indexPath: NSIndexPath) {
    super.initCell(cell, tableView: tableView, indexPath: indexPath)
    cell.textLabel?.text = title
    cell.detailTextLabel?.text = getStringValue()
  }
  
  override func setSelected(selected: Bool) {
    if selected {
      // Picker view supports only three heights: 162.0, 180.0 and 216.0
      let rects = viewController.view.bounds.rectsByDividing(162, fromEdge: .MaxYEdge)
      pickerView = UIPickerView(frame: rects.slice)
      pickerView!.dataSource = viewController
      pickerView!.delegate = viewController
      pickerView!.backgroundColor = UIColor.whiteColor()
      pickerView!.selectRow(getValueIndexInAvailableValues(), inComponent: 0, animated: false)
      viewController.view.addSubview(pickerView!)
      viewController.view.bringSubviewToFront(pickerView!)
    } else {
      if let pickerView = self.pickerView {
        pickerView.removeFromSuperview()
        self.pickerView = nil
      }
    }
  }

  override func getAvailableValuesCount() -> Int {
    return maximumValue - minimumValue + 1
  }
  
  override func getValueTitleByIndex(index: Int) -> String {
    return "\(minimumValue + index)"
  }
  
  override func setValueFromAvailableValueByIndex(index: Int) {
    let number = (minimumValue + index) as NSNumber
    value = number as T
  }
  
  func getValueIndexInAvailableValues() -> Int {
    let number = value as NSNumber
    return number as Int - minimumValue
  }
  
  private func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }
  
  private let viewController: ConsumptionRateViewController
  private let minimumValue: Int
  private let maximumValue: Int
  private var pickerView: UIPickerView?
}

private class SelectableEnumCellInfo<T: TitledEnum where T: RawRepresentable, T.RawValue == Int>: SelectableCellInfo<T> {
  
  init(viewController: ConsumptionRateViewController, title: String, setting: SettingsItemBase<T>) {
    let range = SelectableEnumCellInfo.calculateRange()
    super.init(viewController: viewController, title: title, setting: setting, minimumValue: range.minimumValue, maximumValue: range.maximumValue)
  }

  private class func calculateRange() -> (minimumValue: Int, maximumValue: Int) {
    var index: Int
    for index = 0; T(rawValue: index) != nil; index++ {
    }
    
    return (minimumValue: 0, maximumValue: index - 1)
  }
  
  override func getStringValue() -> String {
    return value.getTitle()
  }

  override func setValueFromAvailableValueByIndex(index: Int) {
    if let value = T(rawValue: index) {
      self.value = value
    }
  }
  
  override func getValueIndexInAvailableValues() -> Int {
    return value.rawValue
  }

  override func getValueTitleByIndex(index: Int) -> String {
    if let value = T(rawValue: index) {
      return value.getTitle()
    }
    return super.getValueTitleByIndex(index)
  }
}

@objc private class EditableCellInfo<T> : CellInfo<T> {
  init(title: String, setting: SettingsItemBase<T>, stringToValueFunction: StringToValueFunction) {
    self.stringToValueFunction = stringToValueFunction
    super.init(cellIdentifier: cellIdentifierEditable, title: title, setting: setting)
  }
  
  override func initCell(cell: UITableViewCell, tableView: UITableView, indexPath: NSIndexPath) {
    super.initCell(cell, tableView: tableView, indexPath: indexPath)
    if let editableCell = cell as? EditableTableViewCell {
      editableCell.title.text = title
      editableCell.value.text = getStringValue()
      editableCell.tableView = tableView
      editableCell.cellInfo = self
      self.editableCell = editableCell
    }
  }

  private override func setSelected(selected: Bool) {
    if let cell = editableCell {
      if selected {
        cell.value.becomeFirstResponder()
      } else {
        cell.value.resignFirstResponder()
      }
    }
  }
  
  override func setValueFromString(stringValue: String) {
    if let value = stringToValueFunction(stringValue) {
      self.value = value
    }
  }

  typealias StringToValueFunction = (String) -> T?
  private let stringToValueFunction: StringToValueFunction
  private var editableCell: EditableTableViewCell?
}

private protocol TitledEnum {
  func getTitle() -> String
}

extension Settings.Gender : TitledEnum {
  private func getTitle() -> String {
    switch self {
    case .Male:   return "Male"
    case .Female: return "Female"
    }
  }
}

extension Settings.ActivityLevel : TitledEnum {
  private func getTitle() -> String {
    switch self {
    case .Low:    return "Low"
    case .Medium: return "Medium"
    case .High:   return "High"
    }
  }
}

private func stringToDouble(value: String) -> Double? {
  return (value as NSString).doubleValue
}

private let cellIdentifierRightDetail = "RightDetail"
private let cellIdentifierRightDetailWithInfo = "RightDetailWithInfo"
private let cellIdentifierEditable = "EditableCell"
