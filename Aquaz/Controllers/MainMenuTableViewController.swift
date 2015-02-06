//
//  MainMenuViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 17.01.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class MainMenuTableViewController: UITableViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = StyleKit.mainMenuBackgroundColor
    tableView.backgroundView = nil
    tableView.backgroundColor = StyleKit.mainMenuBackgroundColor
    tableView.separatorColor = StyleKit.mainMenuTextColor.colorWithAlpha(0.15).colorWithSaturation(0.6)
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .BlackOpaque
  }
  
  override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    cell.backgroundColor = StyleKit.mainMenuBackgroundColor
    cell.textLabel?.textColor = StyleKit.mainMenuTextColor
    
    let selectionView = UIView()
    selectionView.backgroundColor = StyleKit.mainMenuBackgroundColor.colorWithHighlight(0.1)
    cell.selectedBackgroundView = selectionView
  }

}