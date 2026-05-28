import Foundation

struct LevelModel: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String
    let targetScore: Int
    let timeLimit: TimeInterval
    let conveyorSpeed: CGFloat
    let spawnInterval: TimeInterval
    let dangerousBoxChance: Int
    let vipBoxChance: Int
    let qrBoxChance: Int
    let decoyBoxChance: Int
    let hasBlackout: Bool
    let multipleConveyors: Bool
    var isUnlocked: Bool
    var bestScore: Int
    var bestAccuracy: Double
    var timesPlayed: Int
    var timesCompleted: Int
    
    var starsEarned: Int {
        if bestScore >= targetScore * 2 { return 3 }
        if bestScore >= Int(Double(targetScore) * 1.5) { return 2 }
        if bestScore >= targetScore { return 1 }
        return 0
    }
    
    static let allLevels: [LevelModel] = [
        LevelModel(
            id: 1,
            name: "First Day",
            description: "Learn the basics of sorting packages",
            targetScore: 500,
            timeLimit: 60,
            conveyorSpeed: 80,
            spawnInterval: 2.5,
            dangerousBoxChance: 0,
            vipBoxChance: 0,
            qrBoxChance: 0,
            decoyBoxChance: 0,
            hasBlackout: false,
            multipleConveyors: false,
            isUnlocked: true,
            bestScore: 0,
            bestAccuracy: 0,
            timesPlayed: 0,
            timesCompleted: 0
        ),
        LevelModel(
            id: 2,
            name: "Getting Busy",
            description: "Things are picking up speed",
            targetScore: 800,
            timeLimit: 90,
            conveyorSpeed: 100,
            spawnInterval: 2.0,
            dangerousBoxChance: 5,
            vipBoxChance: 0,
            qrBoxChance: 0,
            decoyBoxChance: 0,
            hasBlackout: false,
            multipleConveyors: false,
            isUnlocked: false,
            bestScore: 0,
            bestAccuracy: 0,
            timesPlayed: 0,
            timesCompleted: 0
        ),
        LevelModel(
            id: 3,
            name: "VIP Treatment",
            description: "Handle priority packages with care",
            targetScore: 1200,
            timeLimit: 90,
            conveyorSpeed: 110,
            spawnInterval: 1.8,
            dangerousBoxChance: 5,
            vipBoxChance: 15,
            qrBoxChance: 0,
            decoyBoxChance: 0,
            hasBlackout: false,
            multipleConveyors: false,
            isUnlocked: false,
            bestScore: 0,
            bestAccuracy: 0,
            timesPlayed: 0,
            timesCompleted: 0
        ),
        LevelModel(
            id: 4,
            name: "Scan Everything",
            description: "New QR verification system installed",
            targetScore: 1500,
            timeLimit: 120,
            conveyorSpeed: 120,
            spawnInterval: 1.6,
            dangerousBoxChance: 5,
            vipBoxChance: 10,
            qrBoxChance: 20,
            decoyBoxChance: 0,
            hasBlackout: false,
            multipleConveyors: false,
            isUnlocked: false,
            bestScore: 0,
            bestAccuracy: 0,
            timesPlayed: 0,
            timesCompleted: 0
        ),
        LevelModel(
            id: 5,
            name: "Lights Out",
            description: "Power outages are common here",
            targetScore: 2000,
            timeLimit: 120,
            conveyorSpeed: 130,
            spawnInterval: 1.5,
            dangerousBoxChance: 8,
            vipBoxChance: 10,
            qrBoxChance: 15,
            decoyBoxChance: 0,
            hasBlackout: true,
            multipleConveyors: false,
            isUnlocked: false,
            bestScore: 0,
            bestAccuracy: 0,
            timesPlayed: 0,
            timesCompleted: 0
        ),
        LevelModel(
            id: 6,
            name: "Double Trouble",
            description: "Watch out for fake packages",
            targetScore: 2500,
            timeLimit: 120,
            conveyorSpeed: 140,
            spawnInterval: 1.4,
            dangerousBoxChance: 8,
            vipBoxChance: 10,
            qrBoxChance: 15,
            decoyBoxChance: 10,
            hasBlackout: true,
            multipleConveyors: false,
            isUnlocked: false,
            bestScore: 0,
            bestAccuracy: 0,
            timesPlayed: 0,
            timesCompleted: 0
        ),
        LevelModel(
            id: 7,
            name: "Rush Hour",
            description: "The busiest time of day",
            targetScore: 3000,
            timeLimit: 150,
            conveyorSpeed: 160,
            spawnInterval: 1.2,
            dangerousBoxChance: 10,
            vipBoxChance: 15,
            qrBoxChance: 15,
            decoyBoxChance: 10,
            hasBlackout: true,
            multipleConveyors: false,
            isUnlocked: false,
            bestScore: 0,
            bestAccuracy: 0,
            timesPlayed: 0,
            timesCompleted: 0
        ),
        LevelModel(
            id: 8,
            name: "Holiday Season",
            description: "Everyone is ordering online",
            targetScore: 4000,
            timeLimit: 180,
            conveyorSpeed: 180,
            spawnInterval: 1.0,
            dangerousBoxChance: 12,
            vipBoxChance: 20,
            qrBoxChance: 20,
            decoyBoxChance: 15,
            hasBlackout: true,
            multipleConveyors: false,
            isUnlocked: false,
            bestScore: 0,
            bestAccuracy: 0,
            timesPlayed: 0,
            timesCompleted: 0
        ),
        LevelModel(
            id: 9,
            name: "Chaos Mode",
            description: "Pure madness on the sorting line",
            targetScore: 5000,
            timeLimit: 180,
            conveyorSpeed: 200,
            spawnInterval: 0.8,
            dangerousBoxChance: 15,
            vipBoxChance: 20,
            qrBoxChance: 20,
            decoyBoxChance: 15,
            hasBlackout: true,
            multipleConveyors: false,
            isUnlocked: false,
            bestScore: 0,
            bestAccuracy: 0,
            timesPlayed: 0,
            timesCompleted: 0
        ),
        LevelModel(
            id: 10,
            name: "Endless Shift",
            description: "How long can you survive?",
            targetScore: 10000,
            timeLimit: 300,
            conveyorSpeed: 100,
            spawnInterval: 2.0,
            dangerousBoxChance: 5,
            vipBoxChance: 10,
            qrBoxChance: 10,
            decoyBoxChance: 5,
            hasBlackout: true,
            multipleConveyors: false,
            isUnlocked: false,
            bestScore: 0,
            bestAccuracy: 0,
            timesPlayed: 0,
            timesCompleted: 0
        )
    ]
}

struct LevelStatistics: Codable {
    var levelId: Int
    var totalDelivered: Int = 0
    var totalLost: Int = 0
    var totalWrongContainer: Int = 0
    var totalVIPDelivered: Int = 0
    var totalQRScanned: Int = 0
    var totalDangerousHandled: Int = 0
    var highestCombo: Int = 0
    var totalPlayTime: TimeInterval = 0
    var gamesPlayed: Int = 0
    var gamesCompleted: Int = 0
    
    var averageAccuracy: Double {
        let total = totalDelivered + totalLost + totalWrongContainer
        guard total > 0 else { return 0 }
        return Double(totalDelivered) / Double(total) * 100
    }
}
