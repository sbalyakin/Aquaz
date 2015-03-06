//
//  MultiPickerTableCell.swift
//  Aquaz
//
//  Created by Admin on 05.03.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class MultiPickerTableCell<Value: Equatable, ComponentCollection: CollectionType where ComponentCollection.Generator.Element: Printable, ComponentCollection.Index == Int>: TableCellWithValue<Value>, UIPickerTableViewCellDataSource, UIPickerTableViewCellDelegate {
  
  let components: [Component]
  let height: UIPickerViewHeight
  var selectionToValueFunction: SelectionToValueFunction?
  var valueToSelectionFunction: ValueToSelectionFunction?
  var collectionElementToStringFunction: CollectionElementToStringFunction?

  var uiCell: UIPickerTableViewCell?

  typealias Component = (title: String?, width: CGFloat?, collection: ComponentCollection)
  typealias SelectionToValueFunction = ([Int]) -> Value
  typealias ValueToSelectionFunction = (Value) -> [Int]
  typealias CollectionElementToStringFunction = (ComponentCollection.Generator.Element) -> String

  init(value: Value, components: [Component], container: TableCellsContainer, height: UIPickerViewHeight = .Medium) {
    self.components = components
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
    if let uiCell = uiCell, let selectedRows = valueToSelectionFunction?(value) {
      assert(selectedRows.count == uiCell.pickerView.numberOfComponents)
      for (component, row) in enumerate(selectedRows) {
        uiCell.pickerView.selectRow(row, inComponent: component, animated: true)
      }
    }
  }
  
  override func getRowHeight() -> CGFloat? {
    return height.rawValue
  }
  
  // MARK: PickerTableViewCellDataSource
  
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    let count = components.count
    return count
  }
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return count(components[component].collection)
  }
  
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
    let value = components[component].collection[row]
    let title = collectionElementToStringFunction?(value) ?? value.description
    return title
  }
  
  func pickerView(pickerView: UIPickerView, titleForComponent component: Int) -> String? {
    return components[component].title
  }
  
  // MARK: PickerTableViewCellDelegate
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    var selectedRows = [Int]()
    for component in 0..<pickerView.numberOfComponents {
      selectedRows += [pickerView.selectedRowInComponent(component)]
    }

    assert(selectedRows.count == components.count)
    
    if let value = selectionToValueFunction?(selectedRows) {
      self.value = value
      baseTableCell?.value = value
    }
  }
  
  func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat? {
    return components[component].width
  }
  
}
