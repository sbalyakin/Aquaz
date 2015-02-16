//
//  WaterGoalViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 08.12.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit
import CoreData

private extension Units.Weight {
  var minimumValue: Double {
    switch self {
    case Kilograms: return 1
    case Pounds:    return 1
    }
  }
  
  var maximumValue: Double {
    switch self {
    case Kilograms: return 300
    case Pounds:    return 660
    }
  }
  
  var step: Double {
    switch self {
    case Kilograms: return 1
    case Pounds:    return 1
    }
  }
  
  var precision: Double {
    switch self {
    case Kilograms: return 1
    case Pounds:    return 1
    }
  }
  
  var decimals: Int {
    switch self {
    case Kilograms: return 0
    case Pounds:    return 0
    }
  }
}

private extension Units.Length {
  var minimumValue: Double {
    switch self {
    case Centimeters: return 30
    case Feet:        return 30.48 // 1 foot
    }
  }

  var maximumValue: Double {
    switch self {
    case Centimeters: return 300
    case Feet:        return 304.8 // 10 feet
    }
  }

  var step: Double {
    switch self {
    case Centimeters: return 1
    case Feet:        return 3.048 // 0.1 feet
    }
  }
  
  var precision: Double {
    switch self {
    case Centimeters: return 1
    case Feet:        return 0.1
    }
  }
  
  var decimals: Int {
    switch self {
    case Centimeters: return 0
    case Feet:        return 1
    }
  }
}

private extension Units.Volume {
  var precision: Double {
    switch self {
    case Millilitres: return 1
    case FluidOunces: return 0.1
    }
  }

  var decimals: Int {
    switch self {
    case Millilitres: return 0
    case FluidOunces: return 1
    }
  }
}

