//
//  DrawingView.swift
//  TestVoiceActions
//
//  Created by Le Tai on 8/26/16.
//  Copyright © 2016 Snowball. All rights reserved.
//

import UIKit

enum ShapeType {
    case Circle
    case Square(radius: CGFloat)
}

@IBDesignable
class DrawingView: UIView {
    
    var shapeType: ShapeType = .Circle
    
    var shapeLayer: CAShapeLayer!
    
    init(frame: CGRect, shapeType: ShapeType) {
        super.init(frame: frame)
        self.shapeType = shapeType
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func startAnimating(duration: CFTimeInterval) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.fillMode = kCAFillModeForwards
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.removedOnCompletion = false
        shapeLayer.strokeEnd = 1.0
        shapeLayer.addAnimation(animation, forKey: "strokeEnd animation")
    }
    
    func setProgress(progress: Float) {
        self.shapeLayer.strokeEnd = 0.0
        UIView.animateWithDuration(0.1) {
            self.shapeLayer.strokeEnd = CGFloat(progress)
        }
    }
    
    private func commonInit() {
        let customLayerWidth = CGFloat(5)
        backgroundColor = .yellowColor()
        
        var animatingPath: UIBezierPath!
        var borderPath: UIBezierPath!
        
        let frame = CGRect(x: -customLayerWidth/2,
                           y: -customLayerWidth/2,
                           width: self.frame.width + customLayerWidth,
                           height: self.frame.height + customLayerWidth)
        var cornerRadius: CGFloat!
        
        switch shapeType {
        case .Circle:
            let centerPoint = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
            animatingPath = UIBezierPath(arcCenter: centerPoint,
                                     radius: frame.width/2,
                                     startAngle: 0.0,
                                     endAngle: CGFloat(M_PI * 2.0),
                                     clockwise: true)
            borderPath = UIBezierPath(arcCenter: centerPoint,
                                      radius: frame.width/2,
                                      startAngle: 0.0,
                                      endAngle: CGFloat(M_PI * 2.0),
                                      clockwise: true)
            
            cornerRadius = self.frame.height/2
        case .Square(let radius):
            animatingPath = UIBezierPath(roundedRect: frame, cornerRadius: radius)
            borderPath = UIBezierPath(roundedRect: frame, cornerRadius: radius)
            
            cornerRadius = radius
        }
        
        let borderLayer: CAShapeLayer = CAShapeLayer()
        borderLayer.path = borderPath.CGPath
        borderLayer.fillColor = UIColor.clearColor().CGColor
        borderLayer.strokeColor = UIColor.redColor().colorWithAlphaComponent(0.3).CGColor
        borderLayer.lineWidth = customLayerWidth
        borderLayer.strokeEnd = 1.0
        layer.addSublayer(borderLayer)
        
        shapeLayer = CAShapeLayer()
        shapeLayer.path = animatingPath.CGPath
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        shapeLayer.strokeColor = UIColor.redColor().CGColor
        shapeLayer.lineWidth = customLayerWidth
        shapeLayer.strokeEnd = 0.0
        layer.addSublayer(shapeLayer)
        
        layer.cornerRadius = cornerRadius
    }
}
