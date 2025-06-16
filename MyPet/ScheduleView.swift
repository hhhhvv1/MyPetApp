import SwiftUI
import UserNotifications

struct ScheduleView: View {
    @StateObject private var viewModel = ScheduleViewModel()
    @State private var title: String = ""
    @State private var date: Date = Date()

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    TextField("일정 제목", text: $title)
                    DatePicker("시간 설정", selection: $date, displayedComponents: [.date, .hourAndMinute])

                    Button("일정 추가") {
                        viewModel.addSchedule(title: title, date: date)
                        title = ""
                        date = Date()
                    }
                    .disabled(title.isEmpty)
                }

                List {
                    ForEach(viewModel.scheduleItems) { item in
                        VStack(alignment: .leading) {
                            Text(item.title)
                                .font(.headline)
                            Text(item.date, style: .date)
                            Text(item.date, style: .time)
                        }
                        .contextMenu {
                            Button("알람 해제") {
                                viewModel.removeScheduleById(item.id)
                            }
                        }
                    }
                    .onDelete(perform: viewModel.removeSchedule)
                }
            }
            .navigationTitle("일정 알림")
            .onAppear {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if let error = error {
                        print("알림 권한 오류: \(error.localizedDescription)")
                    }
                    print("알림 권한: \(granted)")

                    let stopAction = UNNotificationAction(identifier: "STOP_ACTION", title: "알람 해제", options: [.destructive])
                    let category = UNNotificationCategory(identifier: "ALARM_CATEGORY", actions: [stopAction], intentIdentifiers: [], options: [])
                    UNUserNotificationCenter.current().setNotificationCategories([category])
                }
            }
        }
    }
}
