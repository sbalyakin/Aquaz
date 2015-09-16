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

final class HealthKitViewController: UIViewController {

  @IBOutlet weak var progressView: UIProgressView!
  @IBOutlet weak var progressLabel: UILabel!
  @IBOutlet weak var labelIntakesInAquaz: UILabel!
  @IBOutlet weak var labelIntakesInHealthApp: UILabel!
  @IBOutlet weak var exportButton: UIButton!
  
  private struct LocalizedStrings {

    lazy var intakesInAquazTitle: String = NSLocalizedString("HKVC:Number of intakes in Aquaz: %@", value: "Number of intakes in Aquaz: %@",
      comment: "HealthKitViewController: Label title displaying number of intakes in Aquaz")
    
    lazy var intakesInHealthAppTitle: String = NSLocalizedString("HKVC:Number of intakes in Apple Health: %@", value: "Number of intakes in Apple Health: %@",
      comment: "HealthKitViewController: Label title displaying number of intakes in Health app")

    lazy var progressTitle: String = NSLocalizedString("HKVC:%1$d of %2$d", value: "%1$d of %2$d",
      comment: "HealthKitViewController: Label title displaying progress of export")
    
    lazy var doneTitle: String = NSLocalizedString("HKVC:Export is done.", value: "Export is done.",
      comment: "HealthKitViewController: Label title displaying end of export")

    lazy var checkAppleHealthTitle: String = NSLocalizedString("HKVC:Aquaz is not allowed to write Water data to Apple Health", value: "Aquaz is not allowed to write Water data to Apple Health",
      comment: "HealthKitViewController: Title of alert displayed when Aquaz is not allowed to write data into Apple Health.")

    lazy var checkAppleHealthMessage: String = NSLocalizedString("HKVC:Check Apple Health settings in the Health app under the Sources tab", value: "Check Apple Health settings in the Health app under the Sources tab",
      comment: "HealthKitViewController: Message of alert displayed when Aquaz is not allowed to write data into Apple Health.")

    lazy var okTitle: String = NSLocalizedString("HKVC:OK", value: "OK",
      comment: "HealthKitViewController: Title for OK button")
    
  }
  
  private var localizedStrings = LocalizedStrings()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    UIHelper.applyStyleToViewController(self)
    
    progressView.alpha = 0
    progressView.tintColor = StyleKit.controlTintColor
    
    progressLabel.alpha = 0

    labelIntakesInAquaz.text = String.localizedStringWithFormat(localizedStrings.intakesInAquazTitle, "--")
    labelIntakesInHealthApp.text = String.localizedStringWithFormat(localizedStrings.intakesInHealthAppTitle, "--")

    if #available(iOS 9.0, *) {
      updateUI()
    }
  }
  
  @available(iOS 9.0, *)
  private func updateUI() {
    updateNumberOfIntakesInAquaz()
    updateNumberOfIntakesInHealthApp()
  }
  
  private func updateNumberOfIntakesInAquaz() {
    CoreDataStack.privateContext.performBlock {
      let request = NSFetchRequest(entityName: Intake.entityName)
      request.includesSubentities = false
      
      var error: NSError?
      var count = CoreDataStack.privateContext.countForFetchRequest(request, error: &error)
      if count == NSNotFound {
        count = 0
      }
      
      dispatch_async(dispatch_get_main_queue()) {
        self.labelIntakesInAquaz.text = String.localizedStringWithFormat(self.localizedStrings.intakesInAquazTitle, NSNumber(integer: count))
      }
    }
  }
  
  @available(iOS 9.0, *)
  private func updateNumberOfIntakesInHealthApp() {
    if !HealthKitProvider.sharedInstance.isAllowedToWriteWaterSamples() {
      return
    }

    HealthKitProvider.sharedInstance.requestNumberOfIntakesInHealthApp { count in
      dispatch_async(dispatch_get_main_queue()) {
        self.labelIntakesInHealthApp.text = String.localizedStringWithFormat(self.localizedStrings.intakesInHealthAppTitle, NSNumber(integer: count))
      }
    }
  }
  
  @IBAction func exportToHealthKit() {
    if #available(iOS 9.0, *) {
      if !HealthKitProvider.sharedInstance.isAllowedToWriteWaterSamples() {
        let alert = UIAlertView(title: localizedStrings.checkAppleHealthTitle, message: localizedStrings.checkAppleHealthMessage, delegate: nil, cancelButtonTitle: localizedStrings.okTitle)
        alert.show()
        return
      }
      
      progressView.progress = 0
      progressView.alpha = 1
      
      progressLabel.text = ""
      progressLabel.alpha = 1
      
      exportButton.enabled = false
    
      HealthKitProvider.sharedInstance.exportAllIntakesToHealthKit(
        progress: { current, maximum in
          dispatch_async(dispatch_get_main_queue()) {
            self.progressView.progress = maximum > 0 ? Float(current) / Float(maximum) : 0
            self.progressLabel.text = String.localizedStringWithFormat(self.localizedStrings.progressTitle, current, maximum)
          }
        },
        completion: {
          self.progressView.alpha = 0
          self.progressLabel.text = self.localizedStrings.doneTitle
          self.exportButton.enabled = true
          self.updateUI()
        }
      )
    }
  }
}