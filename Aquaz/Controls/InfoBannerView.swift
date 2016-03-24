//
//  InfoBannerView.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 04.06.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class InfoBannerView: BannerView {

  struct Constants {
    static let infoBannerViewNib = "InfoBannerView"
  }
  
  struct Defaults {
    static let height: CGFloat = 75
    static let minY: CGFloat = 0
    static let backgroundColor = UIColor.whiteColor()
    static let showDuration: NSTimeInterval = 0.6
    static let hideDuration: NSTimeInterval = 0.6
  }
  
  @IBOutlet weak var infoImageView: UIImageView!
  @IBOutlet weak var infoLabel: UILabel!
  @IBOutlet weak var accessoryImageView: UIImageView!
  
  typealias BannerWasTappedFunction = (InfoBannerView) -> ()
  
  var bannerWasTappedFunction: BannerWasTappedFunction?
  
  var showDuration: NSTimeInterval = Defaults.showDuration
  var hideDuration: NSTimeInterval = Defaults.hideDuration
  var showDelay: NSTimeInterval = 0
  var hideDelay: NSTimeInterval = 0
  
  class func create() -> InfoBannerView {
    let nib = UINib(nibName: Constants.infoBannerViewNib, bundle: nil)
    let infoBannerView = nib.instantiateWithOwner(nil, options: nil).first as! InfoBannerView
    return infoBannerView
  }
  
  func show(animated animated: Bool, parentView: UIView, height: CGFloat = Defaults.height, minY: CGFloat = Defaults.minY, completion: ((Bool) -> Void)? = nil) {
    setupUI(parentView: parentView, height: height, minY: minY)
    
    if animated {
      layer.opacity = 0
      hidden = false
      layer.transform = CATransform3DMakeScale(0.7, 0.7, 0.7)

      UIView.animateWithDuration(showDuration,
        delay: showDelay,
        usingSpringWithDamping: 0.4,
        initialSpringVelocity: 1.7,
        options: [.CurveEaseInOut, .AllowUserInteraction],
        animations: {
          self.layer.opacity = 1
          self.layer.transform = CATransform3DMakeScale(1, 1, 1)
        },
        completion: completion)
    } else {
      hidden = false
    }
  }
  
  func showAndHide(animated animated: Bool, displayTime: NSTimeInterval, parentView: UIView, height: CGFloat = Defaults.height, minY: CGFloat = Defaults.minY, completion: ((Bool) -> Void)? = nil) {
    show(animated: animated, parentView: parentView, height: height, minY: minY) { _ in
      SystemHelper.executeBlockWithDelay(displayTime) {
        self.hide(animated: animated, completion: completion)
      }
    }
  }
  
  func hide(animated animated: Bool, completion: ((Bool) -> Void)? = nil) {
    if animated {
      UIView.animateWithDuration(hideDuration,
        delay: hideDelay,
        usingSpringWithDamping: 0.8,
        initialSpringVelocity: 10,
        options: [.CurveEaseInOut, .AllowUserInteraction],
        animations: {
          self.layer.opacity = 0
          self.layer.transform = CATransform3DMakeScale(0.7, 0.7, 0.7)
        },
        completion: { finished in
          self.removeFromSuperview()
          completion?(finished)
      })
    } else {
      removeFromSuperview()
      completion?(true)
    }
  }
  
  private func setupUI(parentView parentView: UIView, height: CGFloat, minY: CGFloat) {
    translatesAutoresizingMaskIntoConstraints = false
    
    backgroundColor = Defaults.backgroundColor
    hidden = true
    parentView.addSubview(self)
    
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.bannerWasTapped(_:)))
    self.addGestureRecognizer(tapGestureRecognizer)
    
    // Setup constraints
    let views = ["banner": self]
    parentView.addConstraints("H:|-0-[banner]", views: views)
    parentView.addConstraints("H:[banner]-0-|", views: views)
    parentView.addConstraints("V:|-\(minY)-[banner(\(height))]", views: views)
  }
  
  func bannerWasTapped(gestureRecognizer: UITapGestureRecognizer) {
    if gestureRecognizer.state == .Ended {
      bannerWasTappedFunction?(self)
    }
  }
  
}
