//
//  Settings.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 06.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation

public class Settings {

  public static let sharedInstance = Settings()
  
  // MARK: Initializer
  
  private init() {
    // Hide initizalizer, sharedInstance should be used instead.
  }
  
  // MARK: Types
  
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
  
  public enum DayPageHelpTip: Int {
    case SwipeToChangeDay = 0
    case SwipeToSeeDiary
    case HighActivityMode
    case HotWeatherMode
    case SwitchToPercentsAndViceVersa
    case LongPressToChooseAlcohol
    // It should be the last case indicating that all help tips are already shown to user
    case None
  }

  public enum WeekStatisticsPageHelpTip: Int {
    case TapToSeeDayDetails = 0
    case SwipeToChangeWeek
    // It should be the last case indicating that all help tips are already shown to user
    case None
  }

  public enum RateApplicationAlertSelection: Int {
    case RateApplication
    case RemindLater
    case No
  }

  // MARK: General
  
  lazy var generalHasLaunchedOnce = SettingsOrdinalItem(
    key: "General - Has Launched Once", initialValue: false,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)
  
  lazy var generalWeightUnits = SettingsEnumItem<Units.Weight>(
    key: "General - Weight units", initialValue: isMetric ? .Kilograms : .Pounds,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)
  
  lazy var generalHeightUnits = SettingsEnumItem<Units.Length>(
    key: "General - Height units", initialValue: isMetric ? .Centimeters : .Feet,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)
  
  lazy var generalVolumeUnits = SettingsEnumItem<Units.Volume>(
    key: "General - Volume units", initialValue: isMetric ? .Millilitres : .FluidOunces,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)
  
  lazy var generalHotDayExtraFactor = SettingsOrdinalItem<Double>(
    key: "General - Hot day extra factor", initialValue: 0.5,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)
  
  lazy var generalHighActivityExtraFactor = SettingsOrdinalItem<Double>(
    key: "General - High activity extra factor", initialValue: 0.5,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)

  lazy var generalFullVersion = SettingsOrdinalItem<Bool>(
    key: "General - Full version", initialValue: false,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)

  lazy var generalAdCounter = SettingsOrdinalItem<Int>(
    key: "General - Ad counter", initialValue: GlobalConstants.numberOfIntakesToShowAd,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)

  // MARK: User
  
  lazy var userHeight = SettingsOrdinalItem<Double>(
    key: "User - Height", initialValue: 170,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)
  
  lazy var userWeight = SettingsOrdinalItem<Double>(
    key: "User - Weight", initialValue: 70,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)
  
  lazy var userPhysicalActivity = SettingsEnumItem(
    key: "User - Physical activity", initialValue: PhysicalActivity.Occasional,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)
  
  lazy var userGender = SettingsEnumItem(
    key: "User - Gender", initialValue: Gender.Man,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)
  
  lazy var userAge = SettingsOrdinalItem<Int>(
    key: "User - Age", initialValue: 30,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)
  
  lazy var userDailyWaterIntake = SettingsOrdinalItem(
    key: "User - Daily water intake", initialValue: Settings.calcUserDailyWaterIntakeSetting(),
    userDefaults: UserDefaultsProvider.sharedUserDefaults)

  // MARK: User Interface
  
  lazy var uiUseCustomDateForDayView = SettingsOrdinalItem(
    key: "UI - Use custom day page date", initialValue: false,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)
  
  lazy var uiCustomDateForDayView = SettingsOrdinalItem(
    key: "UI - Day page date", initialValue: NSDate(),
    userDefaults: UserDefaultsProvider.sharedUserDefaults)

  lazy var uiDisplayDailyWaterIntakeInPercents = SettingsOrdinalItem(
    key: "UI - Display daily water intake in percents", initialValue: false,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)

  lazy var uiSelectedStatisticsPage = SettingsEnumItem(
    key: "UI - Selected statistics page", initialValue: StatisticsViewPage.Week,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)

  lazy var uiSelectedAlcoholicDrink = SettingsEnumItem(
    key: "UI - Selected alcoholic drink", initialValue: Drink.DrinkType.Wine,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)

