import Foundation

protocol MenuViewModelDelegate: AnyObject {
    func didSelectPlay()
    func didSelectHighScores()
    func didSelectSettings()
}

final class MenuViewModel {
    weak var delegate: MenuViewModelDelegate?
    
    private(set) var highScores: [HighScoreEntry] = []
    private(set) var isSoundEnabled: Bool = true
    private(set) var isMusicEnabled: Bool = true
    private(set) var isHapticsEnabled: Bool = true
    
    init() {
        loadSettings()
        loadHighScores()
    }
    
    func playButtonTapped() {
        delegate?.didSelectPlay()
    }
    
    func highScoresButtonTapped() {
        delegate?.didSelectHighScores()
    }
    
    func settingsButtonTapped() {
        delegate?.didSelectSettings()
    }
    
    func toggleSound() {
        isSoundEnabled.toggle()
        saveSettings()
    }
    
    func toggleMusic() {
        isMusicEnabled.toggle()
        saveSettings()
    }
    
    func toggleHaptics() {
        isHapticsEnabled.toggle()
        saveSettings()
    }
    
    private func loadSettings() {
        isSoundEnabled = UserDefaults.standard.object(forKey: "soundEnabled") as? Bool ?? true
        isMusicEnabled = UserDefaults.standard.object(forKey: "musicEnabled") as? Bool ?? true
        isHapticsEnabled = UserDefaults.standard.object(forKey: "hapticsEnabled") as? Bool ?? true
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(isSoundEnabled, forKey: "soundEnabled")
        UserDefaults.standard.set(isMusicEnabled, forKey: "musicEnabled")
        UserDefaults.standard.set(isHapticsEnabled, forKey: "hapticsEnabled")
    }
    
    private func loadHighScores() {
        guard let data = UserDefaults.standard.data(forKey: "highScores"),
              let scores = try? JSONDecoder().decode([HighScoreEntry].self, from: data) else {
            highScores = []
            return
        }
        highScores = scores
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
