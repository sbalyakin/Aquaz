//
//  NotificationsSoundViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 31.12.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit
import AudioToolbox

class NotificationsSoundViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  @IBOutlet weak var tableView: UITableView!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    fillSoundsList()
    findCheckedIndex()
    UIHelper.applyStyle(self)
  }

  @IBAction func saveWasTapped(sender: AnyObject) {
    let soundInfo = soundList[checkedIndex]
    Settings.sharedInstance.notificationsSound.value = soundInfo.fileName
    
    navigationController?.popViewControllerAnimated(true)
  }

  private func playSound(fileName: String) {
    if let soundURL = NSBundle.mainBundle().URLForResource(fileName.stringByDeletingPathExtension, withExtension: fileName.pathExtension) {
      var mySound: SystemSoundID = 0
      let status = AudioServicesCreateSystemSoundID(soundURL, &mySound)
      if status == OSStatus(kAudioServicesNoError) {
        AudioServicesPlaySystemSound(mySound)
      } else {
        Logger.logError("Failed to create system sound identifier")
      }
    } else {
      Logger.logError("Failed to build URL for sound file", logDetails: [Logger.Attributes.fileName: fileName])
    }
  }

  private func fillSoundsList() {
    if let bundlePath = NSBundle.mainBundle().resourcePath {
      if let allFiles = NSFileManager().contentsOfDirectoryAtPath(bundlePath, error: nil) as? [String] {
        for soundInfo in NotificationSounds.soundList {
          if contains(allFiles, soundInfo.fileName) {
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
  
  private func findCheckedIndex() {
    let fileName = Settings.sharedInstance.notificationsSound.value
    
    for (index, sound) in enumerate(soundList) {
      if sound.fileName == fileName {
        checkedIndex = index
        return
      }
    }
    
    Logger.logWarning("Sound file stored in settings is not found", logDetails: [Logger.Attributes.fileName: fileName])
    checkedIndex == 0
  }
  
  private var soundList: [NotificationSounds.SoundInfo] = []

  private var checkedIndex: Int = 0
}

// MARK: UITableViewDataSource and UITableViewDelegate -
extension NotificationsSoundViewController {
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return NSLocalizedString("NSVC:Notification sounds", value: "Notification sounds", comment: "NotificationsSoundViewController: header title for [NSVC:Notification sounds] section")
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return soundList.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("SoundCell") as! UITableViewCell
    
    let index = indexPath.row
    let sound = soundList[index]
    cell.textLabel?.text = sound.title.capitalizedString
    cell.accessoryType = (index == checkedIndex) ? .Checkmark : .None
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    checkedIndex = indexPath.row
    tableView.reloadData()
    let sound = soundList[checkedIndex]
    playSound(sound.fileName)
  }
  
}
