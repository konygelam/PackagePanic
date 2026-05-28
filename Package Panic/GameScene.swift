import SpriteKit
import GameplayKit

protocol GameSceneDelegate: AnyObject {
    func gameSceneDidRequestPause()
    func gameSceneDidEnd(statistics: GameStatistics, levelId: Int, completed: Bool)
}

final class GameScene: SKScene {
    weak var gameDelegate: GameSceneDelegate?
    var selectedLevel: LevelModel?
    
    private var viewModel: GameViewModel!
    private var conveyorNode: ConveyorNode!
    private var leftContainerNode: ContainerNode!
    private var rightContainerNode: ContainerNode!
    private var hudNode: HUDNode!
    private var boxNodes: [UUID: BoxNode] = [:]
    private var blackoutOverlay: SKShapeNode?
    
    private var lastUpdateTime: TimeInterval = 0
    private var leftButton: SKShapeNode!
    private var rightButton: SKShapeNode!
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    override func didMove(to view: SKView) {
        setupScene()
        setupViewModel()
        if let level = selectedLevel {
            viewModel.startGame(with: level)
        } else {
            viewModel.startGame()
        }
    }
    
    private func setupScene() {
        backgroundColor = UIColor(red: 0.06, green: 0.07, blue: 0.12, alpha: 1.0)
        
        addBackgroundGradient()
        addFloorPattern()
        
        let buttonAreaHeight: CGFloat = 120
        let containerAreaHeight: CGFloat = 180
        let hudHeight: CGFloat = 80
        let conveyorHeight = size.height - hudHeight - containerAreaHeight - buttonAreaHeight - 40
        let conveyorWidth = size.width - 80
        
        conveyorNode = ConveyorNode(width: conveyorWidth, height: conveyorHeight)
        let conveyorY = buttonAreaHeight + containerAreaHeight + conveyorHeight / 2
        conveyorNode.position = CGPoint(x: size.width / 2, y: conveyorY)
        conveyorNode.zPosition = 1
        addChild(conveyorNode)
        
        addConveyorEnd()
        
        let containerY = buttonAreaHeight + containerAreaHeight / 2 - 10
        let leftContainerModel = ContainerModel(
            side: .left,
            acceptedColors: [.red, .orange, .yellow],
            position: CGPoint(x: 80, y: containerY),
            size: CGSize(width: 110, height: 140)
        )
        leftContainerNode = ContainerNode(model: leftContainerModel)
        leftContainerNode.zPosition = 5
        addChild(leftContainerNode)
        
        let rightContainerModel = ContainerModel(
            side: .right,
            acceptedColors: [.blue, .green, .purple],
            position: CGPoint(x: size.width - 80, y: containerY),
            size: CGSize(width: 110, height: 140)
        )
        rightContainerNode = ContainerNode(model: rightContainerModel)
        rightContainerNode.zPosition = 5
        addChild(rightContainerNode)
        
        hudNode = HUDNode(width: size.width)
        hudNode.position = CGPoint(x: size.width / 2, y: size.height - 50)
        hudNode.zPosition = 100
        addChild(hudNode)
        
        setupButtons(buttonAreaHeight: buttonAreaHeight)
    }
    
    private func addBackgroundGradient() {
        let gradient = SKShapeNode(rectOf: size)
        gradient.position = CGPoint(x: size.width / 2, y: size.height / 2)
        gradient.fillColor = UIColor(red: 0.08, green: 0.09, blue: 0.16, alpha: 1.0)
        gradient.strokeColor = .clear
        gradient.zPosition = -10
        addChild(gradient)
        
        for i in 0..<8 {
            let dot = SKShapeNode(circleOfRadius: 2)
            dot.fillColor = UIColor.white.withAlphaComponent(0.05)
            dot.strokeColor = .clear
            dot.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 200...size.height - 100)
            )
            dot.zPosition = -9
            addChild(dot)
            
