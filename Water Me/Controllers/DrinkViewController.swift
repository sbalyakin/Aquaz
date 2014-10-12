//
//  DrinkViewController.swift
//  Water Me
//
//  Created by Sergey Balyakin on 12.10.14.
//  Copyright (c) 2014 Sergey Balyakin. All rights reserved.
//

import UIKit

class DrinkViewController: UIViewController {
  
  @IBOutlet weak var testLabel: UILabel!
  @IBOutlet weak var cancelButton: UIButton!
  
  var drink: Drink!
  
  @IBAction func cancelButtonTapped(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    testLabel.text = drink.name
    view.backgroundColor = drink.color as? UIColor
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
}
