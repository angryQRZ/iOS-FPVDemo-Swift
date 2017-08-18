//
//  FocusView.swift
//  iOS-FPVDemo-Swift
//
//  Created by my Mac on 2017/8/16.
//  Copyright © 2017年 DJI. All rights reserved.
//

import UIKit
@IBDesignable
class FocusView: UIView {
    var color = UIColor.magenta
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let rect = CGRect(x: bounds.midX - 50, y: bounds.midY - 50, width: 100, height: 100)
        var path = UIBezierPath(arcCenter: center, radius: 50, startAngle: 0, endAngle: CGFloat(2.0 * Double.pi), clockwise: true)

        path = UIBezierPath(rect: rect)
        path.lineWidth = 1.0
        path.move(to: center)
        color.set()
        path.stroke()
    }
 

}
