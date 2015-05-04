//
//  DiaryViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 05.11.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData

class DiaryViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  
  var date: NSDate! { didSet { dateWasChanged() } }

  private var fetchedResultsController: NSFetchedResultsController!
  private var managedObjectContext: NSManagedObjectContext { return CoreDataStack.privateContext }
  private var sizingCell: DiaryTableViewCell!
  private var volumeObserverIdentifier: Int?

  private struct Constants {
    static let diaryCellIdentifier = "DiaryTableViewCell"
    static let editIntakeSegue = "Edit Intake"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    applyStyle()
    initFetchedResultsController(completion: nil)
    
    volumeObserverIdentifier = Settings.generalVolumeUnits.addObserver { [unowned self] value in
      self.tableView.reloadData()
    }
  }
  
  deinit {
    if let volumeObserverIdentifier = volumeObserverIdentifier {
      Settings.generalVolumeUnits.removeObserver(volumeObserverIdentifier)
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    if let selectedIndexPath = tableView.indexPathForSelectedRow() {
      tableView.deselectRowAtIndexPath(selectedIndexPath, animated: false)
    }
  }

  private func applyStyle() {
    UIHelper.applyStyle(self)
    tableView.backgroundView = nil
    tableView.backgroundColor = StyleKit.pageBackgroundColor
  }
  
  private func dateWasChanged() {
    if date == nil || fetchedResultsController == nil {
      return
    }
    
    initFetchedResultsController {
      self.tableView?.reloadData()
    }
  }
  
  private func initFetchedResultsController(#completion: (() -> ())?) {
    managedObjectContext.performBlock {
      let beginDate = DateHelper.dateByClearingTime(ofDate: self.date)
      let endDate = DateHelper.addToDate(beginDate, years: 0, months: 0, days: 1)
      
      let predicate = NSPredicate(format: "(date >= %@) AND (date < %@)", argumentArray: [beginDate, endDate])
      let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
      
      let fetchRequest = NSFetchRequest(entityName: Intake.entityName)
      fetchRequest.sortDescriptors = [sortDescriptor]
      fetchRequest.predicate = predicate
      
      self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
      self.fetchedResultsController.delegate = self
      
      var error: NSError?
      if !self.fetchedResultsController.performFetch(&error) {
        Logger.logError(Logger.Messages.failedToSaveManagedObjectContext, error: error)
      }
      
      if let completion = completion {
        dispatch_async(dispatch_get_main_queue()) {
          completion()
        }
      }
    }
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == Constants.editIntakeSegue,
      let intakeViewController = segue.destinationViewController.contentViewController as? IntakeViewController,
      let indexPath = tableView.indexPathForSelectedRow()
    {
      managedObjectContext.performBlock {
        let intake = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Intake
        dispatch_async(dispatch_get_main_queue()) {
          intakeViewController.intake = intake
        }
      }
    }
  }
  
}

// MARK: UITableViewDataSource
extension DiaryViewController: UITableViewDataSource {
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return fetchedResultsController.sections!.count
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let sectionInfo = fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
    return sectionInfo.numberOfObjects
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(Constants.diaryCellIdentifier, forIndexPath: indexPath) as! DiaryTableViewCell
    
    let intake = fetchedResultsController.objectAtIndexPath(indexPath) as! Intake
    
    cell.intake = intake
    
    checkHelpTip(indexPath: indexPath, cell: cell)
    
    return cell
  }
  
  private func checkHelpTip(#indexPath: NSIndexPath, cell: DiaryTableViewCell) {
    if Settings.uiDiaryPageHelpTipIsShown.value || indexPath.row != 0 {
      return
    }
    
    executeBlockWithDelay(1) {
      self.showHelpTipForCell(cell)
    }
  }
  
  private func showHelpTipForCell(cell: DiaryTableViewCell) {
    if view.window == nil {
      return
    }
    
    Settings.uiDiaryPageHelpTipIsShown.value = true
    
    let text = NSLocalizedString("Amount of pure water of the intake", value: "Amount of pure water of the intake", comment: "DiaryViewController: Text for help tip about pure water amount text of the diary cell")

    let tooltip = JDFTooltipView(targetView: cell.waterAmountLabel, hostView: cell, tooltipText: text, arrowDirection: .Up, width: self.view.frame.width / 3)
    
    tooltip.tooltipBackgroundColour = StyleKit.helpTipsColor
    tooltip.textColour = UIColor.blackColor()
    
    tooltip.showCompletionBlock = {
      self.executeBlockWithDelay(4) {
        tooltip.hideAnimated(true)
      }
    }
    tooltip.show()
  }

  private func executeBlockWithDelay(delay: NSTimeInterval, block: () -> ()) {
    let executeTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * NSTimeInterval(NSEC_PER_SEC)));
    
    dispatch_after(executeTime, dispatch_get_main_queue()) {
      block()
    }
  }

  func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  
  func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
      managedObjectContext.performBlock {
        let intake = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Intake
        intake.deleteEntity(saveImmediately: true)
      }
    }
  }
  
}

// MARK: UITableViewDelegate
extension DiaryViewController: UITableViewDelegate {

  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if sizingCell == nil {
      sizingCell = tableView.dequeueReusableCellWithIdentifier(Constants.diaryCellIdentifier) as! DiaryTableViewCell
    }

    let intake = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Intake
    sizingCell.intake = intake
    sizingCell.setNeedsLayout()
    sizingCell.layoutIfNeeded()
    let size = sizingCell.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
    return size.height
  }
  
}

// MARK: NSFetchedResultsControllerDelegate
extension DiaryViewController: NSFetchedResultsControllerDelegate {
  
  func controllerWillChangeContent(controller: NSFetchedResultsController) {
    dispatch_async(dispatch_get_main_queue()) {
      self.tableView.beginUpdates()
    }
  }
  
  func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
    dispatch_async(dispatch_get_main_queue()) {
      switch type {
      case .Insert:
        self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        
      case .Delete:
        self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        
      case .Update:
        let cell = self.tableView.cellForRowAtIndexPath(indexPath!) as! DiaryTableViewCell
        let intake = self.fetchedResultsController.objectAtIndexPath(indexPath!) as! Intake
        cell.intake = intake
        
      case .Move:
        self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
      }
    }
  }
  
  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    dispatch_async(dispatch_get_main_queue()) {
      self.tableView.endUpdates()
    }
  }
}