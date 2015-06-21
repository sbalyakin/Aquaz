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
    
    UITabBar.appearance().tintColor = StyleKit.controlTintColor
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

  class func adjustNavigationTitleViewSize(navigationItem: UINavigationItem) {
    if let titleView = navigationItem.titleView {
      navigationItem.titleView = nil
      titleView.frame.size = titleView.systemLayoutSizeFittingSize(CGSizeZero)
      navigationItem.titleView = titleView
    }
  }
  
  class func showHelpTip(helpTip: JDFTooltipView, hideCompletionHandler: (() -> ())? = nil) {
    helpTip.tooltipBackgroundColour = StyleKit.helpTipsColor
    helpTip.textColour = UIColor.blackColor()
    
    helpTip.showCompletionBlock = {
      SystemHelper.executeBlockWithDelay(GlobalConstants.helpTipDisplayTime) {
        helpTip.hideAnimated(true)
      }
    }
    
    helpTip.hideCompletionBlock = hideCompletionHandler

    helpTip.show()
  }
}

