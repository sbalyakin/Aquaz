//
//  SegmentedTableCell.swift
//  OmegaSettingsViewController
//
//  Created by Sergey Balyakin on 03.03.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class SegmentedTableCell<TValue: CustomStringConvertible, TCollection: Collection>: TableCellWithValue<TValue>, UISegmentedTableViewCellDelegate
where TValue: Equatable, TCollection.Iterator.Element == TValue, TCollection.Index == Int {
  
  var title: String { didSet { uiCell?.textLabel?.text = title } }
  var image: UIImage? { didSet { uiCell?.imageView?.image = image } }
  var collection: TCollection
  var uiCell: UISegmentedTableViewCell?
  
  var segmentsWidth: CGFloat {
    didSet {
      uiCell?.segmentsWidth = segmentsWidth
    }
  }
  
  init(title: String, value: TValue, collection: TCollection, container: TableCellsContainer, segmentsWidth: CGFloat = 0) {
    self.title = title
    self.collection = collection
    self.segmentsWidth = segmentsWidth
    super.init(value: value, container: container)
  }
  
  override func createUICell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
    if uiCell == nil {
      let segmentTitles = collection.map { return self.stringFromValueFunction?($0) ?? $0.description }
      uiCell = UISegmentedTableViewCell(segmentTitles: segmentTitles)
    }
    
    uiCell!.textLabel?.text = title
    uiCell!.imageView?.image = image
    uiCell!.delegate = self
    uiCell!.segmentsWidth = segmentsWidth
    updateUICell()
    return uiCell!
  }
  
  override func valueDidChange() {
    super.valueDidChange()
    updateUICell()
  }
  
  fileprivate func updateUICell() {
    if let uiCell = uiCell, let row = collection.index(of: value) {
      uiCell.segmentedControl.selectedSegmentIndex = row
    }
  }
  
  func segmentedControlValueChanged(_ segmentedControl: UISegmentedControl, segmentIndex: Int) {
    value = collection[segmentIndex]
    
    if !active {
      container.activateTableCell(self)
    }
  }
}
