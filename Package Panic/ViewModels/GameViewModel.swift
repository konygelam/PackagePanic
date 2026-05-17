import Foundation
import UIKit
import Combine

protocol GameViewModelDelegate: AnyObject {
    func gameStateDidChange(_ state: GameStateModel)
    func boxDidSpawn(_ box: BoxModel)
    func boxDidSort(_ box: BoxModel, direction: ContainerSide, correct: Bool)
    func boxDidMiss(_ box: BoxModel)
    func comboDidChange(_ combo: Int)
    func blackoutDidToggle(_ isActive: Bool)
    func shiftDidEnd(statistics: GameStatistics, levelId: Int, completed: Bool)
    func livesDidChange(_ lives: Int)
}

final class GameViewModel {
    weak var delegate: GameViewModelDelegate?
    
    private(set) var gameState: GameStateModel = GameStateModel()
    private(set) var leftContainer: ContainerModel
    private(set) var rightContainer: ContainerModel
    private(set) var activeBoxes: [BoxModel] = []
    
    private var spawnTimer: Timer?
    private var gameTimer: Timer?
    private var blackoutTimer: Timer?
    private var lastUpdateTime: TimeInterval = 0
    private var shiftStartTime: Date?
    private var currentLevel: LevelModel?
    private var targetScore: Int = 0
    
    var sceneWidth: CGFloat = 393
    var spawnY: CGFloat = 900
    var missY: CGFloat = 280
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    init() {
        leftContainer = ContainerModel(
            side: .left,
            acceptedColors: [.red, .orange, .yellow],
            position: CGPoint(x: 50, y: 100),
            size: CGSize(width: 100, height: 150)
        )
        rightContainer = ContainerModel(
            side: .right,
            acceptedColors: [.blue, .green, .purple],
            position: CGPoint(x: 250, y: 100),
            size: CGSize(width: 100, height: 150)
        )
    }
    
    func startGame() {
        startGame(with: nil)
    }
    
    func startGame(with level: LevelModel?) {
        currentLevel = level
        gameState = GameStateModel()
        gameState.phase = .playing
        
        if let level = level {
            gameState.shiftTimeRemaining = level.timeLimit
            gameState.speedMultiplier = level.conveyorSpeed / 100.0
            targetScore = level.targetScore
            
            gameState.difficulty = .easy
            if level.conveyorSpeed >= 160 {
                gameState.difficulty = .extreme
            } else if level.conveyorSpeed >= 130 {
                gameState.difficulty = .hard
            } else if level.conveyorSpeed >= 100 {
                gameState.difficulty = .medium
            }
        } else {
            gameState.shiftTimeRemaining = 120
            targetScore = 0
        }
        
        activeBoxes.removeAll()
        leftContainer.reset()
        rightContainer.reset()
        shiftStartTime = Date()
        
        startSpawnTimer()
        startGameTimer()
        
        delegate?.gameStateDidChange(gameState)
    }
    
    func pauseGame() {
        gameState.isPaused = true
        gameState.phase = .paused
        spawnTimer?.invalidate()
        gameTimer?.invalidate()
        delegate?.gameStateDidChange(gameState)
    }
    
    func resumeGame() {
        gameState.isPaused = false
        gameState.phase = .playing
        startSpawnTimer()
        startGameTimer()
        delegate?.gameStateDidChange(gameState)
    }
    
    func endShift() {
        spawnTimer?.invalidate()
        gameTimer?.invalidate()
        blackoutTimer?.invalidate()
        
        if let start = shiftStartTime {
            gameState.statistics.shiftDuration = Date().timeIntervalSince(start)
        }
        gameState.statistics.totalScore = gameState.score
        gameState.statistics.maxCombo = max(gameState.statistics.maxCombo, gameState.combo)
        gameState.phase = .shiftEnd
        
        let completed = targetScore > 0 ? gameState.score >= targetScore : true
        let levelId = currentLevel?.id ?? 0
        
        saveHighScore()
        delegate?.shiftDidEnd(statistics: gameState.statistics, levelId: levelId, completed: completed)
    }
    
