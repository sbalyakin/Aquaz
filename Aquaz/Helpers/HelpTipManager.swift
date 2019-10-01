//
//  HelpTipManager.swift
//  Aquaz
//
//  Created by Sergey on 15.09.2019.
//  Copyright © 2019 Sergey Balyakin. All rights reserved.
//

import Foundation
import JDFTooltips

class HelpTipManager {
  
  public var isHelpTipActive : Bool { return helpTip != nil }
  
  fileprivate var helpTip: JDFTooltipView?

  public func showHelpTip(targetView: UIView, hostView: UIView, tooltipText : String, arrowDirection: JDFTooltipViewArrowDirection, width: CGFloat) {
    if let helpTip = JDFTooltipView(
      targetView: targetView,
      hostView: hostView,
      tooltipText: tooltipText,
      arrowDirection: arrowDirection,
      width: width)
    {
      self.helpTip = helpTip
      SystemHelper.executeBlockWithDelay(GlobalConstants.helpTipDisplayTime) {
        self.helpTip?.hide(animated: true)
        self.helpTip = nil
      }
      
      helpTip.show()
    }
  }
  
  public func showHelpTip(targetPoint: CGPoint, hostView: UIView, tooltipText : String, arrowDirection: JDFTooltipViewArrowDirection, width: CGFloat) {
    if let helpTip = JDFTooltipView(
      targetPoint: targetPoint,
      hostView: hostView,
      tooltipText: tooltipText,
      arrowDirection: arrowDirection,
      width: width)
    {
      self.helpTip = helpTip
      SystemHelper.executeBlockWithDelay(GlobalConstants.helpTipDisplayTime) {
        self.helpTip?.hide(animated: true)
        self.helpTip = nil
      }
      
      helpTip.show()
    }
  }
  
  public func hideHelpTip(animated: Bool) {
    self.helpTip?.hide(animated: animated)
  }

}
