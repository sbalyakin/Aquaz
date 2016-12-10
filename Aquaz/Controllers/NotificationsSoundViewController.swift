//
//  NotificationsSoundViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 31.12.14.
//  Copyright © 2014 Sergey Balyakin. All rights reserved.
//

import UIKit
import AudioToolbox

class NotificationsSoundViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    fillSoundsList()
    findCheckedIndex()
    UIHelper.applyStyleToViewController(self)
  }
  
  deinit {
    // It prevents EXC_BAD_ACCESS on deferred reloading the table view
    tableView?.dataSource = nil
    tableView?.delegate = nil
  }

  @IBAction func saveWasTapped(_ sender: Any) {
    let soundInfo = soundList[checkedIndex]
    Settings.sharedInstance.notificationsSound.value = soundInfo.fileName
    
    _ = navigationController?.popViewController(animated: true)
  }

  fileprivate func playSound(_ fileName: String) {
    if let soundURL = Bundle.main.url(forResource: fileName, withExtension: nil) {
      var mySound: SystemSoundID = 0
      let status = AudioServicesCreateSystemSoundID(soundURL as CFURL, &mySound)
      if status == OSStatus(kAudioServicesNoError) {
        AudioServicesPlaySystemSound(mySound)
      } else {
        Logger.logError("Failed to create system sound identifier")
      }
    } else {
      Logger.logError("Failed to build URL for sound file", logDetails: [Logger.Attributes.fileName: fileName])
    }
  }

  fileprivate func fillSoundsList() {
    if let bundlePath = Bundle.main.resourcePath {
      if let allFiles = (try? FileManager().contentsOfDirectory(atPath: bundlePath)) {
        for soundInfo in NotificationSounds.soundList {
          if allFiles.contains((soundInfo.fileName)) {
            soundList.append(soundInfo)
          } else {
            Logger.logError("Sound file is not found", logDetails: [Logger.Attributes.fileName: soundInfo.fileName])
          }
        }
      } else {
        Logger.logError("Failed to get contents of resource directory")
      }
    } else {
      Logger.logError("Failed to get resource path")
    }
  }
  
  fileprivate func findCheckedIndex() {
    let fileName = Settings.sharedInstance.notificationsSound.value
    
    for (index, sound) in soundList.enumerated() {
      if sound.fileName == fileName {
        checkedIndex = index
        return
      }
    }
    
    Logger.logWarning("Sound file stored in settings is not found", logDetails: [Logger.Attributes.fileName: fileName])
    checkedIndex = 0
  }
  
  fileprivate var soundList: [NotificationSounds.SoundInfo] = []

  fileprivate var checkedIndex: Int = 0
}

// MARK: UITableViewDataSource -
extension NotificationsSoundViewController: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return NSLocalizedString("NSVC:Notification sounds", value: "Notification sounds", comment: "NotificationsSoundViewController: header title for [NSVC:Notification sounds] section")
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return soundList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "SoundCell")!
    
    let index = (indexPath as NSIndexPath).row
    let sound = soundList[index]
    cell.textLabel?.text = sound.title.capitalized
    cell.accessoryType = (index == checkedIndex) ? .checkmark : .none
    
    return cell
  }
  
}

// MARK: UITableViewDelegate -
extension NotificationsSoundViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    checkedIndex = (indexPath as NSIndexPath).row
    tableView.reloadData()
    let sound = soundList[checkedIndex]
    playSound(sound.fileName)
  }
  
}
