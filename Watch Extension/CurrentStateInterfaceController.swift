//
//  CurrentStateInterfaceController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 18.11.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class CurrentStateInterfaceController: WKInterfaceController {
  
  // MARK: Properties
  
  @IBOutlet var progressGroup: WKInterfaceGroup!
  
  @IBOutlet var progressImage: WKInterfaceImage!

  var progressImageSize: CGSize {
    return CGSize(width: 100, height: 100)
  }
  
  var fontSizes: (title: CGFloat, upTitle: CGFloat, subTitle: CGFloat) {
    return (title: 34, upTitle: 14, subTitle: 14)
  }

  private var session: WCSession?
  
  private var settingsObserverVolumeUnits: SettingsObserver?
  
  private var currentWaterGoal: Double = WatchSettings.sharedInstance.stateWaterGoal.value
  
  private var currentHydrationAmount: Double = 0

  private var tomorrowTimer: NSTimer!

  // MARK: Computed properties
  
  private var settingsWaterGoal: Double {
    get {
      return WatchSettings.sharedInstance.stateWaterGoal.value
    }
    set {
      WatchSettings.sharedInstance.stateWaterGoal.value = newValue
    }
  }
  
  private var settingsHydrationAmount: Double {
    get {
      return WatchSettings.sharedInstance.stateHydration.value
    }
    set {
      WatchSettings.sharedInstance.stateHydration.value = newValue
    }
  }
  
  private var amountPrecision: Double { return WatchSettings.sharedInstance.generalVolumeUnits.value.precision }
  
  private var amountDecimals: Int { return WatchSettings.sharedInstance.generalVolumeUnits.value.decimals }
  
  // MARK: Constructor
  
  override init() {
    super.init()

    setupSettingsSynchronization()
    
    initConnectivity()
    
    setupNotificationsObservation()
    
    setupTomorrowTimer()
    
    setupUI()
    
    updateUI()
  }
  
  // MARK: Destructor
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  // MARK: Methods
  
  override func didAppear() {
    super.didAppear()
    updateUI()
  }
  
  private func initConnectivity() {
    if WCSession.isSupported() {
      session = WCSession.defaultSession()
      session?.delegate = self
      session?.activateSession()
    }
  }
  
  private func setupSettingsSynchronization() {
    settingsObserverVolumeUnits = WatchSettings.sharedInstance.generalVolumeUnits.addObserver { [weak self] _ in
      if let existingSelf = self {
        existingSelf.updateProgressText(
          waterGoal: existingSelf.currentWaterGoal,
          hydrationAmount: existingSelf.currentHydrationAmount)
      }
    }
  }
  
  private func setupNotificationsObservation() {
    NSNotificationCenter.defaultCenter().addObserver(
      self,
      selector: #selector(self.addIntakeNotificationIsReceived(_:)),
      name: GlobalConstants.notificationWatchAddIntake,
      object: nil)
  }
  
  func addIntakeNotificationIsReceived(notification: NSNotification) {
    guard let addIntakeInfo = notification.object as? ConnectivityMessageAddIntake else {
      return
    }
    
    session?.transferUserInfo(addIntakeInfo.composeMetadata())
  }
  
  private func setupTomorrowTimer() {
    let startOfToday = DateHelper.dateByClearingTime(ofDate: NSDate())
    let startOfTomorrow = DateHelper.addToDate(startOfToday, years: 0, months: 0, days: 1)
    let timeInterval = startOfTomorrow.timeIntervalSinceDate(NSDate())
    
    tomorrowTimer = NSTimer.scheduledTimerWithTimeInterval(
      timeInterval,
      target: self,
      selector: #selector(self.tomorrowTimerIsFired(_:)),
      userInfo: nil,
      repeats: false)
  }
  
  func tomorrowTimerIsFired(timer: NSTimer) {
    if timer == tomorrowTimer {
      updateUI()
      setupTomorrowTimer()
    }
  }

  private func stringFromMetricAmount(amount: Double) -> String {
    return Units.sharedInstance.formatMetricAmountToText(
      metricAmount: amount,
      unitType: .Volume,
      roundPrecision: amountPrecision,
      decimals: amountDecimals,
      displayUnits: false)
  }
  
  private func setupUI() {
    progressImage.setImageNamed("Progress-")
  }
  
  private func updateUI() {
    checkForTomorrowHasCome()
    
    updateUI(waterGoal: self.settingsWaterGoal, hydrationAmount: self.settingsHydrationAmount)
  }
  
  private func checkForTomorrowHasCome() {
    let currentDate = NSDate()
    
    if !DateHelper.areDatesEqualByDays(currentDate, WatchSettings.sharedInstance.stateCurrentDate.value) {
      WatchSettings.sharedInstance.stateHydration.value = 0
      WatchSettings.sharedInstance.stateCurrentDate.value = DateHelper.dateByClearingTime(ofDate: currentDate)
    }
  }
  
  private func updateUI(waterGoal waterGoal: Double, hydrationAmount: Double) {
    updateProgressText(waterGoal: waterGoal, hydrationAmount: hydrationAmount)
    
    let animationParameters = ProgressHelper.calcAnimationParameters(
      imagesCount: 100,
      fromCurrentAmount: currentHydrationAmount,
      fromTotalAmount: currentWaterGoal,
      toCurrentAmount: hydrationAmount,
      toTotalAmount: waterGoal)
    
    progressImage.startAnimatingWithImagesInRange(animationParameters.imageRange, duration: animationParameters.animationDuration, repeatCount: 1)
    
    currentWaterGoal = waterGoal
    currentHydrationAmount = hydrationAmount
  }
  
  private func updateProgressText(waterGoal waterGoal: Double, hydrationAmount: Double) {
    let newHydrationAmountText = stringFromMetricAmount(hydrationAmount)
    let newWaterGoalText = stringFromMetricAmount(waterGoal)
    
    let upTitle = WatchSettings.sharedInstance.generalVolumeUnits.value.description
    
    let subTitleTemplate = NSLocalizedString("WIC:of %1$@", value: "of %1$@", comment: "WatchKit Interface Controller: The part of title about current consumption")
    let subTitle = String.localizedStringWithFormat(subTitleTemplate, newWaterGoalText)
    let fontSizes = self.fontSizes // it can be overriden in descendants and probably transformed to complex computed property
    
    let titleItem    = ProgressHelper.TextProgressItem(text: newHydrationAmountText, color: UIColor.whiteColor(), font: UIFont.systemFontOfSize(fontSizes.title, weight: UIFontWeightMedium))
    let subTitleItem = ProgressHelper.TextProgressItem(text: subTitle, color: StyleKit.waterColor, font: UIFont.systemFontOfSize(fontSizes.subTitle))
    let upTitleItem  = ProgressHelper.TextProgressItem(text: upTitle, color: UIColor.grayColor(), font: UIFont.systemFontOfSize(fontSizes.upTitle))
    
    let imageSize = progressImageSize
    
    let backgroundImage = ProgressHelper.generateTextProgressImage(imageSize: imageSize, title: titleItem, subTitle: subTitleItem, upTitle: upTitleItem)
    
    progressGroup.setBackgroundImage(backgroundImage)
  }
  
}

