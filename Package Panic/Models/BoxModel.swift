import Foundation
import SpriteKit

enum BoxColor: String, CaseIterable {
    case red
    case blue
    case green
    case yellow
    case purple
    case orange
    
    var uiColor: UIColor {
        switch self {
        case .red: return UIColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 1.0)
        case .blue: return UIColor(red: 0.2, green: 0.4, blue: 0.9, alpha: 1.0)
        case .green: return UIColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 1.0)
        case .yellow: return UIColor(red: 0.95, green: 0.8, blue: 0.1, alpha: 1.0)
        case .purple: return UIColor(red: 0.6, green: 0.2, blue: 0.8, alpha: 1.0)
        case .orange: return UIColor(red: 0.95, green: 0.5, blue: 0.1, alpha: 1.0)
        }
    }
}

enum BoxShape: CaseIterable {
    case square
    case rectangle
    case tall
    
    var size: CGSize {
        switch self {
        case .square: return CGSize(width: 60, height: 60)
        case .rectangle: return CGSize(width: 80, height: 50)
        case .tall: return CGSize(width: 50, height: 80)
        }
    }
}

enum BoxSticker: String, CaseIterable {
    case none
    case fragile
    case doNotTouch
    case liveBees
    case topSecret
    case thisWayUp
    case handle
    case rush
    
    var displayText: String {
        switch self {
        case .none: return ""
        case .fragile: return "FRAGILE"
        case .doNotTouch: return "DO NOT TOUCH"
        case .liveBees: return "LIVE BEES"
        case .topSecret: return "TOP SECRET"
        case .thisWayUp: return "THIS WAY UP"
        case .handle: return "HANDLE WITH CARE"
        case .rush: return "RUSH"
        }
    }
}

enum BoxType {
    case normal
    case dangerous
    case vip
    case qrRequired
    case decoy
    
    var multiplier: Double {
        switch self {
        case .normal: return 1.0
        case .dangerous: return 0.0
        case .vip: return 3.0
        case .qrRequired: return 2.0
        case .decoy: return 0.5
        }
    }
}

struct BoxModel: Identifiable {
    let id: UUID
    let color: BoxColor
    let shape: BoxShape
    let sticker: BoxSticker
    let type: BoxType
    let targetContainer: ContainerSide
    var vipTimer: TimeInterval?
    var isScanned: Bool
    var position: CGPoint
    var velocity: CGFloat
    
    init(
        color: BoxColor,
        shape: BoxShape,
        sticker: BoxSticker = .none,
        type: BoxType = .normal,
        targetContainer: ContainerSide,
        vipTimer: TimeInterval? = nil,
        position: CGPoint = .zero,
        velocity: CGFloat = 100
    ) {
        self.id = UUID()
        self.color = color
        self.shape = shape
        self.sticker = sticker
        self.type = type
        self.targetContainer = targetContainer
        self.vipTimer = vipTimer
        self.isScanned = type != .qrRequired
        self.position = position
        self.velocity = velocity
    }
}

enum ContainerSide {
    case left
    case right
}
