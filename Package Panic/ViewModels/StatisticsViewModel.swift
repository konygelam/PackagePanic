import Foundation
import UIKit

final class StatisticsViewModel {
    private let statistics: GameStatistics
    
    init(statistics: GameStatistics) {
        self.statistics = statistics
    }
    
    var deliveredCount: String {
        return "\(statistics.deliveredCount)"
    }
    
    var lostCount: String {
        return "\(statistics.lostCount)"
    }
    
    var wrongContainerCount: String {
        return "\(statistics.wrongContainerCount)"
    }
    
    var totalScore: String {
        return "\(statistics.totalScore)"
    }
    
    var accuracy: String {
        return String(format: "%.1f%%", statistics.accuracy)
    }
    
    var workerRating: String {
        return statistics.workerRating
    }
    
    var stars: Int {
        return statistics.stars
    }
    
    var maxCombo: String {
        return "\(statistics.maxCombo)x"
    }
    
    var vipDelivered: String {
        return "\(statistics.vipDelivered)"
    }
    
    var qrScanned: String {
        return "\(statistics.qrScanned)"
    }
    
    var shiftDuration: String {
        let minutes = Int(statistics.shiftDuration) / 60
        let seconds = Int(statistics.shiftDuration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var ratingColor: UIColor {
        switch statistics.stars {
        case 5: return UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        case 4: return UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0)
        case 3: return UIColor(red: 0.8, green: 0.5, blue: 0.2, alpha: 1.0)
        case 2: return UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        default: return UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        }
    }
}
