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
  
  static func addIntakeWithHealthKitChecks(
    amount amount: Double,
    drink: Drink,
    intakeDate: NSDate,
    viewController: UIViewController,
    managedObjectContext: NSManagedObjectContext,
    actionBeforeAddingIntakeToCoreData: (() -> ())?,
    actionAfterAddingIntakeToCoreData: (() -> ())?)
  {
    func addIntakeSugar() {
      addIntake(amount: amount, drink: drink, intakeDate: intakeDate, managedObjectContext: managedObjectContext, actionBeforeAddingIntakeToCoreData: actionBeforeAddingIntakeToCoreData, actionAfterAddingIntakeToCoreData: actionAfterAddingIntakeToCoreData)
    }
    
    if #available(iOS 9.0, *) {
      if !Settings.sharedInstance.healthKitWaterIntakesIntegrationIsRequested.value {
        Settings.sharedInstance.healthKitWaterIntakesIntegrationIsRequested.value = true
        
        let alert = UIAlertController(title: "Integration with Apple Health", message: "Aquaz will save your intakes to Apple Health", preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { _ in
          HealthKitProvider.sharedInstance.authorizeHealthKit { authorized, _ in
            addIntakeSugar()
          }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: { _ in
          Settings.sharedInstance.healthKitWaterIntakesIntegrationIsAllowed.value = false
          addIntakeSugar()
        }))
        
        viewController.presentViewController(alert, animated: true, completion: nil)
      } else {
        addIntakeSugar()
      }
    } else {
      addIntakeSugar()
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
    actionBeforeAddingIntakeToCoreData?()
    
    managedObjectContext.performBlock {
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