
//  GameScene.swift
//  26_project


import SpriteKit
import CoreMotion

enum CollisionTypesEnum: UInt32{
    case player = 1
    case wall = 2
    case star = 4
    case vortex = 8
    case finish = 16
    case port = 32
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var nodePosition: CGPoint = CGPoint(x: 0, y: 0)
    var arrayFromText = [String]()
    var portpositions = [CGPoint]()
    var metPortal = false
    var isGameOver = false
    var nextLev = false
    var scoreLable: SKLabelNode!
    var lastTouchPosition: CGPoint?
    var motionManager: CMMotionManager!
    var player: SKSpriteNode!
    var nextlevel: SKSpriteNode!
    
    var score = 0 {
        didSet{
            scoreLable.text = "Score \(score)"
        }
    }
    
    
    override func didMove(to view: SKView) {
        
        backscorenext()
        physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = .zero
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
        loadLevel2()
        createPlayer()
    }
    
    
    func createPlayer(){
        physicsWorld.gravity = .zero
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 96, y: 672)
        player.zPosition = 1
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 0.5
        player.physicsBody?.categoryBitMask = CollisionTypesEnum.player.rawValue
        player.physicsBody?.contactTestBitMask = CollisionTypesEnum.star.rawValue | CollisionTypesEnum.vortex.rawValue | CollisionTypesEnum.finish.rawValue | CollisionTypesEnum.port.rawValue
        player.physicsBody?.collisionBitMask = CollisionTypesEnum.wall.rawValue
        addChild(player)
        isGameOver = false
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else{
            return
        }
        lastTouchPosition = touch.location(in: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        lastTouchPosition = touch.location(in: self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = nil
        
        guard let touch = touches.first else {return}
        let fingerlocation = touch.location(in: self)
        let childe = childNode(withName: "nextlevel")
        if (childe?.contains(fingerlocation))!{
            physicsWorld.gravity = .zero
            isGameOver = true
            self.removeAllChildren()
            portpositions.removeAll()
            backscorenext()
            loadLevel2()
            createPlayer()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = nil
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update( currentTime)
        if isGameOver == true {return}
        
        #if targetEnvironment(simulator)
        if let touchLocation = lastTouchPosition {
            let diff = CGPoint(x: touchLocation.x - player.position.x, y: touchLocation.y - player.position.y)
            physicsWorld.gravity = CGVector(dx: diff.x/100, dy: diff.y/100)
        }
        #else
        if let acceleratorData = motionManager.accelerometerData{
            self.physicsWorld.gravity = CGVector(dx: acceleratorData.acceleration.y * -50, dy: acceleratorData.acceleration.x * 50)
        }
        #endif
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        guard let nodeA = contact.bodyA.node else {return}
        guard let nodeB = contact.bodyB.node else {return}
        
        if nodeA == player{
            playerCollided(with: nodeB)
        }
        else if nodeB == player{
            playerCollided(with: nodeA)
        }
        
    }
    
    func playerCollided(with node: SKNode){
        if node.name == "vortex" {
            physicsWorld.gravity = .zero
            player.physicsBody?.isDynamic = false
            isGameOver = true
            score -= 1
            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(by: 0.0001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            let seq = SKAction.sequence([move,scale,remove])
            player.run(seq){[weak self] in
                self?.createPlayer()
                self?.isGameOver = false
            }
        }
        else if node.name == "star"{
            score += 1
            node.removeFromParent()
        }
        else if node.name == "finish"{
            isGameOver = true
            score += 1000
            let colorize = SKAction.colorize(with: .yellow, colorBlendFactor: 1, duration: 1)
            node.run(colorize)
            let move = SKAction.move(to: node.position, duration: 0.2)
            let remove = SKAction.removeFromParent()
            let seq = SKAction.sequence([move, remove])
            player.run(seq) {
                let youwon = SKSpriteNode(imageNamed: "won")
                youwon.position = CGPoint(x: 0, y: -60)
                youwon.zPosition = 3
                node.addChild(youwon)
                self.isGameOver = true }
        }
        else if node.name == "port" {
            if metPortal == true {
                metPortal = false
                return
            }
            player.physicsBody?.isDynamic = false
            physicsWorld.gravity = .zero
            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(by: 0.05, duration: 0.25)
            let seq = SKAction.sequence([move,scale])
            player.run(seq){[weak self] in
                
                let portpositionsTemp = self?.portpositions.filter{$0 != node.position}
                self?.player.position = portpositionsTemp!.randomElement()!
                self?.player.run(SKAction.scale(to: 1, duration: 0.05))
                self?.player.physicsBody?.isDynamic = true
                self?.metPortal = true
            }
        }
    }
    
    func backscorenext(){
        
        nextlevel = SKSpriteNode(imageNamed: "nextlevel")
        nextlevel.name = "nextlevel"
        nextlevel.position = CGPoint(x: 925, y: 740)
        nextlevel.zPosition = 3
        addChild(nextlevel)
        
        scoreLable = SKLabelNode(fontNamed: "chalkduster")
        scoreLable.horizontalAlignmentMode = .left
        scoreLable.text = "Score: 0"
        scoreLable.position = CGPoint(x: 20, y: 20)
        scoreLable.zPosition = 2
        addChild(scoreLable)
        
        let background = SKSpriteNode(imageNamed: "background")
        background.blendMode = .replace
        background.zPosition = -1
        background.position = CGPoint(x: 512, y: 384)
        addChild(background)
    }
}

