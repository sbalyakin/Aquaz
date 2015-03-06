//
//  SegmentedTableCell.swift
//  OmegaSettingsViewController
//
//  Created by Sergey Balyakin on 03.03.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class SegmentedTableCell<Value: Printable, Collection: CollectionType where Value: Equatable, Collection.Generator.Element == Value, Collection.Index == Int>: TableCellWithValue<Value>, UISegmentedTableViewCellDelegate {
  
  var title: String { didSet { uiCell?.textLabel?.text = title } }
  var collection: Collection
  var uiCell: UISegmentedTableViewCell?
  var segmentsWidth: CGFloat {
    didSet {
      uiCell?.segmentsWidth = segmentsWidth
    }
  }
  
  init(title: String, value: Value, collection: Collection, container: TableCellsContainer, segmentsWidth: CGFloat = 0) {
    self.title = title
    self.collection = collection
    self.segmentsWidth = segmentsWidth
    super.init(value: value, container: container)
  }
  
  override func createUICell(#tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
    if uiCell == nil {
      let segmentTitles = map(collection) { return self.stringFromValueFunction?($0) ?? $0.description }
      uiCell = UISegmentedTableViewCell(segmentTitles: segmentTitles)
    }
    
    uiCell!.textLabel?.text = title
    uiCell!.delegate = self
    uiCell!.segmentsWidth = segmentsWidth
    updateUICell()
    return uiCell!
  }
  
  override func valueDidChange() {
    super.valueDidChange()
    updateUICell()
  }
  
  private func updateUICell() {
    if let uiCell = uiCell, let row = find(collection, value) {
      uiCell.segmentedControl.selectedSegmentIndex = row
    }
  }
  
  func segmentedControlValueChanged(segmentedControl: UISegmentedControl, segmentIndex: Int) {
    value = collection[segmentIndex]
    
    if !active {
      container.activateTableCell(self)
    }
  }
}
