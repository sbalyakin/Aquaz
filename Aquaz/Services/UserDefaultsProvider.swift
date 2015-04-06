//
//  UserDefaultsProvider.swift
//  Aquaz
//
//  Created by Admin on 06.04.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import Foundation

class UserDefaultsProvider {
  
  static var sharedUserDefaults = NSUserDefaults(suiteName: GlobalConstants.appGroupName)!
  
}