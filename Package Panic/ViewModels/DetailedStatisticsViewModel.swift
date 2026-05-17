import Foundation

final class DetailedStatisticsViewModel {
    private(set) var levels: [LevelModel] = []
    private(set) var levelStatistics: [Int: LevelStatistics] = [:]
    private(set) var totalStats: LevelStatistics
    
    init() {
        levels = DataManager.shared.loadLevels()
        levelStatistics = DataManager.shared.loadStatistics()
        totalStats = DataManager.shared.getTotalStatistics()
    }
    
    var totalPackagesDelivered: String {
        return "\(totalStats.totalDelivered)"
    }
    
    var totalPackagesLost: String {
        return "\(totalStats.totalLost)"
    }
    
    var totalWrongContainer: String {
        return "\(totalStats.totalWrongContainer)"
    }
    
    var overallAccuracy: String {
        return String(format: "%.1f%%", totalStats.averageAccuracy)
    }
    
    var totalVIPDelivered: String {
        return "\(totalStats.totalVIPDelivered)"
    }
    
    var totalQRScanned: String {
        return "\(totalStats.totalQRScanned)"
    }
    
    var highestCombo: String {
        return "\(totalStats.highestCombo)x"
    }
    
    var totalPlayTime: String {
        let hours = Int(totalStats.totalPlayTime) / 3600
        let minutes = (Int(totalStats.totalPlayTime) % 3600) / 60
        let seconds = Int(totalStats.totalPlayTime) % 60
        
        if hours > 0 {
            return String(format: "%dh %dm %ds", hours, minutes, seconds)
        } else if minutes > 0 {
            return String(format: "%dm %ds", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }
    
    var totalGamesPlayed: String {
        return "\(totalStats.gamesPlayed)"
    }
    
    var totalGamesCompleted: String {
        return "\(totalStats.gamesCompleted)"
    }
    
    var completionRate: String {
        guard totalStats.gamesPlayed > 0 else { return "0%" }
        let rate = Double(totalStats.gamesCompleted) / Double(totalStats.gamesPlayed) * 100
        return String(format: "%.1f%%", rate)
    }
    
    func statisticsForLevel(_ levelId: Int) -> LevelStatistics? {
        return levelStatistics[levelId]
    }
    
    func levelAt(index: Int) -> LevelModel? {
        guard index < levels.count else { return nil }
        return levels[index]
    }
    
    func formattedPlayTime(for levelId: Int) -> String {
        guard let stats = levelStatistics[levelId] else { return "0s" }
        let minutes = Int(stats.totalPlayTime) / 60
        let seconds = Int(stats.totalPlayTime) % 60
        if minutes > 0 {
            return String(format: "%dm %ds", minutes, seconds)
        }
        return String(format: "%ds", seconds)
    }
    
    func refresh() {
        levels = DataManager.shared.loadLevels()
        levelStatistics = DataManager.shared.loadStatistics()
        totalStats = DataManager.shared.getTotalStatistics()
    }
}
