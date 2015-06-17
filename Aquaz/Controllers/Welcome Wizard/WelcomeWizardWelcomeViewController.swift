//
//  WelcomeWizardWelcomeViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 16.06.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class WelcomeWizardWelcomeViewController: UIViewController {
  
  @IBOutlet weak var logo: UIImageView!
  @IBOutlet weak var verticalSpaceMultiplierConstraint: NSLayoutConstraint!
  @IBOutlet weak var welcomeLabel: UILabel!
  @IBOutlet weak var swipeLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    welcomeLabel.alpha = 0
    swipeLabel.alpha = 0
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    SystemHelper.executeBlockWithDelay(0.5) {
      self.verticalSpaceMultiplierConstraint.constant = 0
      self.logo.setNeedsUpdateConstraints()
      
      UIView.animateWithDuration(1, delay: 0, options: .CurveEaseInOut, animations: {
        self.logo.layoutIfNeeded()
      }, completion: { finished in
        UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseInOut, animations: {
          self.welcomeLabel.alpha = 1
          }, completion: nil)
        UIView.animateWithDuration(0.5, delay: 0.25, options: .CurveEaseInOut, animations: {
          self.swipeLabel.alpha = 1
        }, completion: nil)
      })
    }
  }
}