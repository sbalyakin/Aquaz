//
//  UIControllersExtensions.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 20.10.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit


extension UIViewController {
  
  var contentViewController: UIViewController {
    if let navigationController = self as? UINavigationController {
      return navigationController.visibleViewController ?? self
    } else {
      return self
    }
  }

}
