//
//  CircularProgressIndicator.swift
//  FlingChallenge
//
//  Created by Alexander Kolov on 9/5/16.
//  Copyright © 2016 Alexander Kolov. All rights reserved.
//

import UIKit

@IBDesignable
class CircularProgressIndicator: UIView {

  override init(frame: CGRect) {
    super.init(frame: frame)
    initialize()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initialize()
  }

  var progress: Float = 0 {
    didSet {
      shapeLayer.path = path.CGPath

      if progress >= 1.0 && hideWhenFinished {
        hidden = true
      }
      else {
        hidden = false
      }
    }
  }

  var hideWhenFinished: Bool = true

  private func initialize() {
    backgroundShapeLayer.fillColor = nil
    backgroundShapeLayer.strokeColor = UIColor(white: 0, alpha: 0.5).CGColor
    backgroundShapeLayer.lineWidth = 10
    backgroundShapeLayer.addSublayer(shapeLayer)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    backgroundShapeLayer.path = UIBezierPath(ovalInRect: bounds).CGPath
  }

  override class func layerClass() -> AnyClass {
    return CAShapeLayer.self
  }

  var backgroundShapeLayer: CAShapeLayer {
    return layer as! CAShapeLayer
  }

  private(set) lazy var shapeLayer: CAShapeLayer = {
    let layer = CAShapeLayer()
    layer.fillColor = nil
    layer.strokeColor = UIColor.whiteColor().CGColor
    layer.lineWidth = 10
    return layer
  }()

  override func intrinsicContentSize() -> CGSize {
    return CGSize(width: 60, height: 60)
  }

  private var path: UIBezierPath {
    let start = M_PI * 1.5
    let end = start + M_PI * 2.0

    let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
    let radius = bounds.width / 2
    let startAngle = CGFloat(start)
    let endAngle = CGFloat(Float(end - start) * progress) + startAngle

    let path = UIBezierPath()
    path.addArcWithCenter(center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
    return path
  }

}
