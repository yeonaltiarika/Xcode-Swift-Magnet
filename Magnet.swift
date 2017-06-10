//
//  Magnet.swift
//  Magnet
//
//  Created by Altiarika on 6/10/17.
//  Copyright © 2017 Altiarika. All rights reserved.
//

import SpriteKit

public protocol MagnetDelegate: class {
    func magnet(_ magnet: Magnet, didSelect node: Node)
    func magnet(_ magnet: Magnet, didDeselect node: Node)
}

open class Magnet: SKScene {
    
    /**
     The field node that accelerates the nodes.
     */
    public lazy var magnetField: SKFieldNode = { [unowned self] in
        let field = SKFieldNode.radialGravityField()
        field.region = SKRegion(radius: 2000)
        field.minimumRadius = 2000
        field.strength = 500
        self.addChild(field)
        return field
        }()
    
    /**
     Controls whether you can select multiple nodes.
     */
    open var allowsMultipleSelection: Bool = true
    
    var isMoving: Bool = false
    
    /**
     The selected children.
     */
    open var selectedChildren: [Node] {
        return children.flatMap { $0 as? Node }.filter { $0.isSelected }
    }
    
    /**
     The object that acts as the delegate of the scene.
     
     The delegate must adopt the MagneticDelegate protocol. The delegate is not retained.
     */
    open weak var magnetDelegate: MagnetDelegate?
    
    override open func didMove(to view: SKView) {
        super.didMove(to: view)
        
        self.backgroundColor = .white
        self.scaleMode = .aspectFill
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: { () -> CGRect in
            var frame = self.frame
            frame.size.width = CGFloat(magnetField.minimumRadius)
            frame.origin.x -= frame.size.width / 2
            return frame
        }())
        magnetField.position = CGPoint(x: size.width / 2, y: size.height / 2)
    }
    
    override open func addChild(_ node: SKNode) {
        var x = -node.frame.width // left
        if children.count % 2 == 0 {
            x = frame.width + node.frame.width // right
        }
        let y = CGFloat.random(node.frame.height, frame.height - node.frame.height)
        node.position = CGPoint(x: x, y: y)
        super.addChild(node)
    }
    
    override open func atPoint(_ p: CGPoint) -> SKNode {
        var node = super.atPoint(p)
        while true {
            if node is Node {
                return node
            } else if let parent = node.parent {
                node = parent
            } else {
                break
            }
        }
        return node
    }
    
}

extension Magnet {
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let previous = touch.previousLocation(in: self)
            
            if location.distance(from: previous) == 0 { return }
            
            isMoving = true
            
            let x = location.x - previous.x
            let y = location.y - previous.y
            
            for node in children {
                let distance = node.position.distance(from: location)
                let acceleration: CGFloat = 3 * pow(distance, 1/2)
                let direction = CGVector(dx: x * acceleration, dy: y * acceleration)
                node.physicsBody?.applyForce(direction)
            }
        }
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isMoving, let point = touches.first?.location(in: self), let node = atPoint(point) as? Node {
            if node.isSelected {
                node.isSelected = false
                magnetDelegate?.magnet(self, didDeselect: node)
            } else {
                if !allowsMultipleSelection, let selectedNode = selectedChildren.first {
                    selectedNode.isSelected = false
                    magnetDelegate?.magnet(self, didDeselect: selectedNode)
                }
                node.isSelected = true
                magnetDelegate?.magnet(self, didSelect: node)
            }
        }
        isMoving = false
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isMoving = false
    }
    
}