// MARK: WCSessionDelegate

extension CurrentStateInterfaceController: WCSessionDelegate {
  
  func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
    if let updatedSettingsMesage = ConnectivityMessageUpdatedSettings(metadata: userInfo) {
      updatedSettingsMesageWasReceived(updatedSettingsMesage)
    } else if let currentStateMesage = ConnectivityMessageCurrentState(metadata: userInfo) {
      currentStateMesageWasReceived(currentStateMesage)
    }
  }
  
  func session(session: WCSession, didFinishUserInfoTransfer userInfoTransfer: WCSessionUserInfoTransfer, error: NSError?) {
    if let _ = error {
      // Trying to transfer the user info again
      session.transferUserInfo(userInfoTransfer.userInfo)
    }
  }
  
  private func updatedSettingsMesageWasReceived(message: ConnectivityMessageUpdatedSettings) {
    for (key, value) in message.settings {
      WatchSettings.userDefaults.setObject(value, forKey: key)
      WatchSettings.sharedInstance.generalVolumeUnits.readFromUserDefaults(sendNotification: true)
    }
  }
  
  private func currentStateMesageWasReceived(message: ConnectivityMessageCurrentState) {
    if !DateHelper.areDatesEqualByDays(NSDate(), message.messageDate) {
      // Skip outdated events
      return
    }
    
    dispatch_async(dispatch_get_main_queue()) {
      self.settingsWaterGoal = message.dailyWaterGoal + message.dehydrationAmount
      self.settingsHydrationAmount = message.hydrationAmount
      self.updateUI(waterGoal: self.settingsWaterGoal, hydrationAmount: self.settingsHydrationAmount)
    }
  }
  
}

// MARK: Units.Volume extension

private extension Units.Volume {
  var precision: Double {
    switch self {
    case Millilitres: return 1.0
    case FluidOunces: return 0.1
    }
  }
  
  var decimals: Int {
    switch self {
    case Millilitres: return 0
    case FluidOunces: return 1
    }
  }
}