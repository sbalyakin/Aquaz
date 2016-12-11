//
//  HealthKitViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 15.09.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit
import CoreData
import HealthKit

@available(iOS 9.0, *)
final class HealthKitViewController: UIViewController {

  // MARK: Types
  fileprivate struct LocalizedStrings {
    
    lazy var intakesInAquazTitle = NSLocalizedString("HKVC:Intakes in Aquaz: %@", value: "Intakes in Aquaz: %@", comment: "HealthKitViewController: Label title displaying number of intakes in Aquaz")
    
    lazy var waterSamplesInAppleHealthTitle = NSLocalizedString("HKVC:Water samples in Apple Health: %@", value: "Water samples in Apple Health: %@", comment: "HealthKitViewController: Label title displaying number of water samples in Health app")
    
    lazy var caffeineSamplesInAppleHealthTitle = NSLocalizedString("HKVC:Caffeine samples in Apple Health: %@", value: "Caffeine samples in Apple Health: %@", comment: "HealthKitViewController: Label title displaying number of caffeine samples in Health app")
    
    lazy var checkAppleHealthTitle = NSLocalizedString("HKVC:Aquaz is not allowed to write water and caffeine data to Apple Health", value: "Aquaz is not allowed to write water and caffeine data to Apple Health", comment: "HealthKitViewController: Title of alert displayed when Aquaz is not allowed to write data into Apple Health.")
    
    lazy var checkAppleHealthMessage = NSLocalizedString("HKVC:Check Apple Health settings in the Health app under the Sources tab", value: "Check Apple Health settings in the Health app under the Sources tab", comment: "HealthKitViewController: Message of alert displayed when Aquaz is not allowed to write data into Apple Health.")
    
    lazy var okTitle = NSLocalizedString("HKVC:OK", value: "OK", comment: "HealthKitViewController: Title for OK button")
    
  }

  
  // MARK: Properties
  @IBOutlet weak var progressView: UIProgressView!
  @IBOutlet weak var labelIntakesInAquaz: UILabel!
  @IBOutlet weak var labelWaterSamplesInHealthApp: UILabel!
  @IBOutlet weak var labelCaffeineSamplesInHealthApp: UILabel!
  @IBOutlet weak var exportButton: UIButton!
  
  fileprivate var localizedStrings = LocalizedStrings()

  
  // MARK: Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    updateUI()
  }

  fileprivate func setupUI() {
    UIHelper.applyStyleToViewController(self)
    
    progressView.alpha = 0
    progressView.tintColor = StyleKit.controlTintColor
    
    labelIntakesInAquaz.text = String.localizedStringWithFormat(localizedStrings.intakesInAquazTitle, "--")
    labelWaterSamplesInHealthApp.text = String.localizedStringWithFormat(localizedStrings.waterSamplesInAppleHealthTitle, "--")
    labelCaffeineSamplesInHealthApp.text = String.localizedStringWithFormat(localizedStrings.caffeineSamplesInAppleHealthTitle, "--")
  }
  
  fileprivate func updateUI() {
    updateNumberOfIntakesInAquaz()
    
    HealthKitProvider.sharedInstance.authorizeHealthKit { authorized, error in
      self.updateInfoFromAppleHealth()
    }
  }
  
  fileprivate func updateNumberOfIntakesInAquaz() {
    CoreDataStack.performOnPrivateContext { privateContext in
      let fetchRequest = Intake.createFetchRequest()
      fetchRequest.includesSubentities = false

      let count = (try? privateContext.count(for: fetchRequest)) ?? 0
      
      DispatchQueue.main.async {
        self.labelIntakesInAquaz.text = String.localizedStringWithFormat(self.localizedStrings.intakesInAquazTitle, NSNumber(value: count))
      }
    }
  }
  
  fileprivate func updateInfoFromAppleHealth() {
    HealthKitProvider.sharedInstance.requestNumberOfWaterSamples { count in
      DispatchQueue.main.async {
        self.labelWaterSamplesInHealthApp.text = String.localizedStringWithFormat(self.localizedStrings.waterSamplesInAppleHealthTitle, NSNumber(value: count))
      }
    }

    HealthKitProvider.sharedInstance.requestNumberOfCaffeineSamples { count in
      DispatchQueue.main.async {
        self.labelCaffeineSamplesInHealthApp.text = String.localizedStringWithFormat(self.localizedStrings.caffeineSamplesInAppleHealthTitle, NSNumber(value: count))
      }
    }
  }
  
  @IBAction func exportToHealthKit() {
    if !HealthKitProvider.sharedInstance.waterSharingIsAuthorized && !HealthKitProvider.sharedInstance.caffeineSharingIsAuthorized {
      let alert = UIAlertView(title: localizedStrings.checkAppleHealthTitle, message: localizedStrings.checkAppleHealthMessage, delegate: nil, cancelButtonTitle: localizedStrings.okTitle)
      alert.show()
      return
    }
    
    progressView.progress = 0
    progressView.alpha = 1
    
    exportButton.isEnabled = false
  
    HealthKitProvider.sharedInstance.exportAllIntakesToHealthKit(
      progress: { current, maximum in
        DispatchQueue.main.async {
          self.progressView.progress = maximum > 0 ? Float(current) / Float(maximum) : 0
        }
      },
      completion: {
        self.progressView.alpha = 0
        self.exportButton.isEnabled = true
        self.updateUI()
      }
    )
  }
}
