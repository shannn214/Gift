//
//  GameScene.swift
//  BamBamLuke
//
//  Created by 尚靖 on 2018/7/18.
//  Copyright © 2018年 尚靖. All rights reserved.
//

import SpriteKit
import GameplayKit

func +(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
}
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

struct PhysicsCategory {
    
    static let none      : UInt32 = 0
    static let all       : UInt32 = UInt32.max
    static let children   : UInt32 = 0b1
    static let enidAttack: UInt32 = 0b10
    
}

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    let luke = SKSpriteNode(imageNamed: "Luke")
    
    var childrenDestroyed = 0
    
    override func didMove(to view: SKView) {
        
        backgroundColor = SKColor.white
        
        luke.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        
        addChild(luke)
        
        physicsWorld.gravity = .zero
        
        physicsWorld.contactDelegate = self
        
        run(SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.run(addDeadChildren),
                    SKAction.wait(forDuration: 1.0)
                    ])
        ))
    }
    
    func random() -> CGFloat {
        
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
        
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        
        return random() * (max - min) + min
        
    }
    
    func addDeadChildren() {
        
        let children = SKSpriteNode(imageNamed: "QShannn")
        
        let actualY = random(min: children.size.height / 2,
                             max: size.height - children.size.height / 2)
        
        children.position = CGPoint(x: size.width + children.size.width / 2,
                                    y: actualY)
        
        addChild(children)
        
        children.physicsBody = SKPhysicsBody(rectangleOf: children.size)
        
        children.physicsBody?.isDynamic = true
        
        children.physicsBody?.categoryBitMask = PhysicsCategory.children
        
        children.physicsBody?.contactTestBitMask = PhysicsCategory.enidAttack
        
        children.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        let actualDuration = random(min: CGFloat(2.0),
                                    max: CGFloat(4.0))
        
        let actionMove = SKAction.move(to: CGPoint(x: -children.size.width / 2, y: actualY), duration: TimeInterval(actualDuration))
        
        let actualMoveDone = SKAction.removeFromParent()
        
        let loseAction = SKAction.run() { [weak self] in
            guard let `self` = self else { return }
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size, won: false)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        
        children.run(SKAction.sequence([actionMove, loseAction, actualMoveDone]))
    }
    
    func enidDidCollideWithChildren(enidAttack: SKSpriteNode, children: SKSpriteNode) {
        
        print("AHHHHHHHHH!!!")
        
        enidAttack.removeFromParent()
        
        children.removeFromParent()
            
        childrenDestroyed += 1
        if childrenDestroyed > 30 {
            
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size, won: true)
            view?.presentScene(gameOverScene, transition: reveal)
        
        }
        
    }
    
    
    //--------
    
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        
        let enidAttack = SKSpriteNode(imageNamed: "Enid")
        
        enidAttack.position = luke.position
        
        let offset = touchLocation - enidAttack.position
        
        if offset.x < 0 { return }
        
        addChild(enidAttack)
        
        enidAttack.physicsBody = SKPhysicsBody(circleOfRadius: enidAttack.size.width/2)
        
        enidAttack.physicsBody?.isDynamic = true
        
        enidAttack.physicsBody?.categoryBitMask = PhysicsCategory.enidAttack
        
        enidAttack.physicsBody?.contactTestBitMask = PhysicsCategory.children
        
        enidAttack.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        enidAttack.physicsBody?.usesPreciseCollisionDetection = true
        
        let direction = offset.normalized()
        
        let shootAmount = direction * 1000
        
        let realDest = shootAmount + enidAttack.position
        
        let actionMove = SKAction.move(to: realDest, duration: 2.0)
        
        let actionMoveDone = SKAction.removeFromParent()
        
        enidAttack.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {

    }
}

extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {

        var firstBody: SKPhysicsBody

        var secondBody: SKPhysicsBody

        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {

            firstBody = contact.bodyA
            secondBody = contact.bodyB

        } else {

            firstBody = contact.bodyB
            secondBody = contact.bodyA

        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.children != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.enidAttack != 0)) {
            if let children = firstBody.node as? SKSpriteNode,
                let enidAttack = secondBody.node as? SKSpriteNode {
                enidDidCollideWithChildren(enidAttack: enidAttack, children: children)
            }
        }
    }


}
