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
  
  func alertOkMessage(message: String, title: String? = nil, okHandler: ((UIAlertAction) -> Void)? = nil) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    let okAction = UIAlertAction(title: CommonLocalizations.ok, style: .default, handler: okHandler)
    alert.addAction(okAction)
    present(alert, animated: true, completion: nil)
  }
}
