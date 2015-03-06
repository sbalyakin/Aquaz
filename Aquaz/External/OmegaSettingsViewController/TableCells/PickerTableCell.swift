//
//  PickerTableCell.swift
//  OmegaSettingsViewController
//
//  Created by Sergey Balyakin on 03.03.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class PickerTableCell<Value: Printable, Collection: CollectionType where Value: Equatable, Collection.Generator.Element == Value, Collection.Index == Int>: TableCellWithValue<Value>, UIPickerTableViewCellDataSource, UIPickerTableViewCellDelegate {
  
  let collection: Collection
  let height: UIPickerViewHeight

  var uiCell: UIPickerTableViewCell?
  
  init(value: Value, collection: Collection, container: TableCellsContainer, height: UIPickerViewHeight = .Medium) {
    self.collection = collection
    self.height = height
    super.init(value: value, container: container)
  }
  
  override func createUICell(#tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
    if uiCell == nil {
      uiCell = UIPickerTableViewCell()
    }
    
    uiCell!.dataSource = self
    uiCell!.delegate = self
    updateUICell()
    return uiCell!
  }
  
  override func valueDidChange() {
    super.valueDidChange()
    updateUICell()
  }
  
  private func updateUICell() {
    if let uiCell = uiCell, let row = find(collection, value) {
      uiCell.pickerView.selectRow(row, inComponent: 0, animated: true)
    }
  }
  
  override func getRowHeight() -> CGFloat? {
    return height.rawValue
  }
  
  // MARK: PickerTableViewCellDataSource
  
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return count(collection)
  }
  
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
    let value = collection[row]
    let title = stringFromValueFunction?(value) ?? value.description
    return title
  }
  
  func pickerView(pickerView: UIPickerView, titleForComponent: Int) -> String? {
    return nil
  }

  // MARK: PickerTableViewCellDelegate
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    let value = collection[row]
    self.value = value
    baseTableCell?.value = value
  }
  
  func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat? {
    return nil
  }

}