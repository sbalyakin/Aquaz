//
//  SelectDrinkViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 29.12.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit
import CoreData

class SelectDrinkViewController: UIViewController {
  
  @IBOutlet weak var collectionView: UICollectionView!

  var date: NSDate!
  
  private let columnsCount = 3
  private var rowsCount = 0
  
  private lazy var popupViewManager: SelectDrinkPopupViewManager = SelectDrinkPopupViewManager(selectDrinkViewController: self)

  private var managedObjectContext: NSManagedObjectContext { return CoreDataStack.privateContext }

  private var displayedDrinkTypes: [Drink.DrinkType] = [
    .Water, .Tea,    .Coffee,
    .Milk,  .Juice,  .Sport,
    .Soda,  .Energy, Settings.uiSelectedAlcoholicDrink.value]
  
  private var drinks: [Drink.DrinkType: Drink] = [:]
  
  private var areDrinksLoaded: Bool {
    return !drinks.isEmpty
  }
  
  private struct Constants {
    static let addIntakeSegue = "Add Intake"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    loadDrinks()
    setupUI()
    setupGestureRecognizers()
    setupNotificationsObservation()
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  private func loadDrinks() {
    managedObjectContext.performBlock {
      self.drinks = Drink.fetchAllDrinksTyped(managedObjectContext: self.managedObjectContext)
    }
  }
  
  private func setupUI() {
    UIHelper.applyStyle(self)
    
    let nib = UINib(nibName: drinkCellNibName, bundle: nil)
    collectionView.registerNib(nib, forCellWithReuseIdentifier: drinkCellReuseIdentifier)
    
    rowsCount = Int(ceil(Float(displayedDrinkTypes.count) / Float(columnsCount)))
  }
  
  private func setupGestureRecognizers() {
    let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleDrinkCellLongPress:")
    longPressGestureRecognizer.minimumPressDuration = 0.5
    longPressGestureRecognizer.cancelsTouchesInView = false
    collectionView.addGestureRecognizer(longPressGestureRecognizer)
    
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleDrinkCellTap:")
    tapGestureRecognizer.numberOfTapsRequired = 1
    collectionView.addGestureRecognizer(tapGestureRecognizer)
  }

  private func setupNotificationsObservation() {
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "preferredContentSizeChanged",
      name: UIContentSizeCategoryDidChangeNotification,
      object: nil)
  }
  
  func preferredContentSizeChanged() {
    collectionView.reloadData()
  }
  
  private func changeAlcoholicDrinkTo(#drinkType: Drink.DrinkType) {
    displayedDrinkTypes[displayedDrinkTypes.count - 1] = drinkType
    Settings.uiSelectedAlcoholicDrink.value = drinkType
    
    collectionView.performBatchUpdates( {
      self.collectionView.reloadSections(NSIndexSet(index: 0))
      },
    completion: { _ in
      if self.areDrinksLoaded {
        let drink = self.drinks[drinkType]
        self.performSegueWithIdentifier(Constants.addIntakeSegue, sender: drink)
      }
    })
  }
  
  func handleDrinkCellLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
    switch gestureRecognizer.state {
    case .Began:
      handleLongPressBegin(gestureRecognizer)
      
    case .Changed:
      popupViewManager.handleLongPressChanged(gestureRecognizer)
      
    case .Ended:
      popupViewManager.handleLongPressEnded(gestureRecognizer)
      
    default: break
    }
  }
  
  private func handleLongPressBegin(gestureRecognizer: UIGestureRecognizer) {
    let pointInCollectionView = gestureRecognizer.locationInView(collectionView)
    let pointInScreen = gestureRecognizer.locationInView(navigationController!.view)
    
    if let indexPath = collectionView.indexPathForItemAtPoint(pointInCollectionView) {
      let drinkIndex = indexPath.row
      if drinkIndex != displayedDrinkTypes.count - 1 {
        return
      }
      
      if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
        var rect = CGRect(x: cell.frame.minX, y: 0, width: cell.frame.width, height: collectionView.bounds.height)
        rect.inset(dx: -popupViewManager.padding, dy: -popupViewManager.padding)
        rect = collectionView.convertRect(rect, toView: navigationController!.view)
        let dy = rect.height / 3
        rect.size.height -= dy
        rect.origin.y += dy - cell.frame.height
        // Adjust to tap position
        rect.origin.y -= rect.maxY - pointInScreen.y + 20
        
        popupViewManager.showPopupView(frame: rect)
      }
    }
  }
  
  func handleDrinkCellTap(gestureRecognizer: UIGestureRecognizer) {
    if popupViewManager.popupIsShown {
      return
    }
    
    if gestureRecognizer.state != .Ended {
      return
    }

    let pointInCollectionView = gestureRecognizer.locationInView(collectionView)
    if let indexPath = collectionView.indexPathForItemAtPoint(pointInCollectionView) {
      collectionViewCellIsSelected(indexPath: indexPath)
    }
  }

  private func collectionViewCellIsSelected(#indexPath: NSIndexPath) {
    if !areDrinksLoaded {
      return
    }
    
    let drinkIndex = indexPath.row
    assert(drinkIndex < displayedDrinkTypes.count)
    
    let drinkType = displayedDrinkTypes[drinkIndex]
    let drink = drinks[drinkType]
    
    performSegueWithIdentifier(Constants.addIntakeSegue, sender: drink)
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == Constants.addIntakeSegue,
      let intakeViewController = segue.destinationViewController.contentViewController as? IntakeViewController,
      let drink = sender as? Drink
    {
      intakeViewController.drink = drink
      intakeViewController.date = DateHelper.dateByJoiningDateTime(datePart: date, timePart: NSDate())
    }
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    collectionView.collectionViewLayout.invalidateLayout()
  }

}

