//
//  OmegaSettingsViewController.swift
//  OmegaSettingsViewController
//
//  Created by Sergey Balyakin on 03.03.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

// MARK: TableCellsContainer -
protocol TableCellsContainer: class {
  func addSupportingTableCell(#baseTableCell: TableCell, supportingTableCell: TableCell)
  func deleteSupportingTableCell()
  func activateTableCell(tableCell: TableCell?)
  
  var rightDetailValueColor: UIColor { get }
  var rightDetailSelectedValueColor: UIColor { get }
}

// MARK: OmegaSettingsViewController -
class OmegaSettingsViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  
  var tableCellsSections: [TableCellsSection] = []

  var rightDetailValueColor = UIColor.darkTextColor()
  var rightDetailSelectedValueColor = UIColor.redColor()
  
  /// If true all settings item will be saved to user defaults automatically on value update
  var saveToSettingsOnValueUpdate = true
  
  private var activeTableCell: TableCell?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.keyboardDismissMode = .OnDrag
    tableCellsSections = createTableCellsSections()
  }
  
  func createTableCellsSections() -> [TableCellsSection] {
    assert(false, "This method should be overriden by descendants")
    return []
  }
  
  func createBasicTableCell(#title: String, accessoryType: UITableViewCellAccessoryType? = nil, selectionChangedFunction: TableCell.TableCellActivatedFunction? = nil) -> BasicTableCell {
    let cell = BasicTableCell(title: title, container: self, accessoryType: accessoryType)
    cell.tableCellDidActivateFunction = selectionChangedFunction
    return cell
  }
  
  func createSwitchTableCell<T>(#title: String, settingsItem: SettingsItemBase<T>) -> SwitchTableCell<T> {
    let cell = SwitchTableCell(title: title, value: settingsItem.value, container: self)
    cell.valueExternalStorage = SettingsItemConnector(settingsItem: settingsItem, saveToSettingsOnValueUpdate: saveToSettingsOnValueUpdate)
    return cell
  }
  
  func createSwitchTableCell(#title: String, value: Bool) -> SwitchTableCell<Bool> {
    return SwitchTableCell(title: title, value: value, container: self)
  }
  
  func createRangedSegmentedTableCell<Value: Printable, Collection: CollectionType where Value: Equatable, Collection.Generator.Element == Value, Collection.Index == Int>(#title: String, value: Value, collection: Collection, stringFromValueFunction: ((Value) -> String)? = nil) -> SegmentedTableCell<Value, Collection> {
    let cell = SegmentedTableCell(title: title, value: value, collection: collection, container: self)
    cell.stringFromValueFunction = stringFromValueFunction
    return cell
  }
  
  func createRangedSegmentedTableCell<Value: Printable, Collection: CollectionType where Value: Equatable, Collection.Generator.Element == Value, Collection.Index == Int>(#title: String, settingsItem: SettingsItemBase<Value>, collection: Collection, stringFromValueFunction: ((Value) -> String)? = nil) -> SegmentedTableCell<Value, Collection> {
    let cell = SegmentedTableCell(title: title, value: settingsItem.value, collection: collection, container: self)
    cell.valueExternalStorage = SettingsItemConnector(settingsItem: settingsItem, saveToSettingsOnValueUpdate: saveToSettingsOnValueUpdate)
    cell.stringFromValueFunction = stringFromValueFunction
    return cell
  }
  
  func createEnumSegmentedTableCell<Value>(#title: String, value: Value, segmentsWidth: CGFloat = 0, stringFromValueFunction: (((Value) -> String)?) = nil) -> SegmentedTableCell<Value, EnumCollection<Value>> {
    let cell = SegmentedTableCell(title: title, value: value, collection: EnumCollection<Value>(), container: self, segmentsWidth: segmentsWidth)
    cell.stringFromValueFunction = stringFromValueFunction
    return cell
  }
  
  func createEnumSegmentedTableCell<Value>(#title: String, settingsItem: SettingsItemBase<Value>, segmentsWidth: CGFloat = 0, stringFromValueFunction: (((Value) -> String)?) = nil) -> SegmentedTableCell<Value, EnumCollection<Value>> {
    let cell = SegmentedTableCell(title: title, value: settingsItem.value, collection: EnumCollection<Value>(), container: self, segmentsWidth: segmentsWidth)
    cell.valueExternalStorage = SettingsItemConnector(settingsItem: settingsItem, saveToSettingsOnValueUpdate: saveToSettingsOnValueUpdate)
    cell.stringFromValueFunction = stringFromValueFunction
    return cell
  }
  
  func createRightDetailTableCell<Value: Printable>(#title: String, value: Value, accessoryType: UITableViewCellAccessoryType = .None, activationChangedFunction: TableCell.TableCellActivatedFunction? = nil, stringFromValueFunction: ((Value) -> String)? = nil) -> RightDetailTableCell<Value> {
    let cell = RightDetailTableCell(title: title, value: value, container: self, accessoryType: accessoryType)
    cell.tableCellDidActivateFunction = activationChangedFunction
    cell.stringFromValueFunction = stringFromValueFunction
    return cell
  }
  
  func createRightDetailTableCell<Value: Printable>(#title: String, settingsItem: SettingsItemBase<Value>, accessoryType: UITableViewCellAccessoryType = .None, activationChangedFunction: TableCell.TableCellActivatedFunction? = nil, stringFromValueFunction: ((Value) -> String)? = nil) -> RightDetailTableCell<Value> {
    let cell = RightDetailTableCell(title: title, value: settingsItem.value, container: self, accessoryType: accessoryType)
    cell.valueExternalStorage = SettingsItemConnector(settingsItem: settingsItem, saveToSettingsOnValueUpdate: saveToSettingsOnValueUpdate)
    cell.tableCellDidActivateFunction = activationChangedFunction
    cell.stringFromValueFunction = stringFromValueFunction
    return cell
  }
  
  func createRangedRightDetailTableCell<Value: Printable, Collection: CollectionType where Value: Equatable, Collection.Generator.Element == Value, Collection.Index == Int>(#title: String, settingsItem: SettingsItemBase<Value>, collection: Collection, pickerTableCellHeight: UIPickerViewHeight = .Medium, stringFromValueFunction: ((Value) -> String)? = nil) -> RightDetailTableCell<Value> {
    let cell = RightDetailTableCell(title: title, value: settingsItem.value, container: self, accessoryType: .None)
    cell.valueExternalStorage = SettingsItemConnector(settingsItem: settingsItem, saveToSettingsOnValueUpdate: saveToSettingsOnValueUpdate)
    cell.supportingTableCell = PickerTableCell(value: settingsItem.value, collection: collection, container: self, height: pickerTableCellHeight)
    
    cell.stringFromValueFunction = stringFromValueFunction
    cell.supportingTableCell?.stringFromValueFunction = stringFromValueFunction
    
    return cell
  }
  
  func createRangedRightDetailTableCell<Value: Printable, Collection: CollectionType where Value: Equatable, Collection.Generator.Element == Value, Collection.Index == Int>(#title: String, value: Value, collection: Collection, pickerTableCellHeight: UIPickerViewHeight = .Medium, stringFromValueFunction: ((Value) -> String)? = nil) -> RightDetailTableCell<Value> {
    let cell = RightDetailTableCell(title: title, value: value, container: self, accessoryType: .None)
    cell.supportingTableCell = PickerTableCell(value: value, collection: collection, container: self, height: pickerTableCellHeight)
    
    cell.stringFromValueFunction = stringFromValueFunction
    cell.supportingTableCell?.stringFromValueFunction = stringFromValueFunction
    
    return cell
  }
  
  func createEnumRightDetailTableCell<Value: RawRepresentable where Value: Printable, Value: Equatable, Value.RawValue == Int>(#title: String, settingsItem: SettingsItemBase<Value>, pickerTableCellHeight: UIPickerViewHeight = .Medium, stringFromValueFunction: ((Value) -> String)? = nil) -> RightDetailTableCell<Value> {
    let cell = createRangedRightDetailTableCell(title: title, settingsItem: settingsItem, collection: EnumCollection<Value>(), pickerTableCellHeight: pickerTableCellHeight)
    cell.stringFromValueFunction = stringFromValueFunction
    return cell
  }
  
  func createEnumRightDetailTableCell<Value: RawRepresentable where Value: Printable, Value: Equatable, Value.RawValue == Int>(#title: String, value: Value, pickerTableCellHeight: UIPickerViewHeight = .Medium, stringFromValueFunction: ((Value) -> String)? = nil) -> RightDetailTableCell<Value> {
    let cell = createRangedRightDetailTableCell(title: title, value: value, collection: EnumCollection<Value>(), pickerTableCellHeight: pickerTableCellHeight)
    cell.stringFromValueFunction = stringFromValueFunction
    return cell
  }
  
  func createTimeIntervalRightDetailTableCell(#title: String, value: NSTimeInterval, timeComponents: [TimeIntervalPickerTableCellComponent], height: UIPickerViewHeight = .Medium, stringFromValueFunction: ((NSTimeInterval) -> String)? = nil) -> RightDetailTableCell<NSTimeInterval> {
    let pickerCell = TimeIntervalPickerTableCell(value: value, timeComponents: timeComponents, container: self, height: height)
    
    let cell = RightDetailTableCell(title: title, value: value, container: self)
    cell.supportingTableCell = pickerCell
    cell.stringFromValueFunction = stringFromValueFunction
    return cell
  }
  
  func createTimeIntervalRightDetailTableCell(#title: String, settingsItem: SettingsItemBase<NSTimeInterval>, timeComponents: [TimeIntervalPickerTableCellComponent], height: UIPickerViewHeight = .Medium, stringFromValueFunction: ((NSTimeInterval) -> String)? = nil) -> RightDetailTableCell<NSTimeInterval> {
    let pickerCell = TimeIntervalPickerTableCell(value: settingsItem.value, timeComponents: timeComponents, container: self, height: height)

    let cell = RightDetailTableCell(title: title, value: settingsItem.value, container: self)
    cell.supportingTableCell = pickerCell
    cell.stringFromValueFunction = stringFromValueFunction
    cell.valueExternalStorage = SettingsItemConnector(settingsItem: settingsItem, saveToSettingsOnValueUpdate: saveToSettingsOnValueUpdate)
    return cell
  }
  
  func createDateRightDetailTableCell(#title: String, value: NSDate, datePickerMode: DatePickerTableCellMode, minimumDate: NSDate? = nil, maximumDate: NSDate? = nil, height: UIPickerViewHeight = .Medium, stringFromValueFunction: ((NSDate) -> String)? = nil) -> RightDetailTableCell<NSDate> {
    let pickerCell = DatePickerTableCell(value: value, container: self, datePickerMode: datePickerMode, minimumDate: minimumDate, maximumDate: maximumDate, height: height)
    
    let cell = RightDetailTableCell(title: title, value: value, container: self)
    cell.supportingTableCell = pickerCell
    cell.stringFromValueFunction = stringFromValueFunction
    return cell
  }
  
  func createDateRightDetailTableCell(#title: String, settingsItem: SettingsItemBase<NSDate>, datePickerMode: DatePickerTableCellMode, minimumDate: NSDate? = nil, maximumDate: NSDate? = nil, height: UIPickerViewHeight = .Medium, stringFromValueFunction: ((NSDate) -> String)? = nil) -> RightDetailTableCell<NSDate> {
    let pickerCell = DatePickerTableCell(value: settingsItem.value, container: self, datePickerMode: datePickerMode, minimumDate: minimumDate, maximumDate: maximumDate, height: height)
    
    let cell = RightDetailTableCell(title: title, value: settingsItem.value, container: self)
    cell.supportingTableCell = pickerCell
    cell.stringFromValueFunction = stringFromValueFunction
    cell.valueExternalStorage = SettingsItemConnector(settingsItem: settingsItem, saveToSettingsOnValueUpdate: saveToSettingsOnValueUpdate)
    return cell
  }
  
  func createTextFieldTableCell<Value: Printable>(#title: String, value: Value, valueFromStringFunction: ((String) -> Value?), stringFromValueFunction: (((Value) -> String)?) = nil, keyboardType: UIKeyboardType = .Default, borderStyle: UITextBorderStyle = .None) -> TextFieldTableCell<Value> {
    let cell = TextFieldTableCell(title: title, value: value, valueFromStringFunction: valueFromStringFunction, container: self, keyboardType: keyboardType, textFieldBorderStyle: borderStyle)
    cell.stringFromValueFunction = stringFromValueFunction
    return cell
  }
  
  func createTextFieldTableCell<Value: Printable>(#title: String, settingsItem: SettingsItemBase<Value>, valueFromStringFunction: ((String) -> Value?), stringFromValueFunction: (((Value) -> String)?) = nil, keyboardType: UIKeyboardType = .Default, borderStyle: UITextBorderStyle = .None) -> TextFieldTableCell<Value> {
    let cell = TextFieldTableCell(title: title, value: settingsItem.value, valueFromStringFunction: valueFromStringFunction, container: self, keyboardType: keyboardType, textFieldBorderStyle: borderStyle)
    cell.valueExternalStorage = SettingsItemConnector(settingsItem: settingsItem, saveToSettingsOnValueUpdate: saveToSettingsOnValueUpdate)
    cell.stringFromValueFunction = stringFromValueFunction
    return cell
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    notificationCenter.addObserver(self, selector: "handleKeyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
    notificationCenter.addObserver(self, selector: "handleKeyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
  }
  
  func handleKeyboardWillShowNotification(notification: NSNotification) {
    let userInfo = notification.userInfo!
    
    let infoRect = userInfo[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue()
    let size = infoRect!.size
    
    let contentInsets: UIEdgeInsets
    if UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation) {
      contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: size.height, right: 0)
    } else {
      contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: size.width, right: 0)
    }
    
    let animationDuration: NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
    UIView.animateWithDuration(animationDuration, animations: {
      self.tableView.contentInset = contentInsets
      self.tableView.scrollIndicatorInsets = contentInsets
    })
  }
  
  func handleKeyboardWillHideNotification(notification: NSNotification) {
    tableView.contentInset = UIEdgeInsetsZero
    tableView.scrollIndicatorInsets = UIEdgeInsetsZero
  }
  
  func writeTableCellValuesToExternalStorage() {
    for section in tableCellsSections {
      for cell in section.tableCells {
        cell.writeToExternalStorage()
      }
    }
  }
  
  func readTableCellValuesFromExternalStorage() {
    for section in tableCellsSections {
      for cell in section.tableCells {
        cell.readFromExternalStorage()
      }
    }
  }
  
}

