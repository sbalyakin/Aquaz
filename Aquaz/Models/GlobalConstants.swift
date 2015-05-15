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

  static let localyticsApplicationKey = "5f18fc62efbdeb52bd87247-87c1e42e-c5ae-11e4-ae01-009c5fda0a25"
  
  static let developerMail = "devmanifest@gmail.com"
  
  static let wormholeOptionalDirectory = "wormhole"
  static let wormholeMessageFromAquaz = "From Aquaz"
  static let wormholeMessageFromWidget = "From Widget"
  
  static let notificationManagedObjectContextWasMerged = "AquazManagedObjectContextWasMerged"
  static let notificationFullVersionIsPurchased = "AquazFullVersionIsPurchased"
  static let notificationInAppPurchaseManagerDidStartTask = "AquazInAppPurchaseManagerDidStartTask"
  static let notificationInAppPurchaseManagerDidFinishTask = "AquazInAppPurchaseManagerDidFinishTask"

  static let numberOfIntakesToShowAd = 5
}
