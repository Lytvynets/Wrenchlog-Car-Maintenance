

import Foundation

enum ExportService {

    static func makeCSV(vehicles: [Vehicle]) -> String {
        var lines = ["Car,Category,Date,Mileage,Cost,Notes"]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let allEntries = vehicles.flatMap { vehicle in
            vehicle.serviceEntries.map { (vehicle, $0) }
        }
        .sorted { $0.1.date < $1.1.date }

        for (vehicle, entry) in allEntries {
            let fields = [
                vehicle.displayName,
                entry.category?.name ?? "Other",
                dateFormatter.string(from: entry.date),
                "\(entry.mileageAtService)",
                "\(entry.cost)",
                entry.notes ?? ""
            ]
            lines.append(fields.map(csvEscape).joined(separator: ","))
        }
        return lines.joined(separator: "\n")
    }

 
    static func writeCSVFile(vehicles: [Vehicle]) -> URL? {
        let csv = makeCSV(vehicles: vehicles)
        let filename = "Wrenchlog-export-\(Int(Date.now.timeIntervalSince1970)).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            print("ExportService: failed to write CSV — \(error)")
            return nil
        }
    }

    private static func csvEscape(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            return "\"\(field.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return field
    }
}