// MARK: TableCellsContainer
extension OmegaSettingsViewController: TableCellsContainer {
  func addSupportingTableCell(#baseTableCell: TableCell, supportingTableCell: TableCell) {
    tableView.beginUpdates()
    
    section: for (sectionIndex, section) in enumerate(tableCellsSections) {
      for (cellIndex, tableCell) in enumerate(section.tableCells) {
        if tableCell === baseTableCell {
          let insertIndex = cellIndex + 1
          let insertedIndexPath = NSIndexPath(forRow: insertIndex, inSection: sectionIndex)
          tableView.insertRowsAtIndexPaths([insertedIndexPath], withRowAnimation: .Fade)
          section.tableCells.insert(supportingTableCell, atIndex: insertIndex)
          break section
        }
      }
    }
    
    tableView.endUpdates()
  }
  
  func activateTableCell(tableCell: TableCell?) {
    if tableCell === activeTableCell {
      tableCell?.setActive(false)
      activeTableCell = nil
    } else {
      activeTableCell?.setActive(false)
      tableCell?.setActive(true)
      if tableCell?.supportsPermanentActivation ?? false {
        activeTableCell = tableCell
      }
    }
  }
  
  func deleteSupportingTableCell() {
    tableView.beginUpdates()
    
    section: for (sectionIndex, section) in enumerate(tableCellsSections) {
      var indexesToDelete = [Int]()
      
      for (cellIndex, tableCell) in enumerate(section.tableCells) {
        if tableCell.isSupportingCell {
          let indexPath = NSIndexPath(forRow: cellIndex, inSection: sectionIndex)
          tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
          section.tableCells.removeAtIndex(cellIndex)
          break section
        }
      }
    }
    
    tableView.endUpdates()
  }
  
}

