import Foundation

protocol SettingsViewModelDelegate: AnyObject {
    func settingsDidChange()
    func didRequestResetConfirmation()
    func didCompleteReset()
}

final class SettingsViewModel {
    weak var delegate: SettingsViewModelDelegate?
    
    private(set) var settings: SettingsModel
    
    var currentTheme: AppColorTheme {
        return settings.colorTheme
    }
    
    var isHapticsEnabled: Bool {
        return settings.isHapticsEnabled
    }
    
    var isSoundEnabled: Bool {
        return settings.isSoundEnabled
    }
    
    var isMusicEnabled: Bool {
        return settings.isMusicEnabled
    }
    
    var allThemes: [AppColorTheme] {
        return AppColorTheme.allCases
    }
    
    init() {
        settings = DataManager.shared.loadSettings()
    }
    
    func setColorTheme(_ theme: AppColorTheme) {
        settings.colorTheme = theme
        saveSettings()
        ThemeManager.shared.applyTheme(theme)
        delegate?.settingsDidChange()
    }
    
    func toggleHaptics() {
        settings.isHapticsEnabled.toggle()
        saveSettings()
        HapticsManager.shared.setEnabled(settings.isHapticsEnabled)
        delegate?.settingsDidChange()
    }
    
    func toggleSound() {
        settings.isSoundEnabled.toggle()
        saveSettings()
        AudioManager.shared.setSoundEnabled(settings.isSoundEnabled)
        delegate?.settingsDidChange()
    }
    
    func toggleMusic() {
        settings.isMusicEnabled.toggle()
        saveSettings()
        AudioManager.shared.setMusicEnabled(settings.isMusicEnabled)
        delegate?.settingsDidChange()
    }
    
    func requestReset() {
        delegate?.didRequestResetConfirmation()
    }
    
    func confirmReset() {
        DataManager.shared.resetAllData()
        settings = SettingsModel()
        saveSettings()
        ThemeManager.shared.applyTheme(settings.colorTheme)
        delegate?.didCompleteReset()
    }
    
    private func saveSettings() {
        DataManager.shared.saveSettings(settings)
    }
    
    func refresh() {
        settings = DataManager.shared.loadSettings()
    }
}