            let twinkle = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.2, duration: Double.random(in: 1.5...3.0)),
                SKAction.fadeAlpha(to: 0.05, duration: Double.random(in: 1.5...3.0))
            ])
            dot.run(SKAction.repeatForever(twinkle))
            
            _ = i
        }
    }
    
    private func addFloorPattern() {
        let floorY: CGFloat = 200
        let floor = SKShapeNode(rectOf: CGSize(width: size.width, height: floorY))
        floor.position = CGPoint(x: size.width / 2, y: floorY / 2)
        floor.fillColor = UIColor(red: 0.12, green: 0.13, blue: 0.18, alpha: 1.0)
        floor.strokeColor = .clear
        floor.zPosition = -5
        addChild(floor)
        
        for i in 0..<6 {
            let line = SKShapeNode(rectOf: CGSize(width: size.width, height: 1))
            line.fillColor = UIColor.white.withAlphaComponent(0.04)
            line.strokeColor = .clear
            line.position = CGPoint(x: size.width / 2, y: CGFloat(i) * 35 + 10)
            line.zPosition = -4
            addChild(line)
        }
    }
    
    private func addConveyorEnd() {
        let endY: CGFloat = 270
        let endHeight: CGFloat = 50
        
        let endShadow = SKShapeNode(rectOf: CGSize(width: size.width - 80, height: endHeight))
        endShadow.position = CGPoint(x: size.width / 2, y: endY)
        endShadow.fillColor = UIColor(white: 0.08, alpha: 1.0)
        endShadow.strokeColor = UIColor.white.withAlphaComponent(0.15)
        endShadow.lineWidth = 1
        endShadow.zPosition = 2
        addChild(endShadow)
        
        let warningStripe = SKNode()
        warningStripe.position = CGPoint(x: size.width / 2, y: endY)
        warningStripe.zPosition = 3
        
        let stripeWidth: CGFloat = 20
        let count = Int((size.width - 80) / stripeWidth)
        
        for i in 0..<count {
            let stripe = SKShapeNode(rectOf: CGSize(width: stripeWidth - 2, height: 6))
            stripe.fillColor = i % 2 == 0 ? 
                UIColor(red: 0.95, green: 0.8, blue: 0.1, alpha: 1.0) :
                UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
            stripe.strokeColor = .clear
            let xOffset = CGFloat(i) * stripeWidth - (CGFloat(count) * stripeWidth) / 2 + stripeWidth / 2
            stripe.position = CGPoint(x: xOffset, y: -endHeight / 2 - 6)
            warningStripe.addChild(stripe)
        }
        
        addChild(warningStripe)
    }
    
    private func setupButtons(buttonAreaHeight: CGFloat) {
        let buttonWidth: CGFloat = (size.width - 60) / 2
        let buttonHeight: CGFloat = 80
        let buttonY: CGFloat = buttonAreaHeight / 2 - 10
        
        leftButton = createGameButton(
            title: "← LEFT",
            color: UIColor(red: 0.95, green: 0.35, blue: 0.35, alpha: 1.0),
            size: CGSize(width: buttonWidth, height: buttonHeight),
            position: CGPoint(x: buttonWidth / 2 + 20, y: buttonY),
            name: "leftButton"
        )
        addChild(leftButton)
        
        rightButton = createGameButton(
            title: "RIGHT →",
            color: UIColor(red: 0.3, green: 0.55, blue: 0.95, alpha: 1.0),
            size: CGSize(width: buttonWidth, height: buttonHeight),
            position: CGPoint(x: size.width - buttonWidth / 2 - 20, y: buttonY),
            name: "rightButton"
        )
        addChild(rightButton)
    }
    
    private func createGameButton(title: String, color: UIColor, size: CGSize, position: CGPoint, name: String) -> SKShapeNode {
        let button = SKShapeNode(rectOf: size, cornerRadius: 18)
        button.fillColor = color
        button.strokeColor = UIColor.white.withAlphaComponent(0.4)
        button.lineWidth = 2
        button.position = position
        button.zPosition = 100
        button.name = name
        
        let highlight = SKShapeNode(rectOf: CGSize(width: size.width - 8, height: 4), cornerRadius: 2)
        highlight.fillColor = UIColor.white.withAlphaComponent(0.3)
        highlight.strokeColor = .clear
        highlight.position = CGPoint(x: 0, y: size.height / 2 - 8)
        button.addChild(highlight)
        
        let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        label.text = title
        label.fontSize = 22
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        button.addChild(label)
        
        let shadow = SKShapeNode(rectOf: size, cornerRadius: 18)
        shadow.fillColor = UIColor.black.withAlphaComponent(0.4)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 2, y: -3)
        shadow.zPosition = -1
        button.addChild(shadow)
        
        return button
    }
    
    private func setupViewModel() {
        viewModel = GameViewModel()
        viewModel.delegate = self
        viewModel.sceneWidth = size.width
        viewModel.spawnY = size.height - 90
        viewModel.missY = 290
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            if node.name == "leftButton" || node.parent?.name == "leftButton" {
                animateButtonPress(leftButton)
                sortLowestBox(direction: .left)
                return
            }
            if node.name == "rightButton" || node.parent?.name == "rightButton" {
                animateButtonPress(rightButton)
                sortLowestBox(direction: .right)
                return
            }
        }
        
        var tappedBoxNode: BoxNode? = nil
        for node in touchedNodes {
            if let boxNode = node as? BoxNode {
                tappedBoxNode = boxNode
                break
            }
            var current: SKNode? = node.parent
            while current != nil {
                if let boxNode = current as? BoxNode {
                    tappedBoxNode = boxNode
                    break
                }
                current = current?.parent
            }
            if tappedBoxNode != nil { break }
        }
        
        if let boxNode = tappedBoxNode, boxNode.boxModel.type == .qrRequired && !boxNode.boxModel.isScanned {
            handleQRScan(boxNode)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    private func animateButtonPress(_ button: SKShapeNode) {
        let scaleDown = SKAction.scale(to: 0.9, duration: 0.05)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        button.run(SKAction.sequence([scaleDown, scaleUp]))
    }
    
    private func sortLowestBox(direction: ContainerSide) {
        feedbackGenerator.impactOccurred()
        
        guard let lowestBox = viewModel.activeBoxes.min(by: { $0.position.y < $1.position.y }) else {
            return
        }
        
        viewModel.sortBox(lowestBox, direction: direction)
    }
    
    private func handleQRScan(_ boxNode: BoxNode) {
        boxNode.showScanEffect()
        viewModel.scanBox(boxNode.boxModel)
        
        let scannerFeedback = UINotificationFeedbackGenerator()
        scannerFeedback.notificationOccurred(.success)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        viewModel.update(deltaTime: deltaTime)
        updateBoxPositions()
    }
    
    private func updateBoxPositions() {
        for box in viewModel.activeBoxes {
            if let node = boxNodes[box.id] {
                node.position = box.position
                
                if box.type == .vip, let timer = box.vipTimer {
                    node.updateVIPTimer(timer)
                }
            }
        }
    }
    
    private func showBlackout() {
        blackoutOverlay = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        blackoutOverlay?.fillColor = UIColor.black.withAlphaComponent(0.9)
        blackoutOverlay?.strokeColor = .clear
        blackoutOverlay?.position = CGPoint(x: size.width / 2, y: size.height / 2)
        blackoutOverlay?.zPosition = 50
        blackoutOverlay?.alpha = 0
        
        if let overlay = blackoutOverlay {
            addChild(overlay)
            overlay.run(SKAction.fadeAlpha(to: 0.85, duration: 0.3))
            
            let warningLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
            warningLabel.text = "BLACKOUT!"
            warningLabel.fontSize = 40
            warningLabel.fontColor = .red
            warningLabel.position = CGPoint(x: 0, y: 0)
            overlay.addChild(warningLabel)
            
            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.3),
                SKAction.scale(to: 1.0, duration: 0.3)
            ])
            warningLabel.run(SKAction.repeatForever(pulse))
        }
    }
    
    private func hideBlackout() {
        blackoutOverlay?.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
        blackoutOverlay = nil
    }
}