// MARK: UITableView data source and delegate
extension OmegaSettingsViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tableCellsSections[section].tableCells.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let tableCell = getTableCellForRowAtIndexPath(indexPath)
    let cell = tableCell.createUICell(tableView: tableView, indexPath: indexPath)
    return cell
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return tableCellsSections.count
  }
  
  private func getTableCellForRowAtIndexPath(indexPath: NSIndexPath) -> TableCell {
    let section = tableCellsSections[indexPath.section]
    let cell = section.tableCells[indexPath.row]
    return cell
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    let tableCell = getTableCellForRowAtIndexPath(indexPath)
    return tableCell.getRowHeight() ?? tableView.rowHeight
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let section = tableCellsSections[section]
    return section.headerTitle
  }
  
  func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    let section = tableCellsSections[section]
    return section.footerTitle
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let tableCell = getTableCellForRowAtIndexPath(indexPath)
    activateTableCell(tableCell)
    // A selected cell should be deselected because iOS does not paint a separator for selected cells.
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
}

// MARK: TableCellsSection -
class TableCellsSection {
  var headerTitle: String?
  var footerTitle: String?
  var tableCells: [TableCell] = []
}

// MARK: EnumCollection -
class EnumCollection<T: RawRepresentable where T.RawValue == Int>: CollectionType {
  
