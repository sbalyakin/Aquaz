//
//  BannerView.swift
//  Aquaz
//
//  Created by Sergey Balyakin on 20.01.15.
//  Copyright © 2015 Sergey Balyakin. All rights reserved.
//

import UIKit

class BannerView: UIView {
  
  override func draw(_ rect: CGRect) {
    let color = UIColor(red: 167/255, green: 169/255, blue: 171/255, alpha: 0.6)
    color.setStroke()
    
    let scaleOffset = (contentScaleFactor > 1) ? 1 / (2 * contentScaleFactor) : 0

    let path = UIBezierPath()
    path.lineWidth = 1 / contentScaleFactor
    path.move(to: CGPoint(x: rect.minX, y: rect.maxY - scaleOffset))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - scaleOffset))
    path.stroke()
  }
  
}