class WaterGoalViewController: StyledViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.backgroundView = nil
    tableView.backgroundColor = StyleKit.pageBackgroundColor
    
    let genderTitle = NSLocalizedString("WGVC:Gender", value: "Gender", comment: "WaterGoalViewController: Table cell title for [Gender] setting")
    let heightTitle = NSLocalizedString("WGVC:Height", value: "Height", comment: "WaterGoalViewController: Table cell title for [Height] setting")
    let weightTitle = NSLocalizedString("WGVC:Weight", value: "Weight", comment: "WaterGoalViewController: Table cell title for [Weight] setting")
    let ageTitle = NSLocalizedString("WGVC:Age", value: "Age", comment: "WaterGoalViewController: Table cell title for [Age] setting")
    let physicalActivityTitle = NSLocalizedString("WGVC:Physical Activity", value: "Physical Activity", comment: "WaterGoalViewController: Table cell title for [Physical Activity] setting")
    let waterGoalTitle = NSLocalizedString("WGVC:Water Intake", value: "Water Intake", comment: "WaterGoalViewController: Table cell title for [Water Intake] setting")
    
    genderCell = SelectableEnumCellInfo<Settings.Gender>(
      viewController: self,
      title: genderTitle,
      setting: Settings.sharedInstance.userGender,
      titleFunction: getTitleForGender)
    
    heightCell = SelectableCellInfo<Double>(
      viewController: self,
      title: heightTitle,
      setting: Settings.sharedInstance.userHeight,
      minimumValue: Settings.sharedInstance.generalHeightUnits.value.minimumValue,
      maximumValue: Settings.sharedInstance.generalHeightUnits.value.maximumValue,
      step: Settings.sharedInstance.generalHeightUnits.value.step,
      titleFunction: getTitleForHeight)
    
    weightCell = SelectableCellInfo<Double>(
      viewController: self,
      title: weightTitle,
      setting: Settings.sharedInstance.userWeight,
      minimumValue: Settings.sharedInstance.generalWeightUnits.value.minimumValue,
      maximumValue: Settings.sharedInstance.generalWeightUnits.value.maximumValue,
      step: Settings.sharedInstance.generalWeightUnits.value.step,
      titleFunction: getTitleForWeight)
    
    ageCell = SelectableCellInfo<Int>(
      viewController: self,
      title: ageTitle,
      setting: Settings.sharedInstance.userAge,
      minimumValue: minimumAge,
      maximumValue: maximumAge,
      step: 1,
      titleFunction: getTitleForAge)
    
    physicalActivityCell = SelectableEnumCellInfo<Settings.PhysicalActivity>(
      viewController: self,
      title: physicalActivityTitle,
      setting: Settings.sharedInstance.userPhysicalActivity,
      titleFunction: getTitleForPhysicalActivity)
    
    let volumeUnit = Settings.sharedInstance.generalVolumeUnits.value.unit
    
    waterGoalCell = EditableCellInfo<Double>(
      title: waterGoalTitle +  " (\(volumeUnit.contraction))",
      setting: Settings.sharedInstance.userWaterGoal,
      stringToValueFunction: stringToWaterGoalInMetricUnit,
      titleFunction: getTitleForWaterGoal)
    
    genderCell.valueChangedFunction = updateSourceCellInTable
    heightCell.valueChangedFunction = updateSourceCellInTable
    weightCell.valueChangedFunction = updateSourceCellInTable
    ageCell.valueChangedFunction = updateSourceCellInTable
    physicalActivityCell.valueChangedFunction = updateSourceCellInTable
    waterGoalCell.valueChangedFunction = updateCellInTable
    
    cellsInfo = [
      [genderCell, heightCell, weightCell, ageCell, physicalActivityCell], // section 1
      [waterGoalCell]                                    // section 2
    ]
    
    registerForKeyboardNotifications()
    
    let tap = UITapGestureRecognizer(target: self, action: "didTapOnTableView:")
    tableView.addGestureRecognizer(tap)
  }
  
  private func getTitleForHeight(value: Double) -> String {
    let unit = Settings.sharedInstance.generalHeightUnits.value
    return Units.sharedInstance.formatMetricAmountToText(metricAmount: value, unitType: unit.unit.type, roundPrecision: unit.precision, decimals: unit.decimals, displayUnits: true)
  }
  
  private func getTitleForWeight(value: Double) -> String {
    let unit = Settings.sharedInstance.generalWeightUnits.value
    return Units.sharedInstance.formatMetricAmountToText(metricAmount: value, unitType: unit.unit.type, roundPrecision: unit.precision, decimals: unit.decimals, displayUnits: true)
  }
  
  private func getTitleForAge(value: Int) -> String {
    return "\(value)"
  }
  
  private func getTitleForGender(gender: Settings.Gender) -> String {
    switch gender {
    case .Man:
      return NSLocalizedString("WGVC:Man", value: "Man", comment: "WaterGoalViewController: [Man] option for gender")
      
    case .Woman:
      return NSLocalizedString("WGVC:Woman", value: "Woman", comment: "WaterGoalViewController: [Woman] option for gender")
      
    case .PregnantFemale:
      return NSLocalizedString("WGVC:Pregnant female", value: "Pregnant female", comment: "WaterGoalViewController: [Pregnant female] option for gender")
      
    case .BreastfeedingFemale:
      return NSLocalizedString("WGVC:Breastfeeding female", value: "Breastfeeding female", comment: "WaterGoalViewController: [Breastfeeding female] option for gender")
    }
  }
  
  private func getTitleForPhysicalActivity(physicalActivity: Settings.PhysicalActivity) -> String {
    switch physicalActivity {
    case .Rare:
      return NSLocalizedString("WGVC:Rare", value: "Rare", comment: "WaterGoalViewController: [Rare] option for physical activity")
      
    case .Occasional:
      return NSLocalizedString("WGVC:Occasional", value: "Occasional", comment: "WaterGoalViewController: [Occasional] option for physical activity")
      
    case .Weekly:
      return NSLocalizedString("WGVC:Weekly", value: "Weekly", comment: "WaterGoalViewController: [Weekly] option for physical activity")
      
    case .Daily:
      return NSLocalizedString("WGVC:Daily", value: "Daily", comment: "WaterGoalViewController: [Daily] option for physical activity")
    }
  }
  
  private func getTitleForWaterGoal(value: Double) -> String {
    let unit = Settings.sharedInstance.generalVolumeUnits.value
    let displayedAmount = Units.sharedInstance.convertMetricAmountToDisplayed(metricAmount: value, unitType: unit.unit.type, roundPrecision: unit.precision)
    let formatter = NSNumberFormatter()
    formatter.minimumFractionDigits = unit.decimals
    formatter.maximumFractionDigits = unit.decimals
    formatter.minimumIntegerDigits = 1
    formatter.numberStyle = .NoStyle
    let title = formatter.stringFromNumber(displayedAmount) ?? "0"
    return title
  }
  
  private func stringToWaterGoalInMetricUnit(value: String) -> Double? {
    if let displayedValue = NSNumberFormatter().numberFromString(value)?.doubleValue {
      if displayedValue <= 0 {
        return nil
      }
      
      let displayedUnit = Settings.sharedInstance.generalVolumeUnits.value
      let quantity = Quantity(ownUnit: Units.Volume.metric.unit, fromUnit: displayedUnit.unit, fromAmount: displayedValue)
      let metricValue = quantity.amount
      let adjustedMetricValue = Units.sharedInstance.adjustMetricAmountForStoring(metricAmount: metricValue, unitType: .Volume, precision: displayedUnit.precision)
      return adjustedMetricValue
    } else {
      return nil
    }
  }
  
  @IBAction func cancelButtonWasTapped(sender: AnyObject) {
    view.endEditing(true)
    navigationController?.popViewControllerAnimated(true)
  }
  
  @IBAction func doneButtonWasTapped(sender: AnyObject) {
    if let selectedIndexPath = tableView.indexPathForSelectedRow() {
      tableView.deselectRowAtIndexPath(selectedIndexPath, animated: false)
    }
    view.endEditing(true)
    saveToSettings()
    navigationController?.popViewControllerAnimated(true)
  }
  
  private func saveToSettings() {
    for section in cellsInfo {
      for cellInfo in section {
        cellInfo.saveToSettings()
      }
    }
    
    saveWaterGoalToCoreData()
  }

  private func saveWaterGoalToCoreData() {
    let date = NSDate()
    if let waterGoal = WaterGoal.fetchWaterGoalStrictlyForDate(date, managedObjectContext: managedObjectContext) {
      waterGoal.baseAmount = waterGoalCell.value
      ModelHelper.save(managedObjectContext: managedObjectContext)
    } else {
      WaterGoal.addEntity(
        date: date,
        baseAmount: waterGoalCell.value,
        hotDayFactor: 0,
        highActivityFactor: 0,
        managedObjectContext: managedObjectContext)
    }
  }

  private func updateSourceCellInTable(cellInfo: CellInfoBase) {
    updateCellInTable(cellInfo)
    
    let data = WaterGoalCalculator.Data(physicalActivity: physicalActivityCell.value, gender: genderCell.value, age: ageCell.value, height: heightCell.value, weight: weightCell.value, country: .Average)
    
    let waterGoalAmount = WaterGoalCalculator.calcDailyWaterIntake(data: data)

    waterGoalCell.value = waterGoalAmount
  }
  
  private func updateCellInTable(cellInfo: CellInfoBase) {
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
    let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! UITableViewCell
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
    selectedCellInfo?.setSelected(false)
    
    selectedCellInfo = cellsInfo[indexPath.section][indexPath.row]
    selectedCellInfo?.setSelected(true)
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
    return selectedCellInfo?.getAvailableValuesCount() ?? 0
  }
  
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
    return selectedCellInfo?.getValueTitleByIndex(row) ?? ""
  }
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    selectedCellInfo?.setValueFromAvailableValueByIndex(row)
  }

  func registerForKeyboardNotifications() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeShown:", name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
  }

  func keyboardWillBeShown(notification: NSNotification) {
    if let infoRect = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue() {
      let size = infoRect.size
      let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: size.height, right: 0)
      originalTableViewContentInset = tableView.contentInset
      tableView.contentInset = contentInsets
      tableView.scrollIndicatorInsets = contentInsets
    }
  }
  
  func keyboardWillBeHidden(notification: NSNotification) {
    tableView.contentInset = originalTableViewContentInset
    tableView.scrollIndicatorInsets = originalTableViewContentInset
  }
  
  private var genderCell: CellInfo<Settings.Gender>!
  private var heightCell: CellInfo<Double>!
  private var weightCell: CellInfo<Double>!
  private var ageCell: CellInfo<Int>!
  private var physicalActivityCell: CellInfo<Settings.PhysicalActivity>!
  private var waterGoalCell: CellInfo<Double>!
  
  private var cellsInfo: [[CellInfoBase]]!
  private var selectedCellInfo: CellInfoBase?
  
  private let minimumAge = 10
  private let maximumAge = 100
  
  private var originalTableViewContentInset: UIEdgeInsets = UIEdgeInsetsZero
  
  private lazy var managedObjectContext: NSManagedObjectContext? = {
    if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
      return appDelegate.managedObjectContext
    } else {
      return nil
    }
  }()
}


