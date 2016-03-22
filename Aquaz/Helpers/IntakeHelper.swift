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
    amount amount: Double,
    drink: Drink,
    intakeDate: NSDate,
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
        managedObjectContext: managedObjectContext,
        actionBeforeAddingIntakeToCoreData: actionBeforeAddingIntakeToCoreData,
        actionAfterAddingIntakeToCoreData: actionAfterAddingIntakeToCoreData)
    }
    
    if #available(iOS 9.0, *) {
      if !Settings.sharedInstance.healthKitWaterIntakesIntegrationIsRequested2.value
      {
        Settings.sharedInstance.healthKitWaterIntakesIntegrationIsRequested2.value = true

        let alertTitle = NSLocalizedString("IH:Integration with Apple Health", value: "Integration with Apple Health",
          comment: "IntakeHelper: Title for alert asking for integration with Apple Health")
        
        let alertMessage = NSLocalizedString("IH:Aquaz will save your intakes to Apple Health", value: "Aquaz will save your intakes to Apple Health",
          comment: "IntakeHelper: Message for alert asking for integration with Apple Health")
        
        let alertOK = NSLocalizedString("IH:OK", value: "OK",
          comment: "IntakeHelper: OK choice for alert asking for integration with Apple Health")
        
        let alertCancel = NSLocalizedString("IH:Cancel", value: "Cancel",
          comment: "IntakeHelper: Cancel choice for alert asking for integration with Apple Health")

        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: alertOK, style: UIAlertActionStyle.Cancel, handler: { _ in
          HealthKitProvider.sharedInstance.authorizeHealthKit { authorized, _ in
            addIntakeInternal()
          }
        }))
        
        alert.addAction(UIAlertAction(title: alertCancel, style: UIAlertActionStyle.Default, handler: { _ in
          Settings.sharedInstance.healthKitWaterIntakesIntegrationIsAllowed2.value = false
          addIntakeInternal()
        }))
        
        viewController.presentViewController(alert, animated: true, completion: nil)
      } else {
        addIntakeInternal()
      }
    } else {
      addIntakeInternal()
    }
  }
  
  private static func addIntake(
    amount amount: Double,
    drink: Drink,
    intakeDate: NSDate,
    managedObjectContext: NSManagedObjectContext,
    actionBeforeAddingIntakeToCoreData: (() -> ())?,
    actionAfterAddingIntakeToCoreData: (() -> ())?)
  {
    managedObjectContext.performBlock {
      actionBeforeAddingIntakeToCoreData?()

      drink.recentAmount.amount = amount
      
      Intake.addEntity(
        drink: drink,
        amount: amount,
        date: intakeDate,
        managedObjectContext: managedObjectContext,
        saveImmediately: true)
      
      actionAfterAddingIntakeToCoreData?()
    }
  }
  
}