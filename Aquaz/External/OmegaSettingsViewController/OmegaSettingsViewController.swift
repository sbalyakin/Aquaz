//
//  OmegaSettingsViewController.swift
//  OmegaSettingsViewController
//
//  Created by Sergey Balyakin on 03.03.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

// MARK: TableCellsContainer -
protocol TableCellsContainer: class {
  func addSupportingTableCell(baseTableCell: TableCell, supportingTableCell: TableCell)
  func deleteSupportingTableCell()
  func activateTableCell(_ tableCell: TableCell?)
  
  var rightDetailValueColor: UIColor { get }
  var rightDetailSelectedValueColor: UIColor { get }
}

// MARK: OmegaSettingsViewController -
class OmegaSettingsViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  
  var tableCellsSections: [TableCellsSection] = []

  var rightDetailValueColor = UIColor.darkGray
  var rightDetailSelectedValueColor = UIColor.red
  
  /// If true all settings item will be saved to user defaults automatically on value update
  var saveToSettingsOnValueUpdate = true
  
  fileprivate var activeTableCell: TableCell?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.keyboardDismissMode = .onDrag
    tableCellsSections = createTableCellsSections()
  }
  
  deinit {
    // It prevents EXC_BAD_ACCESS on deferred reloading the table view
    tableView?.dataSource = nil
    tableView?.delegate = nil
  }
  
  func createTableCellsSections() -> [TableCellsSection] {
    assert(false, "This method should be overriden by descendants")
    return []
  }
  
  func recreateTableCellsSections() {
    tableCellsSections = createTableCellsSections()
    tableView.reloadData()
  }
  
  func createBasicTableCell(
    title: String,
    accessoryType: UITableViewCellAccessoryType? = nil) -> BasicTableCell
  {
    return BasicTableCell(title: title, container: self, accessoryType: accessoryType)
  }
  
  func createSwitchTableCell(
    title: String,
    settingsItem: SettingsItemBase<Bool>) -> SwitchTableCell
  {
    let cell = SwitchTableCell(title: title, value: settingsItem.value, container: self)
    cell.valueExternalStorage = SettingsItemConnector(settingsItem: settingsItem, saveToSettingsOnValueUpdate: saveToSettingsOnValueUpdate)
    return cell
  }
  
  func createSwitchTableCell(title: String, value: Bool) -> SwitchTableCell {
    return SwitchTableCell(title: title, value: value, container: self)
  }
  
  func createRangedSegmentedTableCell<TValue: CustomStringConvertible, TCollection: Collection>(
    title: String,
    value: TValue,
    collection: TCollection,
    stringFromValueFunction: @escaping ((TValue) -> String)) -> SegmentedTableCell<TValue, TCollection>
    where TValue: Equatable, TCollection.Iterator.Element == TValue, TCollection.Index == Int
  {
    let cell = SegmentedTableCell(title: title, value: value, collection: collection, container: self)
    cell.stringFromValueFunction = stringFromValueFunction
    return cell
  }
  
  func createRangedSegmentedTableCell<TValue: CustomStringConvertible, TCollection: Collection>(
    title: String,
    settingsItem: SettingsItemBase<TValue>,
    collection: TCollection,
    stringFromValueFunction: @escaping ((TValue) -> String)) -> SegmentedTableCell<TValue, TCollection>
    where TValue: Equatable, TCollection.Iterator.Element == TValue, TCollection.Index == Int
  {
    let cell = SegmentedTableCell(title: title, value: settingsItem.value, collection: collection, container: self)
    cell.valueExternalStorage = SettingsItemConnector(settingsItem: settingsItem, saveToSettingsOnValueUpdate: saveToSettingsOnValueUpdate)
    cell.stringFromValueFunction = stringFromValueFunction
    return cell
  }
  
  func createEnumSegmentedTableCell<TValue>(
    title: String,
    value: TValue,
    stringFromValueFunction: @escaping ((TValue) -> String),
    segmentsWidth: CGFloat = 0) -> SegmentedTableCell<TValue, EnumCollection<TValue>>
  {
    let cell = SegmentedTableCell(title: title, value: value, collection: EnumCollection<TValue>(), container: self, segmentsWidth: segmentsWidth)
    cell.stringFromValueFunction = stringFromValueFunction
    return cell
  }
  
  func createEnumSegmentedTableCell<TValue>(
    title: String,
    settingsItem: SettingsItemBase<TValue>,
    stringFromValueFunction: @escaping ((TValue) -> String),
    segmentsWidth: CGFloat = 0) -> SegmentedTableCell<TValue, EnumCollection<TValue>>
  {
    let cell = SegmentedTableCell(title: title, value: settingsItem.value, collection: EnumCollection<TValue>(), container: self, segmentsWidth: segmentsWidth)
    cell.valueExternalStorage = SettingsItemConnector(settingsItem: settingsItem, saveToSettingsOnValueUpdate: saveToSettingsOnValueUpdate)
    cell.stringFromValueFunction = stringFromValueFunction
    return cell
  }
  
  func createEnumSegmentedTableCell<TValue>(
    title: String,
    value: TValue,
    segmentsWidth: CGFloat = 0) -> SegmentedTableCell<TValue, EnumCollection<TValue>>
  {
    return SegmentedTableCell(title: title, value: value, collection: EnumCollection<TValue>(), container: self, segmentsWidth: segmentsWidth)
  }
  
  func createEnumSegmentedTableCell<TValue>(
    title: String,
    settingsItem: SettingsItemBase<TValue>,
    segmentsWidth: CGFloat = 0) -> SegmentedTableCell<TValue, EnumCollection<TValue>>
  {
    let cell = SegmentedTableCell(title: title, value: settingsItem.value, collection: EnumCollection<TValue>(), container: self, segmentsWidth: segmentsWidth)
    cell.valueExternalStorage = SettingsItemConnector(settingsItem: settingsItem, saveToSettingsOnValueUpdate: saveToSettingsOnValueUpdate)
    return cell
  }
  
  func createRightDetailTableCell<TValue: CustomStringConvertible>(
    title: String,
    value: TValue,
    stringFromValueFunction: @escaping ((TValue) -> String),
    accessoryType: UITableViewCellAccessoryType = .none) -> RightDetailTableCell<TValue>
  {
    return RightDetailTableCell(title: title, value: value, container: self, accessoryType: accessoryType)
  }
  
  func createRightDetailTableCell<TValue: CustomStringConvertible>(
    title: String,
    settingsItem: SettingsItemBase<TValue>,
    stringFromValueFunction: (@escaping ((TValue) -> String)),
    accessoryType: UITableViewCellAccessoryType = .none) -> RightDetailTableCell<TValue>
  {
    let cell = RightDetailTableCell(title: title, value: settingsItem.value, container: self, accessoryType: accessoryType)
    cell.valueExternalStorage = SettingsItemConnector(settingsItem: settingsItem, saveToSettingsOnValueUpdate: saveToSettingsOnValueUpdate)
    cell.stringFromValueFunction = stringFromValueFunction
    return cell
  }
  
  func createRangedRightDetailTableCell<TValue: CustomStringConvertible, TCollection: Collection>(
    title: String,
    settingsItem: SettingsItemBase<TValue>,
    collection: TCollection,
    stringFromValueFunction: @escaping ((TValue) -> String),
    pickerTableCellHeight: UIPickerViewHeight = .medium) -> RightDetailTableCell<TValue>
    where TValue: Equatable, TCollection.Iterator.Element == TValue, TCollection.Index == Int, TCollection.IndexDistance == Int
  {
    let cell = RightDetailTableCell(title: title, value: settingsItem.value, container: self, accessoryType: .none)
    cell.valueExternalStorage = SettingsItemConnector(settingsItem: settingsItem, saveToSettingsOnValueUpdate: saveToSettingsOnValueUpdate)
    cell.supportingTableCell = PickerTableCell(value: settingsItem.value, collection: collection, container: self, height: pickerTableCellHeight)
    
    cell.stringFromValueFunction = stringFromValueFunction
    cell.supportingTableCell?.stringFromValueFunction = stringFromValueFunction
    
    return cell
  }
  
  func createRangedRightDetailTableCell<TValue: CustomStringConvertible, TCollection: Collection>(
    title: String,
    value: TValue,
    collection: TCollection,
    stringFromValueFunction: @escaping ((TValue) -> String),
    pickerTableCellHeight: UIPickerViewHeight = .medium) -> RightDetailTableCell<TValue>
    where TValue: Equatable, TCollection.Iterator.Element == TValue, TCollection.Index == Int, TCollection.IndexDistance == Int
  {
    let cell = RightDetailTableCell(title: title, value: value, container: self, accessoryType: .none)
    cell.supportingTableCell = PickerTableCell(value: value, collection: collection, container: self, height: pickerTableCellHeight)
    
    cell.stringFromValueFunction = stringFromValueFunction
    cell.supportingTableCell?.stringFromValueFunction = stringFromValueFunction
    
    return cell
  }
  
  func createEnumRightDetailTableCell<TValue: RawRepresentable>(
    title: String,
    settingsItem: SettingsItemBase<TValue>,
    stringFromValueFunction: @escaping ((TValue) -> String),
    pickerTableCellHeight: UIPickerViewHeight = .medium) -> RightDetailTableCell<TValue>
    where TValue: CustomStringConvertible, TValue: Equatable, TValue.RawValue == Int
  {
    return createRangedRightDetailTableCell(
      title: title,
      settingsItem: settingsItem,
      collection: EnumCollection<TValue>(),
      stringFromValueFunction: stringFromValueFunction,
      pickerTableCellHeight: pickerTableCellHeight)
  }
  
  func createEnumRightDetailTableCell<TValue: RawRepresentable>(
    title: String,
    value: TValue,
    stringFromValueFunction: @escaping ((TValue) -> String),
    pickerTableCellHeight: UIPickerViewHeight = .medium) -> RightDetailTableCell<TValue>
    where TValue: CustomStringConvertible, TValue: Equatable, TValue.RawValue == Int
  {
    return createRangedRightDetailTableCell(
      title: title,
      value: value,
      collection: EnumCollection<TValue>(),
      stringFromValueFunction: stringFromValueFunction,
      pickerTableCellHeight: pickerTableCellHeight)
  }
  
  func createTimeIntervalRightDetailTableCell(
    title: String,
    value: TimeInterval,
    timeComponents: [TimeIntervalPickerTableCellComponent],
    stringFromValueFunction: @escaping ((TimeInterval) -> String),
    height: UIPickerViewHeight = .medium) -> RightDetailTableCell<TimeInterval>
  {
    let cell = RightDetailTableCell(title: title, value: value, container: self)
    cell.supportingTableCell = TimeIntervalPickerTableCell(value: value, timeComponents: timeComponents, container: self, height: height)
    cell.stringFromValueFunction = stringFromValueFunction
    return cell
  }
  
  func createTimeIntervalRightDetailTableCell(
    title: String,
    settingsItem: SettingsItemBase<TimeInterval>,
    timeComponents: [TimeIntervalPickerTableCellComponent],
    stringFromValueFunction: @escaping ((TimeInterval) -> String),
    height: UIPickerViewHeight = .medium) -> RightDetailTableCell<TimeInterval>
  {
    let cell = RightDetailTableCell(title: title, value: settingsItem.value, container: self)
    cell.supportingTableCell = TimeIntervalPickerTableCell(value: settingsItem.value, timeComponents: timeComponents, container: self, height: height)
    cell.stringFromValueFunction = stringFromValueFunction
    cell.valueExternalStorage = SettingsItemConnector(settingsItem: settingsItem, saveToSettingsOnValueUpdate: saveToSettingsOnValueUpdate)
    return cell
  }
  
  func createDateRightDetailTableCell(
    title: String,
    value: Date,
    datePickerMode: DatePickerTableCellMode,
    stringFromValueFunction: @escaping ((Date) -> String),
    minimumDate: Date? = nil,
    maximumDate: Date? = nil,
    height: UIPickerViewHeight = .medium) -> RightDetailTableCell<Date>
  {
    let cell = RightDetailTableCell(title: title, value: value, container: self)
    cell.supportingTableCell = DatePickerTableCell(value: value, container: self, datePickerMode: datePickerMode, minimumDate: minimumDate, maximumDate: maximumDate, height: height)
    cell.stringFromValueFunction = stringFromValueFunction
    return cell
  }
  
  func createDateRightDetailTableCell(
    title: String,
    settingsItem: SettingsItemBase<Date>,
    datePickerMode: DatePickerTableCellMode,
    stringFromValueFunction: @escaping ((Date) -> String),
    minimumDate: Date? = nil,
    maximumDate: Date? = nil,
    height: UIPickerViewHeight = .medium) -> RightDetailTableCell<Date>
  {
    let cell = RightDetailTableCell(title: title, value: settingsItem.value, container: self)
    cell.supportingTableCell = DatePickerTableCell(value: settingsItem.value, container: self, datePickerMode: datePickerMode, minimumDate: minimumDate, maximumDate: maximumDate, height: height)
    cell.stringFromValueFunction = stringFromValueFunction
    cell.valueExternalStorage = SettingsItemConnector(settingsItem: settingsItem, saveToSettingsOnValueUpdate: saveToSettingsOnValueUpdate)
    return cell
  }
  
  func createTextFieldTableCell<TValue: CustomStringConvertible>(
    title: String,
    value: TValue,
    valueFromStringFunction: @escaping ((String) -> TValue?),
    stringFromValueFunction: @escaping ((TValue) -> String),
    keyboardType: UIKeyboardType = .default,
    borderStyle: UITextBorderStyle = .none) -> TextFieldTableCell<TValue>
  {
    let cell = TextFieldTableCell(title: title, value: value, valueFromStringFunction: valueFromStringFunction, container: self, keyboardType: keyboardType, textFieldBorderStyle: borderStyle)
    cell.stringFromValueFunction = stringFromValueFunction
    return cell
  }
  
  func createTextFieldTableCell<TValue: CustomStringConvertible>(
    title: String,
    settingsItem: SettingsItemBase<TValue>,
    valueFromStringFunction: @escaping ((String) -> TValue?),
    stringFromValueFunction: @escaping ((TValue) -> String),
    keyboardType: UIKeyboardType = .default,
    borderStyle: UITextBorderStyle = .none) -> TextFieldTableCell<TValue>
  {
    let cell = TextFieldTableCell(title: title, value: settingsItem.value, valueFromStringFunction: valueFromStringFunction, container: self, keyboardType: keyboardType, textFieldBorderStyle: borderStyle)
    cell.valueExternalStorage = SettingsItemConnector(settingsItem: settingsItem, saveToSettingsOnValueUpdate: saveToSettingsOnValueUpdate)
    cell.stringFromValueFunction = stringFromValueFunction
    return cell
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.handleKeyboardWillShowNotification(_:)),
      name: NSNotification.Name.UIKeyboardWillShow,
      object: nil)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.handleKeyboardWillHideNotification(_:)),
      name: NSNotification.Name.UIKeyboardWillHide,
      object: nil)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    activateTableCell(nil)

    let notificationCenter = NotificationCenter.default
    notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }
  
  func handleKeyboardWillShowNotification(_ notification: Notification) {
    let userInfo = (notification as NSNotification).userInfo!
    
    let infoRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue
    let size = infoRect!.size
    
    let contentInsets: UIEdgeInsets
    if UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation) {
      contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: size.height, right: 0)
    } else {
      contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: size.width, right: 0)
    }
    
    let animationDuration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
    UIView.animate(withDuration: animationDuration, animations: {
      self.tableView.contentInset = contentInsets
      self.tableView.scrollIndicatorInsets = contentInsets
    })
  }
  
  func handleKeyboardWillHideNotification(_ notification: Notification) {
    tableView.contentInset = UIEdgeInsets.zero
    tableView.scrollIndicatorInsets = UIEdgeInsets.zero
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
  func addSupportingTableCell(baseTableCell: TableCell, supportingTableCell: TableCell) {
    var insertedIndexPath: IndexPath!
    tableView.beginUpdates()
    
    section: for (sectionIndex, section) in tableCellsSections.enumerated() {
      for (cellIndex, tableCell) in section.tableCells.enumerated() {
        if tableCell === baseTableCell {
          let insertIndex = cellIndex + 1
          insertedIndexPath = IndexPath(row: insertIndex, section: sectionIndex)
          tableView.insertRows(at: [insertedIndexPath], with: .fade)
          section.tableCells.insert(supportingTableCell, at: insertIndex)
          break section
        }
      }
    }
    
    tableView.endUpdates()
    
    if insertedIndexPath != nil {
      tableView.scrollToRow(at: insertedIndexPath, at: UITableViewScrollPosition.bottom, animated: true)
    }
  }
  
  func activateTableCell(_ tableCell: TableCell?) {
    if tableCell === activeTableCell {
      tableCell?.setActive(false)
      activeTableCell = nil
    } else {
      activeTableCell?.setActive(false)
      tableCell?.setActive(true)
      if tableCell?.supportsPermanentActivation ?? true {
        activeTableCell = tableCell
      }
    }
  }
  
  func deleteSupportingTableCell() {
    tableView.beginUpdates()
    
    section: for (sectionIndex, section) in tableCellsSections.enumerated() {
      for (cellIndex, tableCell) in section.tableCells.enumerated() {
        if tableCell.isSupportingCell {
          let indexPath = IndexPath(row: cellIndex, section: sectionIndex)
          tableView.deleteRows(at: [indexPath], with: .fade)
          section.tableCells.remove(at: cellIndex)
          break section
        }
      }
    }
    
    tableView.endUpdates()
  }
  
}