class EditableTableViewCell: UITableViewCell {
  
  @IBOutlet weak var valueTextField: UITextField!
  
  var tableView: UITableView!
  private var cellInfo: CellInfoBase!
  
  deinit {
    valueTextField.resignFirstResponder()
  }
  
  @IBAction func valueEditingDidBegin(sender: AnyObject) {
    if let indexPath = tableView.indexPathForCell(self) {
      if indexPath == tableView.indexPathForSelectedRow() {
        return
      }
      
      if let newIndexPath = tableView.delegate?.tableView?(tableView, willSelectRowAtIndexPath: indexPath) {
        tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        tableView.delegate?.tableView?(tableView, didSelectRowAtIndexPath: newIndexPath)
      }
    }
  }
  
  @IBAction func valueEditingDidEnd(sender: AnyObject) {
    cellInfo.setValueFromString(valueTextField.text)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    self.accessoryView = valueTextField
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
      valueChangedFunction?(self)
    }
  }

  init(cellIdentifier: String, title: String, setting: SettingsItemBase<T>, titleFunction: TitleFunction? = nil) {
    self.setting = setting
    self.value = setting.value
    self.titleFunction = titleFunction
    super.init(cellIdentifier: cellIdentifier, title: title)
  }

  override func getStringValue() -> String {
    return titleFunction?(value) ?? "\(value)"
  }
  
  override func saveToSettings() {
    setting.value = value
  }

  private typealias TitleFunction = (T) -> String

  private let setting: SettingsItemBase<T>
  private var titleFunction: TitleFunction?
}

