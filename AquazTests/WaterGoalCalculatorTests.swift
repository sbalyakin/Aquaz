//
//  WaterGoalCalculatorTests.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 15.02.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit
import XCTest
@testable import AquazPro

class WaterGoalCalculatorTests: XCTestCase {
  
  func testCalcDailyWaterIntake() {
    test(18, .man, 130, 35, .rare, dailyWaterIntake: 1800, lostWater: 2500, supplyWater: 700)
    test(18, .woman, 130, 35, .rare, dailyWaterIntake: 1800, lostWater: 2500, supplyWater: 700)
    test(18, .pregnantFemale, 130, 35, .rare, dailyWaterIntake: 2100, lostWater: 2800, supplyWater: 700)
    test(18, .breastfeedingFemale, 130, 35, .rare, dailyWaterIntake: 2500, lostWater: 3200, supplyWater: 700)
    
    test(30, .man, 170, 60, .occasional, dailyWaterIntake: 2100, lostWater: 2800, supplyWater: 700)
    test(40, .woman, 160, 55, .daily, dailyWaterIntake: 3200, lostWater: 3900, supplyWater: 700)
    test(50, .pregnantFemale, 180, 80, .weekly, dailyWaterIntake: 2900, lostWater: 3600, supplyWater: 700)
    test(25, .breastfeedingFemale, 190, 90, .occasional, dailyWaterIntake: 2900, lostWater: 3600, supplyWater: 700)
  }
  
  fileprivate func test(_ age: Int, _ gender: Settings.Gender, _ height: Double, _ weight: Double, _ physicalActivity: Settings.PhysicalActivity, dailyWaterIntake: Double, lostWater: Double, supplyWater: Double) {
    let data = WaterGoalCalculator.Data(physicalActivity: physicalActivity, gender: gender, age: age, height: height, weight: weight, country: .UnitedKingdom)
    
    let calculatedDailyWaterIntake = WaterGoalCalculator.calcDailyWaterIntake(data: data)
    XCTAssertEqual(calculatedDailyWaterIntake, dailyWaterIntake, "Daily water intake is calculated wrong. Data: \(data)")
    
    let calculatedLostWater = WaterGoalCalculator.calcLostWater(data: data)
    XCTAssertEqual(calculatedLostWater, lostWater, "Water loss is calculated wrong. Data: \(data)")
    
    let calculatedSupplyWater = WaterGoalCalculator.calcSupplyWater(data: data)
    XCTAssertEqual(calculatedSupplyWater, supplyWater, "Water supply is calculated wrong. Data: \(data)")
  }
  
}
