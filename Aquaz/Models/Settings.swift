//
//  Settings.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 06.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation

public class Settings {

  private init() {
    // Hide initizalizer, sharedInstance should be used instead.
  }
  
  public enum Gender: Int, Printable {
    case Man = 0
    case Woman
    case PregnantFemale
    case BreastfeedingFemale
    
    public var description: String {
      switch self {
      case .Man: return "Man"
      case .Woman: return "Woman"
      case .PregnantFemale: return "Pregnant Female"
      case .BreastfeedingFemale: return "Breastfeeding Female"
      }
    }
  }

  public enum PhysicalActivity: Int, Printable {
    case Rare = 0
    case Occasional
    case Weekly
    case Daily
    
    public var description: String {
      switch self {
      case .Rare: return "Rare"
      case .Occasional: return "Occasional"
      case .Weekly: return "Weekly"
      case .Daily: return "Daily"
      }
    }
  }
  
  public enum StatisticsViewPage: Int {
    case Week = 0
    case Month
    case Year
  }

  static let generalHasLaunchedOnce = SettingsOrdinalItem(
    key: "General - Has Launched Once", initialValue: false)

  static let generalWeightUnits = SettingsEnumItem<Units.Weight>(
    key: "General - Weight units",initialValue: isMetric ? .Kilograms : .Pounds)
  
  static let generalHeightUnits = SettingsEnumItem<Units.Length>(
    key: "General - Height units", initialValue: isMetric ? .Centimeters : .Feet)
  
  static let generalVolumeUnits = SettingsEnumItem<Units.Volume>(
    key: "General - Volume units", initialValue: isMetric ? .Millilitres : .FluidOunces)
  
  static let generalHotDayExtraFactor = SettingsOrdinalItem<Double>(
    key: "General - Hot day extra factor", initialValue: 0.5)
  
  static let generalHighActivityExtraFactor = SettingsOrdinalItem<Double>(
    key: "General - High activity extra factor", initialValue: 0.5)
  
  static let userHeight = SettingsOrdinalItem<Double>(
    key: "User - Height", initialValue: 170)
  
  static let userWeight = SettingsOrdinalItem<Double>(
    key: "User - Weight", initialValue: 70)
  
  static let userPhysicalActivity = SettingsEnumItem(
    key: "User - Physical activity", initialValue: PhysicalActivity.Occasional)
  
  static let userGender = SettingsEnumItem(
    key: "User - Gender", initialValue: Gender.Man)
  
  static let userAge = SettingsOrdinalItem<Int>(
    key: "User - Age", initialValue: 30)
  
  static let userWaterGoal = SettingsOrdinalItem(
    key: "User - Daily water intake", initialValue: Settings.calcUserDailyWaterIntakeSetting())

  static let uiUseCustomDateForDayView = SettingsOrdinalItem(
    key: "UI - Use custom day page date", initialValue: false)
  
  static let uiCustomDateForDayView = SettingsOrdinalItem(
    key: "UI - Day page date", initialValue: NSDate())

  static let uiDisplayDailyWaterIntakeInPercents = SettingsOrdinalItem(
    key: "UI - Display daily water intake in percents", initialValue: false)

  static let uiSelectedStatisticsPage = SettingsEnumItem(
    key: "UI - Selected statistics page", initialValue: StatisticsViewPage.Week)

  static let uiSelectedAlcoholicDrink = SettingsEnumItem(
    key: "UI - Selected alcoholic drink", initialValue: Drink.DrinkType.Wine)

  static let notificationsEnabled = SettingsOrdinalItem(
    key: "Notifications - Enabled", initialValue: false)

  static let notificationsFrom = SettingsOrdinalItem(
    key: "Notifications - From", initialValue: DateHelper.dateBySettingHour(9, minute: 0, second: 0, ofDate: NSDate()))
  
  static let notificationsTo = SettingsOrdinalItem(
    key: "Notifications - To", initialValue: DateHelper.dateBySettingHour(21, minute: 0, second: 0, ofDate: NSDate()))

  static let notificationsInterval = SettingsOrdinalItem<NSTimeInterval>(
    key: "Notifications - Interval", initialValue: 60 * 60 * 1.5)
  
  static let notificationsSound = SettingsOrdinalItem(
    key: "Notifications - Sound", initialValue: "aqua.caf")
  
  static let notificationsSmart = SettingsOrdinalItem(
    key: "Notifications - Smart", initialValue: true)

  static let notificationsUseWaterIntake = SettingsOrdinalItem(
    key: "Notifications - Use water intake", initialValue: true)
  
  private class var isMetric: Bool {
    return NSLocale.currentLocale().objectForKey(NSLocaleUsesMetricSystem)! as! Bool
  }

  private class func calcUserDailyWaterIntakeSetting() -> Double {
    let data = WaterGoalCalculator.Data(physicalActivity: Settings.userPhysicalActivity.value, gender: Settings.userGender.value, age: Settings.userAge.value, height: Settings.userHeight.value, weight: Settings.userWeight.value, country: .Average)
    
    return WaterGoalCalculator.calcDailyWaterIntake(data: data)
  }
}