extension SelectDrinkViewController: UICollectionViewDataSource {
  
  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return displayedDrinkTypes.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(drinkCellReuseIdentifier, forIndexPath: indexPath) as! DrinkCollectionViewCell
    
    let drinkIndex = indexPath.row
    assert(drinkIndex < displayedDrinkTypes.count)
    
    let drinkType = displayedDrinkTypes[drinkIndex]
    
    cell.drinkLabel.text = drinkType.localizedName
    cell.drinkLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
    cell.drinkView.drinkType = drinkType
    cell.drinkView.isGroup = drinkIndex == displayedDrinkTypes.count - 1
    cell.invalidateIntrinsicContentSize()
    
    return cell
  }
  
}

extension SelectDrinkViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    let layout = collectionViewLayout as! UICollectionViewFlowLayout
    let contentWidth = collectionView.bounds.width - layout.minimumInteritemSpacing * CGFloat(columnsCount - 1)
    let contentHeight = collectionView.bounds.height - layout.minimumLineSpacing * CGFloat(rowsCount - 1)
    let cellWidth = trunc(contentWidth / CGFloat(columnsCount))
    let cellHeight = trunc(contentHeight / CGFloat(rowsCount))
    let size = CGSize(width: cellWidth, height: cellHeight)
    return size
  }
  
}

