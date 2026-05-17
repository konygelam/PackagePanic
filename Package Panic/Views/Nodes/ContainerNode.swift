import SpriteKit

final class ContainerNode: SKNode {
    private let containerModel: ContainerModel
    private let containerBody: SKShapeNode
    private let containerInside: SKShapeNode
    private let fillIndicator: SKShapeNode
    private let labelNode: SKLabelNode
    private let colorsPreview: SKNode
    private let openingNode: SKShapeNode
    
    init(model: ContainerModel) {
        self.containerModel = model
        
        containerBody = SKShapeNode(rectOf: model.size, cornerRadius: 8)
        containerBody.fillColor = UIColor(white: 0.18, alpha: 1.0)
        containerBody.strokeColor = UIColor.white.withAlphaComponent(0.6)
        containerBody.lineWidth = 3
        
        containerInside = SKShapeNode(rectOf: CGSize(
            width: model.size.width - 12,
            height: model.size.height - 12
        ), cornerRadius: 4)
        containerInside.fillColor = UIColor(white: 0.08, alpha: 1.0)
        containerInside.strokeColor = .clear
        containerInside.position = CGPoint(x: 0, y: -2)
        
        openingNode = SKShapeNode(rectOf: CGSize(width: model.size.width - 20, height: 14), cornerRadius: 4)
        openingNode.fillColor = UIColor(white: 0.04, alpha: 1.0)
        openingNode.strokeColor = UIColor.white.withAlphaComponent(0.3)
        openingNode.lineWidth = 1
        openingNode.position = CGPoint(x: 0, y: model.size.height / 2 - 4)
        
        fillIndicator = SKShapeNode(rectOf: CGSize(width: model.size.width - 16, height: 0))
        fillIndicator.fillColor = UIColor(red: 0.3, green: 0.7, blue: 0.3, alpha: 0.7)
        fillIndicator.strokeColor = .clear
        fillIndicator.position = CGPoint(x: 0, y: -model.size.height / 2 + 6)
        
        labelNode = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        labelNode.fontSize = 14
        labelNode.fontColor = .white
        labelNode.text = model.side == .left ? "WARM" : "COOL"
        labelNode.verticalAlignmentMode = .center
        labelNode.position = CGPoint(x: 0, y: model.size.height / 2 + 18)
        
        colorsPreview = SKNode()
        
        super.init()
        
        addContainerShadow()
        addChild(containerBody)
        addChild(containerInside)
        addChild(fillIndicator)
        addChild(openingNode)
        addChild(labelNode)
        addChild(colorsPreview)
        
        addLabelBackground()
        addContainerLid()
        setupColorPreview()
        position = model.position
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addContainerShadow() {
        let shadow = SKShapeNode(rectOf: containerModel.size, cornerRadius: 8)
        shadow.fillColor = UIColor.black.withAlphaComponent(0.5)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 4, y: -4)
        shadow.zPosition = -2
        addChild(shadow)
    }
    
    private func addLabelBackground() {
        let bg = SKShapeNode(rectOf: CGSize(width: 70, height: 22), cornerRadius: 4)
        bg.fillColor = containerModel.side == .left ?
            UIColor(red: 0.95, green: 0.4, blue: 0.3, alpha: 1.0) :
            UIColor(red: 0.3, green: 0.55, blue: 0.95, alpha: 1.0)
        bg.strokeColor = UIColor.white.withAlphaComponent(0.4)
        bg.lineWidth = 1
        bg.position = CGPoint(x: 0, y: containerModel.size.height / 2 + 18)
        bg.zPosition = -1
        addChild(bg)
    }
    
    private func addContainerLid() {
        let lid = SKShapeNode(rectOf: CGSize(width: containerModel.size.width + 4, height: 8), cornerRadius: 3)
        lid.fillColor = UIColor(white: 0.25, alpha: 1.0)
        lid.strokeColor = UIColor.white.withAlphaComponent(0.4)
        lid.lineWidth = 1
        lid.position = CGPoint(x: 0, y: containerModel.size.height / 2 + 4)
        lid.zPosition = 1
        addChild(lid)
        
        let leftBolt = SKShapeNode(circleOfRadius: 2)
        leftBolt.fillColor = UIColor(white: 0.6, alpha: 1.0)
        leftBolt.strokeColor = .clear
        leftBolt.position = CGPoint(x: -containerModel.size.width / 2 + 4, y: containerModel.size.height / 2 + 4)
        leftBolt.zPosition = 2
        addChild(leftBolt)
        
        let rightBolt = SKShapeNode(circleOfRadius: 2)
        rightBolt.fillColor = UIColor(white: 0.6, alpha: 1.0)
        rightBolt.strokeColor = .clear
        rightBolt.position = CGPoint(x: containerModel.size.width / 2 - 4, y: containerModel.size.height / 2 + 4)
        rightBolt.zPosition = 2
        addChild(rightBolt)
    }
    
