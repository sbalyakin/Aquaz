//
//  WaterGoalCalculator.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 03.02.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import Foundation

// Based on calculator from http://www.h4hinitiative.com/

public class WaterGoalCalculator {

  public struct Data: Printable {
    public let physicalActivity: Settings.PhysicalActivity
    public let gender: Settings.Gender
    public let age: Int
    public let height: Double
    public let weight: Double
    public let country: Country
    
    // Unfortunately Swift 1.2 create only internal synthesised initializers, so it's necessary to create own public one
    public init(physicalActivity: Settings.PhysicalActivity, gender: Settings.Gender, age: Int, height: Double, weight: Double, country: Country) {
      self.physicalActivity = physicalActivity
      self.gender = gender
      self.age = age
      self.height = height
      self.weight = weight
      self.country = country
    }
    
    public var description: String {
      return "Physical activity: \(physicalActivity), Gender: \(gender), Age: \(age), Height: \(height), Weight: \(weight), Country: \(country)"
    }
  }
  
  public enum Country: String, Printable {
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
    
    public var description: String {
      return self.rawValue
    }
  }

  public class func calcDailyWaterIntake(#data: Data) -> Double {
    let lostWater = calcLostWater(data: data)
    let supplyWater = calcSupplyWater(data: data)
    return roundAmount(lostWater - supplyWater)
  }
  
  public class func calcLostWater(#data: Data) -> Double {
    let netWaterLosses = calcNetWaterLosses(data: data, pregnancyAndLactation: true, waterInFood: false)
    return roundAmount(netWaterLosses)
  }
  
  public class func calcSupplyWater(#data: Data) -> Double {
    let waterLossesWithNoFood = calcNetWaterLosses(data: data, pregnancyAndLactation: false, waterInFood: false)
    let waterLossesWithFood = calcNetWaterLosses(data: data, pregnancyAndLactation: false, waterInFood: true)
    return roundAmount(waterLossesWithNoFood - waterLossesWithFood)
  }
  
  private class func roundAmount(amount: Double) -> Double {
    return round(amount / 100) * 100
  }
  
  private class func calcNetWaterLosses(#data: Data, pregnancyAndLactation: Bool, waterInFood useWater: Bool) -> Double {
    let bodySurface = calcBodySurface(weight: data.weight, height: data.height)
    let caloryExpediture = calcCaloryExpendidure(physicalActivity: data.physicalActivity, weight: data.weight, gender: data.gender, age: data.age)
    let caloryExpeditureRare = calcCaloryExpendidure(physicalActivity: .Rare, weight: data.weight, gender: data.gender, age: data.age)
    let lossesSkin = calcLossesSkin(bodySurface: bodySurface)
    let lossesRespiratory = calcLossesRespiratory(caloryExpediture: caloryExpediture)
    let sweatAmount = calcSweatAmount(physicalActivity: data.physicalActivity, caloryExpediture: caloryExpediture, caloryExpeditureRare: caloryExpeditureRare)
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
      waterIntake -= data.country.waterFromFood
    }
    
    return waterIntake
  }
  
  private class func calcBodySurface(#weight: Double, height: Double) -> Double {
    return 0.007184 * pow(height, 0.725) * pow(weight, 0.425)
  }
  
  private class func calcCaloryExpendidure(#physicalActivity: Settings.PhysicalActivity, weight: Double, gender: Settings.Gender, age: Int) -> Double {
    let activityFactor: Double
    
    switch physicalActivity {
    case .Rare:       activityFactor = 1.4
    case .Occasional: activityFactor = 1.53
    case .Weekly:     activityFactor = 1.76
    case .Daily:      activityFactor = 2.25
    }
    
    let factors = (gender == .Man)
      ? [(15.057, 692.2), (11.472, 873.1), (11.711, 587.7)] // Man
      : [(14.818, 486.6), (8.126,  845.6), (9.082,  658.5)] // Woman
    
    let ageFactor: (weightFactor: Double, extraCalory: Double)
    
    switch age {
    case Int.min..<30: ageFactor = factors[0]
    case 30..<60     : ageFactor = factors[1]
    case 60...Int.max: ageFactor = factors[2]
    default:
      Logger.logError(Logger.Messages.logicalError)
      ageFactor = factors[0]
    }
    
    let caloryExpendidure = activityFactor * (ageFactor.weightFactor * weight + ageFactor.extraCalory)
    
    return caloryExpendidure
  }
  
  private class func calcLossesSkin(#bodySurface: Double) -> Double {
    return bodySurface * 7 * 24
  }
  
  private class func calcLossesRespiratory(#caloryExpediture: Double) -> Double {
    return 0.107 * caloryExpediture + 92.2
  }
  
  private class func calcSweatAmount(#physicalActivity: Settings.PhysicalActivity, caloryExpediture: Double, caloryExpeditureRare: Double) -> Double {
    let sweatAmount: Double
    
    switch physicalActivity {
    case .Rare:
      sweatAmount = 500
      
    case .Occasional, .Weekly, .Daily:
      sweatAmount = 500 + (caloryExpediture - caloryExpeditureRare) * 0.75 / 0.58
    }
    
    return sweatAmount
  }
  
  private class func calcGainMetabolicWater(#caloryExpediture: Double) -> Double {
    return 0.119 * caloryExpediture - 2.25
  }
  
}