// MARK: UITableView data source and delegate
extension OmegaSettingsViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tableCellsSections[section].tableCells.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let tableCell = getTableCellForRowAtIndexPath(indexPath)
    let cell = tableCell.createUICell(tableView: tableView, indexPath: indexPath)
    return cell
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return tableCellsSections.count
  }
  
  fileprivate func getTableCellForRowAtIndexPath(_ indexPath: IndexPath) -> TableCell {
    let section = tableCellsSections[(indexPath as NSIndexPath).section]
    let cell = section.tableCells[(indexPath as NSIndexPath).row]
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let tableCell = getTableCellForRowAtIndexPath(indexPath)
    return tableCell.getRowHeight() ?? tableView.rowHeight
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let section = tableCellsSections[section]
    return section.headerTitle
  }
  
  func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    let section = tableCellsSections[section]
    return section.footerTitle
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let tableCell = getTableCellForRowAtIndexPath(indexPath)
    activateTableCell(tableCell)
    // A selected cell should be deselected because iOS does not paint a separator for selected cells.
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

// MARK: TableCellsSection -
class TableCellsSection {
  var headerTitle: String?
  var footerTitle: String?
  var tableCells: [TableCell] = []
}

// MARK: EnumCollection -
class EnumCollection<T: RawRepresentable>: Collection where T.RawValue == Int {
  
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
      endIndex = startIndex
      while T(rawValue: endIndex!) != nil {
        endIndex! += 1
      }
    }
    
    self.endIndex = endIndex!
  }
  
  func makeIterator() -> AnyIterator<T> {
    var index = startIndex
    return AnyIterator {
      index += 1
      return index <= self.endIndex ? T(rawValue: index) : nil
    }
  }
  
  subscript(i: Int) -> T {
    return T(rawValue: startIndex + i)!
  }
  
  /// Returns the position immediately after the given index.
  ///
  /// - Parameter i: A valid index of the collection. `i` must be less than
  ///   `endIndex`.
  /// - Returns: The index value immediately after `i`.
  public func index(after i: Int) -> Int {
    return i + 1
  }
  
}

