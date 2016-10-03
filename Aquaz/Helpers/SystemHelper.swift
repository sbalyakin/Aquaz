//
//  SystemHelper.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 04.06.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import Foundation

class SystemHelper {
  
  class func executeBlockWithDelay(_ delay: TimeInterval, block: @escaping () -> ()) {
    let executeTime = DispatchTime.now() + Double(Int64(delay * TimeInterval(NSEC_PER_SEC))) / Double(NSEC_PER_SEC);
    
    DispatchQueue.main.asyncAfter(deadline: executeTime) {
      block()
    }
  }
  
  class func performBlockAsyncOnMainQueueAndWait(_ block: @escaping () -> ()) {
    let dispatchGroup = DispatchGroup()
    dispatchGroup.enter()
    
    DispatchQueue.main.async {
      block()
      dispatchGroup.leave()
    }
    
    _ = dispatchGroup.wait(timeout: DispatchTime.distantFuture)
  }
}
