import Foundation
import SpriteKit

public class Instruction: SKScene {
    
    // MARK: - Variables
    var nextScene: SKScene? { nil }
    
    // MARK: - LifeCycle
    override public func didMove(to view: SKView) {
        buildView()
    }
    
    // MARK: - Configuration
    func buildView() { }
    
    // MARK: - Movement
    func bounceVertically(_ node: SKNode) {
        
        guard let spriteNode = node as? SKSpriteNode else { return }
        let bounce = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 18, duration: 0.45),
            SKAction.moveBy(x: 0, y: -18, duration: 0.45)
        ])
        spriteNode.run(SKAction.repeatForever(bounce))
    }
    
    enum HorizontalBounceOption {
        case left
        case right
    }
    func bounceHorizontally(_ node: SKNode, option: HorizontalBounceOption = .left ) {
        
        guard let spriteNode = node as? SKSpriteNode else { return }
        let bounce = SKAction.sequence([
            SKAction.moveBy(x: option == .left ? -15 : 15, y: 0, duration: 0.30),
            SKAction.moveBy(x: option == .left ? 15 : -15, y: 0, duration: 0.30)
        ])
        spriteNode.run(SKAction.repeatForever(bounce))
    }
    
    func fall(_ node: SKNode) {
        
        let fallAction = SKAction.sequence([
            SKAction.moveBy(x: 0, y: -700, duration: 10),
            SKAction.moveBy(x: 0, y: 700, duration: 0)
        ])
        
        let fadeAction = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 0, duration: 8),
            SKAction.fadeAlpha(to: 0, duration: 2),
            SKAction.moveBy(x: 0, y: 0, duration: 0.2),
            SKAction.fadeAlpha(to: 1, duration: 0)
        ])
        
        node.run(SKAction.repeatForever(fallAction))
        node.run(SKAction.repeatForever(fadeAction))
    }
    
    func bottomToTop(_ node: SKNode) {
        
        let movementAction = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 1000, duration: 15),
            SKAction.moveBy(x: 0, y: -1000, duration: 0),
        ])
        node.run(SKAction.repeatForever(movementAction))
    }
    
    func moveUp(_ node: SKNode, by distance: Float) {
        
        let distance = CGFloat(distance)
        
        let movementAction = SKAction.sequence([
            SKAction.moveBy(x: 0, y: distance, duration: 5),
            SKAction.moveBy(x: 0, y: distance * -1, duration: 0),
        ])
        node.run(SKAction.repeatForever(movementAction))
    }
    
    func spin(_ node: SKNode) {
        
        let spin = SKAction.rotate(byAngle: CGFloat(3.14), duration: 4.0)
        node.run(SKAction.repeatForever(spin))
    }
    
    // MARK: - Touches
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let nextScene = nextScene else {return}
        sendTo(nextScene)
    }
    
    // MARK: - Navigation
    private func sendTo(_ scene: SKScene) {
        
        let transition = SKTransition.flipVertical(withDuration: 1.0)
        scene.scaleMode = .aspectFit
        view?.presentScene(scene, transition: transition)
    }
}

public class BacteriumInstruction: Instruction {
    
    // MARK: - Variables
    override var nextScene: SKScene? { return BacteriophaguesInstruction(fileNamed: "Instruction-Bacteriophagues") }
    
    // MARK: - Configuration
    override func buildView() {
        
        guard let bacteria = childNode(withName: "bacteria") as? SKSpriteNode else { return }
        
        bounceVertically(bacteria)
    }
}

public class BacteriophaguesInstruction: Instruction {
    
    // MARK: - Variables
    override var nextScene: SKScene? { CellInstruction(fileNamed: "Instruction-Cell") }
    
    // MARK: - Configuration
    override func buildView() {
        
        guard let bacteria = childNode(withName: "bacteria") as? SKSpriteNode else { return }
        
        var viruses: [SKSpriteNode] = []
        for child in self.children {
            if child.name == "virus" {
                if let virus = child as? SKSpriteNode {
                    viruses.append(virus)
                }
            }
        }
        
        bottomToTop(bacteria)
        bounceHorizontally(bacteria, option: .left)
        
        for virus in viruses {
            
            bottomToTop(virus)
            bounceHorizontally(virus, option: .right)
        }
    }
}

public class CellInstruction: Instruction {
    
    // MARK: - Variables
    override var nextScene: SKScene? { FirstLevel(fileNamed: "Level-1") }
    
    // MARK: - Configuration
    override func buildView() {
        
        guard let bacteria = childNode(withName: "bacteria") as? SKSpriteNode else { return }
        
        moveUp(bacteria, by: 300)
        bounceHorizontally(bacteria)
    }
    
}

public class PlasmidInstruction: Instruction {
    
    // MARK: - Variables
    override var nextScene: SKScene? { SecondLevel(fileNamed: "Level-2") }
    
    // MARK: - Configuration
    override func buildView() {
        
        guard let plasmid = childNode(withName: "plasmid") as? SKSpriteNode else { return }
        spin(plasmid)
    }
    
}


public class GameEnd: Instruction {
    
    // MARK: - Variables
    override var nextScene: SKScene? { nil } // Change to About me

    // MARK: - Configuration
    override func buildView() {
        
        guard let bacteria = childNode(withName: "bacteria") as? SKSpriteNode else { return }
        guard let confetti = childNode(withName: "confetti") as? SKSpriteNode else { return }
        
        bounceVertically(bacteria)
        fall(confetti)
    }
    
}
