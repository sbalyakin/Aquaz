//
//  WormholeHelper.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 09.04.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import Foundation

class WormholeHelper {
  
  static let optionalDirectory = "wormhole"
  
  class func createWormhole() -> MMWormhole {
    return MMWormhole(applicationGroupIdentifier: GlobalConstants.appGroupName, optionalDirectory: optionalDirectory)
  }
  
  enum MessageIdentifier: String {
    case ManageObjectContextDidSave = "ManageObjectContextDidSave"
  }
  
  class ManageObjectContextDidSaveMessage {
    
    static let identifier = MessageIdentifier.ManageObjectContextDidSave.rawValue
    static let contextItem = "Context"
    
    typealias MessageObject = [String: String]
    
    enum Context: String {
      case Aquaz = "Aquaz"
      case Widget = "Widget"
    }
    
    class func pass(wormhole: MMWormhole!, context: Context) {
      let messageObject = self.createMessageObject(context)
      wormhole?.passMessageObject(messageObject, identifier: identifier)
    }
    
    class func listen(wormhole: MMWormhole!, listener: (Context) -> ()) {
      wormhole?.listenForMessageWithIdentifier(identifier) { (messageObject) -> Void in
        if let context = self.contextFromMessageObject(messageObject) {
          listener(context)
        }
      }
    }
    
    class func createMessageObject(context: Context) -> MessageObject {
      return [contextItem: context.rawValue]
    }
    
    class func contextFromMessageObject(messageObject: AnyObject!) -> Context? {
      if let
        messageObject = messageObject as? MessageObject,
        contextValue = messageObject[contextItem],
        context = Context(rawValue: contextValue)
      {
        return context
      } else {
        return nil
      }
    }
    
  }
  
}
