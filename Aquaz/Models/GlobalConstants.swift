//
//  GlobalConstants.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 30.03.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

class GlobalConstants {

  static let applicationIdentifier = "963482552"
  static let applicationSchemeURL = "aquaz://"
 
  static let appGroupName = "group.com.devmanifest.Aquaz"
  static let appStoreLink = "http://itunes.apple.com/app/id\(GlobalConstants.applicationIdentifier)"

  static let inAppPurchaseFullVersion = "com.devmanifest.Aquaz.fullversion"

  static let localyticsApplicationKey = "8bcf40f515617dd5c3c5f48-061ebe74-0c2f-11e5-4ab9-00712085a1eb"
  
  static let developerMail = "devmanifest@gmail.com"
  
  static let wormholeOptionalDirectory = "wormhole"
  static let wormholeMessageFromAquaz = "From Aquaz"
  static let wormholeMessageFromWidget = "From Widget"
  
  static let notificationManagedObjectContextWasMerged = "AquazManagedObjectContextWasMerged"
  static let notificationFullVersionIsPurchased = "AquazFullVersionIsPurchased"
  static let notificationFullVersionPurchaseStateDidChange = "AquazFullVersionPurchaseStateDidChange"

  static let numberOfIntakesToShowAd = 5
  
  static let storyboardMain = "Main"
  static let storyboardWelcome = "Welcome"
  
  static let helpTipDisplayTime: NSTimeInterval = 5

}
