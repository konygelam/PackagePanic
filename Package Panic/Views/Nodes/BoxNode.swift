import SpriteKit

final class BoxNode: SKNode {
    let boxModel: BoxModel
    private let boxShape: SKShapeNode
    private let topPanel: SKShapeNode
    private let stickerLabel: SKLabelNode?
    private var vipTimerLabel: SKLabelNode?
    private var glowNode: SKShapeNode?
    
    var onSwipe: ((ContainerSide) -> Void)?
    var onTap: (() -> Void)?
    
    init(model: BoxModel) {
        self.boxModel = model
        
        let cornerRadius: CGFloat = 6
        boxShape = SKShapeNode(rectOf: model.shape.size, cornerRadius: cornerRadius)
        boxShape.fillColor = model.color.uiColor
        boxShape.strokeColor = model.color.uiColor.darker()
        boxShape.lineWidth = 2
        
        topPanel = SKShapeNode(rectOf: CGSize(width: model.shape.size.width - 8, height: 6), cornerRadius: 2)
        topPanel.fillColor = model.color.uiColor.lighter()
        topPanel.strokeColor = .clear
        topPanel.position = CGPoint(x: 0, y: model.shape.size.height / 2 - 8)
        
        if model.sticker != .none {
            stickerLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
            stickerLabel?.text = model.sticker.displayText
            stickerLabel?.fontSize = 7
            stickerLabel?.fontColor = .white
            stickerLabel?.verticalAlignmentMode = .center
            stickerLabel?.horizontalAlignmentMode = .center
        } else {
            stickerLabel = nil
        }
        
        super.init()
        
        addShadow()
        addChild(boxShape)
        addChild(topPanel)
        addTapeStrip()
        
        if let label = stickerLabel {
            addStickerBackground()
            addChild(label)
        }
        
        setupAppearance()
        position = model.position
        isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addShadow() {
        let shadow = SKShapeNode(rectOf: boxModel.shape.size, cornerRadius: 6)
        shadow.fillColor = UIColor.black.withAlphaComponent(0.4)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 3, y: -4)
        shadow.zPosition = -2
        addChild(shadow)
    }
    
    private func addTapeStrip() {
        let tapeWidth = boxModel.shape.size.width - 12
        let tape = SKShapeNode(rectOf: CGSize(width: tapeWidth, height: 4))
        tape.fillColor = UIColor(red: 0.85, green: 0.7, blue: 0.45, alpha: 0.9)
        tape.strokeColor = UIColor(red: 0.6, green: 0.5, blue: 0.3, alpha: 1.0)
        tape.lineWidth = 0.5
        tape.position = CGPoint(x: 0, y: 0)
        tape.zPosition = 1
        addChild(tape)
    }
    
    private func addStickerBackground() {
        guard let label = stickerLabel else { return }
        let bg = SKShapeNode(rectOf: CGSize(width: boxModel.shape.size.width - 8, height: 14), cornerRadius: 2)
        bg.fillColor = UIColor.white.withAlphaComponent(0.95)
        bg.strokeColor = UIColor.black.withAlphaComponent(0.3)
        bg.lineWidth = 0.5
        bg.position = CGPoint(x: 0, y: -boxModel.shape.size.height / 2 + 12)
        bg.zPosition = 2
        addChild(bg)
        
        label.fontColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        label.position = CGPoint(x: 0, y: -boxModel.shape.size.height / 2 + 12)
        label.zPosition = 3
    }
    
    private func setupAppearance() {
        switch boxModel.type {
        case .dangerous:
            addDangerIndicator()
        case .vip:
            addVIPIndicator()
        case .qrRequired:
            addQRIndicator()
        case .decoy:
            addDecoyEffect()
        case .normal:
            break
        }
    }
    
    private func addDangerIndicator() {
        boxShape.strokeColor = UIColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0)
        boxShape.lineWidth = 3
        
