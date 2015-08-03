//
//  SettingItems.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 04.02.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import Foundation

/// Generic class allows its clients to add/remove observers and notify them
class ObservableSettingsItem<ValueType>: ObservationRemover {

  typealias ObserverFunction = (ValueType) -> ()
  
  /// Adds an observer and returns its smart wrapper which removes the observation on deinitialization.
  /// It is preferrable way to use observation.
  func addObserver(observerFunction: ObserverFunction) -> SettingsObserver {
    let observerIdentifier = internalAddObserver(observerFunction)
    return SettingsObserver(observerIdentifier: observerIdentifier, observationRemover: self)
  }
  
  /// Adds an observer and returns its unique identifier (in a scope of class instance)
  /// Should not be used directly in the most of cases.
  func internalAddObserver(observerFunction: ObserverFunction) -> Int {
    observerFunctions[observerIdentifier] = observerFunction
    return observerIdentifier++
  }
  
  /// Removes an observer using its identifier. Should not be used directly in the most of cases.
  func internalRemoveObserver(observerIdentifier: Int) {
    assert(observerFunctions.indexForKey(observerIdentifier) != nil, "Passed observer's identifier is not found")
    observerFunctions.removeValueForKey(observerIdentifier)
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
  
  private var observerIdentifier = 0
  private var observerFunctions: [Int: ObserverFunction] = [:]
  
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
  
  func internalRemoveObserver(observerIdentifier: Int)
  
}


/// Generic class for settings item. Automatically writes changes of a value to user defaults. Provides possibility to observe changes of a value by observers.
public class SettingsItemBase<ValueType>: ObservableSettingsItem<ValueType> {
  
  let key: String
  let userDefaults: NSUserDefaults
  let initialValue: ValueType
  
  public var value: ValueType {
    didSet {
      writeValue(value)
      notify(value)
      userDefaults.synchronize()
    }
  }
  
  public convenience init(key: String, initialValue: ValueType) {
    self.init(key: key, initialValue: initialValue, userDefaults: NSUserDefaults.standardUserDefaults())
  }
  
  public init(key: String, initialValue: ValueType, userDefaults: NSUserDefaults) {
    self.value = initialValue
    self.key = key
    self.initialValue = initialValue
    self.userDefaults = userDefaults
    
    super.init()
    
    readFromUserDefaults()
  }
  
  /// Reads the value from user defaults
  public func readFromUserDefaults() {
    readValue(&value)
  }
  
  /// Write the value to user defaults
  public func writeToUserDefaults() {
    writeValue(value)
  }
  
  /// Removes the value from user defaults
  public func removeFromUserDefaults() {
    userDefaults.removeObjectForKey(key)
    value = initialValue
  }
  
  private func readValue(inout outValue: ValueType) {
    assert(false, "readValue function must be overriden")
  }
  
  private func writeValue(value: ValueType) {
    assert(false, "writeValue function must be overriden")
  }
  
}

/// Settings item class for enumerations
public class SettingsEnumItem<T: RawRepresentable where T.RawValue == Int>: SettingsItemBase<T> {
  
  public convenience init(key: String, initialValue: T) {
    self.init(key: key, initialValue: initialValue, userDefaults: NSUserDefaults.standardUserDefaults())
  }
  
  public override init(key: String, initialValue: T, userDefaults: NSUserDefaults) {
    super.init(key: key, initialValue: initialValue, userDefaults: userDefaults)
  }
  
  private override func readValue(inout outValue: T) {
    if let rawValue = userDefaults.objectForKey(key) as? T.RawValue {
      if let value = T(rawValue: rawValue) {
        outValue = value
      }
    }
  }
  
  private override func writeValue(value: T) {
    userDefaults.setInteger(value.rawValue, forKey: key)
  }
  
}

/// Settings item class for ordinal types (Int, Bool etc.)
public class SettingsOrdinalItem<T>: SettingsItemBase<T> {
  
  public convenience init(key: String, initialValue: T) {
    self.init(key: key, initialValue: initialValue, userDefaults: NSUserDefaults.standardUserDefaults())
  }
  
  public override init(key: String, initialValue: T, userDefaults: NSUserDefaults) {
    super.init(key: key, initialValue: initialValue, userDefaults: userDefaults)
  }
  
  private override func readValue(inout outValue: T) {
    if let value = userDefaults.objectForKey(key) as? T {
      outValue = value
    }
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