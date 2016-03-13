//
//  HealthKitProvider.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 14.09.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import Foundation
import CoreData
import HealthKit

@available(iOS 9.0, *)
final class HealthKitProvider: NSObject {
  
  static let sharedInstance = HealthKitProvider()
  
  private let healthKitStore = HKHealthStore()
  
  private var localizedStrings = LocalizedStrings()
  
  private let waterQuantityType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryWater)!
  
  private var managedObjectContext: NSManagedObjectContext?
  
  private struct LocalizedStrings {
    
    lazy var metadataDrinkKeyTitle: String = NSLocalizedString("HKP:Drink", value: "Drink",
      comment: "HealthKitProvider: Title for metadata key (Drink) used in Health app")

  }
  
  private struct Constants {
    
    static let metadataIdentifierKey = "Intake Identifier"
    
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  /// Sets up synchronization with passed managed object context. On saving the context HealthKitProvider
  /// will add/remove or change corresponding samples in HealthKit.
  func initSynchronizationForManagedObjectContext(managedObjectContext: NSManagedObjectContext) {
    self.managedObjectContext = managedObjectContext
    
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "contextDidSaveContext:",
      name: NSManagedObjectContextDidSaveNotification,
      object: managedObjectContext)
  }
  
  /// Asks HealthKit for authorization, executes completion closure as a result
  func authorizeHealthKit(completion: (authorized: Bool, error: NSError?) -> Void) {
    // It's just an internal flag, it does not takes into account real settings in the Health app
    Settings.sharedInstance.healthKitWaterIntakesIntegrationIsAllowed.value = true

    // If the store is not available (for instance, iPad) throw an exception
    if !HKHealthStore.isHealthDataAvailable()
    {
      let error = NSError(domain: GlobalConstants.appGroupName, code: 2, userInfo:
        [NSLocalizedDescriptionKey: "HealthKit is not available in this device"])
      completion(authorized: false, error: error)
      return
    }

    // Set the types for reading from HealthKitK Store
    let typesToRead: Set<HKObjectType> = [
      HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierDateOfBirth)!,
      HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBiologicalSex)!,
      HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!,
      HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)!]
    
    // Set the types for sharing with HealthKit Store
    let typesToShare: Set<HKSampleType> = [
      HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryWater)!]
    
    healthKitStore.requestAuthorizationToShareTypes(typesToShare, readTypes: typesToRead) {
      authorized, error in
      completion(authorized: authorized, error: error)
    }
  }
  
  /// Exports all intakes into HealthKit, all old samples in HealthKit will be deleted.
  func exportAllIntakesToHealthKit(progress progress: (current: Int, maximum: Int) -> Void, completion: () -> Void) {
    // Remove all old sample objects from HealthKit
    guard let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryWater) else {
      return
    }

    let dispatchGroup = dispatch_group_create()
    dispatch_group_enter(dispatchGroup)

    let predicate = HKQuery.predicateForSamplesWithStartDate(nil, endDate: nil, options: .None)

    healthKitStore.deleteObjectsOfType(sampleType, predicate: predicate) { success, deletedObjectCount, error in
      if !success {
        dispatch_group_leave(dispatchGroup)
        return
      }
      
      // Add intakes into HealthKit
      self.managedObjectContext?.performBlock {
        let intakes = Intake.fetchIntakes(beginDate: nil, endDate: nil, managedObjectContext: self.managedObjectContext!)
        
        progress(current: 0, maximum: intakes.count)
        
        var samplesToSave = [HKQuantitySample]()
        
        let saveToHealthKit = { (currentProgress currentProgress: Int) -> Void in
          dispatch_group_enter(dispatchGroup)
          
          let objects = samplesToSave
          samplesToSave.removeAll()
          
          self.healthKitStore.saveObjects(objects) { success, error in
            progress(current: currentProgress, maximum: intakes.count)
            dispatch_group_leave(dispatchGroup)
          }
        }
        
        for (index, intake) in intakes.enumerate() {
          // Collect samples
          if let sample = self.createQuantitySampleFromIntake(intake) {
            samplesToSave.append(sample)
          }
          
          // Save samples to HealthKit
          if samplesToSave.count >= 100 {
            saveToHealthKit(currentProgress: index + 1)
          }
        }
        
        // Save the rest of samples to HealthKit
        if !samplesToSave.isEmpty {
          saveToHealthKit(currentProgress: intakes.count)
        } else {
          progress(current: intakes.count, maximum: intakes.count)
        }
        
        dispatch_group_leave(dispatchGroup)
      }
    }
    
    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue()) {
      completion()
    }
  }
  
  /// Reads user profile and executes completion closure as a result
  func readUserProfile(completion: (age: Int?, biologicalSex: HKBiologicalSex?, bodyMass: HKQuantitySample?, height: HKQuantitySample?) -> Void) {
    let age = readAge()
    let biologicalSex = readBiologicalSex()

    let dispatchGroup = dispatch_group_create()
    
    // Read body mass
    dispatch_group_enter(dispatchGroup)
    var bodyMass: HKQuantitySample?
    readMostRecentSample(quantityTypeIdentifier: HKQuantityTypeIdentifierBodyMass) { quantitySample, _ in
      bodyMass = quantitySample
      dispatch_group_leave(dispatchGroup)
    }

    // Read height
    dispatch_group_enter(dispatchGroup)
    var height: HKQuantitySample?
    readMostRecentSample(quantityTypeIdentifier: HKQuantityTypeIdentifierHeight) { quantitySample, _ in
      height = quantitySample
      dispatch_group_leave(dispatchGroup)
    }

    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue()) {
      completion(age: age, biologicalSex: biologicalSex, bodyMass: bodyMass, height: height)
    }
  }
  
  private func readAge() -> Int? {
    if let birthDay = try? healthKitStore.dateOfBirth() {
      return DateHelper.calcDistanceBetweenCalendarDates(fromDate: birthDay, toDate: NSDate(), calendarUnit: .Year)
    }
    
    return nil
  }
  
  private func readBiologicalSex() -> HKBiologicalSex? {
    return try? healthKitStore.biologicalSex().biologicalSex
  }
  
  private func readMostRecentSample(quantityTypeIdentifier quantityTypeIdentifier: String, completion: (HKQuantitySample?, NSError?) -> Void) {
    guard let sampleType = HKSampleType.quantityTypeForIdentifier(quantityTypeIdentifier) else {
      let error = NSError(domain: GlobalConstants.appGroupName, code: 2, userInfo:
        [NSLocalizedDescriptionKey: "Passed quantity type is not supported"])
      completion(nil, error)
      return
    }
    
    let sortDesciptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
    
    let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: nil, limit: 1, sortDescriptors: [sortDesciptor]) { sampleQuery, samples, error in
      if let error = error {
        completion(nil, error)
        return
      }
      
      let mostRecentSample = samples?.first as? HKQuantitySample
      
      completion(mostRecentSample, nil)
    }
    
    healthKitStore.executeQuery(sampleQuery)
  }
  
  func requestNumberOfIntakesInHealthApp(completion: (count: Int) -> Void) {
    guard let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryWater) else {
      completion(count: 0)
      return
    }

    let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: nil, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) { sampleQuery, samples, error in
      let count = samples?.count ?? 0
      completion(count: count)
    }
    
    healthKitStore.executeQuery(sampleQuery)
  }

  func isAllowedToWriteWaterSamples() -> Bool {
    return healthKitStore.authorizationStatusForType(waterQuantityType) == .SharingAuthorized
  }
  
  /// Saves water intake to HealthKit
  private func saveWaterIntake(intake: Intake, completion: ((success: Bool) -> Void)? = nil) {
    if let sample = createQuantitySampleFromIntake(intake) {
      healthKitStore.saveObject(sample) { success, error in
        completion?(success: success)
      }
    }
  }
  
  private func createQuantitySampleFromIntake(intake: Intake) -> HKQuantitySample? {
    guard let intakeId = getIntakeId(intake) else {
      return nil
    }
    
    let quantity = HKQuantity(unit: HKUnit.literUnitWithMetricPrefix(.Milli), doubleValue: intake.hydrationAmount)
    
    let metadata = [
      localizedStrings.metadataDrinkKeyTitle: intake.drink.localizedName,
      Constants.metadataIdentifierKey: intakeId]
    
    return HKQuantitySample(type: waterQuantityType, quantity: quantity, startDate: intake.date, endDate: intake.date, metadata: metadata)
  }
  
  /// Removes water intake from HealthKit
  private func removeWaterIntake(intake: Intake, completion: (() -> Void)?) {
    guard let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryWater) else {
      return
    }
    
    guard let intakeId = getIntakeId(intake) else {
      return
    }

    let predicate = HKQuery.predicateForObjectsWithMetadataKey(Constants.metadataIdentifierKey, allowedValues: [intakeId])

    healthKitStore.deleteObjectsOfType(sampleType, predicate: predicate) { success, deletedObjectCount, error in
      completion?()
    }
  }
  
  /// Updates water intake in HealthKit, actually removes an old sample object related to the intake and saves a new one.
  private func updateWaterIntake(intake: Intake) {
    removeWaterIntake(intake) {
      self.saveWaterIntake(intake)
    }
  }

  private func getIntakeId(intake: Intake) -> String? {
    return intake.objectID.URIRepresentation().lastPathComponent
  }
  
  // MARK: Synchronization with CoreData
  
  func contextDidSaveContext(notification: NSNotification) {
    if !Settings.sharedInstance.healthKitWaterIntakesIntegrationIsAllowed.value {
      return
    }
    
    authorizeHealthKit { authorized, _ in
      if authorized {
        self.synchronizeWithHealthKit(notification)
      }
    }
  }
  
  private func synchronizeWithHealthKit(notification: NSNotification) {
    managedObjectContext?.performBlock {
      // Delete intakes from HealthKit
      if let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject> {
        for deletedObject in deletedObjects where deletedObject is Intake {
          self.removeWaterIntake(deletedObject as! Intake, completion: nil)
        }
      }
      
      // Insert intakes to HealthKit
      if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> {
        for insertedObject in insertedObjects where insertedObject is Intake {
          self.saveWaterIntake(insertedObject as! Intake)
        }
      }
      
      // Update intakes in HealthKit
      if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
        for updatedObject in updatedObjects where updatedObject is Intake {
          self.updateWaterIntake(updatedObject as! Intake)
        }
      }
    }
  }
  
}