  lazy var uiWaterGoalReachingIsShownForDate = SettingsOrdinalItem(
    key: "UI - Water goal reaching is shown for date",
    initialValue: DateHelper.addToDate(NSDate(), years: -1, months: 0, days: 0), // It should be any not today date
    userDefaults: UserDefaultsProvider.sharedUserDefaults)

  lazy var uiDayPageHelpTipToShow = SettingsEnumItem(
    key: "UI - Day page help tip to show", initialValue: DayPageHelpTip(rawValue: 0)!,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)
  
  lazy var uiDayPageAlcoholicDehydratrionHelpTipIsShown = SettingsOrdinalItem(
    key: "UI - Day page alcoholic dehydration help tip is shown", initialValue: false,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)

  lazy var uiDayPageIntakesCountTillHelpTip = SettingsOrdinalItem(
    key: "UI - Day page intakes count till help tip", initialValue: 0,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)

  lazy var uiWritingReviewAlertSelection = SettingsEnumItem(
    key: "UI - Writing review alert selection", initialValue: RateApplicationAlertSelection.RemindLater,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)

  lazy var uiWritingReviewAlertLastShownDate = SettingsOrdinalItem(
    key: "UI - Writing review alert last shown date", initialValue: NSDate(),
    userDefaults: UserDefaultsProvider.sharedUserDefaults)

  lazy var uiDiaryPageHelpTipIsShown = SettingsOrdinalItem(
    key: "UI - Diary page help tip is shown", initialValue: false,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)
  
  lazy var uiWeekStatisticsPageHelpTipToShow = SettingsEnumItem(
    key: "UI - Week statistics page help tip to show", initialValue: WeekStatisticsPageHelpTip(rawValue: 0)!,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)

  lazy var uiMonthStatisticsPageHelpTipIsShown = SettingsOrdinalItem(
    key: "UI - Month statistics page help tip is shown", initialValue: false,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)

  lazy var uiYearStatisticsPageHelpTipIsShown = SettingsOrdinalItem(
    key: "UI - Year statistics page help tip is shown", initialValue: false,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)

  // MARK: Notifications
  
  lazy var notificationsEnabled = SettingsOrdinalItem(
    key: "Notifications - Enabled", initialValue: false,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)
  
  lazy var notificationsFrom = SettingsOrdinalItem(
    key: "Notifications - From", initialValue: DateHelper.dateBySettingHour(9, minute: 0, second: 0, ofDate: NSDate()),
    userDefaults: UserDefaultsProvider.sharedUserDefaults)
  
  lazy var notificationsTo = SettingsOrdinalItem(
    key: "Notifications - To", initialValue: DateHelper.dateBySettingHour(21, minute: 0, second: 0, ofDate: NSDate()),
    userDefaults: UserDefaultsProvider.sharedUserDefaults)

  lazy var notificationsInterval = SettingsOrdinalItem<NSTimeInterval>(
    key: "Notifications - Interval", initialValue: 60 * 60 * 1.5,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)
  
  lazy var notificationsSound = SettingsOrdinalItem(
    key: "Notifications - Sound", initialValue: "aqua.caf",
    userDefaults: UserDefaultsProvider.sharedUserDefaults)
  
  lazy var notificationsSmart = SettingsOrdinalItem(
    key: "Notifications - Smart", initialValue: false,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)

  lazy var notificationsLimit = SettingsOrdinalItem(
    key: "Notifications - Check water goal reaching", initialValue: false,
    userDefaults: UserDefaultsProvider.sharedUserDefaults)

  // MARK: Helpers
  
  private class var isMetric: Bool {
    return NSLocale.currentLocale().objectForKey(NSLocaleUsesMetricSystem)! as! Bool
  }

  private class func calcUserDailyWaterIntakeSetting() -> Double {
    let data = WaterGoalCalculator.Data(
      physicalActivity: Settings.sharedInstance.userPhysicalActivity.value,
      gender: Settings.sharedInstance.userGender.value,
      age: Settings.sharedInstance.userAge.value,
      height: Settings.sharedInstance.userHeight.value,
      weight: Settings.sharedInstance.userWeight.value,
      country: .Average)
    
    return WaterGoalCalculator.calcDailyWaterIntake(data: data)
  }
}
