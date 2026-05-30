import AVFoundation

final class AudioManager {
    static let shared = AudioManager()
    
    private var soundPlayers: [String: AVAudioPlayer] = [:]
    private var isSoundEnabled: Bool = true
    private var isMusicEnabled: Bool = true
    
    private init() {
        loadSettings()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
        }
    }
    
    private func loadSettings() {
        isSoundEnabled = UserDefaults.standard.object(forKey: "soundEnabled") as? Bool ?? true
        isMusicEnabled = UserDefaults.standard.object(forKey: "musicEnabled") as? Bool ?? true
    }
    
    func playSwipeSound() {
        guard isSoundEnabled else { return }
        playSystemSound(id: 1104)
    }
    
    func playCorrectSound() {
        guard isSoundEnabled else { return }
        playSystemSound(id: 1057)
    }
    
    func playWrongSound() {
        guard isSoundEnabled else { return }
        playSystemSound(id: 1053)
    }
    
    func playScanSound() {
        guard isSoundEnabled else { return }
        playSystemSound(id: 1110)
    }
    
    func playComboSound() {
        guard isSoundEnabled else { return }
        playSystemSound(id: 1025)
    }
    
    func playGameOverSound() {
        guard isSoundEnabled else { return }
        playSystemSound(id: 1073)
    }
    
    private func playSystemSound(id: SystemSoundID) {
        AudioServicesPlaySystemSound(id)
    }
    
    func setSoundEnabled(_ enabled: Bool) {
        isSoundEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "soundEnabled")
    }
    
    func setMusicEnabled(_ enabled: Bool) {
        isMusicEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "musicEnabled")
    }
}
