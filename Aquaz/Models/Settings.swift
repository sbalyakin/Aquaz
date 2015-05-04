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
  
  enum DayPageHelpTip: Int {
    case SlideToChangeDay = 0
    case HighActivityMode
    case HotWeatherMode
    case SwitchToPercentsAndViceVersa
    case LongPressToChooseAlcohol
    // It should be the last case indicating that all help tips are already shown to user
    case None
  }
  
  enum RateApplicationAlertSelection: Int {
    case RateApplication
    case RemindLater
    case No
  }

  static let generalHasLaunchedOnce = SettingsOrdinalItem(
    key: "General - Has Launched Once", initialValue: false,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)

  static let generalWeightUnits = SettingsEnumItem<Units.Weight>(
    key: "General - Weight units", initialValue: isMetric ? .Kilograms : .Pounds,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)
  
  static let generalHeightUnits = SettingsEnumItem<Units.Length>(
    key: "General - Height units", initialValue: isMetric ? .Centimeters : .Feet,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)
  
  static let generalVolumeUnits = SettingsEnumItem<Units.Volume>(
    key: "General - Volume units", initialValue: isMetric ? .Millilitres : .FluidOunces,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)
  
  static let generalHotDayExtraFactor = SettingsOrdinalItem<Double>(
    key: "General - Hot day extra factor", initialValue: 0.5,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)
  
  static let generalHighActivityExtraFactor = SettingsOrdinalItem<Double>(
    key: "General - High activity extra factor", initialValue: 0.5,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)
  
  static let userHeight = SettingsOrdinalItem<Double>(
    key: "User - Height", initialValue: 170,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)
  
  static let userWeight = SettingsOrdinalItem<Double>(
    key: "User - Weight", initialValue: 70,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)
  
  static let userPhysicalActivity = SettingsEnumItem(
    key: "User - Physical activity", initialValue: PhysicalActivity.Occasional,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)
  
  static let userGender = SettingsEnumItem(
    key: "User - Gender", initialValue: Gender.Man,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)
  
  static let userAge = SettingsOrdinalItem<Int>(
    key: "User - Age", initialValue: 30,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)
  
  static let userWaterGoal = SettingsOrdinalItem(
    key: "User - Daily water intake", initialValue: Settings.calcUserDailyWaterIntakeSetting(),
    userDefaults: UserDefaultsProvider.sharedUserDefaults)

  static let uiUseCustomDateForDayView = SettingsOrdinalItem(
    key: "UI - Use custom day page date", initialValue: false,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)
  
  static let uiCustomDateForDayView = SettingsOrdinalItem(
    key: "UI - Day page date", initialValue: NSDate(),
    userDefaults: UserDefaultsProvider.sharedUserDefaults)

  static let uiDisplayDailyWaterIntakeInPercents = SettingsOrdinalItem(
    key: "UI - Display daily water intake in percents", initialValue: false,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)

  static let uiSelectedStatisticsPage = SettingsEnumItem(
    key: "UI - Selected statistics page", initialValue: StatisticsViewPage.Week,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)

  static let uiSelectedAlcoholicDrink = SettingsEnumItem(
    key: "UI - Selected alcoholic drink", initialValue: Drink.DrinkType.Wine,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)

  static let uiWaterGoalReachingIsShownForDate = SettingsOrdinalItem(
    key: "UI - Water goal reaching is shown for date",
    initialValue: DateHelper.addToDate(NSDate(), years: -1, months: 0, days: 0), // It should be any not today date
    userDefaults: UserDefaultsProvider.sharedUserDefaults)

  static let uiDayPageHelpTipToShow = SettingsEnumItem(
    key: "UI - Day page help tip to show", initialValue: DayPageHelpTip.SlideToChangeDay,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)

  static let uiDayPageIntakesCountTillHelpTip = SettingsOrdinalItem(
    key: "UI - Day page intakes count till help tip", initialValue: 0,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)

  static let uiWritingReviewAlertSelection = SettingsEnumItem(
    key: "UI - Writing review alert selection", initialValue: RateApplicationAlertSelection.RemindLater,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)

  static let uiWritingReviewAlertLastShownDate = SettingsOrdinalItem(
    key: "Notifications - Writing review alert last shown date", initialValue: NSDate(),
    userDefaults: UserDefaultsProvider.sharedUserDefaults)

  static let notificationsEnabled = SettingsOrdinalItem(
    key: "Notifications - Enabled", initialValue: false,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)

  static let notificationsFrom = SettingsOrdinalItem(
    key: "Notifications - From", initialValue: DateHelper.dateBySettingHour(9, minute: 0, second: 0, ofDate: NSDate()),
    userDefaults: UserDefaultsProvider.sharedUserDefaults)
  
  static let notificationsTo = SettingsOrdinalItem(
    key: "Notifications - To", initialValue: DateHelper.dateBySettingHour(21, minute: 0, second: 0, ofDate: NSDate()),
    userDefaults: UserDefaultsProvider.sharedUserDefaults)

  static let notificationsInterval = SettingsOrdinalItem<NSTimeInterval>(
    key: "Notifications - Interval", initialValue: 60 * 60 * 1.5,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)
  
  static let notificationsSound = SettingsOrdinalItem(
    key: "Notifications - Sound", initialValue: "aqua.caf",
    userDefaults: UserDefaultsProvider.sharedUserDefaults)
  
  static let notificationsSmart = SettingsOrdinalItem(
    key: "Notifications - Smart", initialValue: true,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)

  static let notificationsCheckWaterGoalReaching = SettingsOrdinalItem(
    key: "Notifications - Check water goal reaching", initialValue: true,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)
  
  private class var isMetric: Bool {
    return NSLocale.currentLocale().objectForKey(NSLocaleUsesMetricSystem)! as! Bool
  }

  private class func calcUserDailyWaterIntakeSetting() -> Double {
    let data = WaterGoalCalculator.Data(
      physicalActivity: Settings.userPhysicalActivity.value,
      gender: Settings.userGender.value,
      age: Settings.userAge.value,
      height: Settings.userHeight.value,
      weight: Settings.userWeight.value,
      country: .Average)
    
    return WaterGoalCalculator.calcDailyWaterIntake(data: data)
  }
}
