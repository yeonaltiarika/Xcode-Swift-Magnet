//
//  MagnetView.swift
//  Magnet
//
//  Created by Altiarika on 6/10/17.
//  Copyright © 2017 Altiarika. All rights reserved.
//

import SpriteKit

public class MagnetView: SKView {
    
    public lazy var magnet: Magnet = { [unowned self] in
        let scene = Magnet(size: self.bounds.size)
        self.presentScene(scene)
        return scene
        }()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    func commonInit() {
        _ = magnet
    }
    
}

