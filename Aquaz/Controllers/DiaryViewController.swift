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
    return consumptions.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("DiaryTableViewCell", forIndexPath: indexPath) as! DiaryTableViewCell
    
    let consumption = consumptions[indexPath.row]
    cell.consumption = consumption
    
    return cell
  }

  func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  
  func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
      let consumption = consumptions[indexPath.row]
      dayViewController.removeConsumption(consumption)
      consumption.deleteEntity()
    }
  }
  
  func updateTable(consumptions: [Consumption]) {
    self.consumptions = consumptions

    if tableView != nil {
      tableView.reloadData()
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "Edit Consumption" {
      if let consumptionViewController = segue.destinationViewController as? ConsumptionViewController {
        if let indexPath = tableView.indexPathForSelectedRow() {
          let consumption = consumptions[indexPath.row]
          consumptionViewController.consumption = consumption
          consumptionViewController.dayViewController = dayViewController
        }
      }
    }
  }
  
  private var consumptions: [Consumption] = []

}