import Foundation
import SpriteKit

public class Level: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Private Constants
    private let BACTERIA_SPEED: CGFloat = 155.0
    private let VIRUS_SPEED: CGFloat = 40.0
    private let BACTERIA: Int = 1
    private let VIRUS: Int = 2
    private let CELL: Int = 3
    private let PLASMID: Int = 4

    
    // MARK: -  Outlets
    var bacteria: SKSpriteNode?
    var viruses: [SKSpriteNode] = []
    
    
    // MARK: - Variables
    var lastTouch: CGPoint? = nil
    var updateCount: Int = 0
    var touchTimer: Timer?
    var canHandleMove: Bool = true
    var didStartMovement: Bool = false
    var level: Int { return 0 }
    
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
                }
            }
        }
    }
    
    override public func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
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
        
        /// To watch performance
        // updateCount += 1
        // print("Update count: \(updateCount)")
        
        guard let bacteria = bacteria, let touch = lastTouch else { return }
                
        let currentPosition = bacteria.position
        
        if shouldMove(currentPosition: currentPosition, touchPosition: touch) {
            
            updatePosition(for: bacteria, to: touch, speed: BACTERIA_SPEED)
            
        } else {
            
            bacteria.physicsBody?.isResting = true
            
        }
    }
    
    func updateViruses() {
        guard let bacteria = bacteria else { return }
        let targetPosition = bacteria.position
        
        for virus in viruses {
            updatePosition(for: virus, to: targetPosition, speed: VIRUS_SPEED)
        }
    }
    
    private func shouldMove(currentPosition: CGPoint, touchPosition: CGPoint) -> Bool {
                
        guard let bacteria = bacteria else { return false } /// In case bacteria does not exist yet
        
        let isOnHorizontalRange = abs(currentPosition.x - touchPosition.x) > bacteria.frame.width / 2
        let isOnVerticalRange = abs(currentPosition.y - touchPosition.y) > bacteria.frame.height / 2
        
        return isOnHorizontalRange || isOnVerticalRange
    }
    
    fileprivate func updatePosition(for sprite: SKSpriteNode, to target: CGPoint, speed: CGFloat) {
        
        /// Firtst the sprite is rotated
        let currentPosition = sprite.position
        let angle = CGFloat.pi + atan2(currentPosition.y - target.y, currentPosition.x - target.x)
        let rotateAction = SKAction.rotate(toAngle: angle + (CGFloat.pi*0.5), duration: 0)
        
        sprite.run(rotateAction, completion: {
            
            /// And when it finishes rotating, it starts moving
            let movement = SKAction.move(to: target, duration: self.getDuration(from: sprite.position, to: target, speed: speed))
            sprite.removeAllActions() /// In case there was a previously programmed movement, it is canceled
            sprite.run(movement)
        })
    }
    
    func getDuration(from pointA: CGPoint, to pointB: CGPoint, speed:CGFloat = 100)-> TimeInterval {
        let xDist = (pointB.x - pointA.x)
        let yDist = (pointB.y - pointA.y)
        let distance = sqrt((xDist * xDist) + (yDist * yDist));
        let duration : TimeInterval = TimeInterval(distance/speed)
        return duration
    }
    
    
    // MARK: - Physics
    override public func didSimulatePhysics() {
        if !viruses.isEmpty && didStartMovement {
            updateViruses()
        }
    }
    
    
    // MARK: - Contact
    public func didBegin(_ contact: SKPhysicsContact) {
        
        let firstBody: SKPhysicsBody = contact.bodyA
        let secondBody: SKPhysicsBody = contact.bodyB
        
        handleContact(betwwen: firstBody.categoryBitMask, and: secondBody.categoryBitMask)
        
    }
    
    private func handleContact(betwwen bodyA: UInt32, and bodyB: UInt32) {
        
        /// In case the contact does not include the Bacteria
        if bodyA != BACTERIA && bodyB != BACTERIA { return }
        
        let a = Int(bodyA)
        let b = Int(bodyB)
        
        if contactBetween(a, b, is: [BACTERIA, VIRUS]) {
            print("Virus Touched Bacteria")
            endGame(didWin: false)
        }
        
        if contactBetween(a, b, is: [BACTERIA, PLASMID]) {
            print("Virus Touched Plasmid")
        }
        
        if contactBetween(a, b, is: [BACTERIA, CELL]) {
            print("Virus Touched Cell")
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
        let resultScene = LevelEnd(size: size, didWin: didWin, nextLevel: level + 1)
        let transition = SKTransition.flipVertical(withDuration: 1.0)
        view?.presentScene(resultScene, transition: transition)
    }

    
    
}
