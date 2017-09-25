//
//  Settings.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 06.10.14.
//  Copyright © 2014 Sergey Balyakin. All rights reserved.
//

import Foundation

final class Settings {

  static let sharedInstance = Settings()
  
  static let userDefaults = UserDefaults(suiteName: GlobalConstants.appGroupName)!

  // MARK: Initializer
  
  fileprivate init() {
    // Hide initizalizer, sharedInstance should be used instead.
  }
  
  // MARK: Types
  
  enum Gender: Int, CustomStringConvertible {
    case man = 0
    case woman
    case pregnantFemale
    case breastfeedingFemale
    
    var description: String {
      switch self {
      case .man: return "Man"
      case .woman: return "Woman"
      case .pregnantFemale: return "Pregnant Female"
      case .breastfeedingFemale: return "Breastfeeding Female"
      }
    }
  }

  enum PhysicalActivity: Int, CustomStringConvertible {
    case rare = 0
    case occasional
    case weekly
    case daily
    
    var description: String {
      switch self {
      case .rare: return "Rare"
      case .occasional: return "Occasional"
      case .weekly: return "Weekly"
      case .daily: return "Daily"
      }
    }
  }
  
  enum StatisticsViewPage: Int {
    case week = 0
    case month
    case year
  }
  
  enum DayPageHelpTip: Int {
    case swipeToChangeDay = 0
    case swipeToSeeDiary
    case highActivityMode
    case hotWeatherMode
    case switchToPercentsAndViceVersa
    case longPressToChooseAlcohol
    // It should be the last case indicating that all help tips are already shown to user
    case none
  }

  enum WeekStatisticsPageHelpTip: Int {
    case tapToSeeDayDetails = 0
    case swipeToChangeWeek
    // It should be the last case indicating that all help tips are already shown to user
    case none
  }

  enum RateApplicationAlertSelection: Int {
    case rateApplication
    case remindLater
    case no
  }

  enum PredefinedAmountType: Int, CustomStringConvertible {
    case small = 0
    case medium
    case large
    
    var description: String {
      switch self {
      case .small: return "Small"
      case .medium: return "Medium"
      case .large: return "Large"
      }
    }
    
    var defaultAmount: Double {
      switch Settings.sharedInstance.generalVolumeUnits.value {
      case .millilitres:
        switch self {
        case .small: return 200
        case .medium: return 330
        case .large: return 500
        }
      case .fluidOunces:
        switch self {
        case .small: return Quantity.convert(amount: 8, unitFrom: FluidOunceUnit(), unitTo: MilliliterUnit())
        case .medium: return Quantity.convert(amount: 12, unitFrom: FluidOunceUnit(), unitTo: MilliliterUnit())
        case .large: return Quantity.convert(amount: 17, unitFrom: FluidOunceUnit(), unitTo: MilliliterUnit())
        }
      }
    }
  }
  
  final class PredefinedAmounts {
    
    private func getSettingsKey(predefinedAmountType: PredefinedAmountType, drinkType: DrinkType) -> String {
      return "General - Predefined \(predefinedAmountType.description) amount for drink \(drinkType.rawValue)"
    }
    
    subscript (index: (predefinedAmountType: PredefinedAmountType, drinkType: DrinkType)) -> Double {
      get {
        let key = getSettingsKey(predefinedAmountType: index.predefinedAmountType, drinkType: index.drinkType)
        
        if let amount = Settings.userDefaults.value(forKey: key) as? Double {
          return amount
        }
        
        return index.predefinedAmountType.defaultAmount
      }
      set(newAmount) {
        let key = getSettingsKey(predefinedAmountType: index.predefinedAmountType, drinkType: index.drinkType)
        Settings.userDefaults.set(newAmount, forKey: key)
        Settings.userDefaults.synchronize()
      }
    }
  }
  
  // MARK: General
  
  lazy var generalHasLaunchedOnce: SettingsOrdinalItem<Bool> = SettingsOrdinalItem(
    key: "General - Has Launched Once", initialValue: false,
    userDefaults: Settings.userDefaults)
  
  lazy var generalWeightUnits: SettingsEnumItem<Units.Weight> = SettingsEnumItem(
    key: "General - Weight units", initialValue: Settings.isMetric ? .kilograms : .pounds,
    userDefaults: Settings.userDefaults)
  
  lazy var generalHeightUnits: SettingsEnumItem<Units.Length> = SettingsEnumItem(
    key: "General - Height units", initialValue: Settings.isMetric ? .centimeters : .feet,
    userDefaults: Settings.userDefaults)
  
  lazy var generalVolumeUnits: SettingsEnumItem<Units.Volume> = SettingsEnumItem(
    key: "General - Volume units", initialValue: Settings.isMetric ? .millilitres : .fluidOunces,
    userDefaults: Settings.userDefaults)
  
