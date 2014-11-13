//
//  DiaryViewController.swift
//  Water Me
//
//  Created by Sergey Balyakin on 05.11.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation

private extension Units.Volume {
  var precision: Double {
    switch self {
    case Millilitres: return 1.0
    case FluidOunces: return 0.1
    }
  }
  
  var decimals: Int {
    switch self {
    case Millilitres: return 0
    case FluidOunces: return 1
    }
  }
}

class DiaryViewController: UIViewController, UITableViewDataSource {

  @IBOutlet weak var tableView: UITableView!
  
  var dayViewController: DayViewController!
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return consumptions.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Consumption Cell", forIndexPath: indexPath) as UITableViewCell
    
    let consumption = consumptions[indexPath.row]
    let drink = consumption.drink.name
    let amount = Units.sharedInstance.formatAmountToText(amount: consumption.amount.doubleValue, unitType: .Volume, precision: amountPrecision, decimals: amountDecimals, displayUnits: true)

    let formatter = NSDateFormatter()
    formatter.dateStyle = .NoStyle
    formatter.timeStyle = .ShortStyle
    let date = formatter.stringFromDate(consumption.date)
    
    cell.textLabel.text = "\(date): \(drink) - \(amount)"
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
  private let amountPrecision = Settings.sharedInstance.generalVolumeUnits.value.precision
  private let amountDecimals = Settings.sharedInstance.generalVolumeUnits.value.decimals

}