  let startIndex: Int
  let endIndex: Int
  
  init(startValue: T? = nil, endValue: T? = nil)
  {
    startIndex = startValue?.rawValue ?? 0
    
    var endIndex: Int?
    if let endValue = endValue {
      if endValue.rawValue >= startIndex {
        endIndex = endValue.rawValue
      }
    }
    
    if endIndex == nil {
      for endIndex = startIndex; T(rawValue: endIndex!) != nil; endIndex!++ {
      }
    }
    
    self.endIndex = endIndex!
  }
  
  func generate() -> GeneratorOf<T> {
    var index = startIndex
    return GeneratorOf<T> {
      return index <= self.endIndex ? T(rawValue: index++) : nil
    }
  }
  
  subscript(i: Int) -> T {
    return T(rawValue: startIndex + i)!
  }
  
}

// MARK: IntCollection -
class IntCollection: CollectionType {
  
  let startIndex: Int
  let endIndex: Int
  let minimumValue: Int
  let maximumValue: Int
  let step: Int
  
  init(minimumValue: Int, maximumValue: Int, step: Int)
  {
    self.minimumValue = minimumValue
    self.maximumValue = maximumValue
    self.step = step
    startIndex = 0
    endIndex = (maximumValue - minimumValue) / step
  }
  
  func generate() -> GeneratorOf<Int> {
    var index = startIndex
    return GeneratorOf<Int> {
      return index <= self.endIndex ? (self.minimumValue + index * self.step) : nil
    }
  }
  
