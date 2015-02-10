//
//  UnitsTests.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 06.02.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit
import XCTest
import Aquaz

class UnitsTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  private func testQuantityDoubleConversion<From: Unit, To: Unit>(#amount: Double, accuracy: Double, from fromUnit: From, to toUnit: To) {
    let from = Quantity(unit: fromUnit, amount: amount)
    let to = Quantity(unit: toUnit)
    to.convertFrom(quantity: from)
    let check = Quantity(unit: fromUnit)
    check.convertFrom(quantity: to)
    XCTAssertEqualWithAccuracy(from.amount, check.amount, accuracy, "Double conversion test is failed: Unit type is \(from.unit.type.description), conversion from \(from.unit.contraction) to \(to.unit.contraction), amount \(amount)")
  }
  
  private func testConversion<From: Unit, To: Unit>(#fromAmount: Double, expectedAmount: Double, accuracy: Double, from fromUnit: From, to toUnit: To) {
    let from = Quantity(unit: fromUnit, amount: fromAmount)
    let to = Quantity(ownUnit: toUnit, fromQuantity: from)
    XCTAssertEqualWithAccuracy(to.amount, expectedAmount, accuracy, "Conversion test is failed: \(from.amount) \(from.unit.contraction) is converted to \(to.amount) \(to.unit.contraction). It should be \(expectedAmount) \(to.unit.contraction)")
  }
  
  func testVolumeUnits() {
    // Double conversions
    testQuantityDoubleConversion(amount: 0,       accuracy: 0.01, from: MilliliterUnit(), to: FluidOunceUnit())
    testQuantityDoubleConversion(amount: 999.99,  accuracy: 0.01, from: MilliliterUnit(), to: FluidOunceUnit())
    testQuantityDoubleConversion(amount: -999.99, accuracy: 0.01, from: MilliliterUnit(), to: FluidOunceUnit())
    
    testQuantityDoubleConversion(amount: 0,       accuracy: 0.01, from: FluidOunceUnit(), to: MilliliterUnit())
    testQuantityDoubleConversion(amount: 999.99,  accuracy: 0.01, from: FluidOunceUnit(), to: MilliliterUnit())
    testQuantityDoubleConversion(amount: -999.99, accuracy: 0.01, from: FluidOunceUnit(), to: MilliliterUnit())
    
    // Single conversions
    testConversion(fromAmount:  999.99, expectedAmount:  33.813685,    accuracy: 0.000001, from: MilliliterUnit(), to: FluidOunceUnit())
    testConversion(fromAmount: -999.99, expectedAmount: -33.813685,    accuracy: 0.000001, from: MilliliterUnit(), to: FluidOunceUnit())

    testConversion(fromAmount:  999.99, expectedAmount:  29573.233827, accuracy: 0.000001, from: FluidOunceUnit(), to: MilliliterUnit())
    testConversion(fromAmount: -999.99, expectedAmount: -29573.233827, accuracy: 0.000001, from: FluidOunceUnit(), to: MilliliterUnit())
  }

  func testWeightUnits() {
    // Double conversions
    testQuantityDoubleConversion(amount: 0,       accuracy: 0.01, from: KilogramUnit(), to: PoundUnit())
    testQuantityDoubleConversion(amount: 999.99,  accuracy: 0.01, from: KilogramUnit(), to: PoundUnit())
    testQuantityDoubleConversion(amount: -999.99, accuracy: 0.01, from: KilogramUnit(), to: PoundUnit())
    
    testQuantityDoubleConversion(amount: 0,       accuracy: 0.01, from: PoundUnit(), to: KilogramUnit())
    testQuantityDoubleConversion(amount: 999.99,  accuracy: 0.01, from: PoundUnit(), to: KilogramUnit())
    testQuantityDoubleConversion(amount: -999.99, accuracy: 0.01, from: PoundUnit(), to: KilogramUnit())

    // Single conversions
    testConversion(fromAmount:  999.99, expectedAmount:  2204.600576, accuracy: 0.000001, from: KilogramUnit(), to: PoundUnit())
    testConversion(fromAmount: -999.99, expectedAmount: -2204.600576, accuracy: 0.000001, from: KilogramUnit(), to: PoundUnit())
    
    testConversion(fromAmount:  999.99, expectedAmount:  453.587834,  accuracy: 0.000001, from: PoundUnit(), to: KilogramUnit())
    testConversion(fromAmount: -999.99, expectedAmount: -453.587834,  accuracy: 0.000001, from: PoundUnit(), to: KilogramUnit())
  }
  
  func testLengthUnits() {
    // Double conversions
    testQuantityDoubleConversion(amount: 0,       accuracy: 0.01, from: CentimeterUnit(), to: FootUnit())
    testQuantityDoubleConversion(amount: 999.99,  accuracy: 0.01, from: CentimeterUnit(), to: FootUnit())
    testQuantityDoubleConversion(amount: -999.99, accuracy: 0.01, from: CentimeterUnit(), to: FootUnit())
    
    testQuantityDoubleConversion(amount: 0,       accuracy: 0.01, from: FootUnit(), to: CentimeterUnit())
    testQuantityDoubleConversion(amount: 999.99,  accuracy: 0.01, from: FootUnit(), to: CentimeterUnit())
    testQuantityDoubleConversion(amount: -999.99, accuracy: 0.01, from: FootUnit(), to: CentimeterUnit())
    
    // Single conversions
    testConversion(fromAmount:  999.99, expectedAmount:  32.808071,  accuracy: 0.000001, from: CentimeterUnit(), to: FootUnit())
    testConversion(fromAmount: -999.99, expectedAmount: -32.808071,  accuracy: 0.000001, from: CentimeterUnit(), to: FootUnit())
    
    testConversion(fromAmount:  999.99, expectedAmount:  30479.6952, accuracy: 0.0001,   from: FootUnit(), to: CentimeterUnit())
    testConversion(fromAmount: -999.99, expectedAmount: -30479.6952, accuracy: 0.0001,   from: FootUnit(), to: CentimeterUnit())
  }
  
}