private class SelectableCellInfo<T>: CellInfo<T> {
  init(viewController: WaterGoalViewController, title: String, setting: SettingsItemBase<T>, minimumValue: NSNumber, maximumValue: NSNumber, step: NSNumber, titleFunction: TitleFunction? = nil) {
    self.viewController = viewController
    self.minimumValue = minimumValue
    self.maximumValue = maximumValue
    self.step = step
    super.init(cellIdentifier: cellIdentifierRightDetailWithInfo, title: title, setting: setting, titleFunction: titleFunction)
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
      pickerView?.removeFromSuperview()
      pickerView = nil
    }
  }

  override func getAvailableValuesCount() -> Int {
    if step == 0 {
      assert(false)
      return 0
    }
    let count = (maximumValue.doubleValue - minimumValue.doubleValue) / step.doubleValue + 1
    return Int(count)
  }
  
  private func getValueByIndex(index: Int) -> T {
    let value = minimumValue.doubleValue + Double(index) * step.doubleValue
    let numberValue = value as NSNumber
    return numberValue as! T
  }
  
  override func getValueTitleByIndex(index: Int) -> String {
    let value = getValueByIndex(index)
    return titleFunction?(value) ?? "\(value)"
  }
  
  override func setValueFromAvailableValueByIndex(index: Int) {
    let number = (getValueByIndex(index)) as! NSNumber
    value = number as! T
  }
  
  func getValueIndexInAvailableValues() -> Int {
    if step == 0 {
      assert(false)
      return 0
    }
    
    let valueNumber = value as! NSNumber
    let index = (valueNumber.doubleValue - minimumValue.doubleValue) / step.doubleValue
    return Int(trunc(index))
  }
  
  private func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }
  
  private let viewController: WaterGoalViewController
  private let minimumValue: NSNumber
  private let maximumValue: NSNumber
  private var step: NSNumber
  private var pickerView: UIPickerView?
}

