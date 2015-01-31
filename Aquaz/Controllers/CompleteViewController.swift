//
//  CompleteViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 16.01.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class CompleteViewController: StyledViewController {
  
  @IBAction func closeButtonWasTapped(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
}
