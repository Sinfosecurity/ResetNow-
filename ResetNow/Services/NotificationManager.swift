
import Foundation
import UserNotifications
import Combine

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isPermissionGranted = false
    
    private init() {
        checkPermissionStatus()
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.isPermissionGranted = granted
                if granted {
                    self.schedulePrayerNotifications()
                }
            }
        }
    }
    
    func checkPermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isPermissionGranted = (settings.authorizationStatus == .authorized)
            }
        }
    }
    
    func schedulePrayerNotifications() {
        // Clear existing prayer notifications to avoid duplicates
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let service = PrayerTimeService.shared
        // In a real app we'd schedule for the next few days. For simplicity, just today/tomorrow from the service.
        // We'll regenerate the list to ensure coverage
        service.calculatePrayersForToday() 
        let prayers = service.upcomingPrayers
        
        for prayer in prayers {
            scheduleNotification(for: prayer)
        }
    }
    
    private func scheduleNotification(for prayer: Prayer) {
        let calendar = Calendar.current
        let defaults = UserDefaults.standard
        let reminderEnabled = defaults.bool(forKey: "prayerReminderEnabled")
        let adhanEnabled = defaults.bool(forKey: "prayerAdhanEnabled")
        
        // 1. 15 Minutes Before
        let preTime = calendar.date(byAdding: .minute, value: -15, to: prayer.time)!
        if reminderEnabled && preTime > Date() {
            let preContent = UNMutableNotificationContent()
            preContent.title = "Upcoming Prayer: \(prayer.name)"
            preContent.body = "15 minutes remaining until \(prayer.name)."
            preContent.sound = .default
            
            let preComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: preTime)
            let preTrigger = UNCalendarNotificationTrigger(dateMatching: preComponents, repeats: false)
            let preRequest = UNNotificationRequest(identifier: "pre-\(prayer.id)", content: preContent, trigger: preTrigger)
            
            UNUserNotificationCenter.current().add(preRequest)
        }
        
        // 2. Exact Time (Adhan)
        if adhanEnabled && prayer.time > Date() {
            let adhanContent = UNMutableNotificationContent()
            adhanContent.title = "It's time for \(prayer.name)"
            adhanContent.body = "Call to Prayer (Adhan)"
            // Use the specific file we added to Resources (needs to be in Bundle)
            adhanContent.sound = UNNotificationSound(named: UNNotificationSoundName("adhan_short.aiff"))
            
            let adhanComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: prayer.time)
            let adhanTrigger = UNCalendarNotificationTrigger(dateMatching: adhanComponents, repeats: false)
            let adhanRequest = UNNotificationRequest(identifier: "adhan-\(prayer.id)", content: adhanContent, trigger: adhanTrigger)
            
            UNUserNotificationCenter.current().add(adhanRequest)
        }
    }
}
