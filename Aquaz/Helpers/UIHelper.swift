//
//  UIHelper.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 05.12.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation
import UIKit

class UIHelper {
  
  class func applyStylization() {
    UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
    
    UISegmentedControl.appearance().tintColor = StyleKit.controlTintColor
    
    UIButton.appearance().tintColor = StyleKit.controlTintColor
    
    UISwitch.appearance().onTintColor = StyleKit.controlTintColor
    
    UIBarButtonItem.appearance().tintColor = StyleKit.barTextColor
    UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: StyleKit.barTextColor], forState: .Normal)
    
    UINavigationBar.appearance().barTintColor = StyleKit.barBackgroundColor
    UINavigationBar.appearance().barStyle = .Black
    UINavigationBar.appearance().tintColor = StyleKit.barTextColor
    UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: StyleKit.barTextColor]
    UINavigationBar.appearance().translucent = false
    UINavigationBar.appearance().tintAdjustmentMode = .Normal
  }
  
  class func applyStyleToNavigationBar(navigationBar: UINavigationBar) {
    navigationBar.barTintColor = StyleKit.barBackgroundColor
    navigationBar.barStyle = .Black
    navigationBar.tintColor = StyleKit.barTextColor
    navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: StyleKit.barTextColor]
    navigationBar.translucent = false
    navigationBar.tintAdjustmentMode = .Normal
  }
  
  class func applyStyle(viewController: UIViewController) {
    viewController.view.backgroundColor = StyleKit.pageBackgroundColor

    if let tableViewController = viewController as? UITableViewController {
      tableViewController.tableView.backgroundView = nil
      tableViewController.tableView.backgroundColor = UIColor.clearColor()
    } else if let settingsViewController = viewController as? OmegaSettingsViewController {
      settingsViewController.tableView.backgroundView = nil
      settingsViewController.tableView.backgroundColor = UIColor.clearColor()
    }
  }

  class func setupReveal(viewController: UIViewController) {
    if let revealViewController = viewController.revealViewController() {
      let menuImage = UIImage(named: "iconMenu")
      let revealButton = StyledBarButtonItem(image: menuImage, style: .Plain, target: revealViewController, action: "revealToggle:")
      viewController.navigationItem.setLeftBarButtonItem(revealButton, animated: true)
      viewController.navigationController?.navigationBar.addGestureRecognizer(revealViewController.panGestureRecognizer())
      viewController.view.addGestureRecognizer(revealViewController.panGestureRecognizer())
    }
  }
  
}

