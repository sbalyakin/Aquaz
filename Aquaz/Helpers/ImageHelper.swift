//
//  ImageHelper.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 12.06.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import Foundation

struct ImageHelper {
  
  enum Image: String {
    case BannerReward = "BannerReward"
    case IconHighActivityActive = "IconHighActivityActive"
    case IconHotWeatherActive = "IconHotWeatherActive"
    case SettingsWater = "SettingsWater"
    case SettingsExtraFactors = "SettingsExtraFactors"
    case SettingsUnits = "SettingsUnits"
    case SettingsNotifications = "SettingsNotifications"
    case SettingsFeedback = "SettingsFeedback"
    case SettingsHealthKit = "SettingsHealthKit"
  }
  
  static func loadImage(_ image: Image) -> UIImage? {
    return UIImage(named: image.rawValue)
  }
  
  // Hide initializer
  fileprivate init() {
  }
  
}
