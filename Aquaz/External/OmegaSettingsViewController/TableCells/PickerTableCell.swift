//
//  PickerTableCell.swift
//  OmegaSettingsViewController
//
//  Created by Sergey Balyakin on 03.03.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class PickerTableCell<TValue: CustomStringConvertible, TCollection: Collection>: TableCellWithValue<TValue>, UIPickerTableViewCellDataSource, UIPickerTableViewCellDelegate
where TValue: Equatable, TCollection.Iterator.Element == TValue, TCollection.Index == Int {
  
  let collection: TCollection
  let height: UIPickerViewHeight
  
  var font: UIFont? {
    didSet {
      if let font = font {
        uiCell?.pickerViewFont = font
        uiCell?.refresh()
      }
    }
  }

  var uiCell: UIPickerTableViewCell?
  
  init(value: TValue, collection: TCollection, container: TableCellsContainer, height: UIPickerViewHeight = .medium) {
    self.collection = collection
    self.height = height
    super.init(value: value, container: container)
  }
  
  override func createUICell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
    if uiCell == nil {
      uiCell = UIPickerTableViewCell()
    }
    
    uiCell!.dataSource = self
    uiCell!.delegate = self
    if let font = font {
      uiCell!.pickerViewFont = font
    }
    updateUICell()
    return uiCell!
  }
  
  override func valueDidChange() {
    super.valueDidChange()
    updateUICell()
  }
  
  fileprivate func updateUICell() {
    if let uiCell = uiCell {
      var row: Int?
      if let numberValue = value as? NSNumber {
        row = findRowWithNearestValue(numberValue)
      } else {
        row = collection.index(of: value)
      }
      
      if let row = row {
        uiCell.pickerView.selectRow(row, inComponent: 0, animated: true)
      }
    }
  }
  
  fileprivate func findRowWithNearestValue(_ value: NSNumber) -> Int? {
    var minimumDelta: Double?
    var row: Int?
    for (index, item) in collection.enumerated() {
      let numberItem = item as! NSNumber
      let delta = abs(value.doubleValue - numberItem.doubleValue)
      if minimumDelta == nil || delta < minimumDelta! {
        minimumDelta = delta
        row = index
      }
    }
    return row
  }
  
  override func getRowHeight() -> CGFloat? {
    return height.rawValue
  }
  
  // MARK: PickerTableViewCellDataSource
  
  func numberOfComponentsInPickerView(_ pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    let count = collection.count
    return count
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
    let value = collection[row]
    let title = stringFromValueFunction?(value) ?? value.description
    return title
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForComponent: Int) -> String? {
    return nil
  }

  // MARK: PickerTableViewCellDelegate
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    let value = collection[row]
    self.value = value
    baseTableCell?.value = value
  }
  
  func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat? {
    return nil
  }

}
