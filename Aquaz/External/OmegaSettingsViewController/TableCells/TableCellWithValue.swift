//
//  TableCellWithValue.swift
//  OmegaSettingsViewController
//
//  Created by Sergey Balyakin on 03.03.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

protocol TableCellWithValueDelegate {
  func valueDidChange()
}

class ValueExternalStorage<Value> {
  
  var value: Value
  
  init(value: Value) {
    self.value = value
  }
  
  func writeValueToExternalStorage() {
    // Do nothing
  }
  
  func readValueFromExternalStorage() {
    // Do nothing
  }

}

class TableCellWithValue<Value>: TableCell {
  
  var value: Value {
    didSet {
      valueExternalStorage?.value = value
      valueChangedFunction?(self)
    }
  }
  
  var valueExternalStorage: ValueExternalStorage<Value>? {
    didSet {
      if let valueExternalStorage = valueExternalStorage {
        value = valueExternalStorage.value
      }
    }
  }
  
  weak var baseTableCell: TableCellWithValue<Value>?
  
  override var isSupportingCell: Bool { return baseTableCell != nil }
  
  var stringFromValueFunction: StringFromValueFunction?
  var valueChangedFunction: ValueChangedFunction?
  
  typealias StringFromValueFunction = (Value) -> String
  typealias ValueChangedFunction = (TableCell) -> ()
  
  init(value: Value, container: TableCellsContainer){
    self.value = value
    super.init(container: container)
  }
  
  override func writeToExternalStorage() {
    valueExternalStorage?.writeValueToExternalStorage()
  }
  
  override func readFromExternalStorage() {
    if let valueExternalStorage = valueExternalStorage {
      valueExternalStorage.readValueFromExternalStorage()
      value = valueExternalStorage.value
    }
  }
  
}