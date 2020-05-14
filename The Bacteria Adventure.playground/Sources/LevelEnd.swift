import Foundation
import SpriteKit

public class LevelEnd: SKScene {
    
    var didWin: Bool
    var levelToSend: Int
    
    // MARK: - Init
    required init?(coder aDecoder: NSCoder) { fatalError("LevelEnd init not implemented") }
    
    init(size: CGSize, didWin: Bool, nextLevel: Int) {
        self.didWin = didWin
        self.levelToSend = didWin ? nextLevel : nextLevel - 1
        super.init(size: size)
        scaleMode = .aspectFill
    }
    
    
    // MARK: - LifeCycle
    override public func didMove(to view: SKView) {
        buildView()
    }

    
    // MARK: - Configuration
    private func buildView() {
        
        /// Background
        let background = SKSpriteNode(texture: SKTexture(imageNamed: "Asset-Background"))
        background.size = CGSize(width: 2630, height: 1595)
        background.position = CGPoint(x: -620, y: -655)
        background.anchorPoint = CGPoint(x: 0, y: 0)
        addChild(background)
        bounceHorizontally(background, distance: 1000, duration: 15)


        
        /// Main message text
        let winLabel = SKLabelNode(text: didWin ? "You survived!" : "You got infected!")
        winLabel.fontName = "AvenirNext-Bold"
        winLabel.fontSize = 68
        winLabel.fontColor = .white
        winLabel.position = CGPoint(x: frame.midX, y: frame.midY + 275)
        addChild(winLabel)
        
        /// Action tap button
        let tapButton = SKSpriteNode(texture: SKTexture(imageNamed: didWin ? "Asset-Tap-next-level" : "Asset-Tap-try-again"))
        tapButton.size = CGSize(width: didWin ? 460 : 283, height: 90)
        tapButton.position = CGPoint(x: frame.midX, y: frame.midY - 310)
        addChild(tapButton)
        
        /// Big icon
        let pageIcon = SKSpriteNode(imageNamed: didWin ? "Asset-Cell" : "Asset-Virus")
        pageIcon.position = CGPoint(x: frame.midX, y: frame.midY)
        pageIcon.setScale(0.25)
        let bounceAction = SKAction.sequence([ SKAction.moveBy(x: 0, y: 10, duration: 0.2), SKAction.moveBy(x: 0, y: -10, duration: 0.2)])
        pageIcon.run(SKAction.repeatForever(bounceAction))
        addChild(pageIcon)
        
    }
    
    func bounceHorizontally(_ node: SKNode, distance: CGFloat = 15, duration: Double = 0.30 ) {
        
        guard let spriteNode = node as? SKSpriteNode else { return }
        let bounce = SKAction.sequence([
            SKAction.moveBy(x: -1 * distance, y: 0, duration: duration),
            SKAction.moveBy(x: distance, y: 0, duration: duration)
        ])
        spriteNode.run(SKAction.repeatForever(bounce))
    }
    
    
    // MARK: - Touches
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        sendToLevel(levelToSend)
    }
    
    // MARK: - Navigation
    private func sendToLevel(_ level: Int) {
            
        var nextScene: SKScene?
        
        switch level {
        case 1: nextScene = FirstLevel(fileNamed: "Level-1")
        case 2: nextScene = didWin ? PlasmidInstruction(fileNamed: "Instruction-Plasmid") : SecondLevel(fileNamed: "Level-2")
        case 3: nextScene = ThirdLevel(fileNamed: "Level-3")
        default: nextScene = GameEnd(fileNamed: "Instruction-GameEnd")
        }

        guard let scene = nextScene else { fatalError("Scene for level \(level) not found") }
        let transition = SKTransition.flipVertical(withDuration: 1.0)
        scene.scaleMode = .aspectFit
        view?.presentScene(scene, transition: transition) 
    }
}
