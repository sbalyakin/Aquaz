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
  
  private struct Keys {
    static let settings    = "settings"
  }
  
  private struct Constants {
    static let messageKey   = "message"
    static let messagevalue = "ConnectivityMessageUpdatedSettings"
  }
  
  // MARK: Properties
  
  var settings: [String: AnyObject]
  
  // MARK: Methods
  
  init(settings: [String: AnyObject]) {
    self.settings    = settings
  }
  
  init?(metadata: [String : AnyObject]) {
    guard
      let messageValue = metadata[Constants.messageKey] as? String where messageValue == Constants.messagevalue,
      let settings     = metadata[Keys.settings]        as? [String: AnyObject] else
    {
      self.settings = [:]
      
      return nil
    }
    
    self.settings = settings
  }
  
  func composeMetadata() -> [String : AnyObject] {
    var metadata = [String : AnyObject]()
    
    metadata[Constants.messageKey] = Constants.messagevalue
    metadata[Keys.settings]        = settings
    
    return metadata
  }
  
}