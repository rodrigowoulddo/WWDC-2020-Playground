import Foundation
import SpriteKit
import PlaygroundSupport
import AVFoundation

public class Game {
    
    public static func play() {
        
        let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 600, height: 450))
        
        guard let scene = CoverInstruction(fileNamed: "Instruction-Cover") else { return }
        playMusic(on: scene)

        scene.scaleMode = .aspectFit
        sceneView.presentScene(scene)
        PlaygroundSupport.PlaygroundPage.current.liveView = sceneView
    }
    
    private static func playMusic(on scene: SKScene) {
        
        let musicAction = SKAction.playSoundFileNamed("Music.mp3", waitForCompletion: true)
        scene.run(SKAction.repeatForever(musicAction))
    }
    
}
