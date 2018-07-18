//
//  GameOverScene.swift
//  BamBamLuke
//
//  Created by 尚靖 on 2018/7/18.
//  Copyright © 2018年 尚靖. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
    init(size: CGSize, won:Bool) {
        super.init(size: size)
        
        backgroundColor = SKColor.white
        
        let message = won ? "log" : "BuBuBu~~ 路～可～ 怎ㄇ寫～"
        
        let label = SKLabelNode(fontNamed: "Menlo")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.black
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 3.0),
            SKAction.run() { [weak self] in
                guard let `self` = self else { return }
                let reveal = SKTransition.fade(withDuration: 0.5)
                let scene = GameScene(size: size)
                self.view?.presentScene(scene, transition:reveal)
            }
            ]))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
