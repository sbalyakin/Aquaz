//
//  TableCellWithValue.swift
//  OmegaSettingsViewController
//
//  Created by Sergey Balyakin on 03.03.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

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
  
  final var value: Value {
    didSet {
      valueDidChange()
    }
  }
  
  // Value initialization was moved to init() in order to solve Swift 2.2 bug on iOS7
  // More details here https://bugs.swift.org/browse/SR-815
  private var isInternalValueUpdate: Bool
  
  var valueExternalStorage: ValueExternalStorage<Value>? {
    didSet {
      if let valueExternalStorage = valueExternalStorage {
        isInternalValueUpdate = true
        value = valueExternalStorage.value
        isInternalValueUpdate = false
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
    isInternalValueUpdate = false
    
    super.init(container: container)
  }
  
  func valueDidChange() {
    if !isInternalValueUpdate {
      valueExternalStorage?.value = value
    }
    valueChangedFunction?(self)
  }
  
  override func writeToExternalStorage() {
    valueExternalStorage?.writeValueToExternalStorage()
  }
  
  override func readFromExternalStorage() {
    if let valueExternalStorage = valueExternalStorage {
      isInternalValueUpdate = true
      valueExternalStorage.readValueFromExternalStorage()
      value = valueExternalStorage.value
      isInternalValueUpdate = false
    }
  }
  
}