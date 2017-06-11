//
//  ViewController.swift
//  Magnet
//
//  Created by Altiarika on 6/10/17.
//  Copyright © 2017 Altiarika. All rights reserved.
//

import SpriteKit
import Magnet

class ViewController: UIViewController {
    
    @IBOutlet weak var magnetView: MagnetView! {
        didSet {
            magnet.magnetDelegate = self
            #if DEBUG
                magnetView.showsFPS = true
                magnetView.showsDrawCount = true
                magnetView.showsQuadCount = true
            #endif
        }
    }
    
    var magnet: Magnet {
        return magnetView.magnet
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 0..<12 {
            add(nil)
        }
    }
    
    @IBAction func add(_ sender: UIControl?) {
        let name = UIImage.names.randomItem()
        let color = UIColor.colors.randomItem()
        let node = Node(text: name.capitalized, image: UIImage(named: name), color: color, radius: 40)
        magnetic.addChild(node)
    }
    
    @IBAction func reset(_ sender: UIControl?) {
        let speed = magnet.physicsWorld.speed
        magnet.physicsWorld.speed = 0
        let sortedNodes = magnet.children.flatMap { $0 as? Node }.sorted { node, nextNode in
            let distance = node.position.distance(from: magnet.magnetField.position)
            let nextDistance = nextNode.position.distance(from: magnet.magnetField.position)
            return distance < nextDistance && node.isSelected
        }
        var actions = [SKAction]()
        for (index, node) in sortedNodes.enumerated() {
            node.physicsBody = nil
            let action = SKAction.run { [unowned magnetic, unowned node] in
                if node.isSelected {
                    let point = CGPoint(x: magnet.size.width / 2, y: magnet.size.height + 40)
                    let movingXAction = SKAction.moveTo(x: point.x, duration: 0.2)
                    let movingYAction = SKAction.moveTo(y: point.y, duration: 0.4)
                    let resize = SKAction.scale(to: 0.3, duration: 0.4)
                    let throwAction = SKAction.group([movingXAction, movingYAction, resize])
                    node.run(throwAction) { [unowned node] in
                        node.removeFromParent()
                    }
                } else {
                    node.removeFromParent()
                }
            }
            actions.append(action)
            let delay = SKAction.wait(forDuration: TimeInterval(index) * 0.01)
            actions.append(delay)
        }
        magnet.run(.sequence(actions)) { [unowned magnetic] in
            magnet.physicsWorld.speed = speed
        }
    }
    
}

// MARK: - MagnetDelegate
extension ViewController: MagnetDelegate {
    
    func magnet(_ magnet: Magnet, didSelect node: Node) {
        print("didSelect -> \(node)")
    }
    
    func magnet(_ magnet: Magnet, didDeselect node: Node) {
        print("didDeselect -> \(node)")
    }
    
}
