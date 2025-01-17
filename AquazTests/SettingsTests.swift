//
//  SettingsTests.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 04.02.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit
import XCTest
@testable import AquazPro

class SettingsTests: XCTestCase {
  
  lazy var userDefaults: UserDefaults = UserDefaults(suiteName: "SettingsTests")!
  
  func testOrdinalItem<T: Equatable>(key: String, initialValue: T, testValue: T) {
    let settingItem = SettingsOrdinalItem<T>(key: key, initialValue: initialValue, userDefaults: userDefaults)
    settingItem.removeFromUserDefaults()
    XCTAssert(settingItem.value == initialValue, "\(key) setting item is unproperly initialized with value \(initialValue)")
    
    settingItem.value = testValue
    XCTAssert(settingItem.value == testValue, "\(key) setting item has an error with setting a value (\(testValue))")
    
    // Make a copy of the setting, it's supposed that previous value should be read from the user defaults not the initial value.
    let settingItemCopy = SettingsOrdinalItem<T>(key: key, initialValue: initialValue, userDefaults: userDefaults)
    XCTAssert(settingItemCopy.value == testValue, "\(key) setting item has an error with writing a value (\(testValue))")
  }
  
  func testFloat() {
    for _ in 0..<100 {
      testOrdinalItem(key: "Float", initialValue: Float(99.99), testValue: -99.99)
    }
  }
  
  func testDouble() {
    for _ in 0..<100 {
      testOrdinalItem(key: "Double", initialValue: Double(99.99), testValue: -99.99)
    }
  }
  
  func testInt() {
    for _ in 0..<100 {
      testOrdinalItem(key: "Int", initialValue: Int(99), testValue: -99)
    }
  }
  
  func testBool() {
    for _ in 0..<100 {
      testOrdinalItem(key: "Bool", initialValue: true, testValue: false)
    }
  }
  
  func testString() {
    for _ in 0..<100 {
      testOrdinalItem(key: "String", initialValue: "initial", testValue: "test")
    }
  }
  
  func testNSDate() {
    for _ in 0..<100 {
      testOrdinalItem(key: "NSDate", initialValue: Date(), testValue: Date(timeIntervalSinceNow: 60 * 60 * 24))
    }
  }
  
  func testEnumSettings() {
    enum TestEnum: Int {
      case one = 0
      case two
      case three
    }
    
    let key = "TestEnum"
    let initialValue: TestEnum = .two
    let settingItem = SettingsEnumItem<TestEnum>(key: key, initialValue: initialValue, userDefaults: userDefaults)
    settingItem.removeFromUserDefaults()
    XCTAssert(settingItem.value == initialValue, "\(key) setting item is unproperly initialized with value \(initialValue)")
    
    let testValue: TestEnum = .three
    settingItem.value = testValue
    XCTAssert(settingItem.value == testValue, "\(key) setting item has an error with setting a value (\(testValue))")
    
    let settingItemCopy = SettingsEnumItem<TestEnum>(key: key, initialValue: initialValue, userDefaults: userDefaults)
    XCTAssert(settingItemCopy.value == testValue, "\(key) setting item has an error with writing a value (\(testValue))")
  }
  
}
