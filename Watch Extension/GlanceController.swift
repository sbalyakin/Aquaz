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

  override var titleFontSize: CGFloat { return 28 }
  override var subTitleFontSize: CGFloat { return 12 }
  override var upTitleFontSize: CGFloat { return 12 }

}

// MARK: WatchResolution extension

private extension WatchResolution {
  
  var progressImageSize: CGSize {
    switch self {
    case .Watch38mm: return CGSize(width: 102, height: 102)
    case .Watch42mm: return CGSize(width: 114, height: 114)
    case .Unknown:   return CGSize(width: 114, height: 114)
    }
  }
  
}
