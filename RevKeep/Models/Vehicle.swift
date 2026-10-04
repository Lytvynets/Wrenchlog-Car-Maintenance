

import Foundation
import SwiftData

enum DistanceUnit: String, Codable, CaseIterable, Hashable {
    case km, mi

    var shortLabel: String { self == .km ? "km" : "mi" }
}

@Model
final class Vehicle {
    var id: UUID
    var make: String
    var model: String
    var year: Int
    var vin: String?
    var licensePlate: String?
    var photoData: Data?
    var currentMileage: Int
    var distanceUnit: DistanceUnit
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \ServiceEntry.vehicle)
    var serviceEntries: [ServiceEntry] = []

    init(
        make: String,
        model: String,
        year: Int,
        vin: String? = nil,
        licensePlate: String? = nil,
        photoData: Data? = nil,
        currentMileage: Int = 0,
        distanceUnit: DistanceUnit = .km
    ) {
        self.id = UUID()
        self.make = make
        self.model = model
        self.year = year
        self.vin = vin
        self.licensePlate = licensePlate
        self.photoData = photoData
        self.currentMileage = currentMileage
        self.distanceUnit = distanceUnit
        self.createdAt = .now
    }

    var displayName: String { "\(make) \(model)" }
}
