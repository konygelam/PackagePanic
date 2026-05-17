import Foundation

protocol LevelSelectViewModelDelegate: AnyObject {
    func didSelectLevel(_ level: LevelModel)
    func levelsDidUpdate()
}

final class LevelSelectViewModel {
    weak var delegate: LevelSelectViewModelDelegate?
    
    private(set) var levels: [LevelModel] = []
    
    var totalStars: Int {
        return levels.reduce(0) { $0 + $1.starsEarned }
    }
    
    var maxStars: Int {
        return levels.count * 3
    }
    
    var unlockedLevelsCount: Int {
        return levels.filter { $0.isUnlocked }.count
    }
    
    init() {
        loadLevels()
    }
    
    func loadLevels() {
        levels = DataManager.shared.loadLevels()
        delegate?.levelsDidUpdate()
    }
    
    func selectLevel(at index: Int) {
        guard index < levels.count else { return }
        let level = levels[index]
        
        if level.isUnlocked {
            delegate?.didSelectLevel(level)
        }
    }
    
    func levelAt(index: Int) -> LevelModel? {
        guard index < levels.count else { return nil }
        return levels[index]
    }
    
    func refreshData() {
        loadLevels()
    }
}
