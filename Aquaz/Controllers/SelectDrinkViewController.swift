//
//  SelectDrinkViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 29.12.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit
import CoreData

class SelectDrinkViewController: StyledViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
  
  @IBOutlet weak var collectionView: UICollectionView!
  
  var dayViewController: DayViewController!
  
  private let columnsCount = 3
  private var rowsCount = 0
  
  private var popupViewManager: SelectDrinkPopupViewManager!

  private var displayedDrinkTypes: [Drink.DrinkType] = [
    .Water, .Tea,    .Coffee,
    .Milk,  .Juice,  .Sport,
    .Soda,  .Energy, Settings.sharedInstance.uiSelectedAlcoholicDrink.value]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let nib = UINib(nibName: cellNibName, bundle: nil)
    collectionView.registerNib(nib, forCellWithReuseIdentifier: cellReuseIdentifier)

    rowsCount = Int(ceil(Float(displayedDrinkTypes.count) / Float(columnsCount)))
    setupGestureRecognizers()
    popupViewManager = SelectDrinkPopupViewManager(selectDrinkViewController: self)
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
  
  private func changeAlcoholicDrinkTo(#drinkType: Drink.DrinkType) {
    displayedDrinkTypes[displayedDrinkTypes.count - 1] = drinkType
    Settings.sharedInstance.uiSelectedAlcoholicDrink.value = drinkType
    let alcoholIndexPath = NSIndexPath(forRow: displayedDrinkTypes.count - 1, inSection: 0)
    self.collectionView.reloadItemsAtIndexPaths([alcoholIndexPath])

    if let drink = Drink.getDrinkByType(drinkType, managedObjectContext: managedObjectContext) {
      if let intakeViewController = storyboard?.instantiateViewControllerWithIdentifier("IntakeViewController") as? IntakeViewController {
        intakeViewController.drink = drink
        intakeViewController.currentDate = DateHelper.dateByJoiningDateTime(datePart: dayViewController.getCurrentDate(), timePart: NSDate())
        intakeViewController.dayViewController = dayViewController
        navigationController?.pushViewController(intakeViewController, animated: true)
      } else {
        assert(false)
      }
    }
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
      } else {
        assert(false)
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

  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return displayedDrinkTypes.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! DrinkCollectionViewCell
    
    let drinkIndex = indexPath.row
    assert(drinkIndex < displayedDrinkTypes.count)
    
    let drinkType = displayedDrinkTypes[drinkIndex]
    
    if let drink = Drink.getDrinkByType(drinkType, managedObjectContext: managedObjectContext) {
      cell.drinkLabel.text = drink.localizedName
      cell.drinkView.drink = drink
      if drinkIndex == displayedDrinkTypes.count - 1 {
        cell.drinkView.isGroup = true
      }
    } else {
      assert(false)
    }
    
    return cell
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    collectionView.collectionViewLayout.invalidateLayout()
  }

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    let layout = collectionViewLayout as! UICollectionViewFlowLayout
    let contentWidth = collectionView.bounds.width - layout.minimumInteritemSpacing * CGFloat(columnsCount - 1)
    let contentHeight = collectionView.bounds.height - layout.minimumLineSpacing * CGFloat(rowsCount - 1)
    let cellWidth = trunc(contentWidth / CGFloat(columnsCount))
    let cellHeight = trunc(contentHeight / CGFloat(rowsCount))
    let size = CGSize(width: cellWidth, height: cellHeight)
    return size
  }
  
  private func collectionViewCellIsSelected(#indexPath: NSIndexPath) {
    let drinkIndex = indexPath.row
    assert(drinkIndex < displayedDrinkTypes.count)
    
    let drinkType = displayedDrinkTypes[drinkIndex]
    
    if let drink = Drink.getDrinkByType(drinkType, managedObjectContext: managedObjectContext) {
      if let intakeViewController = storyboard?.instantiateViewControllerWithIdentifier("IntakeViewController") as? IntakeViewController {
        intakeViewController.drink = drink
        intakeViewController.currentDate = DateHelper.dateByJoiningDateTime(datePart: dayViewController.getCurrentDate(), timePart: NSDate())
        intakeViewController.dayViewController = dayViewController
        navigationController?.pushViewController(intakeViewController, animated: true)
      } else {
        assert(false)
      }
    } else {
      assert(false)
    }
  }
  
  private lazy var managedObjectContext: NSManagedObjectContext? = {
    if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
      return appDelegate.managedObjectContext
    } else {
      return nil
    }
  }()
}

class SelectDrinkPopupViewManager: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
  
  private var window: UIWindow!
  private var popupView: UIView!
  private var popupCollectionView: UICollectionView!
  
  private let popupDrinkTypes: [Drink.DrinkType] = [ .Beer, .Wine, .StrongLiquor ]
  private var selectDrinkViewController: SelectDrinkViewController!
  
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
    
    let nib = UINib(nibName: cellNibName, bundle: nil)
    popupCollectionView.registerNib(nib, forCellWithReuseIdentifier: cellReuseIdentifier)
    
    backgroundView.addSubview(popupCollectionView)
    
    popupView = UIView(frame: UIScreen.mainScreen().bounds)
    popupView.backgroundColor = UIColor(white: 0, alpha: 0.5)
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
    self.window = nil
    self.popupCollectionView = nil
    self.popupView = nil
  }
  
  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return popupDrinkTypes.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! DrinkCollectionViewCell
    
    let drinkIndex = indexPath.row
    assert(drinkIndex < popupDrinkTypes.count)
    
    let drinkType = popupDrinkTypes[drinkIndex]
    
    if let drink = Drink.getDrinkByType(drinkType, managedObjectContext: managedObjectContext) {
      cell.drinkLabel.text = drink.localizedName
      cell.drinkView.drink = drink
    } else {
      assert(false)
    }
    
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
      } else {
        assert(false)
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
  
  private lazy var managedObjectContext: NSManagedObjectContext? = {
    if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
      return appDelegate.managedObjectContext
    } else {
      return nil
    }
  }()
}

private let cellNibName = "DrinkCollectionViewCell"
private let cellReuseIdentifier = "DrinkCell"