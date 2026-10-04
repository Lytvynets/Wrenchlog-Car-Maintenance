

import Foundation
import SwiftData

@Model
final class ServiceCategory {
    var id: UUID
    var name: String
    var symbolName: String
    var defaultMileageInterval: Int
    var defaultMonthsInterval: Int
    var isBuiltIn: Bool
    var createdAt: Date

    init(
        name: String,
        symbolName: String,
        defaultMileageInterval: Int,
        defaultMonthsInterval: Int,
        isBuiltIn: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.symbolName = symbolName
        self.defaultMileageInterval = defaultMileageInterval
        self.defaultMonthsInterval = defaultMonthsInterval
        self.isBuiltIn = isBuiltIn
        self.createdAt = .now
    }
}