  lazy var generalHotDayExtraFactor: SettingsOrdinalItem<Double> = SettingsOrdinalItem(
    key: "General - Hot day extra factor", initialValue: 0.5,
    userDefaults: Settings.userDefaults)
  
  lazy var generalHighActivityExtraFactor: SettingsOrdinalItem<Double> = SettingsOrdinalItem(
    key: "General - High activity extra factor", initialValue: 0.5,
    userDefaults: Settings.userDefaults)

  lazy var generalPredefinedAmounts = PredefinedAmounts()
  
  #if AQUAZLITE
  lazy var generalFullVersion: SettingsOrdinalItem<Bool> = SettingsOrdinalItem(
    key: "General - Full version", initialValue: false,
    userDefaults: Settings.userDefaults)
  
  lazy var generalAdCounter: SettingsOrdinalItem<Int> = SettingsOrdinalItem(
    key: "General - Ad counter", initialValue: GlobalConstants.numberOfIntakesToShowAd,
    userDefaults: Settings.userDefaults)
  
  lazy var generalAdUserId = SettingsOrdinalItem(
    key: "General - Ad user id", initialValue: UUID().uuidString, userDefaults: Settings.userDefaults)
  #endif

  // MARK: User
  
  lazy var userHeight: SettingsOrdinalItem<Double> = SettingsOrdinalItem(
    key: "User - Height", initialValue: 170,
    userDefaults: Settings.userDefaults)
  
  lazy var userWeight: SettingsOrdinalItem<Double> = SettingsOrdinalItem(
    key: "User - Weight", initialValue: 70,
    userDefaults: Settings.userDefaults)
  
  lazy var userPhysicalActivity: SettingsEnumItem<PhysicalActivity> = SettingsEnumItem(
    key: "User - Physical activity", initialValue: .occasional,
    userDefaults: Settings.userDefaults)
  
  lazy var userGender: SettingsEnumItem<Gender> = SettingsEnumItem(
    key: "User - Gender", initialValue: .man,
    userDefaults: Settings.userDefaults)
  
  lazy var userAge: SettingsOrdinalItem<Int> = SettingsOrdinalItem(
    key: "User - Age", initialValue: 30,
    userDefaults: Settings.userDefaults)
  
  lazy var userDailyWaterIntake: SettingsOrdinalItem<Double> = SettingsOrdinalItem(
    key: "User - Daily water intake", initialValue: Settings.calcUserDailyWaterIntakeSetting(),
    userDefaults: Settings.userDefaults)

  // MARK: User Interface
  
  lazy var uiUseCustomDateForDayView: SettingsOrdinalItem<Bool> = SettingsOrdinalItem(
    key: "UI - Use custom day page date", initialValue: false,
    userDefaults: Settings.userDefaults)
  
  lazy var uiCustomDateForDayView: SettingsOrdinalItem<Date> = SettingsOrdinalItem(
    key: "UI - Day page date", initialValue: Date(),
    userDefaults: Settings.userDefaults)

  lazy var uiDisplayDailyWaterIntakeInPercents: SettingsOrdinalItem<Bool> = SettingsOrdinalItem(
    key: "UI - Display daily water intake in percents", initialValue: false,
    userDefaults: Settings.userDefaults)

  lazy var uiSelectedStatisticsPage: SettingsEnumItem<StatisticsViewPage> = SettingsEnumItem(
    key: "UI - Selected statistics page", initialValue: .week,
    userDefaults: Settings.userDefaults)

  lazy var uiSelectedAlcoholicDrink: SettingsEnumItem<DrinkType> = SettingsEnumItem(
    key: "UI - Selected alcoholic drink", initialValue: .wine,
    userDefaults: Settings.userDefaults)

  lazy var uiWaterGoalReachingIsShownForDate: SettingsOrdinalItem<Date> = SettingsOrdinalItem(
    key: "UI - Water goal reaching is shown for date",
    initialValue: DateHelper.previousYearBefore(Date()), // It should be any not today date
    userDefaults: Settings.userDefaults)

  lazy var uiDayPageHelpTipToShow: SettingsEnumItem<DayPageHelpTip> = SettingsEnumItem(
    key: "UI - Day page help tip to show", initialValue: DayPageHelpTip(rawValue: 0)!,
    userDefaults: Settings.userDefaults)
  
  lazy var uiDayPageAlcoholicDehydratrionHelpTipIsShown: SettingsOrdinalItem<Bool> = SettingsOrdinalItem(
    key: "UI - Day page alcoholic dehydration help tip is shown", initialValue: false,
    userDefaults: Settings.userDefaults)

  lazy var uiDayPageIntakesCountTillHelpTip: SettingsOrdinalItem<Int> = SettingsOrdinalItem(
    key: "UI - Day page intakes count till help tip", initialValue: 0,
    userDefaults: Settings.userDefaults)

