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
    return CGSize(width: 132, height: 132)
  }
  
  var fontSizes: (title: CGFloat, upTitle: CGFloat, subTitle: CGFloat) {
    return (title: 34, upTitle: 15, subTitle: 15)
  }
  
  fileprivate var settingsObserverVolumeUnits: SettingsObserver?
  
  fileprivate var currentWaterGoal: Double = WatchSettings.sharedInstance.stateWaterGoal.value
  
  fileprivate var currentHydrationAmount: Double = 0

  fileprivate var tomorrowTimer: Timer!

  // MARK: Computed properties
  
  fileprivate var settingsWaterGoal: Double {
    get {
      return WatchSettings.sharedInstance.stateWaterGoal.value
    }
    set {
      WatchSettings.sharedInstance.stateWaterGoal.value = newValue
    }
  }
  
  fileprivate var settingsHydrationAmount: Double {
    get {
      return WatchSettings.sharedInstance.stateHydration.value
    }
    set {
      WatchSettings.sharedInstance.stateHydration.value = newValue
    }
  }
  
  fileprivate var amountPrecision: Double { return WatchSettings.sharedInstance.generalVolumeUnits.value.precision }
  
  fileprivate var amountDecimals: Int { return WatchSettings.sharedInstance.generalVolumeUnits.value.decimals }
  
  // MARK: Constructor
  
  override init() {
    super.init()

    setupSettingsSynchronization()
    
    setupNotificationsObservation()
    
    setupTomorrowTimer()
    
    setupUI()
    
    updateUI()
  }
  
  // MARK: Destructor
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: Methods
  
  override func didAppear() {
    super.didAppear()
    updateUI()
  }
  
  fileprivate func setupSettingsSynchronization() {
    settingsObserverVolumeUnits = WatchSettings.sharedInstance.generalVolumeUnits.addObserver { [weak self] _ in
      if let existingSelf = self {
        existingSelf.updateProgressText(
          waterGoal: existingSelf.currentWaterGoal,
          hydrationAmount: existingSelf.currentHydrationAmount)
      }
    }
  }
  
  fileprivate func setupNotificationsObservation() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.currentStateNotificationIsReceived(_:)),
      name: NSNotification.Name(rawValue: GlobalConstants.notificationWatchCurrentState),
      object: nil)
  }
  
  fileprivate func setupTomorrowTimer() {
    let startOfToday = DateHelper.startOfDay(Date())
    let startOfTomorrow = DateHelper.nextDayFrom(startOfToday)
    let timeInterval = startOfTomorrow.timeIntervalSince(Date())
    
    tomorrowTimer = Timer.scheduledTimer(
      timeInterval: timeInterval,
      target: self,
      selector: #selector(self.tomorrowTimerIsFired(_:)),
      userInfo: nil,
      repeats: false)
  }
  
  @objc func tomorrowTimerIsFired(_ timer: Timer) {
    if timer == tomorrowTimer {
      updateUI()
      setupTomorrowTimer()
    }
  }

  fileprivate func stringFromMetricAmount(_ amount: Double) -> String {
    return Units.sharedInstance.formatMetricAmountToText(
      metricAmount: amount,
      unitType: .volume,
      roundPrecision: amountPrecision,
      fractionDigits: amountDecimals,
      displayUnits: false)
  }
  
  fileprivate func setupUI() {
    progressImage.setImageNamed("Progress-")
  }
  
  fileprivate func updateUI() {
    checkForTomorrowHasCome()
    
    updateUI(waterGoal: self.settingsWaterGoal, hydrationAmount: self.settingsHydrationAmount)
  }
  
  fileprivate func checkForTomorrowHasCome() {
    let currentDate = Date()
    
    if !DateHelper.areEqualDays(currentDate, WatchSettings.sharedInstance.stateCurrentDate.value) {
      WatchSettings.sharedInstance.stateHydration.value = 0
      WatchSettings.sharedInstance.stateCurrentDate.value = DateHelper.startOfDay(currentDate)
    }
  }
  
  fileprivate func updateUI(waterGoal: Double, hydrationAmount: Double) {
    updateProgressText(waterGoal: waterGoal, hydrationAmount: hydrationAmount)
    
    let animationParameters = ProgressHelper.calcAnimationParameters(
      imagesCount: 100,
      fromCurrentAmount: currentHydrationAmount,
      fromTotalAmount: currentWaterGoal,
      toCurrentAmount: hydrationAmount,
      toTotalAmount: waterGoal)
    
    progressImage.startAnimatingWithImages(in: animationParameters.imageRange, duration: animationParameters.animationDuration, repeatCount: 1)
    
    currentWaterGoal = waterGoal
    currentHydrationAmount = hydrationAmount
  }
  
  fileprivate func updateProgressText(waterGoal: Double, hydrationAmount: Double) {
    let newHydrationAmountText = stringFromMetricAmount(hydrationAmount)
    let newWaterGoalText = stringFromMetricAmount(waterGoal)
    
    let upTitle = WatchSettings.sharedInstance.generalVolumeUnits.value.description
    
    let subTitleTemplate = NSLocalizedString("WIC:of %1$@", value: "of %1$@", comment: "WatchKit Interface Controller: The part of title about current consumption")
    let subTitle = String.localizedStringWithFormat(subTitleTemplate, newWaterGoalText)
    let fontSizes = self.fontSizes // it can be overriden in descendants and probably transformed to complex computed property
    
    let titleItem    = ProgressHelper.TextProgressItem(text: newHydrationAmountText, color: UIColor.white, font: UIFont.systemFont(ofSize: fontSizes.title, weight: UIFont.Weight.medium))
    let subTitleItem = ProgressHelper.TextProgressItem(text: subTitle, color: StyleKit.waterColor, font: UIFont.systemFont(ofSize: fontSizes.subTitle))
    let upTitleItem  = ProgressHelper.TextProgressItem(text: upTitle, color: UIColor.gray, font: UIFont.systemFont(ofSize: fontSizes.upTitle))
    
    let imageSize = progressImageSize
    
    let backgroundImage = ProgressHelper.generateTextProgressImage(imageSize: imageSize, title: titleItem, subTitle: subTitleItem, upTitle: upTitleItem)
    
    progressGroup.setBackgroundImage(backgroundImage)
  }
  
  @objc func currentStateNotificationIsReceived(_ notification: Notification) {
    guard let message = notification.object as? ConnectivityMessageCurrentState else {
      return
    }

    DispatchQueue.main.async {
      WatchSettings.sharedInstance.generalVolumeUnits.value = message.volumeUnits
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
    case .millilitres: return 1.0
    case .fluidOunces: return 0.1
    }
  }
  
  var decimals: Int {
    switch self {
    case .millilitres: return 0
    case .fluidOunces: return 1
    }
  }
}
