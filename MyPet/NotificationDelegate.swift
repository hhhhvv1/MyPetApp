import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "STOP_ACTION" {
            let id = response.notification.request.identifier
            print("🔕 알람 해제 버튼 눌림 - ID: \(id)")
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        }
        completionHandler()
    }
}
