

import Foundation

enum ServiceStatus {
    case ok, dueSoon, overdue

    var healthValue: Double {
        switch self {
        case .ok: return 1.0
        case .dueSoon: return 0.65
        case .overdue: return 0.15
        }
    }
}

enum ReminderCalculator {

    static func averageDailyDistance(for vehicle: Vehicle) -> Double {
        guard let firstEntry = vehicle.serviceEntries.min(by: { $0.date < $1.date }) else {
            return 40
        }
        let days = max(Date.now.timeIntervalSince(firstEntry.date) / 86_400, 1)
        let distanceCovered = Double(vehicle.currentMileage - firstEntry.mileageAtService)
        guard distanceCovered > 0 else { return 40 }
        return distanceCovered / days
    }

    static func status(for entry: ServiceEntry, vehicle: Vehicle) -> ServiceStatus {
        var isOverdue = false
        var isDueSoon = false

        if let mileageInterval = entry.nextServiceMileageInterval {
            let dueAtMileage = entry.mileageAtService + mileageInterval
            let remaining = dueAtMileage - vehicle.currentMileage
            if remaining <= 0 { isOverdue = true }
            else if Double(remaining) <= 500 { isDueSoon = true }
        }

        if let monthsInterval = entry.nextServiceMonthsInterval,
           let dueDate = Calendar.current.date(byAdding: .month, value: monthsInterval, to: entry.date) {
            let daysRemaining = Calendar.current.dateComponents([.day], from: .now, to: dueDate).day ?? 0
            if daysRemaining <= 0 { isOverdue = true }
            else if daysRemaining <= 14 { isDueSoon = true }
        }

        if isOverdue { return .overdue }
        if isDueSoon { return .dueSoon }
        return .ok
    }


    static func daysUntilNextService(for vehicle: Vehicle) -> Int? {
        let dailyDistance = averageDailyDistance(for: vehicle)
        var soonestDays: Int?

        for entry in vehicle.serviceEntries {
            var candidateDays: [Int] = []

            if let mileageInterval = entry.nextServiceMileageInterval, dailyDistance > 0 {
                let dueAtMileage = entry.mileageAtService + mileageInterval
                let remainingDistance = Double(dueAtMileage - vehicle.currentMileage)
                candidateDays.append(Int(remainingDistance / dailyDistance))
            }

            if let monthsInterval = entry.nextServiceMonthsInterval,
               let dueDate = Calendar.current.date(byAdding: .month, value: monthsInterval, to: entry.date) {
                let days = Calendar.current.dateComponents([.day], from: .now, to: dueDate).day ?? 0
                candidateDays.append(days)
            }

            if let smallest = candidateDays.min() {
                soonestDays = min(soonestDays ?? smallest, smallest)
            }
        }
        return soonestDays
    }


    static func healthValue(for vehicle: Vehicle) -> Double {
        guard !vehicle.serviceEntries.isEmpty else { return 1.0 }
        let worst = vehicle.serviceEntries
            .map { status(for: $0, vehicle: vehicle) }
            .min { $0.healthValue < $1.healthValue }
        return worst?.healthValue ?? 1.0
    }
}
