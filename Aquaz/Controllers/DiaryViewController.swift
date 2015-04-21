//
//  DiaryViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 05.11.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation

class DiaryViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  
  weak var dayViewController: DayViewController!
  
  private var intakes: [Intake] = []
  
  private var sizingCell: DiaryTableViewCell!

  private struct Constants {
    static let diaryCellIdentifier = "DiaryTableViewCell"
    static let editIntakeSegue = "Edit Intake"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    UIHelper.applyStyle(self)
    tableView.backgroundView = nil
    tableView.backgroundColor = StyleKit.pageBackgroundColor
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    if let selectedIndexPath = tableView.indexPathForSelectedRow() {
      tableView.deselectRowAtIndexPath(selectedIndexPath, animated: false)
    }
  }
  
  func updateTable(intakes: [Intake]) {
    self.intakes = intakes
    tableView?.reloadData()
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == Constants.editIntakeSegue,
      let intakeViewController = segue.destinationViewController.contentViewController as? IntakeViewController,
      let indexPath = tableView.indexPathForSelectedRow()
    {
      let intake = intakes[indexPath.row]
      intakeViewController.intake = intake
      intakeViewController.dayViewController = dayViewController
    }
  }
  
}

// MARK: UITableViewDataSource
extension DiaryViewController: UITableViewDataSource {
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return intakes.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(Constants.diaryCellIdentifier, forIndexPath: indexPath) as! DiaryTableViewCell
    
    let intake = intakes[indexPath.row]
    cell.intake = intake
    
    return cell
  }
  
  func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  
  func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
      let intake = intakes[indexPath.row]
      intake.deleteEntity()
    }
  }
  
}

// MARK: UITableViewDelegate
extension DiaryViewController: UITableViewDelegate {

  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if sizingCell == nil {
      sizingCell = tableView.dequeueReusableCellWithIdentifier(Constants.diaryCellIdentifier) as! DiaryTableViewCell
    }

    let intake = intakes[indexPath.row]
    sizingCell.intake = intake
    sizingCell.setNeedsLayout()
    sizingCell.layoutIfNeeded()
    let size = sizingCell.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
    return size.height
  }
  
}
