//
//  StyledViewController.swift
//  Water Me
//
//  Created by Sergey Balyakin on 17.01.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

private class Styler {
  
  class func viewDidLoad(viewController: UIViewController) {
    viewController.view.backgroundColor = StyleKit.pageBackgroundColor
    if let navigationController = viewController.navigationController {
      navigationController.navigationBar.barTintColor = StyleKit.barBackgroundColor
      navigationController.navigationBar.barStyle = .Black
      navigationController.navigationBar.tintColor = StyleKit.barTextColor
    }
  }
  
}

class StyledViewController: UIViewController {
  
  func applyStyle() {
    Styler.viewDidLoad(self)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    applyStyle()
  }
  
}

class StyledTableViewController: UITableViewController {
  
  func applyStyle() {
    Styler.viewDidLoad(self)
    tableView.backgroundView = nil
    tableView.backgroundColor = StyleKit.pageBackgroundColor
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    applyStyle()
  }
  
}

