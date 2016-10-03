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
  
  fileprivate let healthKitStore = HKHealthStore()
  
  fileprivate var localizedStrings = LocalizedStrings()
  
  fileprivate let waterQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryWater)!

  fileprivate let caffeineQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCaffeine)!

  fileprivate var managedObjectContext: NSManagedObjectContext?
  
  fileprivate struct LocalizedStrings {
    
    lazy var metadataDrinkKeyTitle: String = NSLocalizedString("HKP:Drink", value: "Drink",
      comment: "HealthKitProvider: Title for metadata key (Drink) used in Health app")

  }
  
  fileprivate struct Constants {
    
    static let metadataIdentifierKey = "Intake Identifier"
    
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  /// Sets up synchronization with passed managed object context. On saving the context HealthKitProvider
  /// will add/remove or change corresponding samples in HealthKit.
  func initSynchronizationForManagedObjectContext(_ managedObjectContext: NSManagedObjectContext) {
    self.managedObjectContext = managedObjectContext
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.contextDidSaveContext(_:)),
      name: NSNotification.Name.NSManagedObjectContextDidSave,
      object: managedObjectContext)
  }
  
  /// Asks HealthKit for authorization, executes completion closure as a result
  func authorizeHealthKit(_ completion: @escaping (_ authorized: Bool, _ error: NSError?) -> Void) {
    // It's just an internal flag, it does not takes into account real settings in the Health app
    Settings.sharedInstance.healthKitWaterIntakesIntegrationIsAllowed2.value = true

    // If the store is not available (for instance, iPad) throw an exception
    if !HKHealthStore.isHealthDataAvailable()
    {
      let error = NSError(domain: GlobalConstants.appGroupName, code: 2, userInfo:
        [NSLocalizedDescriptionKey: "HealthKit is not available in this device"])
      completion(false, error)
      return
    }

    // Set the types for reading from HealthKitK Store
    let typesToRead: Set<HKObjectType> = [
      HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
      HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!,
      HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!,
      HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!]
    
    // Set the types for sharing with HealthKit Store
    let typesToShare: Set<HKSampleType> = [
      HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryWater)!,
      HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCaffeine)!]
    
    healthKitStore.requestAuthorization(toShare: typesToShare, read: typesToRead) {
      authorized, error in
      completion(authorized, error as NSError?)
    }
  }
  
  /// Exports all intakes into HealthKit, all old samples in HealthKit will be deleted.
  func exportAllIntakesToHealthKit(progress: @escaping (_ current: Int, _ maximum: Int) -> Void, completion: @escaping () -> Void) {
    // Remove all old sample objects from HealthKit
    guard let sampleType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryWater) else {
      return
    }

    let dispatchGroup = DispatchGroup()
    dispatchGroup.enter()

    let predicate = HKQuery.predicateForSamples(withStart: nil, end: nil, options: HKQueryOptions())

    healthKitStore.deleteObjects(of: sampleType, predicate: predicate) { success, deletedObjectCount, error in
      if !success {
        dispatchGroup.leave()
        return
      }
      
      // Add intakes into HealthKit
      self.managedObjectContext?.perform {
        let intakes = Intake.fetchIntakes(beginDate: nil, endDate: nil, managedObjectContext: self.managedObjectContext!)
        
        progress(0, intakes.count)
        
        var samplesToSave = [HKQuantitySample]()
        
        let saveToHealthKit = { (currentProgress: Int) -> Void in
          dispatchGroup.enter()
          
          let objects = samplesToSave
          samplesToSave.removeAll()
          
          self.healthKitStore.save(objects, withCompletion: { success, error in
            progress(currentProgress, intakes.count)
            dispatchGroup.leave()
          }) 
        }
        
        for (index, intake) in intakes.enumerated() {
          // Collect samples
          if let waterSample = self.createWaterQuantitySampleFromIntake(intake) {
            samplesToSave.append(waterSample)
          }

          if let caffeineSample = self.createCaffeineQuantitySampleFromIntake(intake) {
            samplesToSave.append(caffeineSample)
          }

          // Save samples to HealthKit
          if samplesToSave.count >= 100 {
            saveToHealthKit(index + 1)
          }
        }
        
        // Save the rest of samples to HealthKit
        if !samplesToSave.isEmpty {
          saveToHealthKit(intakes.count)
        } else {
          progress(intakes.count, intakes.count)
        }
        
        dispatchGroup.leave()
      }
    }
    
    dispatchGroup.notify(queue: DispatchQueue.main) {
      completion()
    }
  }
  
  /// Reads user profile and executes completion closure as a result
  func readUserProfile(_ completion: @escaping (_ age: Int?, _ biologicalSex: HKBiologicalSex?, _ bodyMass: HKQuantitySample?, _ height: HKQuantitySample?) -> Void) {
    let age = readAge()
    let biologicalSex = readBiologicalSex()

    let dispatchGroup = DispatchGroup()
    
    // Read body mass
    dispatchGroup.enter()
    var bodyMass: HKQuantitySample?
    readMostRecentSample(quantityTypeIdentifier: HKQuantityTypeIdentifier.bodyMass.rawValue) { quantitySample, _ in
      bodyMass = quantitySample
      dispatchGroup.leave()
    }

    // Read height
    dispatchGroup.enter()
    var height: HKQuantitySample?
    readMostRecentSample(quantityTypeIdentifier: HKQuantityTypeIdentifier.height.rawValue) { quantitySample, _ in
      height = quantitySample
      dispatchGroup.leave()
    }

    dispatchGroup.notify(queue: DispatchQueue.main) {
      completion(age, biologicalSex, bodyMass, height)
    }
  }
  
  fileprivate func readAge() -> Int? {
    if let birthDay = try? healthKitStore.dateOfBirth() {
      return DateHelper.years(fromDate: birthDay, toDate: Date())
    }
    
    return nil
  }
  
  fileprivate func readBiologicalSex() -> HKBiologicalSex? {
    return try? healthKitStore.biologicalSex().biologicalSex
  }
  
  fileprivate func readMostRecentSample(quantityTypeIdentifier: String, completion: @escaping (HKQuantitySample?, NSError?) -> Void) {
    guard let sampleType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: quantityTypeIdentifier)) else {
      let error = NSError(domain: GlobalConstants.appGroupName, code: 2, userInfo:
        [NSLocalizedDescriptionKey: "Passed quantity type is not supported"])
      completion(nil, error)
      return
    }
    
    let sortDesciptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
    
    let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: nil, limit: 1, sortDescriptors: [sortDesciptor]) { sampleQuery, samples, error in
      if let error = error {
        completion(nil, error as NSError?)
        return
      }
      
      let mostRecentSample = samples?.first as? HKQuantitySample
      
      completion(mostRecentSample, nil)
    }
    
    healthKitStore.execute(sampleQuery)
  }
  
  func requestNumberOfIntakesInHealthApp(_ completion: @escaping (_ count: Int) -> Void) {
    guard let sampleType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryWater) else {
      completion(0)
      return
    }

    let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: nil, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) { sampleQuery, samples, error in
      let count = samples?.count ?? 0
      completion(count)
    }
    
    healthKitStore.execute(sampleQuery)
  }

  func isAllowedToWriteWaterSamples() -> Bool {
    return healthKitStore.authorizationStatus(for: waterQuantityType) == .sharingAuthorized ||
           healthKitStore.authorizationStatus(for: caffeineQuantityType) == .sharingAuthorized
  }
  
  /// Saves water sample of intake to HealthKit
  fileprivate func saveWaterSampleOfIntake(_ intake: Intake, completion: ((_ success: Bool) -> Void)? = nil) {
    managedObjectContext?.perform { _ in
      if let waterSample = self.createWaterQuantitySampleFromIntake(intake) {
        self.healthKitStore.save(waterSample, withCompletion: { success, error in
          completion?(success)
        }) 
      }
    }
  }

  /// Saves caffeine sample of intake to HealthKit
  fileprivate func saveCaffeineSampleOfIntake(_ intake: Intake, completion: ((_ success: Bool) -> Void)? = nil) {
    managedObjectContext?.perform { _ in
      if let caffeineSample = self.createCaffeineQuantitySampleFromIntake(intake) {
        self.healthKitStore.save(caffeineSample, withCompletion: { success, error in
          completion?(success)
        }) 
      }
    }
  }
  
  fileprivate func createWaterQuantitySampleFromIntake(_ intake: Intake) -> HKQuantitySample? {
    guard let intakeId = getIntakeId(intake) else {
      return nil
    }
    
    let quantity = HKQuantity(unit: HKUnit.literUnit(with: .milli), doubleValue: intake.hydrationAmount)
    
    let metadata = [
      localizedStrings.metadataDrinkKeyTitle: intake.drink.localizedName,
      Constants.metadataIdentifierKey: intakeId]
    
    return HKQuantitySample(type: waterQuantityType, quantity: quantity, start: intake.date as Date, end: intake.date as Date, metadata: metadata)
  }

  fileprivate func createCaffeineQuantitySampleFromIntake(_ intake: Intake) -> HKQuantitySample? {
    if intake.caffeineAmount == 0 {
      return nil
    }
    
    guard let intakeId = getIntakeId(intake) else {
      return nil
    }
    
    let quantity = HKQuantity(unit: HKUnit.gramUnit(with: .milli), doubleValue: intake.caffeineAmount)
    
    let metadata = [
      localizedStrings.metadataDrinkKeyTitle: intake.drink.localizedName,
      Constants.metadataIdentifierKey: intakeId]
    
    return HKQuantitySample(type: caffeineQuantityType, quantity: quantity, start: intake.date as Date, end: intake.date as Date, metadata: metadata)
  }
  
  /// Removes sample of intake from HealthKit
  fileprivate func removeSampleOfIntake(_ intake: Intake, sample: String, completion: (() -> Void)?) {
    guard let sampleType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: sample)) else {
      return
    }
    
    guard let intakeId = getIntakeId(intake) else {
      return
    }
    
    let predicate = HKQuery.predicateForObjects(withMetadataKey: Constants.metadataIdentifierKey, allowedValues: [intakeId])
    
    healthKitStore.deleteObjects(of: sampleType, predicate: predicate) { success, deletedObjectCount, error in
      completion?()
    }
  }
  
  /// Updates water intake in HealthKit, actually removes an old sample object related to the intake and saves a new one.
  fileprivate func updateWaterIntake(_ intake: Intake) {
    removeSampleOfIntake(intake, sample: HKQuantityTypeIdentifier.dietaryWater.rawValue) {
      self.saveWaterSampleOfIntake(intake)
    }
    
    removeSampleOfIntake(intake, sample: HKQuantityTypeIdentifier.dietaryCaffeine.rawValue) {
      self.saveCaffeineSampleOfIntake(intake)
    }
  }

  fileprivate func getIntakeId(_ intake: Intake) -> String? {
    return intake.objectID.uriRepresentation().lastPathComponent
  }
  
  // MARK: Synchronization with CoreData
  
  func contextDidSaveContext(_ notification: Notification) {
    if !Settings.sharedInstance.healthKitWaterIntakesIntegrationIsAllowed2.value {
      return
    }
    
    authorizeHealthKit { authorized, _ in
      if authorized {
        self.synchronizeWithHealthKit(notification)
      }
    }
  }
  
  fileprivate func synchronizeWithHealthKit(_ notification: Notification) {
    managedObjectContext?.perform {
      // Delete intakes from HealthKit
      if let deletedObjects = (notification as NSNotification).userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject> {
        for deletedObject in deletedObjects where deletedObject is Intake {
          self.removeSampleOfIntake(deletedObject as! Intake, sample: HKQuantityTypeIdentifier.dietaryWater.rawValue, completion: nil)
          self.removeSampleOfIntake(deletedObject as! Intake, sample: HKQuantityTypeIdentifier.dietaryCaffeine.rawValue, completion: nil)
        }
      }
      
      // Insert intakes to HealthKit
      if let insertedObjects = (notification as NSNotification).userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> {
        for insertedObject in insertedObjects where insertedObject is Intake {
          self.saveWaterSampleOfIntake(insertedObject as! Intake)
          self.saveCaffeineSampleOfIntake(insertedObject as! Intake)
        }
      }
      
      // Update intakes in HealthKit
      if let updatedObjects = (notification as NSNotification).userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
        for updatedObject in updatedObjects where updatedObject is Intake {
          self.updateWaterIntake(updatedObject as! Intake)
        }
      }
    }
  }
  
}
