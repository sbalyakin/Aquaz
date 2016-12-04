//
//  GlobalConstants.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 30.03.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import Foundation

class GlobalConstants {

  #if AQUAZPRO
  static let applicationIdentifier = "963482552"
  static let applicationSchemeURL = "aquazpro://"
  static let bundleId = "com.devmanifest.Aquaz"
  #else // AQUAZLITE
  static let applicationIdentifier = "1175933484"
  static let applicationSchemeURL = "aquazlite://"
  static let bundleId = "com.devmanifest.AquazLite"
  static let inAppPurchaseFullVersion = "com.devmanifest.AquazLite.fullversion"
  static let inAppPurchaseFullVersionId = "1181032477"
  static let numberOfIntakesToShowAd = 6
  #endif
  
  static let appStoreLink = "http://itunes.apple.com/app/id\(GlobalConstants.applicationIdentifier)"
  static let appReviewLink = "itms-apps://itunes.apple.com/app/id\(GlobalConstants.applicationIdentifier)"
  static let appGroupName = "group.com.devmanifest.Aquaz"

  static let developerMail = "devmanifest@gmail.com"
  
  static let wormholeOptionalDirectory = "AquazPro-Wormhole"
  static let wormholeMessageFromAquaz = "AquazPro-From App"
  static let wormholeMessageFromWidget = "AquazPro-From Widget"
  
  static let notificationManagedObjectContextWasMerged = "Aquaz-ManagedObjectContextWasMerged"
  static let notificationWatchAddIntake = "AquazWatch-AddIntake"
  static let notificationWatchCurrentState = "AquazWatch-CurrentState"
  static let notificationFullVersionIsPurchased = "AquazFullVersionIsPurchased"
  static let notificationFullVersionPurchaseStateDidChange = "AquazFullVersionPurchaseStateDidChange"

  static let numberOfIntakesToShowReviewAlert = 15
  
  static let storyboardMain = "Main"
  static let storyboardWelcome = "Welcome"
  
  static let helpTipDelayToShow: TimeInterval = 1
  static let helpTipDisplayTime: TimeInterval = 6

}