// MARK: IntCollection -
class IntCollection: Collection {
  
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
    endIndex = (maximumValue - minimumValue) / step + 1
  }
  
  func makeIterator() -> AnyIterator<Int> {
    var index = startIndex
    return AnyIterator {
      if index <= self.endIndex {
        let value = self.minimumValue + index * self.step
        index += 1
        return value
      } else {
        return nil
      }
    }
  }
  
  subscript(index: Int) -> Int {
    return minimumValue + index * step
  }
  
  /// Returns the position immediately after the given index.
  ///
  /// - Parameter i: A valid index of the collection. `i` must be less than
  ///   `endIndex`.
  /// - Returns: The index value immediately after `i`.
  public func index(after i: Int) -> Int {
    return i + 1
  }

}

// MARK: DoubleCollection -
class DoubleCollection: Collection {
  
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
    endIndex = Int((maximumValue - minimumValue) / step) + 1
  }
  
  func makeIterator() -> AnyIterator<Double> {
    var index = startIndex
    return AnyIterator {
      if index <= self.endIndex {
        let value = self.minimumValue + Double(index) * self.step
        index += 1
        return value
      } else {
        return nil
      }
    }
  }
  
  subscript(index: Int) -> Double {
    return minimumValue + Double(index) * step
  }
  
  /// Returns the position immediately after the given index.
  ///
  /// - Parameter i: A valid index of the collection. `i` must be less than
  ///   `endIndex`.
  /// - Returns: The index value immediately after `i`.
  public func index(after i: Int) -> Int {
    return i + 1
  }

}

// MARK: SettingsItemConnector -
class SettingsItemConnector<Value: Equatable>: ValueExternalStorage<Value> {
  
  override var value: Value {
    didSet {
      if saveToSettingsOnValueUpdate && !isInternalValueUpdate {
        writeValueToExternalStorage()
      }
    }
  }
  
  weak var settingsItem: SettingsItemBase<Value>?
  let saveToSettingsOnValueUpdate: Bool

  fileprivate var isInternalValueUpdate = false
  
  init(settingsItem: SettingsItemBase<Value>, saveToSettingsOnValueUpdate: Bool) {
    self.settingsItem = settingsItem
    self.saveToSettingsOnValueUpdate = saveToSettingsOnValueUpdate
    
    super.init(value: settingsItem.value)
  }
  
  override func writeValueToExternalStorage() {
    settingsItem?.value = value
  }
  
  override func readValueFromExternalStorage() {
    if let settingsItem = settingsItem {
      isInternalValueUpdate = true
      value = settingsItem.value
      isInternalValueUpdate = false
    }
  }
  
}

