//
//  MultiPickerTableCell.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 05.03.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class MultiPickerTableCell<TValue: Equatable, TComponentCollection: Collection>: TableCellWithValue<TValue>, UIPickerTableViewCellDataSource, UIPickerTableViewCellDelegate
where TComponentCollection.Iterator.Element: CustomStringConvertible, TComponentCollection.Index == Int {
  
  let components: [Component]
  let height: UIPickerViewHeight
  var selectionToValueFunction: SelectionToValueFunction?
  var valueToSelectionFunction: ValueToSelectionFunction?
  var collectionElementToStringFunction: CollectionElementToStringFunction?

  var uiCell: UIPickerTableViewCell?

  typealias Component = (title: String?, width: CGFloat?, collection: TComponentCollection)
  typealias SelectionToValueFunction = ([Int]) -> TValue
  typealias ValueToSelectionFunction = (TValue) -> [Int]
  typealias CollectionElementToStringFunction = (TComponentCollection.Iterator.Element) -> String

  init(value: TValue, components: [Component], container: TableCellsContainer, height: UIPickerViewHeight = .medium) {
    self.components = components
    self.height = height
    super.init(value: value, container: container)
  }
  
  override func createUICell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
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
  
  fileprivate func updateUICell() {
    if let uiCell = uiCell, let selectedRows = valueToSelectionFunction?(value) {
      assert(selectedRows.count == uiCell.pickerView.numberOfComponents)
      for (component, row) in selectedRows.enumerated() {
        uiCell.pickerView.selectRow(row, inComponent: component, animated: true)
      }
    }
  }
  
  override func getRowHeight() -> CGFloat? {
    return height.rawValue
  }
  
  // MARK: protocol UIPickerTableViewCellDataSource
  
  func numberOfComponentsInPickerView(_ pickerView: UIPickerView) -> Int {
    let count = components.count
    return count
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return components[component].collection.count
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
    let value = components[component].collection[row]
    let title = collectionElementToStringFunction?(value) ?? value.description
    return title
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForComponent component: Int) -> String? {
    return components[component].title
  }
  
  // MARK: protocol UIPickerTableViewCellDelegate
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    var selectedRows = [Int]()
    for component in 0..<pickerView.numberOfComponents {
      selectedRows += [pickerView.selectedRow(inComponent: component)]
    }

    assert(selectedRows.count == components.count)
    
    if let value = selectionToValueFunction?(selectedRows) {
      self.value = value
      baseTableCell?.value = value
    }
  }
  
  func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat? {
    return components[component].width
  }
  
}
