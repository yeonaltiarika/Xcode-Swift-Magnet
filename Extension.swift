//
//  Extension.swift
//  Magnet
//
//  Created by Altiarika on 6/10/17.
//  Copyright © 2017 Altiarika. All rights reserved.
//

import Foundation

extension CGFloat {
    
    static func random(_ lower: CGFloat = 0, _ upper: CGFloat = 1) -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * (upper - lower) + lower
    }
    
}

extension CGPoint {
    
    func distance(from point: CGPoint) -> CGFloat {
        return hypot(point.x - x, point.y - y)
    }
    
}

