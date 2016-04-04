//
//  SettingItems.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 04.02.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import Foundation

/// Generic class allows its clients to add/remove observers and notify them
class ObservableSettingsItem<ValueType>: ObservationRemover {

  typealias ObserverFunction = (ValueType) -> ()
  
  private var observerIdentifier: Int
  private var observerFunctions: [Int: ObserverFunction]
  private let identifierQueue: dispatch_queue_t
  
  // Value initialization was moved to init() in order to solve Swift 2.2 bug on iOS7
  // More details here https://bugs.swift.org/browse/SR-815
  init() {
    observerIdentifier = 0
    observerFunctions = [:]
    identifierQueue = dispatch_queue_create("com.devmanifest.Aquaz.ObservableSettingsItem.identifierQueue", DISPATCH_QUEUE_SERIAL)
  }
  
  /// Adds an observer and returns its smart wrapper which removes the observation on deinitialization.
  /// It is preferrable way to use observation.
  func addObserver(observerFunction: ObserverFunction) -> SettingsObserver {
    let observerIdentifier = internalAddObserver(observerFunction)
    return SettingsObserver(observerIdentifier: observerIdentifier, observationRemover: self)
  }
  
  /// Adds an observer and returns its unique identifier (in a scope of class instance)
  /// Should not be used directly in the most of cases.
  private func internalAddObserver(observerFunction: ObserverFunction) -> Int {
    var addedObserverIdentifier: Int!
    
    dispatch_sync(identifierQueue) {
      addedObserverIdentifier = self.observerIdentifier
      self.observerIdentifier += 1
      self.observerFunctions[addedObserverIdentifier] = observerFunction
    }
    
    return addedObserverIdentifier
  }
  
  /// Removes an observer using its identifier. Should not be used directly in the most of cases.
  internal func internalRemoveObserver(removedObserverIdentifier: Int) {
    dispatch_sync(identifierQueue) {
      assert(self.observerFunctions.indexForKey(removedObserverIdentifier) != nil, "Passed observer's identifier is not found")
      self.observerFunctions.removeValueForKey(removedObserverIdentifier)
    }
  }

  /// Notifies all observers
  private func notify(value: ValueType) {
    for (_, observerFunction) in observerFunctions {
      observerFunction(value)
    }
  }
  
  deinit {
    assert(observerFunctions.isEmpty, "There are \(observerFunctions.count) unremoved observers for observable settings item")
  }
  
}

class SettingsObserver {
  
  let observerIdentifier: Int
  private let observationRemover: ObservationRemover
  
  init(observerIdentifier: Int, observationRemover: ObservationRemover) {
    self.observerIdentifier = observerIdentifier
    self.observationRemover = observationRemover
  }
  
  deinit {
    observationRemover.internalRemoveObserver(observerIdentifier)
  }
  
}

protocol ObservationRemover : class {
  
  func internalRemoveObserver(removedObserverIdentifier: Int)
  
}


/// Generic class for settings item. Automatically writes changes of a value to user defaults. Provides possibility to observe changes of a value by observers.
class SettingsItemBase<ValueType: Equatable>: ObservableSettingsItem<ValueType> {

  // MARK: Properties
  
  let key: String
  
  // Value initialization was moved to init() in order to solve Swift 2.2 bug on iOS7
  // More details here https://bugs.swift.org/browse/SR-815
  private let valueQueue: dispatch_queue_t
  
  var value: ValueType {
    get {
      var outputValue: ValueType!
      
      dispatch_sync(valueQueue) {
        outputValue = self.rawValue
      }
      
      return outputValue
    }
    set {
      dispatch_sync(valueQueue) {
        if (newValue == self.rawValue) {
          return
        }
        
        self.rawValue = newValue
      }
      
      writeValue(newValue)
      userDefaults.synchronize()
      notify(newValue)
    }
  }

  var keyValuePair: (key: String, value: AnyObject)? {
    if let value = userDefaults.objectForKey(key) {
      return (key: key, value: value)
    }
    
    return nil
  }
  
