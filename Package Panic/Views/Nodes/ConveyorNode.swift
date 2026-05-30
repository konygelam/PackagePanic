import SpriteKit

final class ConveyorNode: SKNode {
    private let conveyorWidth: CGFloat
    private let conveyorHeight: CGFloat
    private var beltLines: [SKShapeNode] = []
    private var animationDuration: TimeInterval = 0.5
    
    init(width: CGFloat, height: CGFloat) {
        self.conveyorWidth = width
        self.conveyorHeight = height
        
        super.init()
        
        setupConveyor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConveyor() {
        let outerShadow = SKShapeNode(rectOf: CGSize(width: conveyorWidth + 6, height: conveyorHeight + 6), cornerRadius: 4)
        outerShadow.fillColor = UIColor.black.withAlphaComponent(0.5)
        outerShadow.strokeColor = .clear
        outerShadow.position = CGPoint(x: 3, y: -3)
        outerShadow.zPosition = -3
        addChild(outerShadow)
        
        let frame = SKShapeNode(rectOf: CGSize(width: conveyorWidth + 4, height: conveyorHeight), cornerRadius: 2)
        frame.fillColor = UIColor(white: 0.18, alpha: 1.0)
        frame.strokeColor = UIColor.white.withAlphaComponent(0.2)
        frame.lineWidth = 1
        frame.zPosition = -2
        addChild(frame)
        
        let belt = SKShapeNode(rectOf: CGSize(width: conveyorWidth, height: conveyorHeight))
        belt.fillColor = UIColor(red: 0.13, green: 0.14, blue: 0.18, alpha: 1.0)
        belt.strokeColor = .clear
        belt.zPosition = -1
        addChild(belt)
        
        let railWidth: CGFloat = 12
        
        let leftRail = SKShapeNode(rectOf: CGSize(width: railWidth, height: conveyorHeight), cornerRadius: 2)
        leftRail.fillColor = UIColor(white: 0.28, alpha: 1.0)
        leftRail.strokeColor = UIColor.white.withAlphaComponent(0.15)
        leftRail.lineWidth = 0.5
        leftRail.position = CGPoint(x: -conveyorWidth / 2 + railWidth / 2 - 2, y: 0)
        leftRail.zPosition = 1
        addChild(leftRail)
        
        let rightRail = SKShapeNode(rectOf: CGSize(width: railWidth, height: conveyorHeight), cornerRadius: 2)
        rightRail.fillColor = UIColor(white: 0.28, alpha: 1.0)
        rightRail.strokeColor = UIColor.white.withAlphaComponent(0.15)
        rightRail.lineWidth = 0.5
        rightRail.position = CGPoint(x: conveyorWidth / 2 - railWidth / 2 + 2, y: 0)
        rightRail.zPosition = 1
        addChild(rightRail)
        
        addRailBolts(railX: -conveyorWidth / 2 + railWidth / 2 - 2)
        addRailBolts(railX: conveyorWidth / 2 - railWidth / 2 + 2)
        
        let lineSpacing: CGFloat = 32
        let lineCount = Int(conveyorHeight / lineSpacing) + 2
        let beltInnerWidth = conveyorWidth - railWidth * 2 - 8
        
        for i in 0..<lineCount {
            let chevron = SKNode()
            chevron.position = CGPoint(x: 0, y: conveyorHeight / 2 - CGFloat(i) * lineSpacing)
            chevron.zPosition = 0
            
            let line = SKShapeNode(rectOf: CGSize(width: beltInnerWidth, height: 2))
            line.fillColor = UIColor(white: 0.35, alpha: 0.6)
            line.strokeColor = .clear
            chevron.addChild(line)
            
            let arrowLeft = SKLabelNode(fontNamed: "AvenirNext-Bold")
            arrowLeft.text = "▼"
            arrowLeft.fontSize = 8
            arrowLeft.fontColor = UIColor(white: 0.3, alpha: 0.5)
            arrowLeft.position = CGPoint(x: -beltInnerWidth / 4, y: -3)
            arrowLeft.verticalAlignmentMode = .center
            chevron.addChild(arrowLeft)
            
            let arrowRight = SKLabelNode(fontNamed: "AvenirNext-Bold")
            arrowRight.text = "▼"
            arrowRight.fontSize = 8
            arrowRight.fontColor = UIColor(white: 0.3, alpha: 0.5)
            arrowRight.position = CGPoint(x: beltInnerWidth / 4, y: -3)
            arrowRight.verticalAlignmentMode = .center
            chevron.addChild(arrowRight)
            
            beltLines.append(line)
            addChild(chevron)
            
            animateBeltSegment(chevron, lineSpacing: lineSpacing, totalLines: lineCount)
        }
    }
    
    private func addRailBolts(railX: CGFloat) {
        let boltSpacing: CGFloat = 60
        let boltCount = Int(conveyorHeight / boltSpacing)
        
        for i in 0..<boltCount {
            let bolt = SKShapeNode(circleOfRadius: 2.5)
            bolt.fillColor = UIColor(white: 0.5, alpha: 1.0)
            bolt.strokeColor = UIColor(white: 0.15, alpha: 1.0)
            bolt.lineWidth = 0.5
            let yPos = conveyorHeight / 2 - CGFloat(i) * boltSpacing - 30
            bolt.position = CGPoint(x: railX, y: yPos)
            bolt.zPosition = 2
            addChild(bolt)
        }
    }
    
    private func animateBeltSegment(_ node: SKNode, lineSpacing: CGFloat, totalLines: Int) {
        let totalDistance = CGFloat(totalLines) * lineSpacing
        let moveDown = SKAction.moveBy(x: 0, y: -lineSpacing, duration: animationDuration)
        let resetPosition = SKAction.run { [weak node, weak self] in
            guard let node = node, let self = self else { return }
            if node.position.y < -self.conveyorHeight / 2 - 10 {
                node.position.y += totalDistance
            }
        }
        let sequence = SKAction.sequence([moveDown, resetPosition])
        node.run(SKAction.repeatForever(sequence))
    }
    
    func setSpeed(_ multiplier: CGFloat) {
        let newDuration = TimeInterval(0.5 / max(multiplier, 0.5))
        if abs(newDuration - animationDuration) > 0.05 {
            animationDuration = newDuration
        }
    }
}
