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
  
  fileprivate var observerIdentifier: Int
  fileprivate var observerFunctions: [Int: ObserverFunction]
  fileprivate let identifierQueue: DispatchQueue
  
  // Value initialization was moved to init() in order to solve Swift 2.2 bug on iOS7
  // More details here https://bugs.swift.org/browse/SR-815
  init() {
    observerIdentifier = 0
    observerFunctions = [:]
    identifierQueue = DispatchQueue(label: "com.devmanifest.Aquaz.ObservableSettingsItem.identifierQueue", attributes: [])
  }
  
  /// Adds an observer and returns its smart wrapper which removes the observation on deinitialization.
  /// It is preferrable way to use observation.
  func addObserver(_ observerFunction: @escaping ObserverFunction) -> SettingsObserver {
    let observerIdentifier = internalAddObserver(observerFunction)
    return SettingsObserver(observerIdentifier: observerIdentifier, observationRemover: self)
  }
  
  /// Adds an observer and returns its unique identifier (in a scope of class instance)
  /// Should not be used directly in the most of cases.
  fileprivate func internalAddObserver(_ observerFunction: @escaping ObserverFunction) -> Int {
    var addedObserverIdentifier: Int!
    
    identifierQueue.sync {
      addedObserverIdentifier = self.observerIdentifier
      self.observerIdentifier += 1
      self.observerFunctions[addedObserverIdentifier] = observerFunction
    }
    
    return addedObserverIdentifier
  }
  
  /// Removes an observer using its identifier. Should not be used directly in the most of cases.
  internal func internalRemoveObserver(_ removedObserverIdentifier: Int) {
    identifierQueue.sync {
      assert(self.observerFunctions.index(forKey: removedObserverIdentifier) != nil, "Passed observer's identifier is not found")
      self.observerFunctions.removeValue(forKey: removedObserverIdentifier)
    }
  }

  /// Notifies all observers
  fileprivate func notify(_ value: ValueType) {
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
  fileprivate let observationRemover: ObservationRemover
  
  init(observerIdentifier: Int, observationRemover: ObservationRemover) {
    self.observerIdentifier = observerIdentifier
    self.observationRemover = observationRemover
  }
  
  deinit {
    observationRemover.internalRemoveObserver(observerIdentifier)
  }
  
}

protocol ObservationRemover : class {
  
  func internalRemoveObserver(_ removedObserverIdentifier: Int)
  
}


/// Generic class for settings item. Automatically writes changes of a value to user defaults. Provides possibility to observe changes of a value by observers.
class SettingsItemBase<ValueType: Equatable>: ObservableSettingsItem<ValueType> {

  // MARK: Properties
  
  let key: String
  
  // Value initialization was moved to init() in order to solve Swift 2.2 bug on iOS7
  // More details here https://bugs.swift.org/browse/SR-815
  fileprivate let valueQueue: DispatchQueue
  
  var value: ValueType {
    get {
      var outputValue: ValueType!
      
      valueQueue.sync {
        outputValue = self.rawValue
      }
      
      return outputValue
    }
    set {
      valueQueue.sync {
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

  var keyValuePair: (key: String, value: Any)? {
    if let value = userDefaults.object(forKey: key) {
      return (key: key, value: value)
    }
    
    return nil
  }
  
  fileprivate let userDefaults: UserDefaults
  fileprivate let initialValue: ValueType
  fileprivate var rawValue: ValueType

  // MARK: Methods
  
  convenience init(key: String, initialValue: ValueType) {
    self.init(key: key, initialValue: initialValue, userDefaults: UserDefaults.standard)
  }
  
  init(key: String, initialValue: ValueType, userDefaults: UserDefaults) {
    valueQueue = DispatchQueue(label: "com.devmanifest.Aquaz.SettingsItemBase.valueQueue", attributes: [])
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
  func readFromUserDefaults(sendNotification: Bool) -> Bool {
    var success: Bool!
    var oldValue: ValueType!
    var newValue: ValueType!
    
    valueQueue.sync {
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
    valueQueue.sync {
      self.userDefaults.removeObject(forKey: self.key)
      self.rawValue = self.initialValue
    }
  }
  
  fileprivate func readValue(_ outValue: inout ValueType) -> Bool {
    assert(false, "readValue function must be overriden")
    return false
  }
  
  fileprivate func writeValue(_ value: ValueType) {
    assert(false, "writeValue function must be overriden")
  }
  
}

/// Settings item class for enumerations
class SettingsEnumItem<T: RawRepresentable>: SettingsItemBase<T> where T: Equatable, T.RawValue == Int {
  
  convenience init(key: String, initialValue: T) {
    self.init(key: key, initialValue: initialValue, userDefaults: UserDefaults.standard)
  }
  
  override init(key: String, initialValue: T, userDefaults: UserDefaults) {
    super.init(key: key, initialValue: initialValue, userDefaults: userDefaults)
  }
  
  fileprivate override func readValue(_ outValue: inout T) -> Bool {
    if let rawValue = userDefaults.object(forKey: key) as? T.RawValue {
      if let value = T(rawValue: rawValue) {
        outValue = value
        return true
      }
    }
    
    return false
  }
  
  fileprivate override func writeValue(_ value: T) {
    userDefaults.set(value.rawValue, forKey: key)
  }
  
}

/// Settings item class for ordinal types (Int, Bool etc.)
class SettingsOrdinalItem<T: Equatable>: SettingsItemBase<T> {
  
  convenience init(key: String, initialValue: T) {
    self.init(key: key, initialValue: initialValue, userDefaults: UserDefaults.standard)
  }
  
  override init(key: String, initialValue: T, userDefaults: UserDefaults) {
    super.init(key: key, initialValue: initialValue, userDefaults: userDefaults)
  }
  
  fileprivate override func readValue(_ outValue: inout T) -> Bool {
    if let value = userDefaults.object(forKey: key) as? T {
      outValue = value
      return true
    }
    
    return false
  }
  
  fileprivate override func writeValue(_ value: T) {
    switch value {
    case let value as Float:  userDefaults.set  (value, forKey: key)
    case let value as Double: userDefaults.set (value, forKey: key)
    case let value as Int:    userDefaults.set(value, forKey: key)
    case let value as Bool:   userDefaults.set   (value, forKey: key)
    case let value as String: userDefaults.setValue  (value, forKey: key)
    case let value as Date: userDefaults.set (value, forKey: key)
    default: super.writeValue(value)
    }
  }
  
}
