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

  // MARK: Types
  fileprivate struct LocalizedStrings {
    lazy var metadataDrinkKeyTitle = NSLocalizedString("HKP:Drink", value: "Drink", comment: "HealthKitProvider: Title for metadata key (Drink) used in Health app")
  }

  fileprivate struct Constants {
    static let metadataIdentifierKey = "Intake Identifier"
  }

  
  // MARK: Properties
  static let sharedInstance = HealthKitProvider()
  
  fileprivate let healthKitStore = HKHealthStore()
  
  fileprivate var localizedStrings = LocalizedStrings()
  
  fileprivate let waterQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryWater)!

  fileprivate let caffeineQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCaffeine)!
  
  var waterSharingIsAuthorized: Bool {
    return healthKitStore.authorizationStatus(for: waterQuantityType) == .sharingAuthorized
  }

  var caffeineSharingIsAuthorized: Bool {
    return healthKitStore.authorizationStatus(for: caffeineQuantityType) == .sharingAuthorized
  }

  override init() {
    super.init()
    
    CoreDataStack.performOnPrivateContext { managedObjectContext in
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(self.contextDidSaveContext(_:)),
        name: NSNotification.Name.NSManagedObjectContextDidSave,
        object: managedObjectContext)
    }
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  /// Asks HealthKit for authorization, executes completion closure as a result
  func authorizeHealthKit(_ completion: @escaping (_ authorized: Bool, _ error: NSError?) -> Void) {
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
    let typesToShare: Set<HKSampleType> = [waterQuantityType, caffeineQuantityType]
    
    healthKitStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { authorized, error in
      completion(authorized, error as NSError?)
    }
  }
  
  /// Exports all intakes into HealthKit, all old samples in HealthKit will be deleted.
  func exportAllIntakesToHealthKit(progress: @escaping (_ current: Int, _ maximum: Int) -> Void, completion: @escaping () -> Void) {
    let dispatchGroup = DispatchGroup()
    // Just some minor optimizations
    let localWaterSharingIsAuthorized = waterSharingIsAuthorized
    let localCaffeineSharingIsAuthorized = caffeineSharingIsAuthorized
    
    // Remove water samples from Apple Health
    if localWaterSharingIsAuthorized {
      dispatchGroup.enter()

      let predicate = HKQuery.predicateForSamples(withStart: nil, end: nil, options: HKQueryOptions())

      healthKitStore.deleteObjects(of: waterQuantityType, predicate: predicate) { success, deletedObjectCount, error in
        dispatchGroup.leave()
      }
      
      _ = dispatchGroup.wait(timeout: .distantFuture)
    }

    // Remove caffeine samples from Apple Health
    if localCaffeineSharingIsAuthorized {
      dispatchGroup.enter()
      
      let predicate = HKQuery.predicateForSamples(withStart: nil, end: nil, options: HKQueryOptions())
      
      healthKitStore.deleteObjects(of: caffeineQuantityType, predicate: predicate) { success, deletedObjectCount, error in
        dispatchGroup.leave()
      }
      
      _ = dispatchGroup.wait(timeout: .distantFuture)
    }

    // Add samples to Apple Health
    var samplesToSave = [HKQuantitySample]()
    
    CoreDataStack.performOnPrivateContextAndWait { privateContext in
      let intakes = Intake.fetchIntakes(beginDate: nil, endDate: nil, managedObjectContext: privateContext)
      
      for intake in intakes {
        if localWaterSharingIsAuthorized, let waterSample = self.createWaterQuantitySampleFromIntake(intake) {
          samplesToSave.append(waterSample)
        }
        
        if localCaffeineSharingIsAuthorized, let caffeineSample = self.createCaffeineQuantitySampleFromIntake(intake) {
          samplesToSave.append(caffeineSample)
        }
      }
    }
    
    progress(0, samplesToSave.count)
    
    let maxSamplesInPacket = 100
    var packetIndex = 0
    
    while true {
      let skippedSamples = packetIndex * maxSamplesInPacket
      let sliceToSave = samplesToSave.dropFirst(skippedSamples).prefix(maxSamplesInPacket) as ArraySlice<HKQuantitySample>
      
      if sliceToSave.isEmpty {
        break
      }
      
      packetIndex += 1
      
      dispatchGroup.enter()

      let packetToSave = Array<HKQuantitySample>(sliceToSave)
      
      healthKitStore.save(packetToSave, withCompletion: { success, error in
        progress(skippedSamples + sliceToSave.count, samplesToSave.count)
        dispatchGroup.leave()
      })

      _ = dispatchGroup.wait(timeout: .distantFuture)
    }
  
    completion()
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
  
  func requestNumberOfWaterSamples(_ completion: @escaping (_ count: Int) -> Void) {
    if !waterSharingIsAuthorized {
      return
    }
    
    let query = HKSampleQuery(sampleType: waterQuantityType, predicate: nil, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) { sampleQuery, samples, error in
      if error == nil {
        let count = samples?.count ?? 0
        completion(count)
      }
    }
    
    healthKitStore.execute(query)
  }

  func requestNumberOfCaffeineSamples(_ completion: @escaping (_ count: Int) -> Void) {
    if !caffeineSharingIsAuthorized {
      return
    }
    
    let query = HKSampleQuery(sampleType: caffeineQuantityType, predicate: nil, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) { sampleQuery, samples, error in
      if error == nil {
        let count = samples?.count ?? 0
        completion(count)
      }
    }
    
    healthKitStore.execute(query)
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
  
  /// Saves water sample of intake to HealthKit
  fileprivate func saveWaterSampleOfIntake(_ intake: Intake, completion: ((_ success: Bool) -> Void)? = nil) {
    if let waterSample = createWaterQuantitySampleFromIntake(intake) {
      healthKitStore.save(waterSample, withCompletion: { success, error in
        completion?(success)
      }) 
    }
  }

  /// Saves caffeine sample of intake to HealthKit
  fileprivate func saveCaffeineSampleOfIntake(_ intake: Intake, completion: ((_ success: Bool) -> Void)? = nil) {
      if let caffeineSample = createCaffeineQuantitySampleFromIntake(intake) {
        healthKitStore.save(caffeineSample, withCompletion: { success, error in
          completion?(success)
        }) 
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
  
  /// Updates water sample of intake in HealthKit, actually removes an old sample object related to the intake and saves a new one.
  fileprivate func updateWaterSampleOfIntake(_ intake: Intake) {
    removeSampleOfIntake(intake, sample: HKQuantityTypeIdentifier.dietaryWater.rawValue) {
      self.saveWaterSampleOfIntake(intake)
    }
  }
  
  /// Updates caffeine sample of intake in HealthKit, actually removes an old sample object related to the intake and saves a new one.
  fileprivate func updateCaffeineSampleOfIntake(_ intake: Intake) {
    removeSampleOfIntake(intake, sample: HKQuantityTypeIdentifier.dietaryCaffeine.rawValue) {
      self.saveCaffeineSampleOfIntake(intake)
    }
  }
  
  fileprivate func getIntakeId(_ intake: Intake) -> String? {
    return intake.objectID.uriRepresentation().lastPathComponent
  }
  
  // MARK: Synchronization with CoreData
  
  @objc func contextDidSaveContext(_ notification: Notification) {
    let waterChangesAuthorized = healthKitStore.authorizationStatus(for: waterQuantityType) == .sharingAuthorized
    let caffeineChangesAuthorized = healthKitStore.authorizationStatus(for: caffeineQuantityType) == .sharingAuthorized
    
    if !waterChangesAuthorized && !caffeineChangesAuthorized {
      return
    }
    
    // Delete intakes from HealthKit
    if let deletedObjects = (notification as NSNotification).userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject> {
      for deletedObject in deletedObjects where deletedObject is Intake {
        if waterChangesAuthorized {
          self.removeSampleOfIntake(deletedObject as! Intake, sample: HKQuantityTypeIdentifier.dietaryWater.rawValue, completion: nil)
        }
        
        if caffeineChangesAuthorized {
          self.removeSampleOfIntake(deletedObject as! Intake, sample: HKQuantityTypeIdentifier.dietaryCaffeine.rawValue, completion: nil)
        }
      }
    }
    
    // Insert intakes to HealthKit
    if let insertedObjects = (notification as NSNotification).userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> {
      for insertedObject in insertedObjects where insertedObject is Intake {
        if waterChangesAuthorized {
          self.saveWaterSampleOfIntake(insertedObject as! Intake)
        }
        
        if caffeineChangesAuthorized {
          self.saveCaffeineSampleOfIntake(insertedObject as! Intake)
        }
      }
    }
    
    // Update intakes in HealthKit
    if let updatedObjects = (notification as NSNotification).userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
      for updatedObject in updatedObjects where updatedObject is Intake {
        if waterChangesAuthorized {
          self.updateWaterSampleOfIntake(updatedObject as! Intake)
        }
        
        if caffeineChangesAuthorized {
          self.updateCaffeineSampleOfIntake(updatedObject as! Intake)
        }
      }
    }
  }
  
}