    func sortBox(_ box: BoxModel, direction: ContainerSide) {
        guard let index = activeBoxes.firstIndex(where: { $0.id == box.id }) else { return }
        
        var sortedBox = activeBoxes.remove(at: index)
        sortedBox.position = box.position
        
        if sortedBox.type == .dangerous {
            handleDangerousBox()
            delegate?.boxDidSort(sortedBox, direction: direction, correct: false)
            return
        }
        
        if sortedBox.type == .qrRequired && !sortedBox.isScanned {
            handleUnscannedBox(sortedBox)
            delegate?.boxDidSort(sortedBox, direction: direction, correct: false)
            return
        }
        
        let targetContainer = direction == .left ? leftContainer : rightContainer
        let isCorrect = targetContainer.accepts(box: sortedBox)
        
        if isCorrect {
            handleCorrectSort(box: sortedBox, container: direction)
        } else {
            handleIncorrectSort(box: sortedBox)
        }
        
        feedbackGenerator.impactOccurred()
        delegate?.boxDidSort(sortedBox, direction: direction, correct: isCorrect)
    }
    
    func scanBox(_ box: BoxModel) {
        guard let index = activeBoxes.firstIndex(where: { $0.id == box.id }) else { return }
        activeBoxes[index].isScanned = true
        gameState.statistics.qrScanned += 1
        addScore(50)
    }
    
    func update(deltaTime: TimeInterval) {
        guard gameState.phase == .playing else { return }
        
        updateBoxPositions(deltaTime: deltaTime)
        checkMissedBoxes()
        updateBlackout(deltaTime: deltaTime)
        updateVIPTimers(deltaTime: deltaTime)
        checkDifficultyProgression()
    }
    
