//
//  SettingsTests.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 04.02.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit
import XCTest

class SettingsTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testOrdinalItem<T: Equatable>(#key: String, initialValue: T, testValue: T) {
    if let userDefaults = NSUserDefaults(suiteName: "SettingsTests") {
      let settingItem = SettingsOrdinalItem<T>(key: key, initialValue: initialValue, userDefaults: userDefaults)
      settingItem.removeFromUserDefaults()
      XCTAssert(settingItem.value == initialValue, "\(key) setting item is unproperly initialized with value \(initialValue)")
      
      settingItem.value = testValue
      XCTAssert(settingItem.value == testValue, "\(key) setting item has an error with setting a value (\(testValue))")
      
      let settingItemCopy = SettingsOrdinalItem<T>(key: key, initialValue: initialValue, userDefaults: userDefaults)
      XCTAssert(settingItemCopy.value == testValue, "\(key) setting item has an error with writing a value (\(testValue))")
    } else {
      XCTFail("Unable to create user defaults with name SettingsTests")
    }
  }
  
  func testFloat() {
    testOrdinalItem(key: "Float", initialValue: Float(99.99), testValue: -99.99)
  }
  
  func testDouble() {
    testOrdinalItem(key: "Double", initialValue: Double(99.99), testValue: -99.99)
  }
  
  func testInt() {
    testOrdinalItem(key: "Int", initialValue: Int(99), testValue: -99)
  }
  
  func testBool() {
    testOrdinalItem(key: "Bool", initialValue: true, testValue: false)
  }
  
  func testString() {
    testOrdinalItem(key: "String", initialValue: "initial", testValue: "test")
  }
  
  func testNSDate() {
    testOrdinalItem(key: "NSDate", initialValue: NSDate(), testValue: NSDate(timeIntervalSinceNow: 60 * 60 * 24))
  }
  
  func testEnumSettings() {
    enum TestEnum: Int {
      case One = 0
      case Two
      case Three
    }
    
    if let userDefaults = NSUserDefaults(suiteName: "SettingsTests") {
      let key = "TestEnum"
      let initialValue: TestEnum = .Two
      let settingItem = SettingsEnumItem<TestEnum>(key: key, initialValue: initialValue, userDefaults: userDefaults)
      settingItem.removeFromUserDefaults()
      XCTAssert(settingItem.value == initialValue, "\(key) setting item is unproperly initialized with value \(initialValue)")
      
      let testValue: TestEnum = .Three
      settingItem.value = testValue
      XCTAssert(settingItem.value == testValue, "\(key) setting item has an error with setting a value (\(testValue))")
      
      let settingItemCopy = SettingsEnumItem<TestEnum>(key: key, initialValue: initialValue, userDefaults: userDefaults)
      XCTAssert(settingItemCopy.value == testValue, "\(key) setting item has an error with writing a value (\(testValue))")
    } else {
      XCTFail("Unable to create user defaults with name SettingsTests")
    }
  }
  
}
