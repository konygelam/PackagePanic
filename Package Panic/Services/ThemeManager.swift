import UIKit

final class ThemeManager {
    static let shared = ThemeManager()
    
    private(set) var currentTheme: AppColorTheme = .green
    
    var primaryColor: UIColor {
        return currentTheme.primaryColor
    }
    
    var secondaryColor: UIColor {
        return currentTheme.secondaryColor
    }
    
    var accentColor: UIColor {
        return currentTheme.accentColor
    }
    
    var buttonColor: UIColor {
        return currentTheme.buttonColor
    }
    
    var highlightColor: UIColor {
        return currentTheme.highlightColor
    }
    
    var backgroundColor: UIColor {
        return UIColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1.0)
    }
    
    var cardBackgroundColor: UIColor {
        return UIColor(white: 0.15, alpha: 1.0)
    }
    
    private init() {
        loadTheme()
    }
    
    func loadTheme() {
        let settings = DataManager.shared.loadSettings()
        currentTheme = settings.colorTheme
    }
    
    func applyTheme(_ theme: AppColorTheme) {
        currentTheme = theme
        NotificationCenter.default.post(name: .themeDidChange, object: nil)
    }
}

extension Notification.Name {
    static let themeDidChange = Notification.Name("themeDidChange")
}
