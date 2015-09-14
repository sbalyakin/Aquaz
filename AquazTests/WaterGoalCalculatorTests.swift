//
//  WaterGoalCalculatorTests.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 15.02.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit
import XCTest
@testable import Aquaz

class WaterGoalCalculatorTests: XCTestCase {
  
  func testCalcDailyWaterIntake() {
    test(18, .Man, 130, 35, .Rare, dailyWaterIntake: 1800, lostWater: 2500, supplyWater: 700)
    test(18, .Woman, 130, 35, .Rare, dailyWaterIntake: 1800, lostWater: 2500, supplyWater: 700)
    test(18, .PregnantFemale, 130, 35, .Rare, dailyWaterIntake: 2100, lostWater: 2800, supplyWater: 700)
    test(18, .BreastfeedingFemale, 130, 35, .Rare, dailyWaterIntake: 2500, lostWater: 3200, supplyWater: 700)
    
    test(30, .Man, 170, 60, .Occasional, dailyWaterIntake: 2100, lostWater: 2800, supplyWater: 700)
    test(40, .Woman, 160, 55, .Daily, dailyWaterIntake: 3200, lostWater: 3900, supplyWater: 700)
    test(50, .PregnantFemale, 180, 80, .Weekly, dailyWaterIntake: 2900, lostWater: 3600, supplyWater: 700)
    test(25, .BreastfeedingFemale, 190, 90, .Occasional, dailyWaterIntake: 2900, lostWater: 3600, supplyWater: 700)
  }
  
  private func test(age: Int, _ gender: Settings.Gender, _ height: Double, _ weight: Double, _ physicalActivity: Settings.PhysicalActivity, dailyWaterIntake: Double, lostWater: Double, supplyWater: Double) {
    let data = WaterGoalCalculator.Data(physicalActivity: physicalActivity, gender: gender, age: age, height: height, weight: weight, country: .UnitedKingdom)
    
    let calculatedDailyWaterIntake = WaterGoalCalculator.calcDailyWaterIntake(data: data)
    XCTAssertEqual(calculatedDailyWaterIntake, dailyWaterIntake, "Daily water intake is calculated wrong. Data: \(data)")
    
    let calculatedLostWater = WaterGoalCalculator.calcLostWater(data: data)
    XCTAssertEqual(calculatedLostWater, lostWater, "Water loss is calculated wrong. Data: \(data)")
    
    let calculatedSupplyWater = WaterGoalCalculator.calcSupplyWater(data: data)
    XCTAssertEqual(calculatedSupplyWater, supplyWater, "Water supply is calculated wrong. Data: \(data)")
  }
  
}
