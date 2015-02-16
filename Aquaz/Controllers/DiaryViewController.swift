//
//  DiaryViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 05.11.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation

class DiaryViewController: StyledViewController, UITableViewDataSource {

  @IBOutlet weak var tableView: UITableView!
  
  var dayViewController: DayViewController!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.backgroundColor = StyleKit.pageBackgroundColor
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return intakes.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("DiaryTableViewCell", forIndexPath: indexPath) as! DiaryTableViewCell
    
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
    if segue.identifier == "Edit Intake" {
      if let intakeViewController = segue.destinationViewController as? IntakeViewController {
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