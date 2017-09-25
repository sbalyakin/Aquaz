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
    static let backgroundColor = UIColor.white
    static let showDuration: TimeInterval = 0.6
    static let hideDuration: TimeInterval = 0.6
  }
  
  @IBOutlet weak var infoImageView: UIImageView!
  @IBOutlet weak var infoLabel: UILabel!
  @IBOutlet weak var accessoryImageView: UIImageView!
  
  typealias BannerWasTappedFunction = (InfoBannerView) -> ()
  
  var bannerWasTappedFunction: BannerWasTappedFunction?
  
  var showDuration: TimeInterval = Defaults.showDuration
  var hideDuration: TimeInterval = Defaults.hideDuration
  var showDelay: TimeInterval = 0
  var hideDelay: TimeInterval = 0
  
  class func create() -> InfoBannerView {
    let nib = UINib(nibName: Constants.infoBannerViewNib, bundle: nil)
    let infoBannerView = nib.instantiate(withOwner: nil, options: nil).first as! InfoBannerView
    return infoBannerView
  }
  
  func show(animated: Bool, parentView: UIView, height: CGFloat = Defaults.height, minY: CGFloat = Defaults.minY, completion: ((Bool) -> Void)? = nil) {
    setupUI(parentView: parentView, height: height, minY: minY)
    
    if animated {
      layer.opacity = 0
      isHidden = false
      layer.transform = CATransform3DMakeScale(0.7, 0.7, 0.7)

      UIView.animate(withDuration: showDuration,
        delay: showDelay,
        usingSpringWithDamping: 0.4,
        initialSpringVelocity: 1.7,
        options: .allowUserInteraction,
        animations: {
          self.layer.opacity = 1
          self.layer.transform = CATransform3DMakeScale(1, 1, 1)
        },
        completion: completion)
    } else {
      isHidden = false
    }
  }
  
  func showAndHide(animated: Bool, displayTime: TimeInterval, parentView: UIView, height: CGFloat = Defaults.height, minY: CGFloat = Defaults.minY, completion: ((Bool) -> Void)? = nil) {
    show(animated: animated, parentView: parentView, height: height, minY: minY) { _ in
      SystemHelper.executeBlockWithDelay(displayTime) {
        self.hide(animated: animated, completion: completion)
      }
    }
  }
  
  func hide(animated: Bool, completion: ((Bool) -> Void)? = nil) {
    if animated {
      UIView.animate(withDuration: hideDuration,
        delay: hideDelay,
        usingSpringWithDamping: 0.8,
        initialSpringVelocity: 10,
        options: .allowUserInteraction,
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
  
  fileprivate func setupUI(parentView: UIView, height: CGFloat, minY: CGFloat) {
    translatesAutoresizingMaskIntoConstraints = false
    
    backgroundColor = Defaults.backgroundColor
    isHidden = true
    parentView.addSubview(self)
    
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.bannerWasTapped(_:)))
    self.addGestureRecognizer(tapGestureRecognizer)
    
    // Setup constraints
    let views = ["banner": self]
    parentView.addConstraints("H:|-0-[banner]", views: views)
    parentView.addConstraints("H:[banner]-0-|", views: views)
    parentView.addConstraints("V:|-\(minY)-[banner(\(height))]", views: views)
  }
  
  @objc func bannerWasTapped(_ gestureRecognizer: UITapGestureRecognizer) {
    if gestureRecognizer.state == .ended {
      bannerWasTappedFunction?(self)
    }
  }
  
}
