//
//  SelectDrinkViewController.swift
//  Water Me
//
//  Created by Sergey Balyakin on 29.12.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class SelectDrinkViewController: StyledViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
  @IBOutlet weak var collectionView: UICollectionView!
  
  var dayViewController: DayViewController!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    rowsCount = Int(ceil(Float(Drink.getDrinksCount()) / Float(columnsCount)))
  }
  
  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return Drink.getDrinksCount()
  }
  
  // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("DrinkCell", forIndexPath: indexPath) as DrinkCollectionViewCell
    
    let drinkIndex = indexPath.row
    assert(drinkIndex < Drink.getDrinksCount())
    
    if let drink = Drink.getDrinkByIndex(drinkIndex) {
      cell.titleLabel.text = drink.localizedName
      cell.drinkView.drink = drink
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
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let drinkIndex = indexPath.row
    assert(drinkIndex < Drink.getDrinksCount())
    let drink = Drink.getDrinkByIndex(drinkIndex)
    
    let consumptionViewController = storyboard!.instantiateViewControllerWithIdentifier("ConsumptionViewController") as ConsumptionViewController
    consumptionViewController.drink = drink
    consumptionViewController.currentDate = DateHelper.dateByJoiningDateTime(datePart: dayViewController.getCurrentDate(), timePart: NSDate())
    consumptionViewController.dayViewController = dayViewController
    navigationController!.pushViewController(consumptionViewController, animated: true)
  }
  
  let columnsCount = 3
  var rowsCount = 0
}
