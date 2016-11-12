//
//  GlobalConstants.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 30.03.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import Foundation

class GlobalConstants {

  static let applicationIdentifier = "963482552"
  static let applicationSchemeURL = "aquazpro://"
 
  static let bundleId = "com.devmanifest.Aquaz"
  static let appGroupName = "group.com.devmanifest.Aquaz"
  static let appStoreLink = "http://itunes.apple.com/app/id\(GlobalConstants.applicationIdentifier)"
  static let appReviewLink = "itms-apps://itunes.apple.com/app/id\(GlobalConstants.applicationIdentifier)"

  static let developerMail = "devmanifest@gmail.com"
  
  static let wormholeOptionalDirectory = "AquazPro-Wormhole"
  static let wormholeMessageFromAquaz = "AquazPro-From App"
  static let wormholeMessageFromWidget = "AquazPro-From Widget"
  
  static let notificationManagedObjectContextWasMerged = "Aquaz-ManagedObjectContextWasMerged"
  static let notificationWatchAddIntake = "AquazWatch-AddIntake"
  static let notificationWatchCurrentState = "AquazWatch-CurrentState"

  static let numberOfIntakesToShowReviewAlert = 15
  
  static let storyboardMain = "Main"
  static let storyboardWelcome = "Welcome"
  
  static let helpTipDelayToShow: TimeInterval = 1
  static let helpTipDisplayTime: TimeInterval = 6

}
