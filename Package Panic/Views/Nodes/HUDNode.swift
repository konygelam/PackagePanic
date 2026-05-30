import SpriteKit

final class HUDNode: SKNode {
    private var scoreLabel: SKLabelNode!
    private var comboLabel: SKLabelNode!
    private var livesContainer: SKNode!
    private var livesNodes: [SKShapeNode] = []
    private var timerLabel: SKLabelNode!
    private var timerIcon: SKShapeNode!
    
    var onPauseTapped: (() -> Void)?
    
    private let hudWidth: CGFloat
    private let hudHeight: CGFloat = 80
    
    init(width: CGFloat) {
        self.hudWidth = width
        super.init()
        
        setupHUD()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupHUD() {
        let background = SKShapeNode(rectOf: CGSize(width: hudWidth, height: hudHeight))
        background.fillColor = UIColor(white: 0.04, alpha: 0.95)
        background.strokeColor = .clear
        addChild(background)
        
        let bottomBorder = SKShapeNode(rectOf: CGSize(width: hudWidth, height: 1))
        bottomBorder.fillColor = UIColor.white.withAlphaComponent(0.15)
        bottomBorder.strokeColor = .clear
        bottomBorder.position = CGPoint(x: 0, y: -hudHeight / 2)
        addChild(bottomBorder)
        
        setupScoreSection()
        setupComboSection()
        setupLivesSection()
        setupTimerSection()
    }
    
    private func setupScoreSection() {
        let scoreTitle = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        scoreTitle.fontSize = 9
        scoreTitle.fontColor = UIColor.white.withAlphaComponent(0.5)
        scoreTitle.text = "SCORE"
        scoreTitle.horizontalAlignmentMode = .left
        scoreTitle.verticalAlignmentMode = .center
        scoreTitle.position = CGPoint(x: -hudWidth / 2 + 16, y: 16)
        addChild(scoreTitle)
        
        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        scoreLabel.fontSize = 26
        scoreLabel.fontColor = UIColor(red: 0.3, green: 0.85, blue: 0.4, alpha: 1.0)
        scoreLabel.text = "0"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.position = CGPoint(x: -hudWidth / 2 + 16, y: -8)
        addChild(scoreLabel)
    }
    
    private func setupComboSection() {
        let comboBg = SKShapeNode(rectOf: CGSize(width: 100, height: 28), cornerRadius: 14)
        comboBg.fillColor = UIColor(red: 0.25, green: 0.2, blue: 0.05, alpha: 0.9)
        comboBg.strokeColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 0.6)
        comboBg.lineWidth = 1
        comboBg.position = CGPoint(x: 0, y: 4)
        comboBg.alpha = 0
        comboBg.name = "comboBg"
        addChild(comboBg)
        
        comboLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        comboLabel.fontSize = 16
        comboLabel.fontColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        comboLabel.text = ""
        comboLabel.horizontalAlignmentMode = .center
        comboLabel.verticalAlignmentMode = .center
        comboLabel.position = CGPoint(x: 0, y: 4)
        addChild(comboLabel)
    }
    
    private func setupLivesSection() {
        livesContainer = SKNode()
        livesContainer.position = CGPoint(x: hudWidth / 2 - 110, y: 16)
        addChild(livesContainer)
        
        let livesTitle = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        livesTitle.fontSize = 9
        livesTitle.fontColor = UIColor.white.withAlphaComponent(0.5)
        livesTitle.text = "LIVES"
        livesTitle.horizontalAlignmentMode = .center
        livesTitle.verticalAlignmentMode = .center
        livesTitle.position = CGPoint(x: 0, y: 0)
        livesContainer.addChild(livesTitle)
        
        for i in 0..<3 {
            let heart = createHeart()
            heart.position = CGPoint(x: CGFloat(i) * 22 - 22, y: -16)
            livesContainer.addChild(heart)
            livesNodes.append(heart)
        }
    }
    
