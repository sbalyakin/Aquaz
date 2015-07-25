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

  private var fetchedResultsController: NSFetchedResultsController?
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
    
    initFetchedResultsController()
    
    volumeObserverIdentifier = Settings.sharedInstance.generalVolumeUnits.addObserver { [weak self] _ in
      self?.tableView?.reloadData()
    }
  }
  
  deinit {
    if let volumeObserverIdentifier = volumeObserverIdentifier {
      Settings.sharedInstance.generalVolumeUnits.removeObserver(volumeObserverIdentifier)
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    if let selectedIndexPath = tableView.indexPathForSelectedRow() {
      tableView.deselectRowAtIndexPath(selectedIndexPath, animated: false)
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    checkHelpTip()
  }

  private func applyStyle() {
    UIHelper.applyStyleToViewController(self)
    tableView.backgroundView = nil
    tableView.backgroundColor = StyleKit.pageBackgroundColor
  }
  
  private func dateWasChanged() {
    if date == nil || fetchedResultsController == nil {
      return
    }
    
    updateFetchedResultsController()
  }

  private func initFetchedResultsController() {
    createFetchedResultsController {
      self.tableView?.reloadData()
    }
  }

  private func updateFetchedResultsController() {
    createFetchedResultsController {
      self.tableView?.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
    }
  }

  private func createFetchedResultsController(completion: () -> ()) {
    managedObjectContext.performBlock {
      let fetchRequest = self.getFetchRequestForDate(self.date)
      
      self.fetchedResultsController = NSFetchedResultsController(
        fetchRequest: fetchRequest,
        managedObjectContext: self.managedObjectContext,
        sectionNameKeyPath: nil,
        cacheName: nil)
      
      self.fetchedResultsController!.delegate = self
      
      var error: NSError?
      if !self.fetchedResultsController!.performFetch(&error) {
        Logger.logError(Logger.Messages.failedToSaveManagedObjectContext, error: error)
      }
      
      dispatch_async(dispatch_get_main_queue()) {
        completion()
      }
    }
  }

  private func getFetchRequestForDate(date: NSDate) -> NSFetchRequest {
    let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
    
    let fetchRequest = NSFetchRequest(entityName: Intake.entityName)
    fetchRequest.sortDescriptors = [sortDescriptor]
    fetchRequest.predicate = getFetchRequestPredicateForDate(date)
    fetchRequest.fetchBatchSize = 15 // it's maximum number of visible rows in diary
    
    return fetchRequest
  }
  
  private func getFetchRequestPredicateForDate(date: NSDate) -> NSPredicate {
    let beginDate = DateHelper.dateByClearingTime(ofDate: date)
    let endDate = DateHelper.addToDate(beginDate, years: 0, months: 0, days: 1)
    
    return NSPredicate(format: "(date >= %@) AND (date < %@)", argumentArray: [beginDate, endDate])
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == Constants.editIntakeSegue,
      let intakeViewController = segue.destinationViewController.contentViewController as? IntakeViewController,
      let indexPath = tableView.indexPathForSelectedRow()
    {
      managedObjectContext.performBlock {
        if let intake = self.fetchedResultsController?.objectAtIndexPath(indexPath) as? Intake {
          dispatch_async(dispatch_get_main_queue()) {
            intakeViewController.intake = intake
          }
        }
      }
    }
  }
  
}

// MARK: UITableViewDataSource
extension DiaryViewController: UITableViewDataSource {
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return fetchedResultsController?.sections?.count ?? 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let sectionInfo = fetchedResultsController?.sections?[section] as? NSFetchedResultsSectionInfo {
      return sectionInfo.numberOfObjects
    } else {
      return 0
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(Constants.diaryCellIdentifier, forIndexPath: indexPath) as! DiaryTableViewCell
    
    if let intake = fetchedResultsController?.objectAtIndexPath(indexPath) as? Intake {
      cell.intake = intake
    }
    
    return cell
  }
  
  private func checkHelpTip() {
    if Settings.sharedInstance.uiDiaryPageHelpTipIsShown.value || view.window == nil {
      return
    }

    if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? DiaryTableViewCell {
      showHelpTipForCell(cell)
    }
  }
  
  private func showHelpTipForCell(cell: DiaryTableViewCell) {
    SystemHelper.executeBlockWithDelay(GlobalConstants.helpTipDelayToShow) {
      if self.view.window == nil {
        return
      }
      
      let text = NSLocalizedString("DVC:Hydration effect of the intake", value: "Hydration effect of the intake", comment: "DiaryViewController: Text for help tip about hydration effect of an intake of a diary cell")
      
      let helpTip = JDFTooltipView(targetView: cell.waterBalanceLabel, hostView: self.tableView, tooltipText: text, arrowDirection: .Up, width: self.view.frame.width / 2)
      
      UIHelper.showHelpTip(helpTip)

      Settings.sharedInstance.uiDiaryPageHelpTipIsShown.value = true
    }
  }

  func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  
  func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
      managedObjectContext.performBlock {
        if let intake = self.fetchedResultsController?.objectAtIndexPath(indexPath) as? Intake {
          intake.deleteEntity(saveImmediately: true)
        }
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

    if let intake = self.fetchedResultsController?.objectAtIndexPath(indexPath) as? Intake {
      sizingCell.intake = intake
    }
    
    sizingCell.setNeedsLayout()
    sizingCell.layoutIfNeeded()
    let size = sizingCell.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
    return size.height
  }
  
}

// MARK: NSFetchedResultsControllerDelegate
extension DiaryViewController: NSFetchedResultsControllerDelegate {
  
  // All methods below use dispatch_sync for the main queue 
  // because it guarantees sequential calls for tableView's methods:
  //
  // tableView.beginUpdates() -> updating tableView -> tableView.endUpdates()
  //
  // It's safe to execute them in a synchronized way because 
  // NSFetchedResultsController is running in a separate queue of managedObjectContext.
  
  func controllerWillChangeContent(controller: NSFetchedResultsController) {
    dispatch_sync(dispatch_get_main_queue()) {
      self.tableView.beginUpdates()
    }
  }
  
  func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
    switch type {
    case .Insert:
      dispatch_sync(dispatch_get_main_queue()) {
        self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
      }
      
    case .Delete:
      dispatch_sync(dispatch_get_main_queue()) {
        self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
      }
      
    case .Update:
      if let intake = self.fetchedResultsController?.objectAtIndexPath(indexPath!) as? Intake {
        dispatch_sync(dispatch_get_main_queue()) {
          if let cell = self.tableView.cellForRowAtIndexPath(indexPath!) as? DiaryTableViewCell {
            cell.intake = intake
          }
        }
      }
      
    case .Move:
      dispatch_sync(dispatch_get_main_queue()) {
        self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
      }
    }
  }
  
  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    dispatch_sync(dispatch_get_main_queue()) {
      self.tableView.endUpdates()
    }
  }
}