        let warningIcon = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        warningIcon.text = "⚠"
        warningIcon.fontSize = 26
        warningIcon.fontColor = .yellow
        warningIcon.verticalAlignmentMode = .center
        warningIcon.position = CGPoint(x: 0, y: 0)
        warningIcon.zPosition = 4
        addChild(warningIcon)
        
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.15, duration: 0.4),
            SKAction.scale(to: 1.0, duration: 0.4)
        ])
        warningIcon.run(SKAction.repeatForever(pulse))
        
        let glowPulse = SKAction.sequence([
            SKAction.run { [weak self] in self?.boxShape.strokeColor = UIColor.red },
            SKAction.wait(forDuration: 0.3),
            SKAction.run { [weak self] in self?.boxShape.strokeColor = UIColor.yellow },
            SKAction.wait(forDuration: 0.3)
        ])
        run(SKAction.repeatForever(glowPulse))
    }
    
    private func addVIPIndicator() {
        glowNode = SKShapeNode(rectOf: CGSize(
            width: boxModel.shape.size.width + 12,
            height: boxModel.shape.size.height + 12
        ), cornerRadius: 10)
        glowNode?.fillColor = .clear
        glowNode?.strokeColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        glowNode?.lineWidth = 4
        glowNode?.zPosition = -1
        glowNode?.glowWidth = 4
        
        if let glow = glowNode {
            addChild(glow)
            
            let pulse = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.4, duration: 0.5),
                SKAction.fadeAlpha(to: 1.0, duration: 0.5)
            ])
            glow.run(SKAction.repeatForever(pulse))
        }
        
        let crown = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        crown.text = "★"
        crown.fontSize = 18
        crown.fontColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        crown.verticalAlignmentMode = .center
        crown.position = CGPoint(x: 0, y: 4)
        crown.zPosition = 4
        addChild(crown)
        
        vipTimerLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        vipTimerLabel?.fontSize = 11
        vipTimerLabel?.fontColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        vipTimerLabel?.position = CGPoint(x: 0, y: -boxModel.shape.size.height / 2 - 14)
        vipTimerLabel?.text = "VIP 5.0"
        vipTimerLabel?.zPosition = 4
        
        if let label = vipTimerLabel {
            addChild(label)
        }
    }
    
    private func addQRIndicator() {
        let qrSize: CGFloat = 22
        let qrIcon = SKShapeNode(rectOf: CGSize(width: qrSize, height: qrSize), cornerRadius: 2)
        qrIcon.fillColor = .white
        qrIcon.strokeColor = .black
        qrIcon.lineWidth = 1
        qrIcon.position = CGPoint(x: 0, y: 0)
        qrIcon.zPosition = 4
        
        for row in 0..<4 {
            for col in 0..<4 {
                if (row + col) % 2 == 0 || (row == 0 && col == 0) || (row == 3 && col == 3) {
                    let pixel = SKShapeNode(rectOf: CGSize(width: 3, height: 3))
                    pixel.fillColor = .black
                    pixel.strokeColor = .clear
                    let xPos = CGFloat(col) * 4 - 6
                    let yPos = CGFloat(row) * 4 - 6
                    pixel.position = CGPoint(x: xPos, y: yPos)
                    qrIcon.addChild(pixel)
                }
            }
        }
        
        addChild(qrIcon)
        
        let scanHint = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scanHint.text = "TAP TO SCAN"
        scanHint.fontSize = 7
        scanHint.fontColor = UIColor(red: 0.0, green: 1.0, blue: 0.4, alpha: 1.0)
        scanHint.verticalAlignmentMode = .center
        scanHint.position = CGPoint(x: 0, y: -boxModel.shape.size.height / 2 - 14)
        scanHint.zPosition = 4
        addChild(scanHint)
        
        let blink = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.5),
            SKAction.fadeAlpha(to: 1.0, duration: 0.5)
        ])
        scanHint.run(SKAction.repeatForever(blink))
    }
    
    private func addDecoyEffect() {
        boxShape.alpha = 0.6
        topPanel.alpha = 0.6
        
        let flicker = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.4, duration: 0.2),
            SKAction.fadeAlpha(to: 0.85, duration: 0.2)
        ])
        boxShape.run(SKAction.repeatForever(flicker))
        topPanel.run(SKAction.repeatForever(flicker))
        
        let questionMark = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        questionMark.text = "?"
        questionMark.fontSize = 28
        questionMark.fontColor = UIColor.white.withAlphaComponent(0.7)
        questionMark.verticalAlignmentMode = .center
        questionMark.position = CGPoint(x: 0, y: 0)
        questionMark.zPosition = 4
        addChild(questionMark)
    }
    
    func updateVIPTimer(_ time: TimeInterval) {
        vipTimerLabel?.text = String(format: "VIP %.1f", time)
        
        if time < 2.0 {
            vipTimerLabel?.fontColor = .red
        }
    }
    
    func animateSort(to side: ContainerSide, completion: @escaping () -> Void) {
        let targetX: CGFloat = side == .left ? -200 : (parent?.frame.width ?? 600) + 200
        let moveAction = SKAction.moveTo(x: targetX, duration: 0.35)
        moveAction.timingMode = .easeIn
        
        let rotateAction = SKAction.rotate(byAngle: side == .left ? -0.6 : 0.6, duration: 0.35)
        let fadeAction = SKAction.fadeOut(withDuration: 0.35)
        let scaleAction = SKAction.scale(to: 0.7, duration: 0.35)
        
        let group = SKAction.group([moveAction, rotateAction, fadeAction, scaleAction])
        
        run(group) {
            completion()
            self.removeFromParent()
        }
    }
    
    func animateMiss(completion: @escaping () -> Void) {
        let fadeAction = SKAction.fadeOut(withDuration: 0.25)
        let scaleAction = SKAction.scale(to: 0.4, duration: 0.25)
        let rotateAction = SKAction.rotate(byAngle: 0.5, duration: 0.25)
        
        run(SKAction.group([fadeAction, scaleAction, rotateAction])) {
            completion()
            self.removeFromParent()
        }
    }
    
    func showScanEffect() {
        let scanLine = SKShapeNode(rectOf: CGSize(width: boxModel.shape.size.width + 20, height: 3))
        scanLine.fillColor = UIColor(red: 0.0, green: 1.0, blue: 0.4, alpha: 1.0)
        scanLine.strokeColor = .clear
        scanLine.glowWidth = 3
        scanLine.position = CGPoint(x: 0, y: -boxModel.shape.size.height / 2 - 10)
        scanLine.zPosition = 5
        addChild(scanLine)
        
        let moveUp = SKAction.moveTo(y: boxModel.shape.size.height / 2 + 10, duration: 0.4)
        let remove = SKAction.removeFromParent()
        scanLine.run(SKAction.sequence([moveUp, remove]))
        
        let flash = SKAction.sequence([
            SKAction.run { [weak self] in
                self?.boxShape.fillColor = UIColor(red: 0.4, green: 1.0, blue: 0.4, alpha: 1.0)
            },
            SKAction.wait(forDuration: 0.15),
            SKAction.run { [weak self] in
                guard let self = self else { return }
                self.boxShape.fillColor = self.boxModel.color.uiColor
            }
        ])
        run(flash)
        
        let checkMark = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        checkMark.text = "✓"
        checkMark.fontSize = 24
        checkMark.fontColor = UIColor(red: 0.0, green: 1.0, blue: 0.4, alpha: 1.0)
        checkMark.position = CGPoint(x: 0, y: 0)
        checkMark.zPosition = 10
        checkMark.alpha = 0
        addChild(checkMark)
        
        let appear = SKAction.fadeIn(withDuration: 0.2)
        let stay = SKAction.wait(forDuration: 0.3)
        let disappear = SKAction.fadeOut(withDuration: 0.2)
        let removeCheck = SKAction.removeFromParent()
        checkMark.run(SKAction.sequence([appear, stay, disappear, removeCheck]))
    }
}

private extension UIColor {
    func lighter(by amount: CGFloat = 0.2) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            return UIColor(hue: h, saturation: s, brightness: min(b + amount, 1.0), alpha: a)
        }
        return self
    }
    
    func darker(by amount: CGFloat = 0.25) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            return UIColor(hue: h, saturation: s, brightness: max(b - amount, 0), alpha: a)
        }
        return self
    }
}
