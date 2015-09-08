//
//  BezierPathsView.swift
//  Breakout
//
//  Created by Raphael Neuenschwander on 31.08.15.
//  Copyright (c) 2015 Raphael Neuenschwander. All rights reserved.
//

import UIKit

class BezierPathsView: UIView {
    
    private var bezierPaths = [String:UIBezierPath]()
    var fillColor = UIColor(red: 0.00, green: 0.15, blue: 0.47, alpha: 0.7)
    
    func setBezierPath(path:UIBezierPath?, named name: String) {
        bezierPaths[name] = path // if Path is nil , it will remove the bezier path for that name, handy !
        setNeedsDisplay()
    }

    override func drawRect(rect: CGRect) {
        for (_ , path) in bezierPaths {
            fillColor.setFill()
            path.fill()
        }
    }

}
