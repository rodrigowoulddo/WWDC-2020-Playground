import Foundation
import SpriteKit

public class Level1: SKScene, SKPhysicsContactDelegate {
    
    
    // MARK: - Constants
    let bacteriaSpeed: CGFloat = 155.0
    
    
    // MARK: -  Outlets
    var bacteria: SKSpriteNode?
    
    
    // MARK: - Variables
    var lastTouch: CGPoint? = nil
    var updateCount: Int = 0
    
    
    // MARK: - Lifecycle
    override public func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        configureOutlets()
        
    }
    
    // MARK: - Configuration
    private func configureOutlets() {
        bacteria = childNode(withName: "bacteria") as? SKSpriteNode
    }
    
    @objc public static override var supportsSecureCoding: Bool {
        get { return true }
    }
    
    
    override public func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    // MARK: - Touches
    private func handleTouches(_ touches: Set<UITouch>) {
        lastTouch = touches.first?.location(in: self)
        updateBacteria()
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
        
        updateCount += 1
        print("Update count: \(updateCount)") /// To watch performance
        
        guard let bacteria = bacteria, let touch = lastTouch else { return }
                
        let currentPosition = bacteria.position
        
        if shouldMove(currentPosition: currentPosition, touchPosition: touch) {
            
            updatePosition(for: bacteria, to: touch, speed: bacteriaSpeed)
            
        } else {
            bacteria.physicsBody?.isResting = true
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
    
    
    // MARK: - SKPhysicsContactDelegate
    
}
