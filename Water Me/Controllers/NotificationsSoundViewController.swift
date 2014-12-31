//
//  NotificationsSoundViewController.swift
//  Water Me
//
//  Created by Sergey Balyakin on 31.12.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

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
    
    navigationController!.popViewControllerAnimated(true)
  }

  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }

  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0: return NSLocalizedString("NSVC:System sounds", value: "System sounds", comment: "NotificationsSoundViewController: header title for [System sounds] section")
    case 1: return NSLocalizedString("NSVC:Application sounds", value: "Application sounds", comment: "NotificationsSoundViewController: header title for [Application sounds] section")
    default: assert(false)
    }
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0: return 1
    case 1: return soundsList.count - 1
    default: assert(false)
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("SoundCell") as UITableViewCell
    
    let index = indexPath.section + indexPath.row
    let sound = soundsList[index]
    cell.textLabel?.text = sound.title
    cell.accessoryType = (index == checkedIndex) ? .Checkmark : .None
    
    return cell
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    checkedIndex = indexPath.section + indexPath.row
    tableView.reloadData()
  }

  private func fillSoundsList() {
    let defaultTitle = NSLocalizedString("NSVC:Default", value: "Default", comment: "NotificationsSoundViewController: title for default system sound")
    soundsList.append((title: defaultTitle, fileName: UILocalNotificationDefaultSoundName))
    
    let bundlePath = NSBundle.mainBundle().resourcePath!
    let fileManager = NSFileManager()
    
    let allFiles = fileManager.contentsOfDirectoryAtPath(bundlePath, error: nil)
    for fileName in allFiles! {
      let fileNameString = fileName as NSString
      if fileNameString.pathExtension == "wav" {
        soundsList.append((title: fileNameString.stringByDeletingPathExtension, fileName: fileNameString))
      }
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
