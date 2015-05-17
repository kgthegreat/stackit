//
//  GameScene.swift
//  stackit
//
//  Created by Kumar Gaurav on 30/01/15.
//  Copyright (c) 2015 Kumar Gaurav. All rights reserved.
//

import SpriteKit

func randRange (lower: UInt32 , upper: UInt32) -> UInt32 {
    return lower + arc4random_uniform(upper - lower + 1)
}

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
    
    if (cString.hasPrefix("#")) {
        cString = cString.substringFromIndex(advance(cString.startIndex, 1))
    }
    
    if (countElements(cString) != 6) {
        return UIColor.grayColor()
    }
    
    var rgbValue:UInt32 = 0
    NSScanner(string: cString).scanHexInt(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

struct PhysicsCategory {
    static let None : UInt32 = 0
    static let All : UInt32 = UInt32.max
    static let Player : UInt32 = 0b1
    static let Obstacle : UInt32 = 0b10
}
//FF6138 FFFF9D 00A388
var playerColor = hexStringToUIColor("FF6138")
let bgColor = hexStringToUIColor("FFFF9D")
let obColor = hexStringToUIColor("105B63")
let player = SKSpriteNode(color: playerColor, size: CGSize(width: 50, height: 50))

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let playerHeight = player.size.height

    override func didMoveToView(view: SKView) {
        /* Setup your scene here */

        backgroundColor = bgColor
        spawnPlayer()
        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addConveyor),
                SKAction.waitForDuration(4.0)])
            ))
        
        
    }
    
    func spawnPlayer() {
        player.position = CGPoint(x:size.width * 0.5, y:playerHeight/2);
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        player.physicsBody = SKPhysicsBody(rectangleOfSize: player.size)
        player.physicsBody?.dynamic = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Obstacle
        player.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        
        self.addChild(player)
        
    }
    
    func addConveyor() {

//        let trackHeight = player.size.height
//        let offset = player.size.height/2
//        let gutter = 10.0
//        let changer = [1:trackHeight+offset, 2:trackHeight*2+offset, 3:trackHeight*3+offset, 4:trackHeight*4+offset, 5:trackHeight*5+offset, 6:trackHeight*6+offset]
        
        let orientationMap = [1:size.width, 2:0]

        for i in 1...13 {
            
            var conveyorObject = SKSpriteNode(color: obColor, size: player.size)

  //          var c = changer[i]
            var orientor = orientationMap[Int(randRange(1, 2))]
            var dest: CGFloat
            if orientor ==  size.width {
                dest = 0
            } else {
                dest = size.width
            }

            conveyorObject.position = CGPoint(x: CGFloat(orientor!), y: CGFloat(playerHeight * CGFloat(i) + playerHeight/2))
            
            conveyorObject.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 48, height: 48))
            conveyorObject.physicsBody?.dynamic = true
            conveyorObject.physicsBody?.categoryBitMask = PhysicsCategory.Obstacle
            conveyorObject.physicsBody?.contactTestBitMask = PhysicsCategory.Player
            conveyorObject.physicsBody?.collisionBitMask = PhysicsCategory.None
            conveyorObject.physicsBody?.usesPreciseCollisionDetection = true

            
            addChild(conveyorObject)
        
            var actualDuration = randRange(4, 8)
            
            var actionMove = SKAction.moveToX(dest, duration: NSTimeInterval(actualDuration))
            var actionMoveDone = SKAction.removeFromParent()
        
            conveyorObject.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        
//        var movementBoundHorizontal = touchLocation.x < player.position.x - (player.size.width/2) &&
//            touchLocation.x > player.position.x + (player.size.width/2) && touchLocation.y <= player.position.y
//        var movementYLimit = touchLocation.y < player.position.y + (player.size.height*1.5)
//        var movementStraightLimit = touchLocation.x > player.position.x - (player.size.width/2) &&
//        touchLocation.x < player.position.x + (player.size.width/2)
        
        var destination = CGPoint(x: player.position.x, y: player.position.y)

        if touchLocation.x < player.position.x && touchLocation.y <= player.position.y + player.size.height/2 {
            destination = CGPoint(x: player.position.x - player.size.width, y: player.position.y)
        }
        if touchLocation.x > player.position.x && touchLocation.y <= player.position.y + player.size.height/2 {
            destination = CGPoint(x: player.position.x + player.size.width, y: player.position.y)
        }
        
        if touchLocation.y > player.position.y + player.size.height/2  {
            destination = CGPoint(x: player.position.x, y: player.position.y + player.size.height)
        }
        if touchLocation.y < player.position.y - player.size.height/2  {
            destination = CGPoint(x: player.position.x, y: player.position.y - player.size.height)
        }
        
        


        let actionMove = SKAction.moveTo(destination, duration: 0.02)
        player.runAction(SKAction.sequence([actionMove]))
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins
//        touches.
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)
        }*/
        if player.position.y >= size.height - playerHeight {
            // spawnPlayer()
           // let label = SKLabelNode(text: "Success")
            let dummyPlayer = SKSpriteNode(color: playerColor, size: CGSize(width: 50, height: 50))
            dummyPlayer.position = player.position
            self.addChild(dummyPlayer)
            //player.removeFromParent()
            //spawnPlayer()
            player.position = CGPoint(x:size.width * 0.5, y:playerHeight/2)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        
        /* Called before each frame is rendered */
    }
    
    func playerDidCollideWithObstacle(player: SKSpriteNode, obstacle: SKSpriteNode) {
        println("COllision")
        player.removeFromParent()
        //didMoveToView(self.view!)
        //self.addChild(player)
        
        spawnPlayer()
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if((firstBody.categoryBitMask & PhysicsCategory.Player != 0) && (secondBody.categoryBitMask & PhysicsCategory.Obstacle != 0)) {
            playerDidCollideWithObstacle(firstBody.node as SKSpriteNode, obstacle: secondBody.node as SKSpriteNode)
        }
        
    }
}
