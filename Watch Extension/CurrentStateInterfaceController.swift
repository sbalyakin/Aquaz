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
  
  var titleFontSize: CGFloat { return 34 }
  var subTitleFontSize: CGFloat { return 14 }
  var upTitleFontSize: CGFloat { return 14 }

  private var session: WCSession!
  
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
  
  // MARK: Methods
  
  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    
    initConnectivity()
    
    setupSettingsSynchronization()
    
    setupNotificationsObservation()
    
    setupTomorrowTimer()
    
    setupUI()
    
    updateUI()
  }
  
  override func didAppear() {
    super.didAppear()
    updateUI()
  }
  
  private func initConnectivity() {
    if WCSession.isSupported() {
      session = WCSession.defaultSession()
      session.delegate = self
      session.activateSession()
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
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "addIntakeNotificationIsReceived:", name: GlobalConstants.notificationWatchAddIntake, object: nil)
  }
  
  func addIntakeNotificationIsReceived(notification: NSNotification) {
    guard let addIntakeInfo = notification.object as? ConnectivityMessageAddIntake else {
      return
    }
    
    session.transferUserInfo(addIntakeInfo.composeMetadata())
  }
  
  private func setupTomorrowTimer() {
    let startOfToday = DateHelper.dateByClearingTime(ofDate: NSDate())
    let startOfTomorrow = DateHelper.addToDate(startOfToday, years: 0, months: 0, days: 1)
    let timeInterval = startOfTomorrow.timeIntervalSinceDate(NSDate())
    
    tomorrowTimer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: "tomorrowTimerIsFired:", userInfo: nil, repeats: false)
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
    
    let titleItem    = ProgressHelper.TextProgressItem(text: newHydrationAmountText, color: UIColor.whiteColor(), font: UIFont.systemFontOfSize(titleFontSize, weight: UIFontWeightMedium))
    let subTitleItem = ProgressHelper.TextProgressItem(text: subTitle, color: StyleKit.waterColor, font: UIFont.systemFontOfSize(subTitleFontSize))
    let upTitleItem  = ProgressHelper.TextProgressItem(text: upTitle, color: UIColor.grayColor(), font: UIFont.systemFontOfSize(upTitleFontSize))
    
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