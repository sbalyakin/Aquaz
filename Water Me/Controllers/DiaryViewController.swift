//
//  DiaryViewController.swift
//  Water Me
//
//  Created by Sergey Balyakin on 05.11.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation

class DiaryViewController: UIViewController, UITableViewDataSource {

  @IBOutlet weak var tableView: UITableView!
  
  var dayViewController: DayViewController!
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return consumptions.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("DiaryTableViewCell", forIndexPath: indexPath) as DiaryTableViewCell
    
    let consumption = consumptions[indexPath.row]
    cell.consumption = consumption
    
    return cell
  }
  
//  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//    let cell = tableView.dequeueReusableCellWithIdentifier("Consumption Cell", forIndexPath: indexPath) as UITableViewCell
//    
//    let consumption = consumptions[indexPath.row]
//    let drinkName = consumption.drink.localizedName
//    let amount = Units.sharedInstance.formatMetricAmountToText(metricAmount: consumption.amount.doubleValue, unitType: .Volume, roundPrecision: amountPrecision, decimals: amountDecimals, displayUnits: true)
//    
//    let formatter = NSDateFormatter()
//    formatter.dateStyle = .NoStyle
//    formatter.timeStyle = .ShortStyle
//    let date = formatter.stringFromDate(consumption.date)
//    
//    let paragraphStyle = NSMutableParagraphStyle()
//    paragraphStyle.defaultTabInterval = 60
//    
//    let dateTitle = NSAttributedString(string: "\(date)\t", attributes: [
//      NSForegroundColorAttributeName: UIColor.lightGrayColor(),
//      NSFontAttributeName: UIFont.systemFontOfSize(12),
//      NSParagraphStyleAttributeName: paragraphStyle])
//    
//    let drinkTitle = NSMutableAttributedString(string: "\(drinkName)\t\t\t\t", attributes: [
//      NSForegroundColorAttributeName: consumption.drink.darkColor,
//      NSFontAttributeName: UIFont.systemFontOfSize(16),
//      NSParagraphStyleAttributeName: paragraphStyle])
//    
//    let amountTitle = NSAttributedString(string: "\(amount)", attributes: [
//      NSFontAttributeName: UIFont.systemFontOfSize(16)])
//    
//    let title = NSMutableAttributedString()
//    title.appendAttributedString(dateTitle)
//    title.appendAttributedString(drinkTitle)
//    title.appendAttributedString(amountTitle)
//    
//    cell.textLabel!.attributedText = title
//    return cell
//  }
//  
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