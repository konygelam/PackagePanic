import UIKit

enum AppColorTheme: String, CaseIterable, Codable {
    case blue
    case green
    case purple
    case orange
    case red
    case pink
    case teal
    case yellow
    
    var displayName: String {
        switch self {
        case .blue: return "Ocean Blue"
        case .green: return "Forest Green"
        case .purple: return "Royal Purple"
        case .orange: return "Sunset Orange"
        case .red: return "Cherry Red"
        case .pink: return "Bubblegum Pink"
        case .teal: return "Teal Wave"
        case .yellow: return "Golden Sun"
        }
    }
    
    var primaryColor: UIColor {
        switch self {
        case .blue: return UIColor(red: 0.2, green: 0.5, blue: 0.95, alpha: 1.0)
        case .green: return UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0)
        case .purple: return UIColor(red: 0.6, green: 0.3, blue: 0.9, alpha: 1.0)
        case .orange: return UIColor(red: 0.95, green: 0.5, blue: 0.2, alpha: 1.0)
        case .red: return UIColor(red: 0.9, green: 0.25, blue: 0.3, alpha: 1.0)
        case .pink: return UIColor(red: 0.95, green: 0.4, blue: 0.6, alpha: 1.0)
        case .teal: return UIColor(red: 0.2, green: 0.75, blue: 0.75, alpha: 1.0)
        case .yellow: return UIColor(red: 0.95, green: 0.8, blue: 0.2, alpha: 1.0)
        }
    }
    
    var secondaryColor: UIColor {
        return primaryColor.withAlphaComponent(0.7)
    }
    
    var accentColor: UIColor {
        return primaryColor.withAlphaComponent(0.3)
    }
    
    var buttonColor: UIColor {
        return primaryColor
    }
    
    var highlightColor: UIColor {
        switch self {
        case .blue: return UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 1.0)
        case .green: return UIColor(red: 0.3, green: 0.9, blue: 0.5, alpha: 1.0)
        case .purple: return UIColor(red: 0.7, green: 0.4, blue: 1.0, alpha: 1.0)
        case .orange: return UIColor(red: 1.0, green: 0.6, blue: 0.3, alpha: 1.0)
        case .red: return UIColor(red: 1.0, green: 0.35, blue: 0.4, alpha: 1.0)
        case .pink: return UIColor(red: 1.0, green: 0.5, blue: 0.7, alpha: 1.0)
        case .teal: return UIColor(red: 0.3, green: 0.85, blue: 0.85, alpha: 1.0)
        case .yellow: return UIColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0)
        }
    }
}

struct SettingsModel: Codable {
    var colorTheme: AppColorTheme = .green
    var isHapticsEnabled: Bool = true
    var isSoundEnabled: Bool = true
    var isMusicEnabled: Bool = true
}