extension GameScene: GameViewModelDelegate {
    func gameStateDidChange(_ state: GameStateModel) {
        hudNode.updateScore(state.score)
        hudNode.updateTimer(state.shiftTimeRemaining)
        conveyorNode.setSpeed(state.speedMultiplier)
    }
    
    func boxDidSpawn(_ box: BoxModel) {
        let boxNode = BoxNode(model: box)
        boxNode.zPosition = 10
        boxNodes[box.id] = boxNode
        addChild(boxNode)
    }
    
    func boxDidSort(_ box: BoxModel, direction: ContainerSide, correct: Bool) {
        guard let boxNode = boxNodes[box.id] else { return }
        
        if correct {
            if direction == .left {
                leftContainerNode.animateReceive()
                leftContainerNode.updateFillLevel(viewModel.leftContainer.fillPercentage)
            } else {
                rightContainerNode.animateReceive()
                rightContainerNode.updateFillLevel(viewModel.rightContainer.fillPercentage)
            }
        } else {
            if direction == .left {
                leftContainerNode.animateReject()
            } else {
                rightContainerNode.animateReject()
            }
        }
        
        boxNode.animateSort(to: direction) { [weak self] in
            self?.boxNodes.removeValue(forKey: box.id)
        }
    }
    
    func boxDidMiss(_ box: BoxModel) {
        guard let boxNode = boxNodes[box.id] else { return }
        
        boxNode.animateMiss { [weak self] in
            self?.boxNodes.removeValue(forKey: box.id)
        }
    }
    
    func comboDidChange(_ combo: Int) {
        hudNode.updateCombo(combo)
    }
    
    func blackoutDidToggle(_ isActive: Bool) {
        if isActive {
            showBlackout()
        } else {
            hideBlackout()
        }
    }
    
    func shiftDidEnd(statistics: GameStatistics, levelId: Int, completed: Bool) {
        gameDelegate?.gameSceneDidEnd(statistics: statistics, levelId: levelId, completed: completed)
    }
    
    func livesDidChange(_ lives: Int) {
        hudNode.updateLives(lives)
    }
}