    private func createHeart() -> SKShapeNode {
        let heart = SKShapeNode(circleOfRadius: 8)
        heart.fillColor = UIColor(red: 0.95, green: 0.25, blue: 0.35, alpha: 1.0)
        heart.strokeColor = UIColor.white.withAlphaComponent(0.6)
        heart.lineWidth = 1.5
        
        let inner = SKShapeNode(circleOfRadius: 3)
        inner.fillColor = UIColor.white.withAlphaComponent(0.4)
        inner.strokeColor = .clear
        inner.position = CGPoint(x: -2, y: 2)
        heart.addChild(inner)
        
        return heart
    }
    
    private func setupTimerSection() {
        let timerTitle = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        timerTitle.fontSize = 9
        timerTitle.fontColor = UIColor.white.withAlphaComponent(0.5)
        timerTitle.text = "SHIFT"
        timerTitle.horizontalAlignmentMode = .right
        timerTitle.verticalAlignmentMode = .center
        timerTitle.position = CGPoint(x: hudWidth / 2 - 16, y: 16)
        addChild(timerTitle)
        
        timerIcon = SKShapeNode(circleOfRadius: 4)
        timerIcon.fillColor = UIColor(red: 0.95, green: 0.3, blue: 0.3, alpha: 1.0)
        timerIcon.strokeColor = UIColor.white.withAlphaComponent(0.6)
        timerIcon.lineWidth = 1
        timerIcon.position = CGPoint(x: hudWidth / 2 - 70, y: -8)
        addChild(timerIcon)
        
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.4, duration: 0.5),
            SKAction.fadeAlpha(to: 1.0, duration: 0.5)
        ])
        timerIcon.run(SKAction.repeatForever(pulse))
        
        timerLabel = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        timerLabel.fontSize = 22
        timerLabel.fontColor = .white
        timerLabel.text = "2:00"
        timerLabel.horizontalAlignmentMode = .right
        timerLabel.verticalAlignmentMode = .center
        timerLabel.position = CGPoint(x: hudWidth / 2 - 16, y: -8)
        addChild(timerLabel)
    }
    
    func updateScore(_ score: Int) {
        scoreLabel.text = "\(score)"
        
        let scaleUp = SKAction.scale(to: 1.15, duration: 0.08)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.08)
        scoreLabel.run(SKAction.sequence([scaleUp, scaleDown]))
    }
    
    func updateCombo(_ combo: Int) {
        guard let comboBg = childNode(withName: "comboBg") else { return }
        
        if combo > 1 {
            comboLabel.text = "\(combo)x COMBO"
            
            let appear = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
            comboBg.run(appear)
            
            let scaleUp = SKAction.scale(to: 1.25, duration: 0.08)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.08)
            comboLabel.run(SKAction.sequence([scaleUp, scaleDown]))
        } else {
            comboLabel.text = ""
            comboBg.run(SKAction.fadeAlpha(to: 0, duration: 0.2))
        }
    }
    
    func updateLives(_ lives: Int) {
        for (index, heart) in livesNodes.enumerated() {
            if index < lives {
                heart.alpha = 1.0
                heart.fillColor = UIColor(red: 0.95, green: 0.25, blue: 0.35, alpha: 1.0)
            } else {
                heart.alpha = 0.25
                heart.fillColor = UIColor(white: 0.4, alpha: 1.0)
                
                let shake = SKAction.sequence([
                    SKAction.rotate(byAngle: 0.3, duration: 0.05),
                    SKAction.rotate(byAngle: -0.6, duration: 0.1),
                    SKAction.rotate(byAngle: 0.3, duration: 0.05)
                ])
                heart.run(shake)
            }
        }
    }
    
    func updateTimer(_ seconds: TimeInterval) {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        timerLabel.text = String(format: "%d:%02d", minutes, secs)
        
        if seconds <= 30 {
            timerLabel.fontColor = UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
            timerIcon.fillColor = UIColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0)
            
            if action(forKey: "timerPulse") == nil {
                let pulse = SKAction.sequence([
                    SKAction.scale(to: 1.1, duration: 0.5),
                    SKAction.scale(to: 1.0, duration: 0.5)
                ])
                timerLabel.run(SKAction.repeatForever(pulse), withKey: "timerPulse")
            }
        } else if seconds <= 60 {
            timerLabel.fontColor = UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1.0)
        }
    }
}
