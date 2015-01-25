//
//  SelectDrinkViewController.swift
//  Water Me
//
//  Created by Sergey Balyakin on 29.12.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

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
    let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleConsumptionCellLongPress:")
    longPressGestureRecognizer.minimumPressDuration = 0.5
    longPressGestureRecognizer.cancelsTouchesInView = false
    collectionView.addGestureRecognizer(longPressGestureRecognizer)
    
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleConsumptionCellTap:")
    tapGestureRecognizer.numberOfTapsRequired = 1
    collectionView.addGestureRecognizer(tapGestureRecognizer)
  }
  
  func changeAlcoholicDrinkTo(#drinkType: Drink.DrinkType) {
    displayedDrinkTypes[displayedDrinkTypes.count - 1] = drinkType
    Settings.sharedInstance.uiSelectedAlcoholicDrink.value = drinkType
    let alcoholIndexPath = NSIndexPath(forRow: displayedDrinkTypes.count - 1, inSection: 0)
    self.collectionView.reloadItemsAtIndexPaths([alcoholIndexPath])

    let drink = Drink.getDrinkByType(drinkType)
    let consumptionViewController = storyboard!.instantiateViewControllerWithIdentifier("ConsumptionViewController") as ConsumptionViewController
    consumptionViewController.drink = drink
    consumptionViewController.currentDate = DateHelper.dateByJoiningDateTime(datePart: dayViewController.getCurrentDate(), timePart: NSDate())
    consumptionViewController.dayViewController = dayViewController
    navigationController!.pushViewController(consumptionViewController, animated: true)
  }
  
  func handleConsumptionCellLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
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
      
      let cell = collectionView.cellForItemAtIndexPath(indexPath)!
      var rect = CGRectMake(cell.frame.minX, 0, cell.frame.width, collectionView.bounds.height)
      rect.inset(dx: -popupViewManager.padding, dy: -popupViewManager.padding)
      rect = collectionView.convertRect(rect, toView: navigationController!.view)
      let dy = rect.height / 3
      rect.size.height -= dy
      rect.origin.y += dy - cell.frame.height
      // Adjust to tap position
      rect.origin.y -= rect.maxY - pointInScreen.y + 20
      
      let popupView = popupViewManager.createPopupView(frame: rect, screenFrame: navigationController!.view.frame)
      
      popupView.alpha = 0.0
      
      navigationController!.view.addSubview(popupView)

      UIView.animateWithDuration(0.3, animations: {
        popupView.alpha = 1.0
      })
    }
  }
  
  func handleConsumptionCellTap(gestureRecognizer: UIGestureRecognizer) {
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
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as DrinkCollectionViewCell
    
    let drinkIndex = indexPath.row
    assert(drinkIndex < displayedDrinkTypes.count)
    
    let drinkType = displayedDrinkTypes[drinkIndex]
    
    if let drink = Drink.getDrinkByType(drinkType) {
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
    let layout = collectionViewLayout as UICollectionViewFlowLayout
    let contentWidth = collectionView.bounds.width - layout.minimumInteritemSpacing * CGFloat(columnsCount - 1)
    let contentHeight = collectionView.bounds.height - layout.minimumLineSpacing * CGFloat(rowsCount - 1)
    let cellWidth = trunc(contentWidth / CGFloat(columnsCount))
    let cellHeight = trunc(contentHeight / CGFloat(rowsCount))
    let size = CGSizeMake(cellWidth, cellHeight)
    return size
  }
  
  private func collectionViewCellIsSelected(#indexPath: NSIndexPath) {
    let drinkIndex = indexPath.row
    assert(drinkIndex < displayedDrinkTypes.count)
    
    let drinkType = displayedDrinkTypes[drinkIndex]
    
    let drink = Drink.getDrinkByType(drinkType)
    
    let consumptionViewController = storyboard!.instantiateViewControllerWithIdentifier("ConsumptionViewController") as ConsumptionViewController
    consumptionViewController.drink = drink
    consumptionViewController.currentDate = DateHelper.dateByJoiningDateTime(datePart: dayViewController.getCurrentDate(), timePart: NSDate())
    consumptionViewController.dayViewController = dayViewController
    navigationController!.pushViewController(consumptionViewController, animated: true)
  }
  
}

