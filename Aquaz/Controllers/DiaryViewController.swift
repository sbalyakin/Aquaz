//
//  DiaryViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 05.11.14.
//  Copyright © 2014 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData

class DiaryViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  
  var date: NSDate! { didSet { dateWasChanged() } }

  private var fetchedResultsController: NSFetchedResultsController?
  private var sizingCell: DiaryTableViewCell!
  private var volumeObserver: SettingsObserver?
  private let isIOS8AndLater = UIDevice.currentDevice().systemVersion.compare("8.0.0", options: NSStringCompareOptions.NumericSearch) != .OrderedAscending

  private struct Constants {
    static let diaryCellIdentifier = "DiaryTableViewCell"
    static let editIntakeSegue = "Edit Intake"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    applyStyle()
    
    initFetchedResultsController()
    
    volumeObserver = Settings.sharedInstance.generalVolumeUnits.addObserver { [weak self] _ in
      self?.tableView?.reloadData()
    }
    
    if isIOS8AndLater {
      tableView.rowHeight = UITableViewAutomaticDimension
      tableView.estimatedRowHeight = 54
    }
  }

  deinit {
    // It prevents EXC_BAD_ACCESS on deferred reloading the table view
    tableView?.dataSource = nil
    tableView?.delegate = nil
    fetchedResultsController?.delegate = nil
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    if let selectedIndexPath = tableView.indexPathForSelectedRow {
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
      dispatch_async(dispatch_get_main_queue()) {
        self.tableView.reloadData()
      }
    }
  }

  private func updateFetchedResultsController() {
    createFetchedResultsController {
      dispatch_async(dispatch_get_main_queue()) {
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
      }
    }
  }

  // This function is like the fetchedResultsController.objectAtIndexPath but with bounds checks.
  private func getIntakeAtIndexPath(indexPath: NSIndexPath) -> Intake? {
    if let fetchedResultsController = fetchedResultsController,
       let sections = fetchedResultsController.sections
    {
      if indexPath.section >= sections.count {
        return nil
      }
      
      let section = sections[indexPath.section]

      if indexPath.row >= section.numberOfObjects {
        return nil
      }
      
      return section.objects?[indexPath.row] as? Intake
    } else {
      return nil
    }
  }
  
  private func createFetchedResultsController(completion completion: (() -> ())?) {
    CoreDataStack.inPrivateContext { privateContext in
      let fetchRequest = self.getFetchRequestForDate(self.date)
      
      self.fetchedResultsController = NSFetchedResultsController(
        fetchRequest: fetchRequest,
        managedObjectContext: privateContext,
        sectionNameKeyPath: nil,
        cacheName: nil)
      
      self.fetchedResultsController!.delegate = self
      
      do {
        try self.fetchedResultsController!.performFetch()
        completion?()
      } catch let error as NSError {
        Logger.logError(Logger.Messages.failedToSaveManagedObjectContext, error: error)
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
      let intake = sender as? Intake
    {
      intakeViewController.intake = intake
    } else {
      Logger.logError("An error occured on preparing segue for showing Intake scene from Diary scene")
    }
  }
  
}

// MARK: UITableViewDataSource
extension DiaryViewController: UITableViewDataSource {
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return fetchedResultsController?.sections?.count ?? 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let actualSectionsCount = fetchedResultsController?.sections?.count ?? 0
    if section >= actualSectionsCount {
      return 0
    }
    
    let sectionInfo = fetchedResultsController?.sections?[section]
    return sectionInfo?.numberOfObjects ?? 0
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCellWithIdentifier(Constants.diaryCellIdentifier, forIndexPath: indexPath) 
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
    if editingStyle != .Delete {
      return
    }
    
    CoreDataStack.inPrivateContext { _ in
      if let intake = self.getIntakeAtIndexPath(indexPath) {
        intake.deleteEntity(saveImmediately: true)
      }
    }
  }
  
}

// MARK: UITableViewDelegate
extension DiaryViewController: UITableViewDelegate {

  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    guard let diaryCell = cell as? DiaryTableViewCell else { return }

    diaryCell.prepareCell()
    
    CoreDataStack.inPrivateContext { _ in
      if let intake = self.getIntakeAtIndexPath(indexPath) {
        diaryCell.intake = intake
      }
    }
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    CoreDataStack.inPrivateContext { _ in
      if let intake = self.getIntakeAtIndexPath(indexPath) {
        dispatch_async(dispatch_get_main_queue()) {
          self.performSegueWithIdentifier(Constants.editIntakeSegue, sender: intake)
        }
      } else {
        Logger.logError("Failed to get an intake related to selected cell of tableview")
      }
    }
  }

  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if isIOS8AndLater {
      return UITableViewAutomaticDimension
    } else {
      if sizingCell == nil {
        sizingCell = tableView.dequeueReusableCellWithIdentifier(Constants.diaryCellIdentifier) as! DiaryTableViewCell
      }

      sizingCell.updateFonts()
      
      sizingCell.bounds = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: sizingCell.bounds.height)
      
      sizingCell.setNeedsLayout()
      sizingCell.layoutIfNeeded()
      
      let height = sizingCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
      
      return height
    }
  }
  
  func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 54 // Estimated height is taken from storyboard
  }
  
}

// MARK: NSFetchedResultsControllerDelegate
extension DiaryViewController: NSFetchedResultsControllerDelegate {
  
  func controllerWillChangeContent(controller: NSFetchedResultsController) {
    dispatch_async(dispatch_get_main_queue()) {
      self.tableView?.beginUpdates()
    }
  }

  func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
    dispatch_async(dispatch_get_main_queue()) {
      switch type {
      case .Insert:
        self.tableView?.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        
      case .Delete:
        self.tableView?.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        
      default:
        break
      }
    }
  }
  
  func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
    dispatch_async(dispatch_get_main_queue()) {
      switch type {
      case .Insert:
        if let newIndexPath = newIndexPath {
          self.tableView?.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
        }
        
      case .Delete:
        if let indexPath = indexPath {
          self.tableView?.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        
      case .Update:
        if let indexPath = indexPath {
          self.tableView?.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }

      case .Move:
        if let indexPath = indexPath {
          self.tableView?.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        
        if let newIndexPath = newIndexPath {
          self.tableView?.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
        }
      }
    }
  }

  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    dispatch_async(dispatch_get_main_queue()) {
      self.tableView?.endUpdates()
    }
  }
}