//
//  NotificationsSoundViewController.swift
//  Water Me
//
//  Created by Sergey Balyakin on 31.12.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit
import AudioToolbox

class NotificationsSoundViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  var notificationsViewController: NotificationsViewController!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    fillSoundsList()
    findCheckedIndex()
  }

  @IBAction func saveWasTapped(sender: AnyObject) {
    let sound = soundsList[checkedIndex]
    Settings.sharedInstance.notificationsSound.value = sound.fileName
    
    notificationsViewController.initControlsFromSettings()
    notificationsViewController.updateNotificationsFromSettings()
    
    navigationController?.popViewControllerAnimated(true)
  }

  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return NSLocalizedString("NSVC:Notification sounds", value: "Notification sounds", comment: "NotificationsSoundViewController: header title for [NSVC:Notification sounds] section")
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return soundsList.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("SoundCell") as UITableViewCell
    
    let index = indexPath.row
    let sound = soundsList[index]
    cell.textLabel?.text = sound.title.capitalizedString
    cell.accessoryType = (index == checkedIndex) ? .Checkmark : .None
    
    return cell
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    checkedIndex = indexPath.row
    tableView.reloadData()
    let sound = soundsList[checkedIndex]
    playSound(sound.fileName)
  }

  private func playSound(fileName: String) {
    if let soundURL = NSBundle.mainBundle().URLForResource(fileName.stringByDeletingPathExtension, withExtension: fileName.pathExtension) {
      var mySound: SystemSoundID = 0
      let status = AudioServicesCreateSystemSoundID(soundURL, &mySound)
      if status == OSStatus(kAudioServicesNoError) {
        AudioServicesPlaySystemSound(mySound)
      } else {
        assert(false)
      }
    } else {
      assert(false)
    }
  }

  private func fillSoundsList() {
    if let bundlePath = NSBundle.mainBundle().resourcePath {
      if let allFiles = NSFileManager().contentsOfDirectoryAtPath(bundlePath, error: nil) {
        for fileName in allFiles {
          if fileName.pathExtension == "wav" {
            let item: Sound = (title: fileName.stringByDeletingPathExtension, fileName: fileName as NSString)
            soundsList.append(item)
          }
        }
      } else {
        assert(false)
      }
    } else {
      assert(false)
    }
  }
  
  private func findCheckedIndex() {
    for (index, sound) in enumerate(soundsList) {
      if sound.fileName == Settings.sharedInstance.notificationsSound.value {
        checkedIndex = index
      }
    }
  }
  
  private typealias Sound = (title: String, fileName: NSString)
  private var soundsList: [Sound] = []
  private var checkedIndex: Int = 0
}
