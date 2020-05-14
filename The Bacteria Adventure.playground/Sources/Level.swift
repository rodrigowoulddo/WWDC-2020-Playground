import Foundation
import SpriteKit

public class Level: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Private Constants
    private let BACTERIA_SPEED: CGFloat = 155.0
    private let VIRUS_SPEED: CGFloat = 40.0
    private let VIRUS_AWAKE_RANGE: Float = 180.0
    private let BACTERIA: Int = 1
    private let VIRUS: Int = 2
    private let CELL: Int = 3
    private let PLASMID: Int = 4
    
    
    // MARK: -  Outlets
    var bacteria: SKSpriteNode?
    var viruses: [SKSpriteNode] = []
    var virusAweakning: [Bool] = []
    
    
    // MARK: - Variables
    var lastTouch: CGPoint? = nil
    var updateCount: Int = 0
    var touchTimer: Timer?
    var canHandleMove: Bool = true
    var didStartMovement: Bool = false
    
    /// Imune Variables
    var isBacteriaImune: Bool = false
    var imuneTimer: Timer?
    
    var level: Int { return 0 }
    var nextScene: SKScene? { return nil }
    var repeatCurrentScene: SKScene? { return nil }

    // MARK: - Lifecycle
    override public func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        configureOutlets()
    }
    
    
    // MARK: - Configuration
    private func configureOutlets() {
        
        /// Bacteria
        bacteria = childNode(withName: "bacteria") as? SKSpriteNode
        
        /// Viruses
        for sprite in self.children {
            if sprite.name == "virus" {
                if let sprite = sprite as? SKSpriteNode {
                    viruses.append(sprite)
                    virusAweakning.append(false)
                }
            }
        }
        
        /// Plasmids
        for sprite in self.children {
            if sprite.name == "plasmid" {
                spin(sprite)
            }
        }
        
        /// Cell
        for sprite in self.children {
            if sprite.name == "cell" {
                bounce(sprite)
            }
        }
    }
    
    
    // MARK: - Touches
    private func handleTouches(_ touches: Set<UITouch>) {
        
        didStartMovement = true
        
        lastTouch = touches.first?.location(in: self)
        
        if canHandleMove {
            
            canHandleMove = false
            
            touchTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { timer in
                self.canHandleMove = true
            }
            
            updateBacteria()
        }
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouches(touches)
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouches(touches)
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouches(touches)
    }
    
    
    // MARK: - Movements
    private func updateBacteria() {
        
        guard let bacteria = bacteria, let touch = lastTouch else { return }
        
        let currentPosition = bacteria.position
        
        if shouldMove(currentPosition: currentPosition, touchPosition: touch) {
            
            updatePosition(for: bacteria, to: touch, speed: BACTERIA_SPEED)
            
        } else {
            
            bacteria.physicsBody?.isResting = true
            
        }
    }
    
    private func stopBacteriaIfNeeded() {
        
        guard let bacteria = bacteria, let touch = lastTouch else { return }
        
        if !shouldMove(currentPosition: bacteria.position, touchPosition: touch) {
            
            bacteria.physicsBody?.isResting = true
        }
    }
    
    func updateViruses() {
        
        guard let bacteria = bacteria else { return }
        let targetPosition = bacteria.position
        
        
        
        for (index, virus) in viruses.enumerated() {
            
            if virusAweakning[index] {
                updatePosition(for: virus, to: targetPosition, speed: VIRUS_SPEED)
            }
                
            else {
                if viruShouldMove(virus) { virusAweakning[index] = true }
            }
        }
    }
    
    private func shouldMove(currentPosition: CGPoint, touchPosition: CGPoint) -> Bool {
        
        guard let bacteria = bacteria else { return false } /// In case bacteria does not exist yet
        
        let isOnHorizontalRange = abs(currentPosition.x - touchPosition.x) > bacteria.frame.width / 2
        let isOnVerticalRange = abs(currentPosition.y - touchPosition.y) > bacteria.frame.height / 2
        
        return isOnHorizontalRange || isOnVerticalRange
    }
    
    private func viruShouldMove(_ virus: SKNode) -> Bool {
        
        guard let bacteria = bacteria else { return false }
        
        return distance(from: virus, to: bacteria) <= VIRUS_AWAKE_RANGE
        
    }
    
    fileprivate func updatePosition(for sprite: SKSpriteNode, to target: CGPoint, speed: CGFloat) {
        
        /// Firtst the sprite is rotated
        let currentPosition = sprite.position
        let angle = CGFloat.pi + atan2(currentPosition.y - target.y, currentPosition.x - target.x)
        let rotateAction = SKAction.rotate(toAngle: angle + (CGFloat.pi*0.5), duration: 0)
        
        sprite.run(rotateAction, completion: {
            
            /// And when it finishes rotating, it starts moving
            let velocityX = speed * cos(angle)
            let velocityY = speed * sin(angle)
            
            let newVelocity = CGVector(dx: velocityX, dy: velocityY)
            sprite.removeAllActions() /// In case there was a previously programmed movement, it is canceled
            sprite.physicsBody?.velocity = newVelocity
        })
    }
    
    private func spin(_ node: SKNode) {
        guard let spriteNode = node as? SKSpriteNode else { return }
        let spin = SKAction.rotate(byAngle: CGFloat(3.14), duration: 4.0)
        spriteNode.run(SKAction.repeatForever(spin))
    }
    
    private func bounce(_ node: SKNode) {
        
        guard let spriteNode = node as? SKSpriteNode else { return }
        let bounce = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 10, duration: 0.45),
            SKAction.moveBy(x: 0, y: -10, duration: 0.45)
        ])
        spriteNode.run(SKAction.repeatForever(bounce))
    }
    
    private func floatDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
    }
    
    private func floatDistance(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt(floatDistanceSquared(from: from, to: to))
    }
    
    private func distance(from nodeA: SKNode, to nodeB: SKNode) -> Float {
        return Float(floatDistance(from: nodeA.position, to: nodeB.position))
    }
    
    // MARK: - Power-Up's
    func grantImunity() {
        
        guard let bacteria = bacteria else { return }
        
        if let imuneTimer = imuneTimer {
            imuneTimer.invalidate()
            self.imuneTimer = nil
            bacteria.removeAction(forKey: "imune")
            print("did cancel color change")
            bacteria.run(SKAction.setTexture(SKTexture(imageNamed: "Asset-Bacteria")))
        }
        
        isBacteriaImune = true
        print("Power-up did start")
        
        
        //  let colorChangeAction = SKAction.sequence([
        //      SKAction.setTexture(SKTexture(imageNamed: "Asset-Bacteria-PowerUp-Orange")),
        //      SKAction.wait(forDuration: 0.15),
        //      SKAction.setTexture(SKTexture(imageNamed: "Asset-Bacteria-PowerUp-Green")),
        //      SKAction.wait(forDuration: 0.15),
        //      SKAction.setTexture(SKTexture(imageNamed: "Asset-Bacteria")),
        //      SKAction.wait(forDuration: 0.15),
        //  ])
        
        // let imuneAction = SKAction.repeatForever(colorChangeAction)
        
        let imuneAction = SKAction.setTexture(SKTexture(imageNamed: "Asset-Bacteria-PowerUp"))
        
        imuneTimer = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: false) {
            timer in
            
            self.isBacteriaImune = false
            print("Power-up did end")
            
            bacteria.removeAction(forKey: "imune")
            bacteria.run(SKAction.setTexture(SKTexture(imageNamed: "Asset-Bacteria")))
        }
        
        bacteria.run(imuneAction, withKey: "imune")
        print("did start color change")
    }
    
    
    // MARK: - Physics
    override public func didSimulatePhysics() {
        if !viruses.isEmpty && didStartMovement {
            updateViruses()
            updateBacteria()
        }
    }
    
    
    // MARK: - Contact
    public func didBegin(_ contact: SKPhysicsContact) {
        
        let firstBody: SKPhysicsBody = contact.bodyA
        let secondBody: SKPhysicsBody = contact.bodyB
        
        handleContact(betwwen: firstBody, and: secondBody)
    }
    
    private func handleContact(betwwen bodyA: SKPhysicsBody, and bodyB: SKPhysicsBody) {
        
        let a = Int(bodyA.categoryBitMask)
        let b = Int(bodyB.categoryBitMask)
        
        /// In case the contact does not include the Bacteria
        if a != BACTERIA && b != BACTERIA { return }
        
        if contactBetween(a, b, is: [BACTERIA, VIRUS]) {
            
            print("Virus Touched Bacteria")
            if isBacteriaImune { return }
            endGame(didWin: false)
        }
        
        if contactBetween(a, b, is: [BACTERIA, PLASMID]) {
            
            print("Bacteria Touched Plasmid")
            if let node = bodyA.node { if node.name  == "plasmid" { node.removeFromParent() } }
            if let node = bodyB.node { if node.name  == "plasmid" { node.removeFromParent() } }
            
            grantImunity()
        }
        
        if contactBetween(a, b, is: [BACTERIA, CELL]) {
            
            print("Bacteria Touched Cell")
            endGame(didWin: true)
        }
    }
    
    private func contactBetween(_ a: Int, _ b: Int, is contactBodies: [Int]) -> Bool {
        
        var bodies = contactBodies
        if bodies.contains(a) { bodies.remove(at: bodies.firstIndex(of: a) ?? 0) }
        if bodies.contains(b) { bodies.remove(at: bodies.firstIndex(of: b) ?? 0) }
        
        return bodies.isEmpty
    }
    
    // MARK: - Navigation
    private func endGame(didWin: Bool) {
        
        if didWin {
            
            guard let nextScene = nextScene else { return }
            let transition = SKTransition.flipVertical(withDuration: 1.0)
            nextScene.scaleMode = .aspectFit
            view?.presentScene(nextScene, transition: transition)
        }
        
        else {
            
            guard let repeatCurrentScene = repeatCurrentScene else { return }
            let transition = SKTransition.flipVertical(withDuration: 1.0)
            repeatCurrentScene.scaleMode = .aspectFit
            view?.presentScene(repeatCurrentScene, transition: transition)
        }
    }
}


public class FirstLevel: Level {
    override var level: Int { return 1 }
    override var nextScene: SKScene? { return  LevelEnd(size: size, didWin: true, nextLevel: level + 1) }
    override var repeatCurrentScene: SKScene? { return  LevelEnd(size: size, didWin: false, nextLevel: level + 1) }
}

public class SecondLevel: Level {
    override var level: Int { return 2 }
    override var nextScene: SKScene? { return  LevelEnd(size: size, didWin: true, nextLevel: level + 1) }
    override var repeatCurrentScene: SKScene? { return  LevelEnd(size: size, didWin: false, nextLevel: level + 1) }
}

public class ThirdLevel: Level {
    override var level: Int { return 3 }
    override var nextScene: SKScene? { return  GameEnd(fileNamed: "Instruction-GameEnd")}
    override var repeatCurrentScene: SKScene? { return  LevelEnd(size: size, didWin: false, nextLevel: level + 1) }
}
