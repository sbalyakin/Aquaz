//
//  Settings.swift
//  Water Me
//
//  Created by Sergey Balyakin on 06.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

class Settings {
  
  class General {
    class var isMetricWeight: Bool {
      get {
        if let value = NSUserDefaults.standardUserDefaults().objectForKey("General.isMetricWeight") as? Bool {
          return value
        }
        return true
      }
      set {
        NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "General.isMetricWeight")
      }
    }
    
    class var isMetricHeight: Bool {
      get {
        if let value = NSUserDefaults.standardUserDefaults().objectForKey("General.isMetricHeight") as? Bool {
          return value
        }
        return true
      }
      set {
        NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "General.isMetricHeight")
      }
    }
    
    class var isMetricVolume: Bool {
      get {
        if let value = NSUserDefaults.standardUserDefaults().objectForKey("General.isMetricVolume") as? Bool {
          return value
        }
        return true
      }
      set {
        NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "General.isMetricVolume")
      }
    }

    class var extraConsumptionHot: Double {
      get {
        if let value = NSUserDefaults.standardUserDefaults().objectForKey("General.extraConsumptionHot") as? Double {
          return value
        }
        return 0.5
      }
      set {
        NSUserDefaults.standardUserDefaults().setDouble(newValue, forKey: "General.extraConsumptionHot")
      }
    }
    
    class var extraConsumptionHighActivity: Double {
      get {
        if let value = NSUserDefaults.standardUserDefaults().objectForKey("General.extraConsumptionHighActivity") as? Double {
          return value
        }
        return 0.5
      }
      set {
        NSUserDefaults.standardUserDefaults().setDouble(newValue, forKey: "General.extraConsumptionHighActivity")
      }
    }
  }

  class User {
    class var height: Int {
      get {
        if let value = NSUserDefaults.standardUserDefaults().objectForKey("User.height") as? Int {
          return value
        }
        return 170
      }
      set {
        NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: "User.height")
      }
    }

    class var weight: Int {
      get {
        if let value = NSUserDefaults.standardUserDefaults().objectForKey("User.weight") as? Int {
          return value
        }
        return 70
      }
      set {
        NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: "User.weight")
      }
    }
    
    enum ActivityLevel: Int {
      case Low = 0
      case Medium
      case High
    }
    
    class var activityLevel: ActivityLevel {
      get {
        if let value = NSUserDefaults.standardUserDefaults().objectForKey("User.activityLevel") as? Int {
          if let activityLevel = ActivityLevel(rawValue: value) {
            return activityLevel
          }
        }
        return .Medium
      }
      set {
        NSUserDefaults.standardUserDefaults().setInteger(newValue.rawValue, forKey: "User.activityLevel")
      }
    }
    
    class var isMale: Bool {
      get {
        if let value = NSUserDefaults.standardUserDefaults().objectForKey("User.isMale") as? Bool {
          return value
        }
        return true
      }
      set {
        NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "User.isMale")
      }
    }
    
    class var age: Int {
      get {
        if let value = NSUserDefaults.standardUserDefaults().objectForKey("User.age") as? Int {
          return value
        }
        return 30
      }
      set {
        NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: "User.age")
      }
    }
    
    class var waterPerDay: Int {
      get {
        if let value = NSUserDefaults.standardUserDefaults().objectForKey("User.waterPerDay") as? Int {
          return value
        }
        return 2000
      }
      set {
        NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: "User.waterPerDay")
      }
    }
  }
  
}
