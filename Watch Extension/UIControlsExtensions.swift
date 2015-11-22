//
//  UIControlsExtensions.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 10.11.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import Foundation
import WatchKit

enum WatchResolution {
  case Watch38mm
  case Watch42mm
  case Unknown
}

extension WKInterfaceDevice {
  class func currentResolution() -> WatchResolution {
    let watch38mmRect = CGRect(x: 0, y: 0, width: 136, height: 170)
    let watch42mmRect = CGRect(x: 0, y: 0, width: 156, height: 195)
    
    let currentBounds = WKInterfaceDevice.currentDevice().screenBounds
    
    switch currentBounds {
    case watch38mmRect: return .Watch38mm
    case watch42mmRect: return .Watch42mm
    default:            return .Unknown
    }
  }
}
