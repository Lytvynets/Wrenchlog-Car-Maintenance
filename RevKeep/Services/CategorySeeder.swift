

import Foundation
import SwiftData

enum CategorySeeder {
    static func seedIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<ServiceCategory>()
        let existingCount = (try? context.fetchCount(descriptor)) ?? 0
        guard existingCount == 0 else { return }

        let defaults: [(name: String, symbol: String, mileage: Int, months: Int)] = [
            ("Oil change", "drop.fill", 10_000, 6),
            ("Tires", "circle.dashed", 40_000, 24),
            ("Brakes", "octagon.fill", 25_000, 18),
            ("Battery", "bolt.fill", 60_000, 36),
            ("Filter", "line.3.horizontal.decrease.circle", 15_000, 12),
            ("Other", "wrench.and.screwdriver.fill", 10_000, 6)
        ]

        for item in defaults {
            context.insert(ServiceCategory(
                name: item.name,
                symbolName: item.symbol,
                defaultMileageInterval: item.mileage,
                defaultMonthsInterval: item.months,
                isBuiltIn: true
            ))
        }

        try? context.save()
    }
}
