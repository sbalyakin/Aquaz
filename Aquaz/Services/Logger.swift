//
//  Logger.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 09.03.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import Foundation

public class Logger {

  struct Messages {
    static let failedToSaveManagedObjectContext = "Failed to save managed object context"
    static let failedToExecuteFetchRequest = "Failed to execute fetch request"
    static let failedToInstantiateViewController = "Failed to instantiate view controller"
    static let drinkIsNotFound = "Drink is not found"
    static let failedToInsertNewObjectForEntity = "Failed to insert new object for entity"
    static let failedToCreateEntityDescription = "Field to create entity description"
    static let imageNotFound = "Image not found"
    static let logicalError = "Logical error"
    static let inconsistentWaterIntakesAndGoals = "Number of grouped water intakes does not match to water goals count"
  }
  
  struct Attributes {
    static let message = "message"
    static let logLevel = "logLevel"
    static let fileName = "fileName"
    static let lineNumber = "lineNumber"
    static let details = "details"
    static let storyboardID = "storyboardID"
    static let drinkIndex = "drinkIndex"
    static let entity = "entity"
    static let name = "name"
    static let date = "date"
    static let count = "count"
  }
  
  public class var sharedInstance: Logger {
    struct Static {
      static var instance = Logger()
    }
    return Static.instance
  }
  
  var logLevel: LogLevel = .Warning
  var assertLevel: LogLevel = .Error
  var showLogLevel = true
  var showFileNames = true
  var showLineNumbers = true
  
  public enum LogLevel: Int, Printable {
    case Verbose = 0
    case Debug
    case Info
    case Warning
    case Error
    case Severe
    case None
    
    public var description: String {
      switch self {
      case .Verbose: return "Verbose"
      case .Debug:   return "Debug"
      case .Info:    return "Info"
      case .Warning: return "Warning"
      case .Error:   return "Error"
      case .Severe:  return "Severe"
      case .None:    return "None"
      }
    }
  }

  public func setup(logLevel: LogLevel = .Warning, assertLevel: LogLevel = .Error, showLogLevel: Bool = true, showFileNames: Bool = true, showLineNumbers: Bool = true) {
    self.logLevel = logLevel
    self.assertLevel = assertLevel
    self.showLogLevel = showLogLevel
    self.showFileNames = showFileNames
    self.showLineNumbers = showLineNumbers
  }

  public func isEnabledForLogLevel(logLevel: LogLevel) -> Bool {
    return logLevel.rawValue >= self.logLevel.rawValue
  }
  
  public func isAssertsEnabledForLogLevel(logLevel: LogLevel) -> Bool {
    return assertLevel.rawValue >= self.logLevel.rawValue
  }
  
  // MARK: logMessage
  public func logMessage(@autoclosure condition: () -> Bool, _ logMessage: String, logDetails: [String: String], logLevel: LogLevel, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__, forceAssert: Bool = false) {
    if forceAssert {
      assert(condition(), logMessage)
    } else if isAssertsEnabledForLogLevel(logLevel) {
      assert(condition(), logMessage)
    }
    
    if !isEnabledForLogLevel(logLevel) {
      return
    }

    if condition() == true {
      return
    }

    var attributes: [String: String] = [Attributes.message: logMessage]
    
    for (key, value) in logDetails {
      attributes.updateValue(value, forKey: key)
    }
    
    if showLogLevel {
      attributes[Attributes.logLevel] = self.logLevel.description
    }
    
    if showFileNames {
      attributes[Attributes.fileName] = fileName
    }
    
    if showLineNumbers {
      attributes[Attributes.lineNumber] = "\(lineNumber)"
    }
    
    Localytics.tagEvent(logLevel.description, attributes: attributes)
  }

