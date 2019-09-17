//
//  UIHelper.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 05.12.14.
//  Copyright © 2014 Sergey Balyakin. All rights reserved.
//

import Foundation
import UIKit

class UIHelper {
  
  class func applyStylization() {
    UISegmentedControl.appearance().tintColor = StyleKit.controlTintColor
    
    UINavigationBar.appearance().tintColor = StyleKit.barTextColor
    
    UIButton.appearance().tintColor = StyleKit.controlTintColor
    
    UISwitch.appearance().onTintColor = StyleKit.controlTintColor
    
    UITabBar.appearance().tintColor = StyleKit.controlTintColor
    
    if #available(iOS 11.0, *) {
      UIButton.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = StyleKit.barTextColor
    }
  }
  
  class func applyStyleToViewController(_ viewController: UIViewController) {
    viewController.view.backgroundColor = StyleKit.pageBackgroundColor

    if let tableViewController = viewController as? UITableViewController {
      tableViewController.tableView.backgroundView = nil
      tableViewController.tableView.backgroundColor = StyleKit.pageBackgroundColor
    } else if let settingsViewController = viewController as? OmegaSettingsViewController {
      settingsViewController.tableView.backgroundView = nil
      settingsViewController.tableView.backgroundColor = StyleKit.pageBackgroundColor
    }
    
    if let navigationBar = viewController.navigationController?.navigationBar {
      applyStyleToNavigationBar(navigationBar)
    }
  }

  class func applyStyleToNavigationBar(_ navigationBar: UINavigationBar) {
    navigationBar.barTintColor = StyleKit.barBackgroundColor
    navigationBar.barStyle = .black
    navigationBar.tintColor = StyleKit.barTextColor
    navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: StyleKit.barTextColor]
    navigationBar.isTranslucent = false
    navigationBar.tintAdjustmentMode = .normal
  }
  
  class func adjustNavigationTitleViewSize(_ navigationItem: UINavigationItem) {
    if let titleView = navigationItem.titleView {
      navigationItem.titleView = nil
      titleView.setNeedsLayout()
      titleView.layoutIfNeeded()
      titleView.frame.size = titleView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
      navigationItem.titleView = titleView
    }
  }
}