    private func setupColorPreview() {
        let colors = containerModel.acceptedColors
        let spacing: CGFloat = 22
        let startX = -CGFloat(colors.count - 1) * spacing / 2
        
        for (index, color) in colors.enumerated() {
            let dotBg = SKShapeNode(circleOfRadius: 9)
            dotBg.fillColor = UIColor(white: 0.1, alpha: 1.0)
            dotBg.strokeColor = .clear
            dotBg.position = CGPoint(x: startX + CGFloat(index) * spacing, y: -containerModel.size.height / 2 - 22)
            colorsPreview.addChild(dotBg)
            
            let dot = SKShapeNode(circleOfRadius: 7)
            dot.fillColor = color.uiColor
            dot.strokeColor = UIColor.white.withAlphaComponent(0.8)
            dot.lineWidth = 1.5
            dot.position = CGPoint(x: startX + CGFloat(index) * spacing, y: -containerModel.size.height / 2 - 22)
            colorsPreview.addChild(dot)
        }
    }
    
    func updateFillLevel(_ percentage: CGFloat) {
        let newHeight = (containerModel.size.height - 16) * percentage
        
        let resizeAction = SKAction.customAction(withDuration: 0.2) { [weak self] node, elapsedTime in
            guard let self = self else { return }
            let progress = elapsedTime / 0.2
            let currentHeight = newHeight * progress
            
            let newShape = SKShapeNode(rectOf: CGSize(
                width: self.containerModel.size.width - 16,
                height: max(currentHeight, 1)
            ))
            newShape.fillColor = self.fillIndicator.fillColor
            newShape.strokeColor = .clear
            
            self.fillIndicator.path = newShape.path
            self.fillIndicator.position = CGPoint(
                x: 0,
                y: -self.containerModel.size.height / 2 + 6 + currentHeight / 2
            )
        }
        
        fillIndicator.run(resizeAction)
        
        if percentage >= 0.8 {
            fillIndicator.fillColor = UIColor(red: 0.95, green: 0.35, blue: 0.35, alpha: 0.7)
        } else if percentage >= 0.5 {
            fillIndicator.fillColor = UIColor(red: 0.95, green: 0.75, blue: 0.35, alpha: 0.7)
        } else {
            fillIndicator.fillColor = UIColor(red: 0.35, green: 0.75, blue: 0.35, alpha: 0.7)
        }
    }
    
    func animateReceive() {
        let scaleUp = SKAction.scale(to: 1.08, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        run(SKAction.sequence([scaleUp, scaleDown]))
        
        flashColor(.green)
        
        showFloatingText("+1", color: UIColor(red: 0.3, green: 1.0, blue: 0.4, alpha: 1.0))
    }
    
    func animateReject() {
        let shake = SKAction.sequence([
            SKAction.moveBy(x: -6, y: 0, duration: 0.05),
            SKAction.moveBy(x: 12, y: 0, duration: 0.05),
            SKAction.moveBy(x: -12, y: 0, duration: 0.05),
            SKAction.moveBy(x: 6, y: 0, duration: 0.05)
        ])
        run(shake)
        
        flashColor(.red)
        showFloatingText("✗", color: UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0))
    }
    
    private func flashColor(_ color: UIColor) {
        let originalColor = containerBody.strokeColor
        let flash = SKAction.sequence([
            SKAction.run { [weak self] in
                self?.containerBody.strokeColor = color
                self?.containerBody.lineWidth = 5
            },
            SKAction.wait(forDuration: 0.15),
            SKAction.run { [weak self] in
                self?.containerBody.strokeColor = originalColor
                self?.containerBody.lineWidth = 3
            }
        ])
        containerBody.run(flash)
    }
    
    private func showFloatingText(_ text: String, color: UIColor) {
        let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        label.text = text
        label.fontSize = 20
        label.fontColor = color
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: containerModel.size.height / 2 + 40)
        label.zPosition = 50
        addChild(label)
        
        let moveUp = SKAction.moveBy(x: 0, y: 30, duration: 0.6)
        let fadeOut = SKAction.fadeOut(withDuration: 0.6)
        let group = SKAction.group([moveUp, fadeOut])
        let remove = SKAction.removeFromParent()
        label.run(SKAction.sequence([group, remove]))
    }
}
