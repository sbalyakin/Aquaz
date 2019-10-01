//
//  Logger.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 09.03.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import Foundation
import Crashlytics

class Logger {

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
    static let functionName = "functionName"
    static let details = "details"
    static let storyboardID = "storyboardID"
    static let drinkIndex = "drinkIndex"
    static let entity = "entity"
    static let name = "name"
    static let date = "date"
    static let count = "count"
  }
  
  static let sharedInstance = Logger()
  
  var logLevel: LogLevel = .warning
  var assertLevel: LogLevel = .error
  var consoleLevel: LogLevel = .warning
  var showLogLevel = true
  var showFileNames = true
  var showLineNumbers = true
  var showFunctionNames = true
  
  enum LogLevel: Int, CustomStringConvertible {
    case verbose = 0
    case debug
    case info
    case warning
    case error
    case severe
    case none
    
    var description: String {
      switch self {
      case .verbose: return "Verbose"
      case .debug:   return "Debug"
      case .info:    return "Info"
      case .warning: return "Warning"
      case .error:   return "Error"
      case .severe:  return "Severe"
      case .none:    return "None"
      }
    }
  }

  func setup(logLevel: LogLevel = .warning, assertLevel: LogLevel = .error, consoleLevel: LogLevel = .warning, showLogLevel: Bool = true, showFileNames: Bool = true, showLineNumbers: Bool = true, showFunctionNames: Bool = true) {
    self.logLevel = logLevel
    self.assertLevel = assertLevel
    self.consoleLevel = consoleLevel
    self.showLogLevel = showLogLevel
    self.showFileNames = showFileNames
    self.showLineNumbers = showLineNumbers
    self.showFunctionNames = showFunctionNames
  }

  func isEnabledForLogLevel(_ logLevel: LogLevel) -> Bool {
    return logLevel.rawValue >= self.logLevel.rawValue
  }
  
  func isAssertsEnabledForLogLevel(_ logLevel: LogLevel) -> Bool {
    return logLevel.rawValue >= self.assertLevel.rawValue
  }

  func isConsoleEnabledForLogLevel(_ logLevel: LogLevel) -> Bool {
    return logLevel.rawValue >= self.consoleLevel.rawValue
  }

  // MARK: logMessage
  func logMessage(_ condition: @autoclosure () -> Bool, _ logMessage: String, logDetails: [String: String], logLevel: LogLevel, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line, forceAssert: Bool = false) {
    if forceAssert || isAssertsEnabledForLogLevel(logLevel) {
      let message = logDetails.isEmpty ? logMessage : "\(logMessage) \r\n \(logDetails.description)"
      assert(condition(), message)
    }
    
    #if AQUAZ
      if !isEnabledForLogLevel(logLevel) && !isConsoleEnabledForLogLevel(logLevel) {
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
      
      if showFunctionNames {
        attributes[Attributes.functionName] = functionName
      }

      if isEnabledForLogLevel(logLevel) {
        Answers.logCustomEvent(withName: logLevel.description, customAttributes: attributes)
      }
      
      if isConsoleEnabledForLogLevel(logLevel) {
        let message = logDetails.isEmpty ? logMessage : "\(logMessage) \r\n \(logDetails.description)"
        print(message)
      }
    #endif
  }

  func logMessage(_ condition: @autoclosure () -> Bool, _ logMessage: String, logDetails: String = "", logLevel: LogLevel, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line, forceAssert: Bool = false) {
    let detailsMap = logDetails.isEmpty ? [:] : [Attributes.details: logDetails]
    self.logMessage(condition(), logMessage, logDetails: detailsMap, logLevel: logLevel, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: forceAssert)
  }
  
  func logMessage(_ logMessage: String, logDetails: [String: String], logLevel: LogLevel, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line, forceAssert: Bool = false) {
    self.logMessage(false, logMessage, logDetails: logDetails, logLevel: logLevel, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: forceAssert)
  }

  func logMessage(_ logMessage: String, logDetails: String = "", logLevel: LogLevel, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line, forceAssert: Bool = false) {
    let detailsMap = logDetails.isEmpty ? [:] : [Attributes.details: logDetails]
    self.logMessage(false, logMessage, logDetails: detailsMap, logLevel: logLevel, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: forceAssert)
  }
  
  // MARK: logVerbose
  func logVerbose(_ condition: @autoclosure () -> Bool, _ logMessage: String, logDetails: [String: String], functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.logMessage(condition(), logMessage, logDetails: logDetails, logLevel: .verbose, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: false)
  }

  func logVerbose(_ condition: @autoclosure () -> Bool, _ logMessage: String, logDetails: String = "", functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.logMessage(condition(), logMessage, logDetails: logDetails, logLevel: .verbose, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: false)
  }

  func logVerbose(_ logMessage: String, logDetails: [String: String], functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.logMessage(logMessage, logDetails: logDetails, logLevel: .verbose, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  func logVerbose(_ logMessage: String, logDetails: String = "", functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.logMessage(logMessage, logDetails: logDetails, logLevel: .verbose, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  // MARK: logDebug
  func logDebug(_ condition: @autoclosure () -> Bool, _ logMessage: String, logDetails: [String: String], functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.logMessage(condition(), logMessage, logDetails: logDetails, logLevel: .debug, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: false)
  }
  
  func logDebug(_ condition: @autoclosure () -> Bool, _ logMessage: String, logDetails: String = "", functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.logMessage(condition(), logMessage, logDetails: logDetails, logLevel: .debug, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: false)
  }
  
  func logDebug(_ logMessage: String, logDetails: [String: String], functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.logMessage(logMessage, logDetails: logDetails, logLevel: .debug, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  func logDebug(_ logMessage: String, logDetails: String = "", functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.logMessage(logMessage, logDetails: logDetails, logLevel: .debug, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  // MARK: logInfo
  func logInfo(_ condition: @autoclosure () -> Bool, _ logMessage: String, logDetails: [String: String], functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.logMessage(condition(), logMessage, logDetails: logDetails, logLevel: .info, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: false)
  }
  
  func logInfo(_ condition: @autoclosure () -> Bool, _ logMessage: String, logDetails: String = "", functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.logMessage(condition(), logMessage, logDetails: logDetails, logLevel: .info, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: false)
  }
  
  func logInfo(_ logMessage: String, logDetails: [String: String], functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.logMessage(logMessage, logDetails: logDetails, logLevel: .info, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  func logInfo(_ logMessage: String, logDetails: String = "", functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.logMessage(logMessage, logDetails: logDetails, logLevel: .info, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }

  // MARK: logWarning
  func logWarning(_ condition: @autoclosure () -> Bool, _ logMessage: String, logDetails: [String: String], functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.logMessage(condition(), logMessage, logDetails: logDetails, logLevel: .warning, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: false)
  }
  
  func logWarning(_ condition: @autoclosure () -> Bool, _ logMessage: String, logDetails: String = "", functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.logMessage(condition(), logMessage, logDetails: logDetails, logLevel: .warning, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: false)
  }
  
  func logWarning(_ logMessage: String, logDetails: [String: String], functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.logMessage(logMessage, logDetails: logDetails, logLevel: .warning, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  func logWarning(_ logMessage: String, logDetails: String = "", functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.logMessage(logMessage, logDetails: logDetails, logLevel: .warning, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  // MARK: logError
  func logError(_ condition: @autoclosure () -> Bool, _ logMessage: String, logDetails: [String: String], functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.logMessage(condition(), logMessage, logDetails: logDetails, logLevel: .error, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: false)
  }
  
  func logError(_ condition: @autoclosure () -> Bool, _ logMessage: String, logDetails: String = "", functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.logMessage(condition(), logMessage, logDetails: logDetails, logLevel: .error, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: false)
  }
  
  func logError(_ logMessage: String, logDetails: [String: String], functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.logMessage(logMessage, logDetails: logDetails, logLevel: .error, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  func logError(_ logMessage: String, logDetails: String = "", functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.logMessage(logMessage, logDetails: logDetails, logLevel: .error, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  func logError(_ logMessage: String, error: NSError?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.logMessage(logMessage, logDetails: error?.description ?? "", logLevel: .error, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  // MARK: logSevere
  func logSevere(_ condition: @autoclosure () -> Bool, _ logMessage: String, logDetails: [String: String], functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.logMessage(condition(), logMessage, logDetails: logDetails, logLevel: .severe, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: false)
  }
  
  func logSevere(_ condition: @autoclosure () -> Bool, _ logMessage: String, logDetails: String = "", functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.logMessage(condition(), logMessage, logDetails: logDetails, logLevel: .severe, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: false)
  }
  
  func logSevere(_ logMessage: String, logDetails: [String: String], functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.logMessage(logMessage, logDetails: logDetails, logLevel: .severe, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  func logSevere(_ logMessage: String, logDetails: String = "", functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    self.logMessage(logMessage, logDetails: logDetails, logLevel: .severe, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  // MARK: Convenience class methods -
  
  class func setup(logLevel: LogLevel = .warning, assertLevel: LogLevel = .error, consoleLevel: LogLevel = .warning, showLogLevel: Bool = true, showFileNames: Bool = true, showLineNumbers: Bool = true, showFunctionNames: Bool = true) {
    sharedInstance.setup(logLevel: logLevel, assertLevel: assertLevel, consoleLevel: consoleLevel, showLogLevel: showLogLevel, showFileNames: showFileNames, showLineNumbers: showLineNumbers, showFunctionNames: showFunctionNames)
  }

  // MARK: logMessage
  class func logMessage(_ condition: @autoclosure () -> Bool, _ logMessage: String, logDetails: String, logLevel: LogLevel, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line, forceAssert: Bool = false) {
    sharedInstance.logMessage(condition(), logMessage, logDetails: logDetails, logLevel: logLevel, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: forceAssert)
  }
  
  class func logMessage(_ condition: @autoclosure () -> Bool, _ logMessage: String, logDetails: [String: String], logLevel: LogLevel, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line, forceAssert: Bool = false) {
    sharedInstance.logMessage(condition(), logMessage, logDetails: logDetails, logLevel: logLevel, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: forceAssert)
  }
  
  class func logMessage(_ logMessage: String, logDetails: String, logLevel: LogLevel, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line, forceAssert: Bool = false) {
    sharedInstance.logMessage(logMessage, logDetails: logDetails, logLevel: logLevel, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: forceAssert)
  }

  class func logMessage(_ logMessage: String, logDetails: [String: String], logLevel: LogLevel, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line, forceAssert: Bool = false) {
    sharedInstance.logMessage(logMessage, logDetails: logDetails, logLevel: logLevel, functionName: functionName, fileName: fileName, lineNumber: lineNumber, forceAssert: forceAssert)
  }

  // MARK: logVerbose
  class func logVerbose(_ condition: @autoclosure () -> Bool, _ logMessage: String, logDetails: [String: String], functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    sharedInstance.logVerbose(condition(), logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  class func logVerbose(_ condition: @autoclosure () -> Bool, _ logMessage: String, logDetails: String = "", functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    sharedInstance.logVerbose(condition(), logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  class func logVerbose(_ logMessage: String, logDetails: [String: String], functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    sharedInstance.logVerbose(logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  class func logVerbose(_ logMessage: String, logDetails: String = "", functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    sharedInstance.logVerbose(logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  // MARK: logDebug
  class func logDebug(_ condition: @autoclosure () -> Bool, _ logMessage: String, logDetails: [String: String], functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    sharedInstance.logDebug(condition(), logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  class func logDebug(_ condition: @autoclosure () -> Bool, _ logMessage: String, logDetails: String = "", functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    sharedInstance.logDebug(condition(), logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  class func logDebug(_ logMessage: String, logDetails: [String: String], functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    sharedInstance.logDebug(logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  class func logDebug(_ logMessage: String, logDetails: String = "", functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    sharedInstance.logDebug(logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  // MARK: logInfo
  class func logInfo(_ condition: @autoclosure () -> Bool, _ logMessage: String, logDetails: [String: String], functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    sharedInstance.logInfo(condition(), logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  class func logInfo(_ condition: @autoclosure () -> Bool, _ logMessage: String, logDetails: String = "", functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    sharedInstance.logInfo(condition(), logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  class func logInfo(_ logMessage: String, logDetails: [String: String], functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    sharedInstance.logInfo(logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }

  class func logInfo(_ logMessage: String, logDetails: String = "", functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    sharedInstance.logInfo(logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  // MARK: logWarning
  class func logWarning(_ condition: @autoclosure () -> Bool, _ logMessage: String, logDetails: [String: String], functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    sharedInstance.logWarning(condition(), logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  class func logWarning(_ condition: @autoclosure () -> Bool, _ logMessage: String, logDetails: String = "", functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    sharedInstance.logWarning(condition(), logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  class func logWarning(_ logMessage: String, logDetails: [String: String], functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    sharedInstance.logWarning(logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  class func logWarning(_ logMessage: String, logDetails: String = "", functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    sharedInstance.logWarning(logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  // MARK: logError
  class func logError(_ condition: @autoclosure () -> Bool, _ logMessage: String, logDetails: [String: String], functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    sharedInstance.logError(condition(), logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  class func logError(_ condition: @autoclosure () -> Bool, _ logMessage: String, logDetails: String = "", functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    sharedInstance.logError(condition(), logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  class func logError(_ logMessage: String, logDetails: [String: String], functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    sharedInstance.logError(logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  class func logError(_ logMessage: String, logDetails: String = "", functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    sharedInstance.logError(logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  class func logError(_ logMessage: String, error: NSError?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    sharedInstance.logError(logMessage, error: error, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  // MARK: logSevere
  class func logSevere(_ condition: @autoclosure () -> Bool, _ logMessage: String, logDetails: [String: String], functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    sharedInstance.logSevere(condition(), logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  class func logSevere(_ condition: @autoclosure () -> Bool, _ logMessage: String, logDetails: String = "", functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    sharedInstance.logSevere(condition(), logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }

  class func logSevere(_ logMessage: String, logDetails: [String: String], functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    sharedInstance.logSevere(logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }

  class func logSevere(_ logMessage: String, logDetails: String = "", functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    sharedInstance.logSevere(logMessage, logDetails: logDetails, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
  }
  
  // Hide initializer from direct usage
  fileprivate init() { }
  
}


// MARK: Popular checks and logs
extension Logger {
  class func checkViewController(_ condition: @autoclosure () -> Bool, storyboardID: String) {
    logMessage(condition(), Messages.failedToInstantiateViewController, logDetails: [Attributes.storyboardID: storyboardID], logLevel: .severe, functionName: #function, fileName: #file, lineNumber: #line, forceAssert: false)
  }
  
  class func logDrinkIsNotFound(drinkIndex: Int, logLevel: LogLevel = .error) {
    logMessage(Messages.drinkIsNotFound, logDetails: [Attributes.drinkIndex: "\(drinkIndex)"], logLevel: logLevel)
  }
  
}


class LoggedActions {
  // Expanded in other places for particular actions
}
