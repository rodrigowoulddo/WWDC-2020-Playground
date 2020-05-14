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
        
        /// Main message text
        let winLabel = SKLabelNode(text: didWin ? "You survived!" : "You got infected!")
        winLabel.fontName = "AvenirNext-Bold"
        winLabel.fontSize = 45
        winLabel.fontColor = .white
        winLabel.position = CGPoint(x: frame.midX, y: frame.midY*1.5)
        addChild(winLabel)
        
        /// Action text
        let label = SKLabelNode(text: didWin ? "Tap to play the next level" : "Tap to try again")
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 30
        label.fontColor = .white
        label.position = CGPoint(x: frame.midX, y: frame.midY*0.5)
        addChild(label)
        
        /// Big icon
        let pageIcon = SKSpriteNode(imageNamed: didWin ? "Asset-Cell" : "Asset-Virus")
        pageIcon.position = CGPoint(x: frame.midX, y: frame.midY)
        pageIcon.setScale(0.25)
        let bounceAction = SKAction.sequence([ SKAction.moveBy(x: 0, y: 10, duration: 0.2), SKAction.moveBy(x: 0, y: -10, duration: 0.2)])
        pageIcon.run(SKAction.repeatForever(bounceAction))
        addChild(pageIcon)
        
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
        case 2: nextScene = PlasmidInstruction(fileNamed: "Instruction-Plasmid")
        case 3: nextScene = ThirdLevel(fileNamed: "Level-3")
        default: nextScene = GameEnd(fileNamed: "Instruction-GameEnd")
        }

        guard let scene = nextScene else { fatalError("Scene for level \(level) not found") }
        let transition = SKTransition.flipVertical(withDuration: 1.0)
        scene.scaleMode = .aspectFit
        view?.presentScene(scene, transition: transition) 
    }
}
