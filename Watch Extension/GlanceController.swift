//
//  GlanceController.swift
//  Watch Extension
//
//  Created by Sergey Balyakin on 20.10.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import WatchKit
import Foundation

final class GlanceController: CurrentStateInterfaceController {
  
  override var progressImageSize: CGSize {
    return WKInterfaceDevice.currentResolution().progressImageSize
  }

  override var fontSizes: (title: CGFloat, upTitle: CGFloat, subTitle: CGFloat) {
    return WKInterfaceDevice.currentResolution().fontSizes
  }

}

// MARK: WatchResolution extension

private extension WatchResolution {
  
  var progressImageSize: CGSize {
    switch self {
    case .watch38mm: return CGSize(width: 102, height: 102)
    case .watch42mm: return CGSize(width: 114, height: 114)
    case .unknown:   return CGSize(width: 114, height: 114)
    }
  }
  
  var fontSizes: (title: CGFloat, upTitle: CGFloat, subTitle: CGFloat) {
    switch self {
    case .watch38mm: return (title: 26, upTitle: 12, subTitle: 12)
    case .watch42mm: return (title: 30, upTitle: 14, subTitle: 14)
    case .unknown:   return (title: 30, upTitle: 14, subTitle: 14)
    }
  }

}
