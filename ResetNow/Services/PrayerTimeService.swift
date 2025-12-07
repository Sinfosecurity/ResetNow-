
import Foundation
import CoreLocation

// MARK: - Prayer Times Service
class PrayerTimeService: ObservableObject {
    static let shared = PrayerTimeService()
    
    @Published var upcomingPrayers: [Prayer] = []
    @Published var nextPrayer: Prayer?
    
    private init() {
        calculatePrayersForToday()
    }
    
    func calculatePrayersForToday() {
        // In a real app, we would use CoreLocation to get coordinates.
        // For this MVP/Demo, we'll use a fixed location (e.g., New York City) 
        // or a default if permission isn't granted yet.
        // 40.7128° N, 74.0060° W
        let coordinates = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        let date = Date()
        
        self.upcomingPrayers = PrayerCalculator.calculate(for: date, coordinates: coordinates)
        updateNextPrayer()
    }
    
    func updateNextPrayer() {
        let now = Date()
        // Filter for prayers that extend into the future
        // We might need to calculate tomorrow's fajr if all today's are passed
        if let next = upcomingPrayers.first(where: { $0.time > now }) {
            self.nextPrayer = next
        } else {
            // Calculate for tomorrow
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
            let coordinates = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
            let tomorrowPrayers = PrayerCalculator.calculate(for: tomorrow, coordinates: coordinates)
            self.nextPrayer = tomorrowPrayers.first
        }
    }
}

// MARK: - Models
struct Prayer: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let time: Date
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
}

// MARK: - Calculation Logic (Simplified)
struct PrayerCalculator {
    static func calculate(for date: Date, coordinates: CLLocationCoordinate2D) -> [Prayer] {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        
        // This is a SIMULATED calculation for demonstration purposes.
        // A full astronomical calculation is quite complex (Sun position, etc.)
        // For the purpose of this task (integrating flows), we will mock realistic times relative to dawn/dusk
        // based on the provided date.
        
        // Let's assume:
        // Fajr: 05:00 AM
        // Dhuhr: 01:00 PM
        // Asr: 04:30 PM
        // Maghrib: 07:00 PM
        // Isha: 08:30 PM
        
        // In a production version, we would implement the full equation or use a library like Adhan-swift.
        
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        func makeDate(hour: Int, minute: Int) -> Date {
            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = day
            components.hour = hour
            components.minute = minute
            return calendar.date(from: components) ?? date
        }
        
        return [
            Prayer(name: "Fajr", time: makeDate(hour: 5, minute: 0)),
            Prayer(name: "Dhuhr", time: makeDate(hour: 13, minute: 0)),
            Prayer(name: "Asr", time: makeDate(hour: 16, minute: 30)),
            Prayer(name: "Maghrib", time: makeDate(hour: 19, minute: 0)),
            Prayer(name: "Isha", time: makeDate(hour: 20, minute: 30))
        ]
    }
}
