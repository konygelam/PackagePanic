import Foundation
import SpriteKit

struct ContainerModel {
    let side: ContainerSide
    let acceptedColors: [BoxColor]
    var position: CGPoint
    var size: CGSize
    var fillLevel: Int = 0
    var maxCapacity: Int = 10
    
    var isFull: Bool {
        return fillLevel >= maxCapacity
    }
    
    var fillPercentage: CGFloat {
        return CGFloat(fillLevel) / CGFloat(maxCapacity)
    }
    
    func accepts(box: BoxModel) -> Bool {
        return acceptedColors.contains(box.color)
    }
    
    mutating func addBox() {
        fillLevel = min(fillLevel + 1, maxCapacity)
    }
    
    mutating func reset() {
        fillLevel = 0
    }
}

struct ConveyorModel {
    let id: Int
    var position: CGPoint
    var width: CGFloat
    var speed: CGFloat
    var isActive: Bool = true
    var boxes: [BoxModel] = []
    
    mutating func addBox(_ box: BoxModel) {
        boxes.append(box)
    }
    
    mutating func removeBox(id: UUID) {
        boxes.removeAll { $0.id == id }
    }
}
