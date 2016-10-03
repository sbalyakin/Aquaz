//
//  SelectDrinkViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 29.12.14.
//  Copyright © 2014 Sergey Balyakin. All rights reserved.
//

import UIKit
import CoreData

class SelectDrinkViewController: UIViewController {
  
  @IBOutlet weak var collectionView: UICollectionView!

  var date: Date!
  
  fileprivate let columnsCount = 3
  fileprivate var rowsCount = 0
  
  fileprivate lazy var popupViewManager: SelectDrinkPopupViewManager = SelectDrinkPopupViewManager(selectDrinkViewController: self)

  fileprivate var displayedDrinkTypes: [DrinkType] = [
    .water, .tea,    .coffee,
    .milk,  .juice,  .sport,
    .soda,  .energy, Settings.sharedInstance.uiSelectedAlcoholicDrink.value]
  
  fileprivate struct Constants {
    static let addIntakeSegue = "Add Intake"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    setupGestureRecognizers()
    setupNotificationsObservation()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  fileprivate func setupUI() {
    UIHelper.applyStyleToViewController(self)
    
    let nib = UINib(nibName: drinkCellNibName, bundle: nil)
    collectionView.register(nib, forCellWithReuseIdentifier: drinkCellReuseIdentifier)
    
    rowsCount = Int(ceil(Float(displayedDrinkTypes.count) / Float(columnsCount)))
  }
  
  fileprivate func setupGestureRecognizers() {
    let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleDrinkCellLongPress(_:)))
    longPressGestureRecognizer.minimumPressDuration = 0.5
    longPressGestureRecognizer.cancelsTouchesInView = false
    collectionView.addGestureRecognizer(longPressGestureRecognizer)
    
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleDrinkCellTap(_:)))
    tapGestureRecognizer.numberOfTapsRequired = 1
    collectionView.addGestureRecognizer(tapGestureRecognizer)
  }

  fileprivate func setupNotificationsObservation() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.preferredContentSizeChanged),
      name: NSNotification.Name.UIContentSizeCategoryDidChange,
      object: nil)
  }
  
  func preferredContentSizeChanged() {
    collectionView.reloadData()
  }
  
  fileprivate func changeAlcoholicDrinkTo(drinkType: DrinkType) {
    displayedDrinkTypes[displayedDrinkTypes.count - 1] = drinkType
    Settings.sharedInstance.uiSelectedAlcoholicDrink.value = drinkType
    
    collectionView.performBatchUpdates( {
      self.collectionView.reloadSections(IndexSet(integer: 0))
      },
      completion: { _ in
        let indexPath = IndexPath(row: self.displayedDrinkTypes.count - 1, section: 0)
        
        if let cell = self.collectionView.cellForItem(at: indexPath) {
          self.performSegue(withIdentifier: Constants.addIntakeSegue, sender: cell)
        }
      })
  }
  
  func handleDrinkCellLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
    switch gestureRecognizer.state {
    case .began:
      handleLongPressBegin(gestureRecognizer)
      
    case .changed:
      popupViewManager.handleLongPressChanged(gestureRecognizer)
      
    case .ended:
      popupViewManager.handleLongPressEnded(gestureRecognizer)
      
    default: break
    }
  }
  
  fileprivate func handleLongPressBegin(_ gestureRecognizer: UIGestureRecognizer) {
    let pointInCollectionView = gestureRecognizer.location(in: collectionView)
    let pointInScreen = gestureRecognizer.location(in: navigationController!.view)
    
    if let indexPath = collectionView.indexPathForItem(at: pointInCollectionView) {
      let drinkIndex = (indexPath as NSIndexPath).row
      if drinkIndex != displayedDrinkTypes.count - 1 {
        return
      }
      
      if let cell = collectionView.cellForItem(at: indexPath) {
        var rect = CGRect(x: cell.frame.minX, y: 0, width: cell.frame.width, height: collectionView.bounds.height)
        rect = rect.insetBy(dx: -popupViewManager.padding, dy: -popupViewManager.padding)
        rect = collectionView.convert(rect, to: navigationController!.view)
        let dy = rect.height / 3
        rect.size.height -= dy
        rect.origin.y += dy - cell.frame.height
        // Adjust to tap position
        rect.origin.y -= rect.maxY - pointInScreen.y + 20
        
        popupViewManager.showPopupView(frame: rect)
      }
    }
  }
  
  func handleDrinkCellTap(_ gestureRecognizer: UIGestureRecognizer) {
    if popupViewManager.popupIsShown {
      return
    }
    
    if gestureRecognizer.state != .ended {
      return
    }

    let pointInCollectionView = gestureRecognizer.location(in: collectionView)
    
    if let indexPath = collectionView.indexPathForItem(at: pointInCollectionView),
       let cell = collectionView.cellForItem(at: indexPath)
    {
      performSegue(withIdentifier: Constants.addIntakeSegue, sender: cell)
    }
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Constants.addIntakeSegue,
      let intakeViewController = segue.destination.contentViewController as? IntakeViewController,
      let cell = sender as? DrinkCollectionViewCell
    {
      intakeViewController.drinkType = cell.drinkView.drinkType
      intakeViewController.date = DateHelper.dateByJoiningDateTime(datePart: date, timePart: Date())
    } else {
      Logger.logError("An error occured on preparing segue for showing Intake scene from Select Drink scene")
    }
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    collectionView.collectionViewLayout.invalidateLayout()
  }

}

