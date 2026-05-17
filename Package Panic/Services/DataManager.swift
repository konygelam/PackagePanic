import Foundation

final class DataManager {
    static let shared = DataManager()
    
    private let levelsKey = "savedLevels"
    private let statisticsKey = "levelStatistics"
    private let settingsKey = "appSettings"
    private let highScoresKey = "highScores"
    
    private init() {}
    
    func saveLevels(_ levels: [LevelModel]) {
        if let encoded = try? JSONEncoder().encode(levels) {
            UserDefaults.standard.set(encoded, forKey: levelsKey)
        }
    }
    
    func loadLevels() -> [LevelModel] {
        guard let data = UserDefaults.standard.data(forKey: levelsKey),
              let levels = try? JSONDecoder().decode([LevelModel].self, from: data) else {
            return LevelModel.allLevels
        }
        return levels
    }
    
    func saveStatistics(_ statistics: [Int: LevelStatistics]) {
        let array = Array(statistics.values)
        if let encoded = try? JSONEncoder().encode(array) {
            UserDefaults.standard.set(encoded, forKey: statisticsKey)
        }
    }
    
    func loadStatistics() -> [Int: LevelStatistics] {
        guard let data = UserDefaults.standard.data(forKey: statisticsKey),
              let array = try? JSONDecoder().decode([LevelStatistics].self, from: data) else {
            return [:]
        }
        var dict: [Int: LevelStatistics] = [:]
        for stat in array {
            dict[stat.levelId] = stat
        }
        return dict
    }
    
    func saveSettings(_ settings: SettingsModel) {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: settingsKey)
        }
    }
    
    func loadSettings() -> SettingsModel {
        guard let data = UserDefaults.standard.data(forKey: settingsKey),
              let settings = try? JSONDecoder().decode(SettingsModel.self, from: data) else {
            return SettingsModel()
        }
        return settings
    }
    
    func saveHighScores(_ scores: [HighScoreEntry]) {
        if let encoded = try? JSONEncoder().encode(scores) {
            UserDefaults.standard.set(encoded, forKey: highScoresKey)
        }
    }
    
    func loadHighScores() -> [HighScoreEntry] {
        guard let data = UserDefaults.standard.data(forKey: highScoresKey),
              let scores = try? JSONDecoder().decode([HighScoreEntry].self, from: data) else {
            return []
        }
        return scores
    }
    
    func resetAllData() {
        UserDefaults.standard.removeObject(forKey: levelsKey)
        UserDefaults.standard.removeObject(forKey: statisticsKey)
        UserDefaults.standard.removeObject(forKey: highScoresKey)
        UserDefaults.standard.synchronize()
    }
    
    func updateLevelProgress(levelId: Int, score: Int, accuracy: Double, completed: Bool) {
        var levels = loadLevels()
        
        guard let index = levels.firstIndex(where: { $0.id == levelId }) else { return }
        
        levels[index].timesPlayed += 1
        if completed {
            levels[index].timesCompleted += 1
        }
        
        if score > levels[index].bestScore {
            levels[index].bestScore = score
        }
        
        if accuracy > levels[index].bestAccuracy {
            levels[index].bestAccuracy = accuracy
        }
        
        if completed && levelId < levels.count {
            levels[levelId].isUnlocked = true
        }
        
        saveLevels(levels)
    }
    
    func updateLevelStatistics(levelId: Int, gameStats: GameStatistics) {
        var statistics = loadStatistics()
        
        var levelStat = statistics[levelId] ?? LevelStatistics(levelId: levelId)
        
        levelStat.totalDelivered += gameStats.deliveredCount
        levelStat.totalLost += gameStats.lostCount
        levelStat.totalWrongContainer += gameStats.wrongContainerCount
        levelStat.totalVIPDelivered += gameStats.vipDelivered
        levelStat.totalQRScanned += gameStats.qrScanned
        levelStat.totalDangerousHandled += gameStats.dangerousHandled
        levelStat.highestCombo = max(levelStat.highestCombo, gameStats.maxCombo)
        levelStat.totalPlayTime += gameStats.shiftDuration
        levelStat.gamesPlayed += 1
        if gameStats.totalScore >= 0 {
            levelStat.gamesCompleted += 1
        }
        
        statistics[levelId] = levelStat
        saveStatistics(statistics)
    }
    
    func getTotalStatistics() -> LevelStatistics {
        let allStats = loadStatistics()
        var total = LevelStatistics(levelId: 0)
        
        for stat in allStats.values {
            total.totalDelivered += stat.totalDelivered
            total.totalLost += stat.totalLost
            total.totalWrongContainer += stat.totalWrongContainer
            total.totalVIPDelivered += stat.totalVIPDelivered
            total.totalQRScanned += stat.totalQRScanned
            total.totalDangerousHandled += stat.totalDangerousHandled
            total.highestCombo = max(total.highestCombo, stat.highestCombo)
            total.totalPlayTime += stat.totalPlayTime
            total.gamesPlayed += stat.gamesPlayed
            total.gamesCompleted += stat.gamesCompleted
        }
        
        return total
    }
}
