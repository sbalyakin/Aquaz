//
//  ConnectivityMessageUpdatedSettings.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 17.11.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import Foundation

final class ConnectivityMessageUpdatedSettings {
  
  // MARK: Types
  
  fileprivate struct Keys {
    static let settings = "settings"
  }
  
  fileprivate struct Constants {
    static let messageKey   = "message"
    static let messageValue = "ConnectivityMessageUpdatedSettings"
  }
  
  // MARK: Properties
  
  var settings: [String: Any]
  
  // MARK: Methods
  
  init(settings: [String: Any]) {
    self.settings = settings
  }
  
  init?(metadata: [String : Any]) {
    guard
      let messageValue = metadata[Constants.messageKey] as? String , messageValue == Constants.messageValue,
      let settings = metadata[Keys.settings] as? [String: Any] else
    {
      self.settings = [:]
      return nil
    }
    
    self.settings = settings
  }
  
  func composeMetadata() -> [String : Any] {
    var metadata = [String : Any]()
    
    metadata[Constants.messageKey] = Constants.messageValue
    metadata[Keys.settings] = settings
    
    return metadata
  }
  
}
