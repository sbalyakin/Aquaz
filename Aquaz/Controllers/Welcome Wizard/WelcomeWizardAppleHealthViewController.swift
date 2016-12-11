//
//  WelcomeWizardAppleHealthViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 11.12.16.
//  Copyright © 2016 Sergey Balyakin. All rights reserved.
//

import UIKit

@available(iOS 9.0, *)
final class WelcomeWizardAppleHealthViewController: UIViewController {
  
  // MARK: Types
  private struct LocalizedStrings {
    lazy var done = NSLocalizedString("WWAHVC:Done", value: "Done", comment: "WelcomeWizardAppleHealthViewController: Done button title")
  }
  
  
  // MARK: Properties
  
  @IBOutlet weak var connectToAppleHealthButton: RoundedButton!
  
  private let enabledColor = #colorLiteral(red: 0, green: 0.5803921569, blue: 0.7215686275, alpha: 1)
  private let disabledColor = #colorLiteral(red: 0.6729370952, green: 0.6774026155, blue: 0.7209731936, alpha: 1)
  private let doneColor = #colorLiteral(red: 0.1968496442, green: 0.7056635022, blue: 0.2647150755, alpha: 1)
  
  private var localizedStrings = LocalizedStrings()
  
  // MARK: Methods
  
  @IBAction func connectToAppleHealth() {
    connectToAppleHealthButton.isEnabled = false
    connectToAppleHealthButton.backgroundColor = disabledColor
    
    HealthKitProvider.sharedInstance.authorizeHealthKit { authorized, error in
      DispatchQueue.main.async {
        if authorized {
          self.connectToAppleHealthButton.isEnabled = true
          self.connectToAppleHealthButton.backgroundColor = self.enabledColor
          self.connectToAppleHealthButton.setTitle(self.localizedStrings.done, for: .normal)
          self.connectToAppleHealthButton.backgroundColor = self.doneColor
        } else {
          self.connectToAppleHealthButton.isEnabled = true
          self.connectToAppleHealthButton.backgroundColor = self.enabledColor
        }
      }
    }
  }
  
}
