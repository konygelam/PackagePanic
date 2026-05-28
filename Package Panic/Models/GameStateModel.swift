import Foundation

enum GamePhase {
    case menu
    case playing
    case paused
    case gameOver
    case shiftEnd
}

enum GameDifficulty {
    case easy
    case medium
    case hard
    case extreme
    
    var baseSpeed: CGFloat {
        switch self {
        case .easy: return 80
        case .medium: return 120
        case .hard: return 160
        case .extreme: return 200
        }
    }
    
    var spawnInterval: TimeInterval {
        switch self {
        case .easy: return 2.5
        case .medium: return 1.8
        case .hard: return 1.2
        case .extreme: return 0.8
        }
    }
}

struct GameStatistics {
    var deliveredCount: Int = 0
    var lostCount: Int = 0
    var wrongContainerCount: Int = 0
    var dangerousHandled: Int = 0
    var vipDelivered: Int = 0
    var qrScanned: Int = 0
    var totalScore: Int = 0
    var maxCombo: Int = 0
    var shiftDuration: TimeInterval = 0
    
    var accuracy: Double {
        let total = deliveredCount + lostCount + wrongContainerCount
        guard total > 0 else { return 0 }
        return Double(deliveredCount) / Double(total) * 100
    }
    
    var workerRating: String {
        switch accuracy {
        case 90...100: return "EMPLOYEE OF THE MONTH"
        case 75..<90: return "RELIABLE WORKER"
        case 50..<75: return "NEEDS IMPROVEMENT"
        case 25..<50: return "WARNING ISSUED"
        default: return "FIRED"
        }
    }
    
    var stars: Int {
        switch accuracy {
        case 90...100: return 5
        case 75..<90: return 4
        case 60..<75: return 3
        case 40..<60: return 2
        case 20..<40: return 1
        default: return 0
        }
    }
}

struct GameStateModel {
    var phase: GamePhase = .menu
    var difficulty: GameDifficulty = .easy
    var currentLevel: Int = 1
    var lives: Int = 3
    var score: Int = 0
    var combo: Int = 0
    var isBlackoutMode: Bool = false
    var blackoutTimer: TimeInterval = 0
    var conveyorCount: Int = 1
    var speedMultiplier: CGFloat = 1.0
    var statistics: GameStatistics = GameStatistics()
    var shiftTimeRemaining: TimeInterval = 120
    var isPaused: Bool = false
}

struct HighScoreEntry: Codable {
    let score: Int
    let date: Date
    let rating: String
    let accuracy: Double
}
