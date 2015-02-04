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
  
  func testFloatSettingItem() {
    NSUserDefaults.resetStandardUserDefaults()
    let initialValue: Float = 99.99
    let settingItem = SettingsOrdinalItem<Float>(key: "Float", initialValue: initialValue)
    XCTAssert(settingItem.value == initialValue, "Float setting item is unproperly initialized with value \(initialValue)")
    
    let testValue: Float = -99.99
    settingItem.value = testValue
    XCTAssert(settingItem.value == testValue, "Float setting item has an error with reading/writing a value (\(testValue))")
  }
  
  func testDoubleSettingItem() {
    NSUserDefaults.resetStandardUserDefaults()
    let initialValue: Double = 99.99
    let settingItem = SettingsOrdinalItem<Double>(key: "Double", initialValue: initialValue)
    XCTAssert(settingItem.value == initialValue, "Double setting item is unproperly initialized with value \(initialValue)")
    
    let testValue: Double = -99.99
    settingItem.value = testValue
    XCTAssert(settingItem.value == testValue, "Double setting item has an error with reading/writing a value (\(testValue))")
  }
  
  func testEnumSettings() {
  }
  
}
