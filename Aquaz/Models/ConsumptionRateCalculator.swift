//
//  ConsumptionRateCalculator.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 03.02.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import Foundation

struct ConsumptionRateCalculatorData {
  var physicalActivity: Settings.PhysicalActivity
  var gender: Settings.Gender
  var age: Int
  var height: Double
  var weight: Double
}

class ConsumptionRateCalculator {
  private var data: ConsumptionRateCalculatorData!
  let minimumAge = 1
  let maximumAge = 100
  
  init () {
  }
  
  func calcDailyWaterIntake(data: ConsumptionRateCalculatorData) -> Double {
    self.data = data
    
    let lostWater = calcLostWater(pregnancyAndLactation: true)
    let supplyWater = calcSupplyWater()
    return lostWater - supplyWater
  }

  private func calcLostWater(#pregnancyAndLactation: Bool) -> Double {
    let netWaterLosses = calcNetWaterLosses(pregnancyAndLactation: pregnancyAndLactation, waterInFood: true)
    return round(netWaterLosses)
  }
  
  private func calcSupplyWater() -> Double {
    let waterLossesWithNoFood = calcNetWaterLosses(pregnancyAndLactation: false, waterInFood: false)
    let waterLossesWithFood = calcNetWaterLosses(pregnancyAndLactation: false, waterInFood: true)
    return round(waterLossesWithNoFood - waterLossesWithFood)
  }
  
  private func calcNetWaterLosses(#pregnancyAndLactation: Bool, waterInFood useWater: Bool) -> Double {
    let bodySurface = calcBodySurface()
    let caloryExpediture = calcCaloryExpendidure(physicalActivity: data.physicalActivity)
    let caloryExpeditureRare = calcCaloryExpendidure(physicalActivity: .Rare)
    let lossesSkin = calcLossesSkin(bodySurface: bodySurface)
    let lossesRespiratory = calcLossesRespiratory(caloryExpediture: caloryExpediture)
    let sweatAmount = calcSweatAmount(caloryExpediture: caloryExpediture, caloryExpeditureRare: caloryExpeditureRare)
    let metabolicWater = calcGainMetabolicWater(caloryExpediture: caloryExpediture)
    let lossesUrine = 1500.0
    let lossesFaeces = 200.0
    
    var waterIntake = lossesUrine + lossesFaeces + lossesSkin + lossesRespiratory + sweatAmount - metabolicWater
    
    if pregnancyAndLactation {
      switch data.gender {
      case .PregnantFemale     : waterIntake += 300
      case .BreastfeedingFemale: waterIntake += 700
      default: break
      }
    }
    
    if useWater {
      waterIntake -= calcWaterFromFood()
    }
    
    return waterIntake
  }
  
  private func calcBodySurface() -> Double {
    return 0.007184 * pow(data.height, 0.725) * pow(data.weight, 0.425)
  }
  
  private func calcCaloryExpendidure(#physicalActivity: Settings.PhysicalActivity) -> Double {
    var activityFactor: Double
    
    switch physicalActivity {
    case .Rare:       activityFactor = 1.4
    case .Occasional: activityFactor = 1.53
    case .Weekly:     activityFactor = 1.76
    case .Daily:      activityFactor = 2.25
    }
    
    let factors = (data.gender == .Man)
      ? [(15.057, 692.2), (11.472, 873.1), (11.711, 587.7)] // Man
      : [(14.818, 486.6), (8.126,  845.6), (9.082,  658.5)] // Woman
    
    var factorIndex = 0
    
    switch data.age {
    case minimumAge..<30: factorIndex = 0
    case 30..<60        : factorIndex = 1
    case 60...maximumAge: factorIndex = 2
    default: assert(false)
    }
    
    let factor = factors[factorIndex]
    let caloryExpendidure = activityFactor * (factor.0 * data.weight + factor.1)
    
    return caloryExpendidure
  }
  
  private func calcLossesSkin(#bodySurface: Double) -> Double {
    return bodySurface * 7 * 24
  }
  
  private func calcLossesRespiratory(#caloryExpediture: Double) -> Double {
    return 0.107 * caloryExpediture + 92.2
  }
  
  private func calcSweatAmount(#caloryExpediture: Double, caloryExpeditureRare: Double) -> Double {
    var sweatAmount: Double = 0
    
    switch data.physicalActivity {
    case .Rare:
      sweatAmount = 500
      
    case .Occasional, .Weekly, .Daily:
      sweatAmount = 500 + (caloryExpediture - caloryExpeditureRare) * 0.75 / 0.58
    }
    
    return sweatAmount
  }
  
  private func calcGainMetabolicWater(#caloryExpediture: Double) -> Double {
    return 0.119 * caloryExpediture - 2.25
  }
  
  private func calcWaterFromFood() -> Double {
    return 711
  }
}