class SelectDrinkPopupViewManager: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
  var collectionView: UICollectionView!
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
  
  func createPopupView(#frame: CGRect, screenFrame: CGRect) -> UIView {
    removePopupView()
    
    let backgroundView = UIView(frame: frame)
    backgroundView.backgroundColor = StyleKit.pageBackgroundColor
    backgroundView.layer.cornerRadius = padding * 2
    
    let layout = UICollectionViewFlowLayout()
    popupCollectionView = UICollectionView(frame: backgroundView.bounds.rectByInsetting(dx: padding, dy: padding), collectionViewLayout: layout)
    popupCollectionView.backgroundColor = UIColor.clearColor()
    popupCollectionView.delegate = self
    popupCollectionView.dataSource = self
    
    let nib = UINib(nibName: cellNibName, bundle: nil)
    popupCollectionView.registerNib(nib, forCellWithReuseIdentifier: cellReuseIdentifier)
    
    backgroundView.addSubview(popupCollectionView)
    
    popupView = UIView(frame: screenFrame)
    popupView.backgroundColor = UIColor(white: 0.5, alpha: 0.7)
    popupView.addSubview(backgroundView)
    
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handlePopupViewTap:")
    tapGestureRecognizer.numberOfTapsRequired = 1
    popupView.addGestureRecognizer(tapGestureRecognizer)
    
    return popupView
  }
  
  private func removePopupView() {
    if popupView != nil {
      popupCollectionView = nil
      popupView.removeFromSuperview()
      popupView = nil
    }
  }
  
  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return popupDrinkTypes.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as DrinkCollectionViewCell
    
    let drinkIndex = indexPath.row
    assert(drinkIndex < popupDrinkTypes.count)
    
    let drinkType = popupDrinkTypes[drinkIndex]
    
    if let drink = Drink.getDrinkByType(drinkType) {
      cell.drinkLabel.text = drink.localizedName
      cell.drinkView.drink = drink
    } else {
      assert(false)
    }
    
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    let layout = collectionViewLayout as UICollectionViewFlowLayout
    let contentWidth = collectionView.bounds.width - layout.minimumInteritemSpacing * CGFloat(columnsCount - 1)
    let contentHeight = collectionView.bounds.height - layout.minimumLineSpacing * CGFloat(rowsCount - 1)
    let cellWidth = trunc(contentWidth / CGFloat(columnsCount))
    let cellHeight = trunc(contentHeight / CGFloat(rowsCount))
    let size = CGSizeMake(cellWidth, cellHeight)
    return size
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    popupCellIsSelected(indexPath: indexPath)
  }
  
  private func popupCellIsSelected(#indexPath: NSIndexPath) {
    removePopupView()
    
    let drinkIndex = indexPath.row
    assert(drinkIndex < popupDrinkTypes.count)
    let drinkType = popupDrinkTypes[drinkIndex]
    
    selectDrinkViewController.changeAlcoholicDrinkTo(drinkType: drinkType)
  }
  
  func handlePopupViewTap(gestureRecognizer: UITapGestureRecognizer) {
    if popupView == nil {
      return
    }
    
    let pointInCollectionView = gestureRecognizer.locationInView(popupCollectionView)
    if let indexPath = popupCollectionView.indexPathForItemAtPoint(pointInCollectionView) {
      popupCellIsSelected(indexPath: indexPath)
    } else {
      removePopupView()
    }
  }
  
  func handleLongPressChanged(gestureRecognizer: UIGestureRecognizer) {
    if popupCollectionView == nil {
      return
    }
    
    let pointInCollectionView = gestureRecognizer.locationInView(popupCollectionView)
    if let indexPath = popupCollectionView.indexPathForItemAtPoint(pointInCollectionView) {
      
      for currentCell in popupCollectionView.visibleCells() {
        if let visibleCell = currentCell as? UICollectionViewCell {
          visibleCell.highlighted = false
          visibleCell.setNeedsDisplay()
        }
      }
      
      let cell = popupCollectionView.cellForItemAtIndexPath(indexPath)!
      cell.highlighted = true
      cell.setNeedsDisplay()
      
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

private let cellNibName = "DrinkCollectionViewCell"
private let cellReuseIdentifier = "DrinkCell"