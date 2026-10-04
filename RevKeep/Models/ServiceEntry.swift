
import Foundation
import SwiftData

@Model
final class ServiceEntry {
    var id: UUID
    var vehicle: Vehicle?
    var category: ServiceCategory?
    var date: Date
    var mileageAtService: Int
    var cost: Decimal
    var notes: String?
    var receiptPhotoData: Data?
    var nextServiceMileageInterval: Int?
    var nextServiceMonthsInterval: Int?

    init(
        vehicle: Vehicle?,
        category: ServiceCategory?,
        date: Date,
        mileageAtService: Int,
        cost: Decimal,
        notes: String? = nil,
        receiptPhotoData: Data? = nil,
        nextServiceMileageInterval: Int? = nil,
        nextServiceMonthsInterval: Int? = nil
    ) {
        self.id = UUID()
        self.vehicle = vehicle
        self.category = category
        self.date = date
        self.mileageAtService = mileageAtService
        self.cost = cost
        self.notes = notes
        self.receiptPhotoData = receiptPhotoData
        self.nextServiceMileageInterval = nextServiceMileageInterval ?? category?.defaultMileageInterval ?? 10_000
        self.nextServiceMonthsInterval = nextServiceMonthsInterval ?? category?.defaultMonthsInterval ?? 6
    }
}
