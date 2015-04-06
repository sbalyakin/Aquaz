//
//  TodayViewController.swift
//  Widget
//
//  Created by Admin on 06.04.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit
import NotificationCenter
import Aquaz

class TodayViewController: UIViewController, NCWidgetProviding {
        
  @IBOutlet weak var progressLabel: UILabel!
  @IBOutlet weak var progressView: UIProgressView!
  @IBOutlet weak var drink1AmountLabel: UILabel!
  @IBOutlet weak var drink1View: DrinkView!
  @IBOutlet weak var drink1TitleLabel: UILabel!
  @IBOutlet weak var drink2AmountLabel: UILabel!
  @IBOutlet weak var drink2View: DrinkView!
  @IBOutlet weak var drink2TitleLabel: UILabel!
  @IBOutlet weak var drink3AmountLabel: UILabel!
  @IBOutlet weak var drink3View: DrinkView!
  @IBOutlet weak var drink3TitleLabel: UILabel!
  
  private var drink1: Drink! {
    didSet {
      drink1AmountLabel.text = "\(drink1.recentAmount.amount)"
      drink1TitleLabel.text = drink1.localizedName
      drink1View.drink = drink1
    }
  }
  
  private var drink2: Drink! {
    didSet {
      drink2AmountLabel.text = "\(drink2.recentAmount.amount)"
      drink2TitleLabel.text = drink2.localizedName
      drink2View.drink = drink2
    }
  }

  private var drink3: Drink! {
    didSet {
      drink3AmountLabel.text = "\(drink3.recentAmount.amount)"
      drink3TitleLabel.text = drink3.localizedName
      drink3View.drink = drink3
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    drink1 = Drink.getDrinkByType(.Water, managedObjectContext: CoreDataProvider.sharedInstance.managedObjectContext)
    drink2 = Drink.getDrinkByType(.Tea, managedObjectContext: CoreDataProvider.sharedInstance.managedObjectContext)
    drink3 = Drink.getDrinkByType(.Coffee, managedObjectContext: CoreDataProvider.sharedInstance.managedObjectContext)
  }
  
  func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResult.Failed
    // If there's no update required, use NCUpdateResult.NoData
    // If there's an update, use NCUpdateResult.NewData
    
    completionHandler(NCUpdateResult.NewData)
  }
  
  func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
    return UIEdgeInsetsMake(0, 8, 20, 8)
  }
}