  public func logMessage(@autoclosure condition: () -> Bool, _ logMessage: String, logDetails: String = "", logLevel: LogLevel, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__, forceAssert: Bool = false) {
    let detailsMap = logDetails.isEmpty ? [:] : [Attributes.details: logDetails]
    self.logMessage(condition, logMessage, logDetails: detailsMap, logLevel: logLevel, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: forceAssert)
  }
  
  public func logMessage(logMessage: String, logDetails: [String: String], logLevel: LogLevel, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__, forceAssert: Bool = false) {
    self.logMessage(false, logMessage, logDetails: logDetails, logLevel: logLevel, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: forceAssert)
  }

  public func logMessage(logMessage: String, logDetails: String = "", logLevel: LogLevel, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__, forceAssert: Bool = false) {
    let detailsMap = logDetails.isEmpty ? [:] : [Attributes.details: logDetails]
    self.logMessage(false, logMessage, logDetails: detailsMap, logLevel: logLevel, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: forceAssert)
  }
  
  // MARK: logVerbose
  public func logVerbose(@autoclosure condition: () -> Bool, _ logMessage: String, logDetails: [String: String], functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    self.logMessage(condition, logMessage, logDetails: logDetails, logLevel: .Verbose, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: false)
  }

  public func logVerbose(@autoclosure condition: () -> Bool, _ logMessage: String, logDetails: String = "", functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    self.logMessage(condition, logMessage, logDetails: logDetails, logLevel: .Verbose, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: false)
  }

