//
//  GameScene.swift
//  coinMan
//
//  Created by harshvardhan singh on 9/19/19.
//  Copyright © 2019 harshvardhan singh. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var coinMan: SKSpriteNode?
    var coinTimer: Timer?
    var bombTimer: Timer?
    var ceiling: SKSpriteNode?
    var scoreLabel: SKLabelNode?
    var yourScoreLabel: SKLabelNode?
    var finalScoreLabel: SKLabelNode?
    var highScoreLabel: SKLabelNode?
    
    let coinManCategory: UInt32 = 0x1 << 1
    let coinCategory: UInt32 = 0x1 << 2
    let bombCategory: UInt32 = 0x1 << 3
    let groundAndCeilingCategory: UInt32 = 0x1 << 4
    
    var score = 0
    var highScore = 0
    var highInt = 0

    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        
        coinMan = childNode(withName: "coinMan") as? SKSpriteNode
        coinMan?.physicsBody?.categoryBitMask = coinManCategory
        coinMan?.physicsBody?.contactTestBitMask = coinCategory | bombCategory
        coinMan?.physicsBody?.collisionBitMask = groundAndCeilingCategory
        var coinManRun: [SKTexture] = []
        for number in 1...9{
            
            coinManRun.append(SKTexture(imageNamed: "JK_P_Gun__Run_00\(number)"))
            
        }
        
        coinMan?.run(SKAction.repeatForever(SKAction.animate(with: coinManRun, timePerFrame: 0.05)))
        
        //ground = childNode(withName: "ground") as! SKSpriteNode
        //ground?.physicsBody?.categoryBitMask = groundAndCeilingCategory
        //ground?.physicsBody?.collisionBitMask = coinManCategory
        
        ceiling = childNode(withName: "ceiling") as! SKSpriteNode
        ceiling?.physicsBody?.categoryBitMask = groundAndCeilingCategory
        ceiling?.physicsBody?.collisionBitMask = coinManCategory
        
        scoreLabel = childNode(withName: "scoreLabel") as! SKLabelNode
        highScoreLabel = childNode(withName: "highScoreLabel") as! SKLabelNode
        
        startTimers()
        createGrass()
        
    }
    
    func createGrass(){
        
        let sizingGrass = SKSpriteNode(imageNamed: "grass")
        let numberOfGrass = Int(size.width/sizingGrass.size.width) + 1
        for number in 0...numberOfGrass{
            
            let grass = SKSpriteNode(imageNamed: "grass")
            grass.physicsBody = SKPhysicsBody(rectangleOf: grass.size)
            grass.physicsBody?.categoryBitMask = groundAndCeilingCategory
            grass.physicsBody?.collisionBitMask = coinManCategory
            grass.physicsBody?.affectedByGravity = false
            grass.physicsBody?.isDynamic = false
            addChild(grass)
            
            let x = Int(-size.width/2) + (Int(grass.size.width) * number) - 50
            grass.position = CGPoint(x: x, y: Int(-size.height/2 + grass.size.height) - 91)
            
            let speed = 100.0
            let moveLeft = SKAction.moveBy(x: -grass.size.width - grass.size.width * CGFloat(number), y: 0, duration: TimeInterval(grass.size.width + grass.size.width * CGFloat(number)) / speed)
            
            let resetGrass = SKAction.moveBy(x: size.width + grass.size.width, y: 0, duration: 0)
            
            let grassFullMove = SKAction.moveBy(x: -size.width - grass.size.width, y: 0, duration: TimeInterval(size.width + grass.size.width)/speed)
                
            let grassMovingForever = SKAction.repeatForever(SKAction.sequence([grassFullMove, resetGrass]))
            
            grass.run(SKAction.sequence([moveLeft, resetGrass, grassMovingForever]))
            
        }
        
    }
    
    func startTimers() {
        
        coinTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            
            self.createCoin()
            
        })
        
        bombTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (timer) in
            
            self.createBomb()
            
        })
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if scene?.isPaused == false{
        
            coinMan!.physicsBody?.applyForce(CGVector(dx: 0, dy: 20000))
        
        }
            
        let touch = touches.first
        
        if let location = touch?.location(in: self){
            
             let theNodes = nodes(at: location)
            
            for node in theNodes{
                
                if node.name == "play"{
                    
                    score = 0
                    highInt = 0
                    node.removeFromParent()
                    finalScoreLabel?.removeFromParent()
                    yourScoreLabel?.removeFromParent()
                    
                    scene?.isPaused = false
                    scoreLabel?.text = "Score: \(score)"
                    
                    startTimers()
                    
                }
                
            }
            
        }
        
    }
    
    func createCoin(){
        
        let coin = SKSpriteNode(imageNamed: "coin")
        coin.physicsBody = SKPhysicsBody(rectangleOf: coin.size)
        coin.physicsBody?.affectedByGravity = false
        coin.physicsBody?.categoryBitMask = coinCategory
        coin.physicsBody?.contactTestBitMask = coinManCategory
        coin.physicsBody?.collisionBitMask = 0
        addChild(coin)
        
        let sizingGrass = SKSpriteNode(imageNamed: "grass")
        
        let maxY = size.height/2 - coin.size.height/2
        let minY = -size.height/2 + coin.size.height/2 + sizingGrass.size.height
        let range = maxY - minY
        
        let coinY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        
        coin.position = CGPoint(x: size.width/2 + coin.size.width/2 , y: coinY)
        let moveLeft = SKAction.moveBy(x: -size.width/2 - coin.size.width/2, y: 0, duration: 4)
        coin.run(moveLeft)
        SKAction.removeFromParent()
        coin.run(SKAction.sequence([moveLeft, SKAction.removeFromParent()]))
        
    }
    
    func createBomb() {
        
        let bomb = SKSpriteNode(imageNamed: "bomb")
        bomb.physicsBody = SKPhysicsBody(rectangleOf: bomb.size)
        bomb.physicsBody?.affectedByGravity = false
        bomb.physicsBody?.categoryBitMask = bombCategory
        bomb.physicsBody?.contactTestBitMask = coinManCategory
        bomb.physicsBody?.collisionBitMask = 0
        addChild(bomb)
        
        let sizingGrass = SKSpriteNode(imageNamed: "grass")
        
        let maxY = size.height/2 - bomb.size.height/2
        let minY = -size.height/2 + bomb.size.height/2 + sizingGrass.size.height
        let range = maxY - minY
        
        let bombY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        
        bomb.position = CGPoint(x: size.width/2 + bomb.size.width/2 , y: bombY)
        let moveLeft = SKAction.moveBy(x: -size.width/2 - bomb.size.width/2, y: 0, duration: 4)
        bomb.run(moveLeft)
        SKAction.removeFromParent()
        bomb.run(SKAction.sequence([moveLeft, SKAction.removeFromParent()]))
        
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if contact.bodyA.categoryBitMask == coinCategory{
            
            score += 1
            scoreLabel?.text = "Score: \(score)"
            
            if score >= highScore{
                highInt = 1
                highScore = score
                highScoreLabel?.text = "High Score:\(highScore)"
            }
            
            contact.bodyA.node?.removeFromParent()
            
        }
        if contact.bodyB.categoryBitMask == coinCategory{
            
            score += 1
            scoreLabel?.text = "Score: \(score)"
            
            if score >= highScore{
                highInt = 1
                highScore = score
                highScoreLabel?.text = "High Score:\(highScore)"
            }
            
            contact.bodyB.node?.removeFromParent()
            
        }
        if contact.bodyA.categoryBitMask == bombCategory{
            
            contact.bodyA.node?.removeFromParent()
            gameOver()
            
        }
        if contact.bodyB.categoryBitMask == bombCategory{
            
            contact.bodyB.node?.removeFromParent()
            gameOver()
            
        }
    }
    
    func gameOver() {
        
        scene?.isPaused = true
        
        coinTimer?.invalidate()
        bombTimer?.invalidate()
        
        if highInt == 1{
            
            yourScoreLabel = SKLabelNode(text: "New High Score:")
            yourScoreLabel?.position = CGPoint(x: 0, y: 200)
            yourScoreLabel?.zPosition = 1
            yourScoreLabel?.fontSize = 90
            if yourScoreLabel != nil{
                addChild(yourScoreLabel!)
            }
            
        }else if highInt == 0{
            yourScoreLabel = SKLabelNode(text: "Your Score:")
            yourScoreLabel?.position = CGPoint(x: 0, y: 200)
            yourScoreLabel?.zPosition = 1
            yourScoreLabel?.fontSize = 100
            if yourScoreLabel != nil{
                addChild(yourScoreLabel!)
            }
        }
        
        finalScoreLabel = SKLabelNode(text: "\(score)")
        finalScoreLabel?.position = CGPoint(x: 0, y: 0)
        finalScoreLabel?.zPosition = 1
        finalScoreLabel?.fontSize = 200
        if finalScoreLabel != nil{
            addChild(finalScoreLabel!)
        }
        
        let playButton = SKSpriteNode(imageNamed: "play")
        playButton.name = "play"
        playButton.zPosition = 1
        playButton.position = CGPoint(x: 0, y: -200)
        addChild(playButton)
        
    }
    
}
