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
  
  private var popupView: UIView!
  private var popupCollectionView: UICollectionView!
  
  var dayViewController: DayViewController!
  
  private let columnsCount = 3
  private var rowsCount = 0

  private var displayedDrinkTypes: [Drink.DrinkType] = [
    .Water, .Tea,    .Coffee,
    .Milk,  .Juice,  .Sport,
    .Soda,  .Energy, .Alcohol]
  
  private let popupDrinkTypes: [Drink.DrinkType] = [ .Beer, .Wine, .StrongLiquor ]
  
  private let collectionViewTag = 0
  private let popupCollectionViewTag = 1
  
  override func viewDidLoad() {
    super.viewDidLoad()
    rowsCount = Int(ceil(Float(displayedDrinkTypes.count) / Float(columnsCount)))
    setupGestureRecognizers()
    collectionView.tag = collectionViewTag
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
  
  func handleConsumptionCellLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
    switch gestureRecognizer.state {
    case .Began:
      handleLongPressBegin(gestureRecognizer)
      
    case .Changed:
      handleLongPressChanged(gestureRecognizer)
      
    case .Ended:
      handleLongPressEnded(gestureRecognizer)
      
    default: break
    }
  }
  
  private func handleLongPressBegin(gestureRecognizer: UIGestureRecognizer) {
    let pointInCollectionView = gestureRecognizer.locationInView(collectionView)
    if let indexPath = collectionView.indexPathForItemAtPoint(pointInCollectionView) {
      
      let drinkIndex = indexPath.row
      if drinkIndex != displayedDrinkTypes.count - 1 {
        return
      }
      
      let drinkType = displayedDrinkTypes[drinkIndex]
      let cell = collectionView.cellForItemAtIndexPath(indexPath)!
      var rect = CGRectMake(cell.frame.minX, 0, cell.frame.width, collectionView.bounds.height)
      rect.inset(dx: -10, dy: -10)
      rect = collectionView.convertRect(rect, toView: navigationController!.view)
      let view = createViewForAlcoholSelection(rect)
      
      view.alpha = 0.0
      
      navigationController!.view.addSubview(view)

      let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handlePopupViewTap:")
      tapGestureRecognizer.numberOfTapsRequired = 1
      view.addGestureRecognizer(tapGestureRecognizer)
      
      UIView.animateWithDuration(0.3, animations: {
        view.alpha = 1.0
      })
    }
  }
  
  private func handleLongPressChanged(gestureRecognizer: UIGestureRecognizer) {
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
  
  private func handleLongPressEnded(gestureRecognizer: UIGestureRecognizer) {
    if popupCollectionView == nil {
      return
    }
    
    let pointInCollectionView = gestureRecognizer.locationInView(popupCollectionView)
    if let indexPath = popupCollectionView.indexPathForItemAtPoint(pointInCollectionView) {
      popupCellIsSelected(indexPath: indexPath)
    }
  }
  
  func handleConsumptionCellTap(gestureRecognizer: UIGestureRecognizer) {
    if gestureRecognizer.state != .Ended {
      return
    }

    let pointInCollectionView = gestureRecognizer.locationInView(collectionView)
    if let indexPath = collectionView.indexPathForItemAtPoint(pointInCollectionView) {
      collectionViewCellIsSelected(indexPath: indexPath)
    }
  }

  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
    if gestureRecognizer.view == popupView {
      return true
    }
    
    return false
  }
  
  func handlePopupViewTap(gestureRecognizer: UIGestureRecognizer) {
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
  
  private func removePopupView() {
    if popupView != nil {
      popupCollectionView = nil
      popupView.removeFromSuperview()
      popupView = nil
    }
  }
  
  private func createViewForAlcoholSelection(rect: CGRect) -> UIView {
    removePopupView()

    let frame = CGRectMake(rect.minX, 0, rect.width, collectionView.bounds.height)
    let backgroundView = UIView(frame: rect)
    backgroundView.backgroundColor = StyleKit.pageBackgroundColor
    backgroundView.layer.cornerRadius = 20
    
    let layout = UICollectionViewFlowLayout()
    popupCollectionView = UICollectionView(frame: backgroundView.bounds.rectByInsetting(dx: 10, dy: 10), collectionViewLayout: layout)
    popupCollectionView.backgroundColor = UIColor.clearColor()
    popupCollectionView.delegate = self
    popupCollectionView.dataSource = self
    popupCollectionView.tag = popupCollectionViewTag
    
    let nib = UINib(nibName: "NewDrinkCollectionViewCell", bundle: nil)
    popupCollectionView.registerNib(nib, forCellWithReuseIdentifier: "NewDrinkCell")
    
    backgroundView.addSubview(popupCollectionView)
    
    popupView = UIView(frame: navigationController!.view.bounds)
    popupView.backgroundColor = UIColor(white: 0.5, alpha: 0.7)
    popupView.addSubview(backgroundView)
    
    return popupView
  }

  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    switch collectionView.tag {
    case collectionViewTag:
      return displayedDrinkTypes.count
      
    case popupCollectionViewTag:
      return popupDrinkTypes.count
      
    default:
      assert(false)
    }
    
    return 0
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    switch collectionView.tag {
    case collectionViewTag:
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier("DrinkCell", forIndexPath: indexPath) as DrinkCollectionViewCell
      
      let drinkIndex = indexPath.row
      assert(drinkIndex < displayedDrinkTypes.count)
      
      let drinkType = displayedDrinkTypes[drinkIndex]
      
      if let drink = Drink.getDrinkByType(drinkType) {
        cell.titleLabel.text = drink.localizedName
        cell.drinkView.drink = drink
      } else {
        assert(false)
      }
      
      return cell
      
    case popupCollectionViewTag:
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier("NewDrinkCell", forIndexPath: indexPath) as NewDrinkCollectionViewCell
      
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
      
    default: assert(false)
    }
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    collectionView.collectionViewLayout.invalidateLayout()
  }

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    switch collectionView.tag {
    case collectionViewTag:
      let layout = collectionViewLayout as UICollectionViewFlowLayout
      let contentWidth = collectionView.bounds.width - layout.minimumInteritemSpacing * CGFloat(columnsCount - 1)
      let contentHeight = collectionView.bounds.height - layout.minimumLineSpacing * CGFloat(rowsCount - 1)
      let cellWidth = trunc(contentWidth / CGFloat(columnsCount))
      let cellHeight = trunc(contentHeight / CGFloat(rowsCount))
      let size = CGSizeMake(cellWidth, cellHeight)
      return size

    case popupCollectionViewTag:
      let layout = collectionViewLayout as UICollectionViewFlowLayout
      let contentWidth = collectionView.bounds.width
      let contentHeight = collectionView.bounds.height - layout.minimumLineSpacing * CGFloat(popupDrinkTypes.count - 1)
      let cellWidth = trunc(contentWidth)
      let cellHeight = trunc(contentHeight / CGFloat(rowsCount))
      let size = CGSizeMake(cellWidth, cellHeight)
      return size
      
    default:
      assert(false)
    }
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    switch collectionView.tag {
    case collectionViewTag:
      collectionViewCellIsSelected(indexPath: indexPath)
      
    case popupCollectionViewTag:
      popupCellIsSelected(indexPath: indexPath)
      
    default: assert(false)
    }
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
  
  private func popupCellIsSelected(#indexPath: NSIndexPath) {
    let drinkIndex = indexPath.row
    assert(drinkIndex < popupDrinkTypes.count)
    
    let drinkType = popupDrinkTypes[drinkIndex]
    
    let drink = Drink.getDrinkByType(drinkType)
    
    displayedDrinkTypes[displayedDrinkTypes.count - 1] = drinkType
    let alcoholIndexPath = NSIndexPath(forRow: displayedDrinkTypes.count - 1, inSection: 0)
    self.collectionView.reloadItemsAtIndexPaths([alcoholIndexPath])
    
    popupCollectionView = nil
    popupView.removeFromSuperview()
    popupView = nil
    
    let consumptionViewController = storyboard!.instantiateViewControllerWithIdentifier("ConsumptionViewController") as ConsumptionViewController
    consumptionViewController.drink = drink
    consumptionViewController.currentDate = DateHelper.dateByJoiningDateTime(datePart: dayViewController.getCurrentDate(), timePart: NSDate())
    consumptionViewController.dayViewController = dayViewController
    navigationController!.pushViewController(consumptionViewController, animated: true)
  }
  
  func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
  }
  
//  func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
//    if collectionView.tag != popupCollectionViewTag {
//      return
//    }
//    
//    let cell = collectionView.cellForItemAtIndexPath(indexPath)
//    cell?.setNeedsDisplay()
//  }

}