  lazy var uiWritingReviewAlertSelection: SettingsEnumItem<RateApplicationAlertSelection> = SettingsEnumItem(
    key: "UI - Writing review alert selection", initialValue: .remindLater,
    userDefaults: Settings.userDefaults)

  lazy var uiIntakesCountTillShowWritingReviewAlert: SettingsOrdinalItem<Int> = SettingsOrdinalItem(
    key: "UI - Intakes count till show writing review alert", initialValue: GlobalConstants.numberOfIntakesToShowReviewAlert,
    userDefaults: Settings.userDefaults)

  lazy var uiIntakeHelpTipIsShown = SettingsOrdinalItem<Bool>(
    key: "UI - Intake page help tip is shown", initialValue: false,
    userDefaults: Settings.userDefaults)
  

  lazy var uiDiaryPageHelpTipIsShown: SettingsOrdinalItem<Bool> = SettingsOrdinalItem(
    key: "UI - Diary page help tip is shown", initialValue: false,
    userDefaults: Settings.userDefaults)
  
  lazy var uiWeekStatisticsPageHelpTipToShow: SettingsEnumItem<WeekStatisticsPageHelpTip> = SettingsEnumItem(
    key: "UI - Week statistics page help tip to show", initialValue: WeekStatisticsPageHelpTip(rawValue: 0)!,
    userDefaults: Settings.userDefaults)

  lazy var uiMonthStatisticsPageHelpTipIsShown: SettingsOrdinalItem<Bool> = SettingsOrdinalItem(
    key: "UI - Month statistics page help tip is shown", initialValue: false,
    userDefaults: Settings.userDefaults)

  lazy var uiYearStatisticsPageHelpTipIsShown: SettingsOrdinalItem<Bool> = SettingsOrdinalItem(
    key: "UI - Year statistics page help tip is shown", initialValue: false,
    userDefaults: Settings.userDefaults)

  // MARK: Notifications
  
  lazy var notificationsEnabled: SettingsOrdinalItem<Bool> = SettingsOrdinalItem(
    key: "Notifications - Enabled", initialValue: false,
    userDefaults: Settings.userDefaults)
  
  lazy var notificationsFrom: SettingsOrdinalItem<Date> = SettingsOrdinalItem(
    key: "Notifications - From", initialValue: DateHelper.dateBySettingHour(9, minute: 0, second: 0, ofDate: Date()),
    userDefaults: Settings.userDefaults)
  
  lazy var notificationsTo: SettingsOrdinalItem<Date> = SettingsOrdinalItem(
    key: "Notifications - To", initialValue: DateHelper.dateBySettingHour(21, minute: 0, second: 0, ofDate: Date()),
    userDefaults: Settings.userDefaults)

  lazy var notificationsInterval: SettingsOrdinalItem<TimeInterval> = SettingsOrdinalItem(
    key: "Notifications - Interval", initialValue: 60 * 60 * 1.5,
    userDefaults: Settings.userDefaults)
  
  lazy var notificationsSound: SettingsOrdinalItem<String> = SettingsOrdinalItem(
    key: "Notifications - Sound", initialValue: "aqua.caf",
    userDefaults: Settings.userDefaults)
  
  lazy var notificationsSmart: SettingsOrdinalItem<Bool> = SettingsOrdinalItem(
    key: "Notifications - Smart", initialValue: false,
    userDefaults: Settings.userDefaults)

  lazy var notificationsLimit: SettingsOrdinalItem<Bool> = SettingsOrdinalItem(
    key: "Notifications - Check water goal reaching", initialValue: false,
    userDefaults: Settings.userDefaults)

  // MARK: Setting items for Apple Watch
  
  func getExportedSettingsForWatchApp() -> [String: Any] {
    var exportedSettings = [String: Any]()
    
    addSettingItemToDictionary(dictionary: &exportedSettings, settingItem: generalVolumeUnits)
    
    return exportedSettings
  }
  
  fileprivate func addSettingItemToDictionary<T>(dictionary: inout [String: Any], settingItem: SettingsItemBase<T>) {
    if let pair = settingItem.keyValuePair {
      dictionary[pair.key] = pair.value
    }
  }
  
  // MARK: Helpers
  
  fileprivate class var isMetric: Bool {
    return (Locale.current as NSLocale).object(forKey: NSLocale.Key.usesMetricSystem)! as! Bool
  }

  class func calcUserDailyWaterIntakeSetting() -> Double {
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

extension Units.Length {
  static var settings: Units.Length {
    return Settings.sharedInstance.generalHeightUnits.value
  }
}

extension Units.Volume {
  static var settings: Units.Volume {
    return Settings.sharedInstance.generalVolumeUnits.value
  }
}

extension Units.Weight {
  static var settings: Units.Weight {
    return Settings.sharedInstance.generalWeightUnits.value
  }
}
