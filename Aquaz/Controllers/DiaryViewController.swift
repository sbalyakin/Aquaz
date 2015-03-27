//
//  DiaryViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 05.11.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation

class DiaryViewController: UIViewController, UITableViewDataSource {

  @IBOutlet weak var tableView: UITableView!
  
  weak var dayViewController: DayViewController!
  
  private struct Constants {
    static let diaryCellIdentifier = "DiaryTableViewCell"
    static let editIntakeSegue = "Edit Intake"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    UIHelper.applyStyle(self)
    tableView.backgroundColor = StyleKit.pageBackgroundColor
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    if let selectedIndexPath = tableView.indexPathForSelectedRow() {
      tableView.deselectRowAtIndexPath(selectedIndexPath, animated: false)
    }
  }
  
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
      dayViewController.removeIntake(intake)
      intake.deleteEntity()
    }
  }
  
  func updateTable(intakes: [Intake]) {
    self.intakes = intakes

    if tableView != nil {
      tableView.reloadData()
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == Constants.editIntakeSegue {
      if let intakeViewController = segue.destinationViewController.contentViewController as? IntakeViewController {
        if let indexPath = tableView.indexPathForSelectedRow() {
          let intake = intakes[indexPath.row]
          intakeViewController.intake = intake
          intakeViewController.dayViewController = dayViewController
        }
      }
    }
  }
  
  private var intakes: [Intake] = []

}