extension SelectDrinkViewController: UICollectionViewDataSource {
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return displayedDrinkTypes.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: drinkCellReuseIdentifier, for: indexPath) as! DrinkCollectionViewCell
    
    let drinkIndex = (indexPath as NSIndexPath).row
    assert(drinkIndex < displayedDrinkTypes.count)
    
    let drinkType = displayedDrinkTypes[drinkIndex]
    
    cell.backgroundColor = StyleKit.pageBackgroundColor
    cell.drinkLabel.text = drinkType.localizedName
    cell.drinkLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.footnote)
    cell.drinkView.drinkType = drinkType
    cell.drinkView.isGroup = drinkIndex == displayedDrinkTypes.count - 1
    cell.invalidateIntrinsicContentSize()
    
    return cell
  }
  
}

extension SelectDrinkViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
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
  
  fileprivate var window: UIWindow!
  fileprivate var popupView: UIView!
  fileprivate var popupCollectionView: UICollectionView!
  
  fileprivate let popupDrinkTypes: [DrinkType] = [ .beer, .wine, .hardLiquor ]
  fileprivate weak var selectDrinkViewController: SelectDrinkViewController!

  fileprivate let columnsCount = 1
  fileprivate var rowsCount = 3
  fileprivate let padding: CGFloat = 10

  var popupIsShown: Bool {
    return popupView != nil
  }
  
  init(selectDrinkViewController: SelectDrinkViewController) {
    self.selectDrinkViewController = selectDrinkViewController
    super.init()
  }
  
  func showPopupView(frame: CGRect) {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.preferredContentSizeChanged),
      name: NSNotification.Name.UIContentSizeCategoryDidChange,
      object: nil)

    cleanPopupView()
    
    let backgroundView = UIView(frame: frame)
    backgroundView.backgroundColor = StyleKit.pageBackgroundColor
    backgroundView.layer.cornerRadius = padding * 2
    backgroundView.layer.masksToBounds = true
    
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 0
    layout.minimumInteritemSpacing = 0
    
    let collectionViewRect = backgroundView.bounds.insetBy(dx: padding, dy: padding)
    let contentWidth = collectionViewRect.width - layout.minimumInteritemSpacing * CGFloat(columnsCount - 1)
    let contentHeight = collectionViewRect.height - layout.minimumLineSpacing * CGFloat(rowsCount - 1)
    let cellWidth = trunc(contentWidth / CGFloat(columnsCount))
    let cellHeight = trunc(contentHeight / CGFloat(rowsCount))
    layout.itemSize = CGSize(width: cellWidth, height: cellHeight)

    popupCollectionView = UICollectionView(frame: collectionViewRect, collectionViewLayout: layout)
    popupCollectionView.backgroundColor = UIColor.clear
    popupCollectionView.delegate = self
    popupCollectionView.dataSource = self
    
    let nib = UINib(nibName: drinkCellNibName, bundle: nil)
    popupCollectionView.register(nib, forCellWithReuseIdentifier: drinkCellReuseIdentifier)
    
    backgroundView.addSubview(popupCollectionView)
    
    popupView = UIView(frame: UIScreen.main.bounds)
    popupView.backgroundColor = UIColor(white: 0, alpha: 0.3)
    popupView.addSubview(backgroundView)
    popupView.alpha = 0
    
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handlePopupViewTap(_:)))
    tapGestureRecognizer.numberOfTapsRequired = 1
    popupView.addGestureRecognizer(tapGestureRecognizer)
    
    let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePopupViewPan(_:)))
    panGestureRecognizer.maximumNumberOfTouches = 1
    popupView.addGestureRecognizer(panGestureRecognizer)
    
    window = UIWindow(frame: UIScreen.main.bounds)
    window.windowLevel = UIWindowLevelAlert
    window.isOpaque = false
    window.addSubview(popupView)
    window.makeKeyAndVisible()
    
    UIView.animate(withDuration: 0.3, animations: {
      self.popupView.alpha = 1.0
    })
  }
  
  fileprivate func hidePopupView() {
    NotificationCenter.default.removeObserver(self)

    if window != nil {
      UIView.animate(withDuration: 0.3,
        animations: {
        self.popupView.alpha = 0
        },
        completion: {
          (completed: Bool) in
          self.cleanPopupView()
      })
    }
  }
  
  fileprivate func cleanPopupView() {
    window = nil
    popupCollectionView = nil
    popupView = nil
  }
  
  func preferredContentSizeChanged() {
    popupCollectionView.reloadData()
  }

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return popupDrinkTypes.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: drinkCellReuseIdentifier, for: indexPath) as! DrinkCollectionViewCell
    
    let drinkIndex = (indexPath as NSIndexPath).row
    assert(drinkIndex < popupDrinkTypes.count)
    
    let drinkType = popupDrinkTypes[drinkIndex]
    
    cell.backgroundColor = StyleKit.pageBackgroundColor
    cell.drinkLabel.text = drinkType.localizedName
    cell.drinkLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.footnote)
    cell.drinkView.drinkType = drinkType
    cell.drinkView.isGroup = false
    cell.invalidateIntrinsicContentSize()
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    popupCellIsSelected(indexPath: indexPath)
  }
  
  fileprivate func popupCellIsSelected(indexPath: IndexPath) {
    hidePopupView()
    
    let drinkIndex = (indexPath as NSIndexPath).row
    assert(drinkIndex < popupDrinkTypes.count)
    let drinkType = popupDrinkTypes[drinkIndex]
    
    selectDrinkViewController.changeAlcoholicDrinkTo(drinkType: drinkType)
  }
  
  func handlePopupViewTap(_ gestureRecognizer: UIGestureRecognizer) {
    if popupCollectionView == nil {
      return
    }
    
    let pointInCollectionView = gestureRecognizer.location(in: popupCollectionView)
    if let indexPath = popupCollectionView.indexPathForItem(at: pointInCollectionView) {
      popupCellIsSelected(indexPath: indexPath)
    } else {
      hidePopupView()
    }
  }
  
  func handlePopupViewPan(_ gestureRecognizer: UIGestureRecognizer) {
    switch gestureRecognizer.state {
    case .changed:
      handleLongPressChanged(gestureRecognizer)
      
    case .ended:
      handleLongPressEnded(gestureRecognizer)
      
    default: break
    }
  }
  
  func handleLongPressChanged(_ gestureRecognizer: UIGestureRecognizer) {
    if popupCollectionView == nil {
      return
    }

    for visibleCell in popupCollectionView.visibleCells {
      visibleCell.isHighlighted = false
      visibleCell.setNeedsDisplay()
    }

    let pointInCollectionView = gestureRecognizer.location(in: popupCollectionView)
    if let indexPath = popupCollectionView.indexPathForItem(at: pointInCollectionView) {
      if let cell = popupCollectionView.cellForItem(at: indexPath) {
        cell.isHighlighted = true
        cell.setNeedsDisplay()
      }
      
      if gestureRecognizer.state == .ended {
        popupCellIsSelected(indexPath: indexPath)
      }
    }
  }
  
  func handleLongPressEnded(_ gestureRecognizer: UIGestureRecognizer) {
    if popupCollectionView == nil {
      return
    }
    
    let pointInCollectionView = gestureRecognizer.location(in: popupCollectionView)
    if let indexPath = popupCollectionView.indexPathForItem(at: pointInCollectionView) {
      popupCellIsSelected(indexPath: indexPath)
    }
  }
  
}

private let drinkCellNibName = "DrinkCollectionViewCell"
private let drinkCellReuseIdentifier = "DrinkCell"
