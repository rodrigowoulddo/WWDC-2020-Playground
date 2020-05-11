import Foundation
import SpriteKit


public class FirstLevel: Level {
    override var level: Int { return 1 }
    override var nextScene: SKScene? { return  PlasmidInstruction(fileNamed: "Instruction-Plasmid") }
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
