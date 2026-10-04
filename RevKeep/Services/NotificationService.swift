

import Foundation
import UserNotifications

enum NotificationPermissionRequester {
    static func requestIfNeeded() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, error in
            if let error {
                print("Wrenchlog: notification permission error — \(error)")
            }
        }
    }
}

enum ReminderNotificationScheduler {
    
    static func schedule(for entry: ServiceEntry, vehicle: Vehicle) {
        guard let monthsInterval = entry.nextServiceMonthsInterval,
              let dueDate = Calendar.current.date(byAdding: .month, value: monthsInterval, to: entry.date) else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "\(vehicle.displayName) — service due soon"
        content.body = "\(entry.category?.name ?? "Service") is due around \(dueDate.formatted(date: .abbreviated, time: .omitted))."
        content.sound = .default
        
        var triggerDate = Calendar.current.date(byAdding: .day, value: -3, to: dueDate) ?? dueDate
        if triggerDate < .now {
            triggerDate = .now.addingTimeInterval(60)
        }
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: entry.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Wrenchlog: failed to schedule reminder — \(error)")
            }
        }
    }
    
    static func cancel(for entry: ServiceEntry) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [entry.id.uuidString])
    }
    
    static func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    
    static func rescheduleAll(vehicles: [Vehicle]) {
        for vehicle in vehicles {
            for entry in vehicle.serviceEntries {
                schedule(for: entry, vehicle: vehicle)
            }
        }
    }
}
