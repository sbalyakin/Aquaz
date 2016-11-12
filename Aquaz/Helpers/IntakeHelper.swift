//
//  IntakeHelper.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 17.11.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import Foundation
import UIKit
import CoreData

final class IntakeHelper {
  
  // MARK: Functions -
  
  static func addIntakeWithHealthKitChecks(
    amount: Double,
    drink: Drink,
    intakeDate: Date,
    saveImmediately: Bool,
    viewController: UIViewController,
    managedObjectContext: NSManagedObjectContext,
    actionBeforeAddingIntakeToCoreData: (() -> ())?,
    actionAfterAddingIntakeToCoreData: (() -> ())?)
  {
    func addIntakeInternal() {
      addIntake(
        amount: amount,
        drink: drink,
        intakeDate: intakeDate,
        saveImmediately: saveImmediately,
        managedObjectContext: managedObjectContext,
        actionBeforeAddingIntakeToCoreData: actionBeforeAddingIntakeToCoreData,
        actionAfterAddingIntakeToCoreData: actionAfterAddingIntakeToCoreData)
    }
    
    if #available(iOS 9.3, *) {
      if !Settings.sharedInstance.healthKitWaterIntakesIntegrationIsRequested2.value
      {
        Settings.sharedInstance.healthKitWaterIntakesIntegrationIsRequested2.value = true

        DispatchQueue.main.async {
          let alertTitle = NSLocalizedString("IH:Integration with Apple Health", value: "Integration with Apple Health",
            comment: "IntakeHelper: Title for alert asking for integration with Apple Health")
          
          let alertMessage = NSLocalizedString("IH:Aquaz will save your intakes to Apple Health", value: "Aquaz will save your intakes to Apple Health",
            comment: "IntakeHelper: Message for alert asking for integration with Apple Health")
          
          let alertOK = NSLocalizedString("IH:OK", value: "OK",
            comment: "IntakeHelper: OK choice for alert asking for integration with Apple Health")
          
          let alertCancel = NSLocalizedString("IH:Cancel", value: "Cancel",
            comment: "IntakeHelper: Cancel choice for alert asking for integration with Apple Health")

          let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
          
          alert.addAction(UIAlertAction(title: alertOK, style: UIAlertActionStyle.cancel, handler: { _ in
            HealthKitProvider.sharedInstance.authorizeHealthKit { authorized, _ in
              managedObjectContext.perform {
                addIntakeInternal()
              }
            }
          }))
          
          alert.addAction(UIAlertAction(title: alertCancel, style: UIAlertActionStyle.default, handler: { _ in
            Settings.sharedInstance.healthKitWaterIntakesIntegrationIsAllowed2.value = false
            managedObjectContext.perform {
              addIntakeInternal()
            }
          }))
          
          viewController.present(alert, animated: true, completion: nil)
        }
      } else {
        addIntakeInternal()
      }
    } else {
      addIntakeInternal()
    }
  }
  
  fileprivate static func addIntake(
    amount: Double,
    drink: Drink,
    intakeDate: Date,
    saveImmediately: Bool,
    managedObjectContext: NSManagedObjectContext,
    actionBeforeAddingIntakeToCoreData: (() -> ())?,
    actionAfterAddingIntakeToCoreData: (() -> ())?)
  {
    actionBeforeAddingIntakeToCoreData?()

    drink.recentAmount.amount = amount
    
    _ = Intake.addEntity(
      drink: drink,
      amount: amount,
      date: intakeDate,
      managedObjectContext: managedObjectContext,
      saveImmediately: saveImmediately)
    
    actionAfterAddingIntakeToCoreData?()
  }
  
}
