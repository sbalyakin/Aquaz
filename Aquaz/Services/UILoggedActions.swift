//
//  UILoggedActions.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 20.10.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import Foundation
import UIKit

extension LoggedActions {
  
  class func instantiateViewController<ViewControllerType>(storyboard: UIStoryboard?, storyboardID: String) -> ViewControllerType? {
    let viewController = storyboard?.instantiateViewController(withIdentifier: storyboardID) as? ViewControllerType
    Logger.checkViewController(viewController != nil, storyboardID: storyboardID)
    return viewController
  }
}
