//
//  SystemHelper.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 04.06.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import Foundation

class SystemHelper {
  
  class func executeBlockWithDelay(delay: NSTimeInterval, block: () -> ()) {
    let executeTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * NSTimeInterval(NSEC_PER_SEC)));
    
    dispatch_after(executeTime, dispatch_get_main_queue()) {
      block()
    }
  }
}