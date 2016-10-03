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
  
  var date: Date! { didSet { dateWasChanged() } }

  fileprivate var fetchedResultsController: NSFetchedResultsController<Intake>?
  fileprivate var sizingCell: DiaryTableViewCell!
  fileprivate var volumeObserver: SettingsObserver?
  fileprivate let isIOS8AndLater = UIDevice.current.systemVersion.compare("8.0.0", options: NSString.CompareOptions.numeric) != .orderedAscending

  fileprivate struct Constants {
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
    fetchedResultsController?.delegate = nil
    tableView?.dataSource = nil
    tableView?.delegate = nil
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if let selectedIndexPath = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: selectedIndexPath, animated: false)
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    checkHelpTip()
  }

  fileprivate func applyStyle() {
    UIHelper.applyStyleToViewController(self)
    tableView.backgroundView = nil
    tableView.backgroundColor = StyleKit.pageBackgroundColor
  }
  
  fileprivate func dateWasChanged() {
    if date == nil || fetchedResultsController == nil {
      return
    }
    
    updateFetchedResultsController()
  }

  fileprivate func initFetchedResultsController() {
    createFetchedResultsController {
      DispatchQueue.main.async {
        self.tableView.reloadData()
      }
    }
  }

  fileprivate func updateFetchedResultsController() {
    createFetchedResultsController {
      DispatchQueue.main.async {
        self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
      }
    }
  }

  // This function is like the fetchedResultsController.objectAtIndexPath but with bounds checks.
  fileprivate func getIntakeAtIndexPath(_ indexPath: IndexPath) -> Intake? {
    if let fetchedResultsController = fetchedResultsController,
       let sections = fetchedResultsController.sections
    {
      if (indexPath as NSIndexPath).section >= sections.count {
        return nil
      }
      
      let section = sections[(indexPath as NSIndexPath).section]

      if (indexPath as NSIndexPath).row >= section.numberOfObjects {
        return nil
      }
      
      return section.objects?[(indexPath as NSIndexPath).row] as? Intake
    } else {
      return nil
    }
  }
  
  fileprivate func createFetchedResultsController(completion: (() -> ())?) {
    CoreDataStack.performOnPrivateContext { privateContext in
      let fetchRequest = self.getFetchRequestForDate(self.date)
      
      let fetchedResultsController = NSFetchedResultsController(
        fetchRequest: fetchRequest,
        managedObjectContext: privateContext,
        sectionNameKeyPath: nil,
        cacheName: nil)
      
      fetchedResultsController.delegate = self
      
      self.fetchedResultsController = fetchedResultsController
      
      do {
        try self.fetchedResultsController!.performFetch()
        completion?()
      } catch let error as NSError {
        Logger.logError(Logger.Messages.failedToSaveManagedObjectContext, error: error)
      }
    }
  }

  fileprivate func getFetchRequestForDate(_ date: Date) -> NSFetchRequest<Intake> {
    let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
    
    let fetchRequest = Intake.createFetchRequest()
    fetchRequest.sortDescriptors = [sortDescriptor]
    fetchRequest.predicate = getFetchRequestPredicateForDate(date)
    fetchRequest.fetchBatchSize = 15 // it's maximum number of visible rows in diary
    
    return fetchRequest
  }
  
  fileprivate func getFetchRequestPredicateForDate(_ date: Date) -> NSPredicate {
    let beginDate = DateHelper.startOfDay(date)
    let endDate = DateHelper.nextDayFrom(beginDate)
    
    return NSPredicate(format: "(date >= %@) AND (date < %@)", argumentArray: [beginDate, endDate])
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Constants.editIntakeSegue,
      let intakeViewController = segue.destination.contentViewController as? IntakeViewController,
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
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return fetchedResultsController?.sections?.count ?? 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let actualSectionsCount = fetchedResultsController?.sections?.count ?? 0
    if section >= actualSectionsCount {
      return 0
    }
    
    let sectionInfo = fetchedResultsController?.sections?[section]
    return sectionInfo?.numberOfObjects ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCell(withIdentifier: Constants.diaryCellIdentifier, for: indexPath) 
  }
  
  fileprivate func checkHelpTip() {
    if Settings.sharedInstance.uiDiaryPageHelpTipIsShown.value || view.window == nil {
      return
    }

    if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? DiaryTableViewCell {
      showHelpTipForCell(cell)
    }
  }
  
  fileprivate func showHelpTipForCell(_ cell: DiaryTableViewCell) {
    SystemHelper.executeBlockWithDelay(GlobalConstants.helpTipDelayToShow) {
      if self.view.window == nil {
        return
      }
      
      let text = NSLocalizedString("DVC:Hydration effect of the intake", value: "Hydration effect of the intake", comment: "DiaryViewController: Text for help tip about hydration effect of an intake of a diary cell")
      
      if let helpTip = JDFTooltipView(targetView: cell.waterBalanceLabel, hostView: self.tableView, tooltipText: text, arrowDirection: .up, width: self.view.frame.width / 2) {
        UIHelper.showHelpTip(helpTip)
        Settings.sharedInstance.uiDiaryPageHelpTipIsShown.value = true
      }
    }
  }

  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle != .delete {
      return
    }
    
    CoreDataStack.performOnPrivateContext { _ in
      if let intake = self.getIntakeAtIndexPath(indexPath) {
        intake.deleteEntity(saveImmediately: true)
      }
    }
  }
  
}