  public func logVerbose(logMessage: String, logDetails: [String: String], functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    self.logMessage(logMessage, logDetails: logDetails, logLevel: .Verbose, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  public func logVerbose(logMessage: String, logDetails: String = "", functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    self.logMessage(logMessage, logDetails: logDetails, logLevel: .Verbose, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  // MARK: logDebug
  public func logDebug(@autoclosure condition: () -> Bool, _ logMessage: String, logDetails: [String: String], functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    self.logMessage(condition, logMessage, logDetails: logDetails, logLevel: .Debug, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: false)
  }
  
  public func logDebug(@autoclosure condition: () -> Bool, _ logMessage: String, logDetails: String = "", functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    self.logMessage(condition, logMessage, logDetails: logDetails, logLevel: .Debug, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: false)
  }
  
  public func logDebug(logMessage: String, logDetails: [String: String], functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    self.logMessage(logMessage, logDetails: logDetails, logLevel: .Debug, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  public func logDebug(logMessage: String, logDetails: String = "", functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    self.logMessage(logMessage, logDetails: logDetails, logLevel: .Debug, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  // MARK: logInfo
  public func logInfo(@autoclosure condition: () -> Bool, _ logMessage: String, logDetails: [String: String], functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    self.logMessage(condition, logMessage, logDetails: logDetails, logLevel: .Info, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: false)
  }
  
  public func logInfo(@autoclosure condition: () -> Bool, _ logMessage: String, logDetails: String = "", functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    self.logMessage(condition, logMessage, logDetails: logDetails, logLevel: .Info, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: false)
  }
  
  public func logInfo(logMessage: String, logDetails: [String: String], functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    self.logMessage(logMessage, logDetails: logDetails, logLevel: .Info, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  public func logInfo(logMessage: String, logDetails: String = "", functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    self.logMessage(logMessage, logDetails: logDetails, logLevel: .Info, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }

  // MARK: logWarning
  public func logWarning(@autoclosure condition: () -> Bool, _ logMessage: String, logDetails: [String: String], functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    self.logMessage(condition, logMessage, logDetails: logDetails, logLevel: .Warning, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: false)
  }
  
  public func logWarning(@autoclosure condition: () -> Bool, _ logMessage: String, logDetails: String = "", functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    self.logMessage(condition, logMessage, logDetails: logDetails, logLevel: .Warning, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: false)
  }
  
  public func logWarning(logMessage: String, logDetails: [String: String], functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    self.logMessage(logMessage, logDetails: logDetails, logLevel: .Warning, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  public func logWarning(logMessage: String, logDetails: String = "", functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    self.logMessage(logMessage, logDetails: logDetails, logLevel: .Warning, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  // MARK: logError
  public func logError(@autoclosure condition: () -> Bool, _ logMessage: String, logDetails: [String: String], functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    self.logMessage(condition, logMessage, logDetails: logDetails, logLevel: .Error, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: false)
  }
  
  public func logError(@autoclosure condition: () -> Bool, _ logMessage: String, logDetails: String = "", functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    self.logMessage(condition, logMessage, logDetails: logDetails, logLevel: .Error, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: false)
  }
  
  public func logError(logMessage: String, logDetails: [String: String], functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    self.logMessage(logMessage, logDetails: logDetails, logLevel: .Error, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  public func logError(logMessage: String, logDetails: String = "", functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    self.logMessage(logMessage, logDetails: logDetails, logLevel: .Error, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  public func logError(logMessage: String, error: NSError?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    self.logMessage(logMessage, logDetails: error?.description ?? "", logLevel: .Error, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  // MARK: logSevere
  public func logSevere(@autoclosure condition: () -> Bool, _ logMessage: String, logDetails: [String: String], functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    self.logMessage(condition, logMessage, logDetails: logDetails, logLevel: .Severe, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: false)
  }
  
  public func logSevere(@autoclosure condition: () -> Bool, _ logMessage: String, logDetails: String = "", functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    self.logMessage(condition, logMessage, logDetails: logDetails, logLevel: .Severe, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: false)
  }
  
  public func logSevere(logMessage: String, logDetails: [String: String], functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    self.logMessage(logMessage, logDetails: logDetails, logLevel: .Severe, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  public func logSevere(logMessage: String, logDetails: String = "", functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    self.logMessage(logMessage, logDetails: logDetails, logLevel: .Severe, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  // MARK: Convenience class methods -
  
  public class func setup(logLevel: LogLevel = .Warning, assertLevel: LogLevel = .Error, showLogLevel: Bool = true, showFileNames: Bool = true, showLineNumbers: Bool = true) {
    sharedInstance.setup(logLevel: logLevel, assertLevel: assertLevel, showLogLevel: showLogLevel, showFileNames: showFileNames, showLineNumbers: showLineNumbers)
  }

  // MARK: logMessage
  public class func logMessage(@autoclosure condition: () -> Bool, _ logMessage: String, logDetails: String, logLevel: LogLevel, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__, forceAssert: Bool = false) {
    sharedInstance.logMessage(condition, logMessage, logDetails: logDetails, logLevel: logLevel, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: forceAssert)
  }
  
  public class func logMessage(@autoclosure condition: () -> Bool, _ logMessage: String, logDetails: [String: String], logLevel: LogLevel, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__, forceAssert: Bool = false) {
    sharedInstance.logMessage(condition, logMessage, logDetails: logDetails, logLevel: logLevel, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: forceAssert)
  }
  
  public class func logMessage(logMessage: String, logDetails: String, logLevel: LogLevel, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__, forceAssert: Bool = false) {
    sharedInstance.logMessage(logMessage, logDetails: logDetails, logLevel: logLevel, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: forceAssert)
  }

  public class func logMessage(logMessage: String, logDetails: [String: String], logLevel: LogLevel, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__, forceAssert: Bool = false) {
    sharedInstance.logMessage(logMessage, logDetails: logDetails, logLevel: logLevel, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: forceAssert)
  }

  // MARK: logVerbose
  public class func logVerbose(@autoclosure condition: () -> Bool, _ logMessage: String, logDetails: [String: String], functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    sharedInstance.logVerbose(condition, logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  public class func logVerbose(@autoclosure condition: () -> Bool, _ logMessage: String, logDetails: String = "", functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    sharedInstance.logVerbose(condition, logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  public class func logVerbose(logMessage: String, logDetails: [String: String], functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    sharedInstance.logVerbose(logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  public class func logVerbose(logMessage: String, logDetails: String = "", functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    sharedInstance.logVerbose(logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  // MARK: logDebug
  public class func logDebug(@autoclosure condition: () -> Bool, _ logMessage: String, logDetails: [String: String], functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    sharedInstance.logDebug(condition, logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  public class func logDebug(@autoclosure condition: () -> Bool, _ logMessage: String, logDetails: String = "", functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    sharedInstance.logDebug(condition, logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  public class func logDebug(logMessage: String, logDetails: [String: String], functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    sharedInstance.logDebug(logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  public class func logDebug(logMessage: String, logDetails: String = "", functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    sharedInstance.logDebug(logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  // MARK: logInfo
  public class func logInfo(@autoclosure condition: () -> Bool, _ logMessage: String, logDetails: [String: String], functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    sharedInstance.logInfo(condition, logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  public class func logInfo(@autoclosure condition: () -> Bool, _ logMessage: String, logDetails: String = "", functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    sharedInstance.logInfo(condition, logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  public class func logInfo(logMessage: String, logDetails: [String: String], functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    sharedInstance.logInfo(logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }

  public class func logInfo(logMessage: String, logDetails: String = "", functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    sharedInstance.logInfo(logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  // MARK: logWarning
  public class func logWarning(@autoclosure condition: () -> Bool, _ logMessage: String, logDetails: [String: String], functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    sharedInstance.logWarning(condition, logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  public class func logWarning(@autoclosure condition: () -> Bool, _ logMessage: String, logDetails: String = "", functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    sharedInstance.logWarning(condition, logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  public class func logWarning(logMessage: String, logDetails: [String: String], functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    sharedInstance.logWarning(logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  public class func logWarning(logMessage: String, logDetails: String = "", functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    sharedInstance.logWarning(logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  // MARK: logError
  public class func logError(@autoclosure condition: () -> Bool, _ logMessage: String, logDetails: [String: String], functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    sharedInstance.logError(condition, logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  public class func logError(@autoclosure condition: () -> Bool, _ logMessage: String, logDetails: String = "", functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    sharedInstance.logError(condition, logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  public class func logError(logMessage: String, logDetails: [String: String], functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    sharedInstance.logError(logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  public class func logError(logMessage: String, logDetails: String = "", functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    sharedInstance.logError(logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  public class func logError(logMessage: String, error: NSError?, functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    sharedInstance.logError(logMessage, error: error, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  // MARK: logSevere
  public class func logSevere(@autoclosure condition: () -> Bool, _ logMessage: String, logDetails: [String: String], functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    sharedInstance.logSevere(condition, logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  public class func logSevere(@autoclosure condition: () -> Bool, _ logMessage: String, logDetails: String = "", functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    sharedInstance.logSevere(condition, logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }

  public class func logSevere(logMessage: String, logDetails: [String: String], functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    sharedInstance.logSevere(logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }

  public class func logSevere(logMessage: String, logDetails: String = "", functionName: String = __FUNCTION__, fileName: String = __FILE__, lineNumber: Int = __LINE__) {
    sharedInstance.logSevere(logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  // Hide initializer from direct usage
  private init() { }
  
}


// MARK: Popular checks and logs
extension Logger {
  public class func checkViewController(@autoclosure condition: () -> Bool, storyboardID: String) {
    logMessage(condition, Messages.failedToInstantiateViewController, logDetails: [Attributes.storyboardID: storyboardID], logLevel: .Severe, functionName: __FUNCTION__, fileName: __FILE__, lineNumber: __LINE__, forceAssert: false)
  }
  
  public class func logDrinkIsNotFound(#drinkIndex: Int, logLevel: LogLevel = .Error) {
    logMessage(Messages.drinkIsNotFound, logDetails: [Attributes.drinkIndex: "\(drinkIndex)"], logLevel: logLevel)
  }
  
  
}