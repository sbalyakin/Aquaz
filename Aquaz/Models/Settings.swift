//
//  Settings.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 06.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation

public class Settings {

  public class var sharedInstance: Settings {
    struct Instance {
      static let instance = Settings()
    }
    return Instance.instance
  }
  
  private init() {
    // Hide initizalizer, sharedInstance should be used instead.
  }
  
  public enum Gender: Int {
    case Man = 0
    case Woman
    case PregnantFemale
    case BreastfeedingFemale
  }

  public enum PhysicalActivity: Int {
    case Rare = 0
    case Occasional
    case Weekly
    case Daily
  }
  
  public enum StatisticsViewPage: Int {
    case Week = 0
    case Month
    case Year
  }

  
  lazy var generalHasLaunchedOnce = SettingsOrdinalItem(
    key: "General - Has Launched Once", initialValue: false)

  lazy var generalWeightUnits = SettingsEnumItem(
    key: "General - Weight units",initialValue: Units.Weight.Kilograms)
  
  lazy var generalHeightUnits = SettingsEnumItem(
    key: "General - Height units", initialValue: Units.Length.Centimeters)
  
  lazy var generalVolumeUnits = SettingsEnumItem(
    key: "General - Volume units", initialValue: Units.Volume.Millilitres)
  
  lazy var generalExtraConsumptionHot = SettingsOrdinalItem<Double>(
    key: "General - Extra consumption hot", initialValue: 0.5)
  
  lazy var generalExtraConsumptionHighActivity = SettingsOrdinalItem<Double>(
    key: "General - Extra consumption high activity", initialValue: 0.5)
  
  lazy var userHeight = SettingsOrdinalItem<Double>(
    key: "User - Height", initialValue: 170)
  
  lazy var userWeight = SettingsOrdinalItem<Double>(
    key: "User - Weight", initialValue: 70)
  
  lazy var userPhysicalActivity = SettingsEnumItem(
    key: "User - Physical activity", initialValue: PhysicalActivity.Occasional)
  
  lazy var userGender = SettingsEnumItem(
    key: "User - Gender", initialValue: Gender.Man)
  
  lazy var userAge = SettingsOrdinalItem<Int>(
    key: "User - Age", initialValue: 30)
  
  lazy var userDailyWaterIntake = Settings.createUserDailyWaterIntakeSetting()

  lazy var uiUseCustomDateForDayView = SettingsOrdinalItem(
    key: "UI - Use custom day page date", initialValue: false)
  
  lazy var uiCustomDateForDayView = SettingsOrdinalItem(
    key: "UI - Day page date", initialValue: NSDate())

  lazy var uiDisplayDayConsumptionInPercents = SettingsOrdinalItem(
    key: "UI - Display day consumption in percents", initialValue: false)

  lazy var uiDisplayDaySelection = SettingsOrdinalItem(
    key: "UI - Display day selection", initialValue: false)

  lazy var uiSelectedStatisticsPage = SettingsEnumItem(
    key: "UI - Selected statistics page", initialValue: StatisticsViewPage.Week)

  lazy var uiWeekStatisticsDate = SettingsOrdinalItem(
    key: "UI - Week statistics date", initialValue: NSDate())

  lazy var uiMonthStatisticsDate = SettingsOrdinalItem(
    key: "UI - Month statistics date", initialValue: NSDate())
  
  lazy var uiYearStatisticsDate = SettingsOrdinalItem(
    key: "UI - Year statistics date", initialValue: NSDate())

  lazy var uiSelectedAlcoholicDrink = SettingsEnumItem(
    key: "UI - Selected alcoholic drink", initialValue: Drink.DrinkType.Beer)

  lazy var notificationsEnabled = SettingsOrdinalItem(
    key: "Notifications - Enabled", initialValue: false)

  lazy var notificationsFrom = SettingsOrdinalItem(
    key: "Notifications - From", initialValue: DateHelper.dateBySettingHour(9, minute: 0, second: 0, ofDate: NSDate()))
  
  lazy var notificationsTo = SettingsOrdinalItem(
    key: "Notifications - To", initialValue: DateHelper.dateBySettingHour(21, minute: 0, second: 0, ofDate: NSDate()))

  lazy var notificationsInterval = SettingsOrdinalItem<NSTimeInterval>(
    key: "Notifications - Interval", initialValue: 60 * 60 * 1.5)
  
  lazy var notificationsSound = SettingsOrdinalItem(
    key: "Notifications - Sound", initialValue: "aqua.caf")
  
  lazy var notificationsSmart = SettingsOrdinalItem(
    key: "Notifications - Smart", initialValue: true)

  lazy var notificationsUseWaterIntake = SettingsOrdinalItem(
    key: "Notifications - Use water intake", initialValue: true)
  
  private class func createUserDailyWaterIntakeSetting() -> SettingsOrdinalItem<Double> {
    let settings = sharedInstance
    
    let consumptionRateCalculatorData = ConsumptionRateCalculatorData(physicalActivity: settings.userPhysicalActivity.value, gender: settings.userGender.value, age: settings.userAge.value, height: settings.userHeight.value, weight: settings.userWeight.value)
    
    let consumptionRateCalculator = ConsumptionRateCalculator()
    
    let dailyWaterIntake = consumptionRateCalculator.calcDailyWaterIntake(consumptionRateCalculatorData)
    
    return SettingsOrdinalItem<Double>(key: "User - Daily water intake", initialValue: dailyWaterIntake)
  }
}