private class SelectableEnumCellInfo<T: RawRepresentable where T.RawValue == Int>: SelectableCellInfo<T> {
  
  init(viewController: WaterGoalViewController, title: String, setting: SettingsItemBase<T>, titleFunction: TitleFunction? = nil) {
    let range = SelectableEnumCellInfo.calculateRange()
    super.init(viewController: viewController, title: title, setting: setting, minimumValue: range.minimumValue, maximumValue: range.maximumValue, step: 1, titleFunction: titleFunction)
  }

  private class func calculateRange() -> (minimumValue: Int, maximumValue: Int) {
    var index: Int
    for index = 0; T(rawValue: index) != nil; index++ {
    }
    
    return (minimumValue: 0, maximumValue: index - 1)
  }
  
  override func setValueFromAvailableValueByIndex(index: Int) {
    if let value = T(rawValue: index) {
      self.value = value
    }
  }
  
  override func getValueByIndex(index: Int) -> T {
    let value = minimumValue.doubleValue + Double(index) * step.doubleValue
    let numberValue = value as NSNumber
    return T(rawValue: numberValue.integerValue)!
  }
  
  override func getValueIndexInAvailableValues() -> Int {
    return value.rawValue
  }
}

private class EditableCellInfo<T> : CellInfo<T> {
  init(title: String, setting: SettingsItemBase<T>, stringToValueFunction: StringToValueFunction, titleFunction: TitleFunction? = nil) {
    self.stringToValueFunction = stringToValueFunction
    super.init(cellIdentifier: cellIdentifierEditable, title: title, setting: setting, titleFunction: titleFunction)
  }
  
  override func initCell(cell: UITableViewCell, tableView: UITableView, indexPath: NSIndexPath) {
    super.initCell(cell, tableView: tableView, indexPath: indexPath)
    if let editableCell = cell as? EditableTableViewCell {
      editableCell.textLabel?.text = title
      editableCell.valueTextField.text = getStringValue()
      editableCell.tableView = tableView
      editableCell.cellInfo = self
      self.editableCell = editableCell
    }
  }

  private override func setSelected(selected: Bool) {
    if let cell = editableCell {
      if selected {
        cell.valueTextField.becomeFirstResponder()
      } else {
        cell.valueTextField.resignFirstResponder()
      }
    }
  }
  
  override func setValueFromString(stringValue: String) {
    if let value = stringToValueFunction(stringValue) {
      self.value = value
    } else {
      // Just for restoring previous value
      valueChangedFunction?(self)
    }
  }

  typealias StringToValueFunction = (String) -> T?
  private let stringToValueFunction: StringToValueFunction
  private var editableCell: EditableTableViewCell?
}

private let cellIdentifierRightDetail = "RightDetail"
private let cellIdentifierRightDetailWithInfo = "RightDetailWithInfo"
private let cellIdentifierEditable = "EditableCell"