// MARK: UITableViewDelegate
extension DiaryViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard let diaryCell = cell as? DiaryTableViewCell else { return }

    diaryCell.prepareCell()
    
    CoreDataStack.performOnPrivateContext { _ in
      if let intake = self.getIntakeAtIndexPath(indexPath) {
        diaryCell.intake = intake
      }
    }
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    CoreDataStack.performOnPrivateContext { _ in
      if let intake = self.getIntakeAtIndexPath(indexPath) {
        DispatchQueue.main.async {
          self.performSegue(withIdentifier: Constants.editIntakeSegue, sender: intake)
        }
      } else {
        Logger.logError("Failed to get an intake related to selected cell of tableview")
      }
    }
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if isIOS8AndLater {
      return UITableViewAutomaticDimension
    } else {
      if sizingCell == nil {
        sizingCell = tableView.dequeueReusableCell(withIdentifier: Constants.diaryCellIdentifier) as! DiaryTableViewCell
      }

      sizingCell.updateFonts()
      
      sizingCell.bounds = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: sizingCell.bounds.height)
      
      sizingCell.setNeedsLayout()
      sizingCell.layoutIfNeeded()
      
      let height = sizingCell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
      
      return height
    }
  }
  
  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return 54 // Estimated height is taken from storyboard
  }
  
}

// MARK: NSFetchedResultsControllerDelegate
extension DiaryViewController: NSFetchedResultsControllerDelegate {
  
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    SystemHelper.performBlockAsyncOnMainQueueAndWait {
      self.tableView?.beginUpdates()
    }
  }

  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    SystemHelper.performBlockAsyncOnMainQueueAndWait {
      switch type {
      case .insert:
        self.tableView?.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        
      case .delete:
        self.tableView?.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        
      default:
        break
      }
    }
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    SystemHelper.performBlockAsyncOnMainQueueAndWait {
      switch type {
      case .insert:
        if let newIndexPath = newIndexPath {
          self.tableView?.insertRows(at: [newIndexPath], with: .fade)
        }
        
      case .delete:
        if let indexPath = indexPath {
          self.tableView?.deleteRows(at: [indexPath], with: .fade)
        }
        
      case .update:
        if let indexPath = indexPath {
          self.tableView?.reloadRows(at: [indexPath], with: .fade)
        }

      case .move:
        if let indexPath = indexPath {
          self.tableView?.deleteRows(at: [indexPath], with: .fade)
        }
        
        if let newIndexPath = newIndexPath {
          self.tableView?.insertRows(at: [newIndexPath], with: .fade)
        }
      }
    }
  }

  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    SystemHelper.performBlockAsyncOnMainQueueAndWait {
      self.tableView?.endUpdates()
    }
  }
}
