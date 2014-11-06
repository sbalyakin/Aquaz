//
//  DiaryViewController.swift
//  Water Me
//
//  Created by Sergey Balyakin on 05.11.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import Foundation

class DiaryViewController: UIViewController, UITableViewDataSource {

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 30
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
    cell.textLabel.text = "\(indexPath.row)"
    return cell
  }
  
}