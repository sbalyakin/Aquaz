//
//  WaterGoalCalculator.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 03.02.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import Foundation

// Based on calculator from http://www.h4hinitiative.com/

class WaterGoalCalculator {

  struct Data: CustomStringConvertible {
    let physicalActivity: Settings.PhysicalActivity
    let gender: Settings.Gender
    let age: Int
    let height: Double
    let weight: Double
    let country: Country
    
    var description: String {
      return "Physical activity: \(physicalActivity), Gender: \(gender), Age: \(age), Height: \(height), Weight: \(weight), Country: \(country)"
    }
  }
  
  enum Country: String, CustomStringConvertible {
    case Argentina     = "argentina"
    case Mexico        = "mexico"
    case Brazil        = "brazil"
    case Uruguay       = "uruguay"
    case China         = "china"
    case Indonesia     = "indonesia"
    case Singapore     = "singapore"
    case Dubai         = "dubai"
    case Russia        = "russia"
    case France        = "france"
    case UnitedKingdom = "united kingdom"
    case Spain         = "spain"
    case Japan         = "japan"
    case Germany       = "germany"
    case Poland        = "poland"
    case Turkey        = "turkey"
    case Average       = "average"
    
    var waterFromFood: Double {
      switch self {
      case .Argentina:     return 623
      case .Mexico:        return 557
      case .Brazil:        return 470
      case .Uruguay:       return 550
      case .China:         return 1000
      case .Indonesia:     return 468
      case .Singapore:     return 533
      case .Dubai:         return 711
      case .Russia:        return 926
      case .France:        return 840
      case .UnitedKingdom: return 683
      case .Spain:         return 794
      case .Japan:         return 855
      case .Germany:       return 780
      case .Poland:        return 780
      case .Turkey:        return 830
      case .Average:       return 711
      }
    }
    
    var description: String {
      return self.rawValue
    }
  }

  class func calcDailyWaterIntake(data: Data) -> Double {
    let lostWater = calcLostWater(data: data)
    let supplyWater = calcSupplyWater(data: data)
    return roundAmount(lostWater - supplyWater)
  }
  
  class func calcLostWater(data: Data) -> Double {
    let netWaterLosses = calcNetWaterLosses(data: data, pregnancyAndLactation: true, waterInFood: false)
    return roundAmount(netWaterLosses)
  }
  
  class func calcSupplyWater(data: Data) -> Double {
    let waterLossesWithNoFood = calcNetWaterLosses(data: data, pregnancyAndLactation: false, waterInFood: false)
    let waterLossesWithFood = calcNetWaterLosses(data: data, pregnancyAndLactation: false, waterInFood: true)
    return roundAmount(waterLossesWithNoFood - waterLossesWithFood)
  }
  
  fileprivate class func roundAmount(_ amount: Double) -> Double {
    return round(amount / 100) * 100
  }
  
  fileprivate class func calcNetWaterLosses(data: Data, pregnancyAndLactation: Bool, waterInFood useWater: Bool) -> Double {
    let bodySurface = calcBodySurface(weight: data.weight, height: data.height)
    let caloryExpediture = calcCaloryExpendidure(physicalActivity: data.physicalActivity, weight: data.weight, gender: data.gender, age: data.age)
    let caloryExpeditureRare = calcCaloryExpendidure(physicalActivity: .rare, weight: data.weight, gender: data.gender, age: data.age)
    let lossesSkin = calcLossesSkin(bodySurface: bodySurface)
    let lossesRespiratory = calcLossesRespiratory(caloryExpediture: caloryExpediture)
    let sweatAmount = calcSweatAmount(physicalActivity: data.physicalActivity, caloryExpediture: caloryExpediture, caloryExpeditureRare: caloryExpeditureRare)
    let metabolicWater = calcGainMetabolicWater(caloryExpediture: caloryExpediture)
    let lossesUrine = 1500.0
    let lossesFaeces = 200.0
    
    var waterIntake = lossesUrine + lossesFaeces + lossesSkin + lossesRespiratory + sweatAmount - metabolicWater
    
    if pregnancyAndLactation {
      switch data.gender {
      case .pregnantFemale     : waterIntake += 300
      case .breastfeedingFemale: waterIntake += 700
      default: break
      }
    }
    
    if useWater {
      waterIntake -= data.country.waterFromFood
    }
    
    return waterIntake
  }
  
  fileprivate class func calcBodySurface(weight: Double, height: Double) -> Double {
    return 0.007184 * pow(height, 0.725) * pow(weight, 0.425)
  }
  
  fileprivate class func calcCaloryExpendidure(physicalActivity: Settings.PhysicalActivity, weight: Double, gender: Settings.Gender, age: Int) -> Double {
    let activityFactor: Double
    
    switch physicalActivity {
    case .rare:       activityFactor = 1.4
    case .occasional: activityFactor = 1.53
    case .weekly:     activityFactor = 1.76
    case .daily:      activityFactor = 2.25
    }
    
    let factors = (gender == .man)
      ? [(15.057, 692.2), (11.472, 873.1), (11.711, 587.7)] // Man
      : [(14.818, 486.6), (8.126,  845.6), (9.082,  658.5)] // Woman
    
    let ageFactor: (weightFactor: Double, extraCalory: Double)
    
    if age < 30 {
      ageFactor = factors[0]
    } else if age >= 60 {
      ageFactor = factors[2]
    } else { // 30..<60
      ageFactor = factors[1]
    }
    
    let caloryExpendidure = activityFactor * (ageFactor.weightFactor * weight + ageFactor.extraCalory)
    
    return caloryExpendidure
  }
  
  fileprivate class func calcLossesSkin(bodySurface: Double) -> Double {
    return bodySurface * 7 * 24
  }
  
  fileprivate class func calcLossesRespiratory(caloryExpediture: Double) -> Double {
    return 0.107 * caloryExpediture + 92.2
  }
  
  fileprivate class func calcSweatAmount(physicalActivity: Settings.PhysicalActivity, caloryExpediture: Double, caloryExpeditureRare: Double) -> Double {
    let sweatAmount: Double
    
    switch physicalActivity {
    case .rare:
      sweatAmount = 500
      
    case .occasional, .weekly, .daily:
      sweatAmount = 500 + (caloryExpediture - caloryExpeditureRare) * 0.75 / 0.58
    }
    
    return sweatAmount
  }
  
  fileprivate class func calcGainMetabolicWater(caloryExpediture: Double) -> Double {
    return 0.119 * caloryExpediture - 2.25
  }
  
}