  subscript(index: Int) -> Int {
    return minimumValue + index * step
  }
  
}

// MARK: DoubleCollection -
class DoubleCollection: CollectionType {
  
  let startIndex: Int
  let endIndex: Int
  let minimumValue: Double
  let maximumValue: Double
  let step: Double
  
  init(minimumValue: Double, maximumValue: Double, step: Double)
  {
    self.minimumValue = minimumValue
    self.maximumValue = maximumValue
    self.step = step
    startIndex = 0
    endIndex = Int((maximumValue - minimumValue) / step)
  }
  
  func generate() -> GeneratorOf<Double> {
    var index = startIndex
    return GeneratorOf<Double> {
      return index <= self.endIndex ? (self.minimumValue + Double(index) * self.step) : nil
    }
  }
  
  subscript(index: Int) -> Double {
    return minimumValue + Double(index) * step
  }
  
}

// MARK: SettingsItemConnector -
class SettingsItemConnector<Value>: ValueExternalStorage<Value> {
  
  override var value: Value {
    didSet {
      if saveToSettingsOnValueUpdate {
        writeValueToExternalStorage()
      }
    }
  }
  
  let settingsItem: SettingsItemBase<Value>
  var saveToSettingsOnValueUpdate: Bool
  
  init(settingsItem: SettingsItemBase<Value>, saveToSettingsOnValueUpdate: Bool) {
    self.settingsItem = settingsItem
    self.saveToSettingsOnValueUpdate = saveToSettingsOnValueUpdate
    super.init(value: settingsItem.value)
  }
  
  override func writeValueToExternalStorage() {
    settingsItem.value = value
  }
  
  override func readValueFromExternalStorage() {
    value = settingsItem.value
  }
  
}