    private func startSpawnTimer() {
        spawnTimer?.invalidate()
        let interval = currentLevel?.spawnInterval ?? gameState.difficulty.spawnInterval
        spawnTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.spawnBox()
        }
    }
    
    private func startGameTimer() {
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.gameState.shiftTimeRemaining -= 1
            if self.gameState.shiftTimeRemaining <= 0 {
                self.endShift()
            }
            self.delegate?.gameStateDidChange(self.gameState)
        }
    }
    
    private func spawnBox() {
        let box = generateRandomBox()
        activeBoxes.append(box)
        delegate?.boxDidSpawn(box)
        
        if shouldTriggerBlackout() {
            triggerBlackout()
        }
    }
    
    private func generateRandomBox() -> BoxModel {
        let color = BoxColor.allCases.randomElement()!
        let shape = BoxShape.allCases.randomElement()!
        let sticker = Bool.random() ? BoxSticker.allCases.randomElement()! : .none
        
        let type = determineBoxType()
        let target: ContainerSide = [.red, .orange, .yellow].contains(color) ? .left : .right
        
        var vipTimer: TimeInterval? = nil
        if type == .vip {
            vipTimer = 5.0
        }
        
        let lanes: [CGFloat] = [
            sceneWidth / 2 - 90,
            sceneWidth / 2,
            sceneWidth / 2 + 90
        ]
        let xPosition = lanes.randomElement() ?? sceneWidth / 2
        
        let baseSpeed = currentLevel?.conveyorSpeed ?? gameState.difficulty.baseSpeed
        
        return BoxModel(
            color: color,
            shape: shape,
            sticker: sticker,
            type: type,
            targetContainer: target,
            vipTimer: vipTimer,
            position: CGPoint(x: xPosition, y: spawnY),
            velocity: baseSpeed * gameState.speedMultiplier
        )
    }
    
    private func determineBoxType() -> BoxType {
        let random = Int.random(in: 1...100)
        
        if let level = currentLevel {
            if random <= level.dangerousBoxChance {
                return .dangerous
            } else if random <= level.dangerousBoxChance + level.vipBoxChance {
                return .vip
            } else if random <= level.dangerousBoxChance + level.vipBoxChance + level.qrBoxChance {
                return .qrRequired
            } else if random <= level.dangerousBoxChance + level.vipBoxChance + level.qrBoxChance + level.decoyBoxChance {
                return .decoy
            }
            return .normal
        }
        
        switch random {
        case 1...5: return .dangerous
        case 6...15: return .vip
        case 16...25: return .qrRequired
        case 26...30 where gameState.currentLevel > 3: return .decoy
        default: return .normal
        }
    }
    
    private func updateBoxPositions(deltaTime: TimeInterval) {
        for i in activeBoxes.indices {
            activeBoxes[i].position.y -= activeBoxes[i].velocity * CGFloat(deltaTime)
        }
    }
    
    private func checkMissedBoxes() {
        let missedBoxes = activeBoxes.filter { $0.position.y < missY }
        for box in missedBoxes {
            handleMissedBox(box)
        }
        activeBoxes.removeAll { $0.position.y < missY }
    }
    
    private func handleCorrectSort(box: BoxModel, container: ContainerSide) {
        gameState.combo += 1
        gameState.statistics.maxCombo = max(gameState.statistics.maxCombo, gameState.combo)
        
        var points = 100
        points += gameState.combo * 10
        
        if box.type == .vip {
            points = Int(Double(points) * box.type.multiplier)
            gameState.statistics.vipDelivered += 1
        }
        
        addScore(points)
        gameState.statistics.deliveredCount += 1
        
        if container == .left {
            leftContainer.addBox()
        } else {
            rightContainer.addBox()
        }
        
        delegate?.comboDidChange(gameState.combo)
    }
    
    private func handleIncorrectSort(box: BoxModel) {
        gameState.combo = 0
        gameState.statistics.wrongContainerCount += 1
        loseLife()
        delegate?.comboDidChange(0)
    }
    
    private func handleMissedBox(_ box: BoxModel) {
        if box.type != .dangerous {
            gameState.statistics.lostCount += 1
            gameState.combo = 0
            loseLife()
        }
        delegate?.boxDidMiss(box)
    }
    
    private func handleDangerousBox() {
        gameState.statistics.dangerousHandled += 1
        loseLife()
        loseLife()
    }
    
    private func handleUnscannedBox(_ box: BoxModel) {
        gameState.combo = 0
        loseLife()
    }
    
    private func loseLife() {
        gameState.lives -= 1
        delegate?.livesDidChange(gameState.lives)
        
        if gameState.lives <= 0 {
            endShift()
        }
    }
    
    private func addScore(_ points: Int) {
        gameState.score += points
        delegate?.gameStateDidChange(gameState)
    }
    
    private func shouldTriggerBlackout() -> Bool {
        if let level = currentLevel {
            guard level.hasBlackout && !gameState.isBlackoutMode else { return false }
            return Int.random(in: 1...100) <= 5
        }
        
        guard gameState.currentLevel >= 3 && !gameState.isBlackoutMode else { return false }
        return Int.random(in: 1...100) <= 5
    }
    
    private func triggerBlackout() {
        gameState.isBlackoutMode = true
        gameState.blackoutTimer = 5.0
        delegate?.blackoutDidToggle(true)
        
        blackoutTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            self?.gameState.isBlackoutMode = false
            self?.delegate?.blackoutDidToggle(false)
        }
    }
    
    private func updateBlackout(deltaTime: TimeInterval) {
        if gameState.isBlackoutMode {
            gameState.blackoutTimer -= deltaTime
            if gameState.blackoutTimer <= 0 {
                gameState.isBlackoutMode = false
                delegate?.blackoutDidToggle(false)
            }
        }
    }
    
    private func updateVIPTimers(deltaTime: TimeInterval) {
        for i in activeBoxes.indices {
            if activeBoxes[i].type == .vip, var timer = activeBoxes[i].vipTimer {
                timer -= deltaTime
                activeBoxes[i].vipTimer = timer
                if timer <= 0 {
                    handleMissedBox(activeBoxes[i])
                }
            }
        }
    }
    
    private func checkDifficultyProgression() {
        let deliveredCount = gameState.statistics.deliveredCount
        
        if deliveredCount >= 50 && gameState.difficulty == .easy {
            gameState.difficulty = .medium
            gameState.currentLevel = 2
            restartSpawnTimer()
        } else if deliveredCount >= 100 && gameState.difficulty == .medium {
            gameState.difficulty = .hard
            gameState.currentLevel = 3
            restartSpawnTimer()
        } else if deliveredCount >= 200 && gameState.difficulty == .hard {
            gameState.difficulty = .extreme
            gameState.currentLevel = 4
            restartSpawnTimer()
        }
        
        if deliveredCount % 25 == 0 && deliveredCount > 0 {
            gameState.speedMultiplier += 0.05
        }
    }
    
    private func restartSpawnTimer() {
        startSpawnTimer()
    }
    
    private func saveHighScore() {
        let entry = HighScoreEntry(
            score: gameState.score,
            date: Date(),
            rating: gameState.statistics.workerRating,
            accuracy: gameState.statistics.accuracy
        )
        
        var highScores = loadHighScores()
        highScores.append(entry)
        highScores.sort { $0.score > $1.score }
        highScores = Array(highScores.prefix(10))
        
        if let encoded = try? JSONEncoder().encode(highScores) {
            UserDefaults.standard.set(encoded, forKey: "highScores")
        }
    }
    
    func loadHighScores() -> [HighScoreEntry] {
        guard let data = UserDefaults.standard.data(forKey: "highScores"),
              let scores = try? JSONDecoder().decode([HighScoreEntry].self, from: data) else {
            return []
        }
        return scores
    }
}
