//
//  Settings.swift
//  Water Me
//
//  Created by Sergey Balyakin on 06.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

class Settings {
  
  class General {
    
    class var weightUnits: Units.Weight {
      get {
        if let value = NSUserDefaults.standardUserDefaults().objectForKey("General.weightUnits") as? Int {
          if let weightUnits = Units.Weight(rawValue: value) {
            return weightUnits
          }
        }
        return .kilograms
      }
      set {
        NSUserDefaults.standardUserDefaults().setInteger(newValue.rawValue, forKey: "General.weightUnits")
      }
    }
    
    class var heightUnits: Units.Length {
      get {
        if let value = NSUserDefaults.standardUserDefaults().objectForKey("General.heightUnits") as? Int {
          if let heightUnits = Units.Length(rawValue: value) {
            return heightUnits
          }
        }
        return .centimeters
      }
      set {
        NSUserDefaults.standardUserDefaults().setInteger(newValue.rawValue, forKey: "General.heightUnits")
      }
    }
    
    class var volumeUnits: Units.Volume {
      get {
        if let value = NSUserDefaults.standardUserDefaults().objectForKey("General.volumeUnits") as? Int {
          if let volumeUnits = Units.Volume(rawValue: value) {
            return volumeUnits
          }
        }
        return .millilitres
      }
      set {
        NSUserDefaults.standardUserDefaults().setInteger(newValue.rawValue, forKey: "General.volumeUnits")
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
