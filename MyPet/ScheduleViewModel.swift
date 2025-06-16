import Foundation
import UserNotifications
import SwiftUI

class ScheduleViewModel: ObservableObject {
    @Published var scheduleItems: [ScheduleItem] = []

    func addSchedule(title: String, date: Date) {
        let newItem = ScheduleItem(id: UUID(), title: title, date: date)
        scheduleItems.append(newItem)
        scheduleNotification(for: newItem)
    }

    func removeSchedule(at offsets: IndexSet) {
        for index in offsets {
            let item = scheduleItems[index]
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [item.id.uuidString])
        }
        scheduleItems.remove(atOffsets: offsets)
    }

    func removeScheduleById(_ id: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
        scheduleItems.removeAll { $0.id == id }
    }

    private func scheduleNotification(for item: ScheduleItem) {
        let content = UNMutableNotificationContent()
        content.title = "알람"
        content.body = item.title
        content.sound = .default
        content.categoryIdentifier = "ALARM_CATEGORY"

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: item.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(identifier: item.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("알림 등록 실패: \(error.localizedDescription)")
            } else {
                print("✅ 알림 등록 성공!")
            }
        }
    }
}
