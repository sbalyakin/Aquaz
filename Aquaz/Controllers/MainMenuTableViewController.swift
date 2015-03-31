//
//  MainMenuViewController.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 17.01.15.
//  Copyright (c) 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class MainMenuTableViewController: UITableViewController {

  typealias CellInfo = (id: String, title: String)
  
  private var cells: [CellInfo]!

  private struct Constants {
    static let waterBalanceCellId  = "Water Balance"
    static let statisticsCellId    = "Statistics"
    static let notificationsCellId = "Notifications"
    static let settingsCellId      = "Settings"
    static let supportCellId       = "Support"
  }
  
  private struct Strings {
    lazy var waterBalanceTitle: String = NSLocalizedString("MMTVC:Water Balance", value: "Water Balance",
      comment: "MainMenuTableViewController: Title for water balance menu item")
    lazy var statisticsTitle: String = NSLocalizedString("MMTVC:Statistics", value: "Statistics",
      comment: "MainMenuTableViewController: Title for statistics menu item")
    lazy var notificationsTitle: String = NSLocalizedString("MMTVC:Notifications", value: "Notifications",
      comment: "MainMenuTableViewController: Title for notifications menu item")
    lazy var settingsTitle: String = NSLocalizedString("MMTVC:Settings", value: "Settings",
      comment: "MainMenuTableViewController: Title for settings menu item")
    lazy var supportTitle: String = NSLocalizedString("MMTVC:Support", value: "Support",
      comment: "MainMenuTableViewController: Title for support menu item")
  }
  
  private var strings = Strings()

  override func viewDidLoad() {
    super.viewDidLoad()

    cells = [
      (id: Constants.waterBalanceCellId,  title: strings.waterBalanceTitle),
      (id: Constants.statisticsCellId,    title: strings.statisticsTitle),
      (id: Constants.notificationsCellId, title: strings.notificationsTitle),
      (id: Constants.settingsCellId,      title: strings.settingsTitle),
      (id: Constants.supportCellId,       title: strings.supportTitle)]
    
    view.backgroundColor = StyleKit.mainMenuBackgroundColor
    tableView.backgroundView = nil
    tableView.backgroundColor = StyleKit.mainMenuBackgroundColor
    tableView.separatorColor = StyleKit.mainMenuTextColor.colorWithAlpha(0.4).colorWithSaturation(0.6)
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return cells.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cellInfo = cells[indexPath.row]
    
    let cell = tableView.dequeueReusableCellWithIdentifier(cellInfo.id, forIndexPath: indexPath) as! UITableViewCell
    cell.backgroundColor = StyleKit.mainMenuBackgroundColor.colorWithHighlight(0.05)
    cell.textLabel?.text = cellInfo.title
    cell.textLabel?.textColor = StyleKit.mainMenuTextColor
    
    let selectionView = UIView()
    selectionView.backgroundColor = StyleKit.mainMenuBackgroundColor.colorWithHighlight(0.1)
    cell.selectedBackgroundView = selectionView
    return cell
  }

}