  private let userDefaults: NSUserDefaults
  private let initialValue: ValueType
  private var rawValue: ValueType

  // MARK: Methods
  
  convenience init(key: String, initialValue: ValueType) {
    self.init(key: key, initialValue: initialValue, userDefaults: NSUserDefaults.standardUserDefaults())
  }
  
  init(key: String, initialValue: ValueType, userDefaults: NSUserDefaults) {
    valueQueue = dispatch_queue_create("com.devmanifest.Aquaz.SettingsItemBase.valueQueue", DISPATCH_QUEUE_SERIAL)
    rawValue = initialValue
    
    self.key = key
    self.initialValue = initialValue
    self.userDefaults = userDefaults
    
    super.init()
    
    if (!readFromUserDefaults(sendNotification: false)) {
      // Initialize the setting item in the user defaults
      writeToUserDefaults()
    }
  }
  
  /// Reads the value from user defaults
  func readFromUserDefaults(sendNotification sendNotification: Bool) -> Bool {
    var success: Bool!
    var oldValue: ValueType!
    var newValue: ValueType!
    
    dispatch_sync(valueQueue) {
      oldValue = self.rawValue
      success = self.readValue(&self.rawValue)
      newValue = self.rawValue
    }

    if newValue != oldValue && sendNotification {
      notify(newValue)
    }
    
    return success
  }
  
  /// Write the value to user defaults
  func writeToUserDefaults() {
    writeValue(rawValue)
  }
  
  /// Removes the value from user defaults
  func removeFromUserDefaults() {
    dispatch_sync(valueQueue) {
      self.userDefaults.removeObjectForKey(self.key)
      self.rawValue = self.initialValue
    }
  }
  
  private func readValue(inout outValue: ValueType) -> Bool {
    assert(false, "readValue function must be overriden")
    return false
  }
  
  private func writeValue(value: ValueType) {
    assert(false, "writeValue function must be overriden")
  }
  
}

/// Settings item class for enumerations
class SettingsEnumItem<T: RawRepresentable where T: Equatable, T.RawValue == Int>: SettingsItemBase<T> {
  
  convenience init(key: String, initialValue: T) {
    self.init(key: key, initialValue: initialValue, userDefaults: NSUserDefaults.standardUserDefaults())
  }
  
  override init(key: String, initialValue: T, userDefaults: NSUserDefaults) {
    super.init(key: key, initialValue: initialValue, userDefaults: userDefaults)
  }
  
  private override func readValue(inout outValue: T) -> Bool {
    if let rawValue = userDefaults.objectForKey(key) as? T.RawValue {
      if let value = T(rawValue: rawValue) {
        outValue = value
        return true
      }
    }
    
    return false
  }
  
  private override func writeValue(value: T) {
    userDefaults.setInteger(value.rawValue, forKey: key)
  }
  
}

/// Settings item class for ordinal types (Int, Bool etc.)
class SettingsOrdinalItem<T: Equatable>: SettingsItemBase<T> {
  
  convenience init(key: String, initialValue: T) {
    self.init(key: key, initialValue: initialValue, userDefaults: NSUserDefaults.standardUserDefaults())
  }
  
  override init(key: String, initialValue: T, userDefaults: NSUserDefaults) {
    super.init(key: key, initialValue: initialValue, userDefaults: userDefaults)
  }
  
  private override func readValue(inout outValue: T) -> Bool {
    if let value = userDefaults.objectForKey(key) as? T {
      outValue = value
      return true
    }
    
    return false
  }
  
  private override func writeValue(value: T) {
    switch value {
    case let value as Float:  userDefaults.setFloat  (value, forKey: key)
    case let value as Double: userDefaults.setDouble (value, forKey: key)
    case let value as Int:    userDefaults.setInteger(value, forKey: key)
    case let value as Bool:   userDefaults.setBool   (value, forKey: key)
    case let value as String: userDefaults.setValue  (value, forKey: key)
    case let value as NSDate: userDefaults.setObject (value, forKey: key)
    default: super.writeValue(value)
    }
  }
  
}