class SelectDrinkPopupViewManager: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
  
  private var window: UIWindow!
  private var popupView: UIView!
  private var popupCollectionView: UICollectionView!
  
  private let popupDrinkTypes: [Drink.DrinkType] = [ .Beer, .Wine, .HardLiquor ]
  private weak var selectDrinkViewController: SelectDrinkViewController!
  private var managedObjectContext: NSManagedObjectContext { return CoreDataStack.privateContext }

  private let columnsCount = 1
  private var rowsCount = 3
  private let padding: CGFloat = 10

  var popupIsShown: Bool {
    return popupView != nil
  }
  
  init(selectDrinkViewController: SelectDrinkViewController) {
    self.selectDrinkViewController = selectDrinkViewController
    super.init()
  }
  
  func showPopupView(#frame: CGRect) {
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "preferredContentSizeChanged",
      name: UIContentSizeCategoryDidChangeNotification,
      object: nil)

    cleanPopupView()
    
    let backgroundView = UIView(frame: frame)
    backgroundView.backgroundColor = StyleKit.pageBackgroundColor
    backgroundView.layer.cornerRadius = padding * 2
    backgroundView.layer.masksToBounds = true
    
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 0
    layout.minimumInteritemSpacing = 0
    
    let collectionViewRect = backgroundView.bounds.rectByInsetting(dx: padding, dy: padding)
    let contentWidth = collectionViewRect.width - layout.minimumInteritemSpacing * CGFloat(columnsCount - 1)
    let contentHeight = collectionViewRect.height - layout.minimumLineSpacing * CGFloat(rowsCount - 1)
    let cellWidth = trunc(contentWidth / CGFloat(columnsCount))
    let cellHeight = trunc(contentHeight / CGFloat(rowsCount))
    layout.itemSize = CGSize(width: cellWidth, height: cellHeight)

    popupCollectionView = UICollectionView(frame: collectionViewRect, collectionViewLayout: layout)
    popupCollectionView.backgroundColor = UIColor.clearColor()
    popupCollectionView.delegate = self
    popupCollectionView.dataSource = self
    
    let nib = UINib(nibName: drinkCellNibName, bundle: nil)
    popupCollectionView.registerNib(nib, forCellWithReuseIdentifier: drinkCellReuseIdentifier)
    
    backgroundView.addSubview(popupCollectionView)
    
    popupView = UIView(frame: UIScreen.mainScreen().bounds)
    popupView.backgroundColor = UIColor(white: 0, alpha: 0.3)
    popupView.addSubview(backgroundView)
    popupView.alpha = 0
    
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handlePopupViewTap:")
    tapGestureRecognizer.numberOfTapsRequired = 1
    popupView.addGestureRecognizer(tapGestureRecognizer)
    
    let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePopupViewPan:")
    panGestureRecognizer.maximumNumberOfTouches = 1
    popupView.addGestureRecognizer(panGestureRecognizer)
    
    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    window.windowLevel = UIWindowLevelAlert
    window.opaque = false
    window.addSubview(popupView)
    window.makeKeyAndVisible()
    
    UIView.animateWithDuration(0.3, animations: {
      self.popupView.alpha = 1.0
    })
  }
  
  private func hidePopupView() {
    NSNotificationCenter.defaultCenter().removeObserver(self)

    if window != nil {
      UIView.animateWithDuration(0.3,
        animations: {
        self.popupView.alpha = 0
        },
        completion: {
          (completed: Bool) in
          self.cleanPopupView()
      })
    }
  }
  
  private func cleanPopupView() {
    window = nil
    popupCollectionView = nil
    popupView = nil
  }
  
  func preferredContentSizeChanged() {
    popupCollectionView.reloadData()
  }

  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return popupDrinkTypes.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(drinkCellReuseIdentifier, forIndexPath: indexPath) as! DrinkCollectionViewCell
    
    let drinkIndex = indexPath.row
    assert(drinkIndex < popupDrinkTypes.count)
    
    let drinkType = popupDrinkTypes[drinkIndex]
    
    cell.drinkLabel.text = drinkType.localizedName
    cell.drinkLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
    cell.drinkView.drinkType = drinkType
    cell.drinkView.isGroup = false
    cell.invalidateIntrinsicContentSize()
    
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    popupCellIsSelected(indexPath: indexPath)
  }
  
  private func popupCellIsSelected(#indexPath: NSIndexPath) {
    hidePopupView()
    
    let drinkIndex = indexPath.row
    assert(drinkIndex < popupDrinkTypes.count)
    let drinkType = popupDrinkTypes[drinkIndex]
    
    selectDrinkViewController.changeAlcoholicDrinkTo(drinkType: drinkType)
  }
  
  func handlePopupViewTap(gestureRecognizer: UIGestureRecognizer) {
    if popupCollectionView == nil {
      return
    }
    
    let pointInCollectionView = gestureRecognizer.locationInView(popupCollectionView)
    if let indexPath = popupCollectionView.indexPathForItemAtPoint(pointInCollectionView) {
      popupCellIsSelected(indexPath: indexPath)
    } else {
      hidePopupView()
    }
  }
  
  func handlePopupViewPan(gestureRecognizer: UIGestureRecognizer) {
    switch gestureRecognizer.state {
    case .Changed:
      handleLongPressChanged(gestureRecognizer)
      
    case .Ended:
      handleLongPressEnded(gestureRecognizer)
      
    default: break
    }
  }
  
  func handleLongPressChanged(gestureRecognizer: UIGestureRecognizer) {
    if popupCollectionView == nil {
      return
    }

    for currentCell in popupCollectionView.visibleCells() {
      if let visibleCell = currentCell as? UICollectionViewCell {
        visibleCell.highlighted = false
        visibleCell.setNeedsDisplay()
      }
    }

    let pointInCollectionView = gestureRecognizer.locationInView(popupCollectionView)
    if let indexPath = popupCollectionView.indexPathForItemAtPoint(pointInCollectionView) {
      if let cell = popupCollectionView.cellForItemAtIndexPath(indexPath) {
        cell.highlighted = true
        cell.setNeedsDisplay()
      }
      
      if gestureRecognizer.state == .Ended {
        popupCellIsSelected(indexPath: indexPath)
      }
    }
  }
  
  func handleLongPressEnded(gestureRecognizer: UIGestureRecognizer) {
    if popupCollectionView == nil {
      return
    }
    
    let pointInCollectionView = gestureRecognizer.locationInView(popupCollectionView)
    if let indexPath = popupCollectionView.indexPathForItemAtPoint(pointInCollectionView) {
      popupCellIsSelected(indexPath: indexPath)
    }
  }
  
}

private let drinkCellNibName = "DrinkCollectionViewCell"
private let drinkCellReuseIdentifier = "DrinkCell"