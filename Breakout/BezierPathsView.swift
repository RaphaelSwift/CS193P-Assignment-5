//
//  BezierPathsView.swift
//  Breakout
//
//  Created by Raphael Neuenschwander on 31.08.15.
//  Copyright (c) 2015 Raphael Neuenschwander. All rights reserved.
//

import UIKit

class BezierPathsView: UIView {
    
    private var bezierPaths = [String:[UIBezierPath]]()
    
    func setBezierPaths(paths:[UIBezierPath]?, named name: String) {
        bezierPaths[name] = paths
        setNeedsDisplay()
    }
    
    func clearBezierPaths(named name:String) {
        bezierPaths[name] = []
        setNeedsDisplay()
    }

    override func drawRect(rect: CGRect) {
        for (_, pathArray) in bezierPaths {
            for path in pathArray {
                path.stroke()
            }
        }
    }

}
