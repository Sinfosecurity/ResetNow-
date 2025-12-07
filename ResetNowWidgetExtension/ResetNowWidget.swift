//
//  ResetNowWidget.swift
//  ResetNowWidgetExtension
//
//  Home Screen and Lock Screen widgets for ResetNow
//

import WidgetKit
import SwiftUI

// MARK: - Widget Entry
struct AffirmationEntry: TimelineEntry {
    let date: Date
    let affirmation: String
    let category: String
}

// MARK: - Timeline Provider
struct AffirmationProvider: TimelineProvider {
    
    // Sample affirmations for widget
    private let affirmations = [
        ("I am enough, exactly as I am right now.", "Self Worth"),
        ("This feeling will pass. I am safe.", "Calm"),
        ("I have overcome challenges before. I will again.", "Strength"),
        ("Tomorrow is a fresh start.", "Hope"),
        ("I forgive myself for being imperfect.", "Self Compassion"),
        ("I breathe in calm, I breathe out tension.", "Calm"),
        ("I am worthy of rest and peace.", "Self Worth"),
        ("Good things are coming my way.", "Hope"),
        ("I am resilient, even when I don't feel like it.", "Strength"),
        ("I am doing the best I can with what I have.", "Self Compassion")
    ]
    
    func placeholder(in context: Context) -> AffirmationEntry {
        AffirmationEntry(
            date: Date(),
            affirmation: "I am enough, exactly as I am right now.",
            category: "Self Worth"
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (AffirmationEntry) -> Void) {
        let entry = getEntry(for: Date())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<AffirmationEntry>) -> Void) {
        var entries: [AffirmationEntry] = []
        let currentDate = Date()
        
        // Create entries for the next 24 hours (new affirmation every 6 hours)
        for hourOffset in stride(from: 0, to: 24, by: 6) {
            guard let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate) else { continue }
            let entry = getEntry(for: entryDate)
            entries.append(entry)
        }
        
        // Refresh timeline after 6 hours
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 6, to: currentDate)!
        let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func getEntry(for date: Date) -> AffirmationEntry {
        // Use day and hour to select affirmation
        let calendar = Calendar.current
        let day = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        let hour = calendar.component(.hour, from: date)
        let index = (day + hour / 6) % affirmations.count
        
        let (text, category) = affirmations[index]
        return AffirmationEntry(date: date, affirmation: text, category: category)
    }
}

// MARK: - Widget Views

// Small Widget
struct SmallWidgetView: View {
    let entry: AffirmationEntry
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(hex: "8BA888").opacity(0.4),
                    Color(hex: "B8A9C9").opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "8BA888"))
                    
                    Text("ResetNow")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "8A8A8A"))
                }
                
                Spacer()
                
                Text(entry.affirmation)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "2C3E50"))
                    .lineLimit(4)
                    .minimumScaleFactor(0.8)
            }
            .padding()
        }
        .widgetURL(URL(string: "resetnow://affirm"))
    }
}

// Medium Widget
struct MediumWidgetView: View {
    let entry: AffirmationEntry
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(hex: "FBF9F7"),
                    Color(hex: "FFE5D9").opacity(0.5)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            HStack(spacing: 16) {
                // Affirmation section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "8BA888"))
                        
                        Text("Today's Affirmation")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "8A8A8A"))
                    }
                    
                    Text(entry.affirmation)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color(hex: "2C3E50"))
                        .lineLimit(3)
                    
                    Text(entry.category)
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "8BA888"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color(hex: "8BA888").opacity(0.15))
                        )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Quick actions
                VStack(spacing: 8) {
                    QuickActionButton(icon: "wind", label: "Breathe", url: "resetnow://breathe")
                    QuickActionButton(icon: "moon.stars.fill", label: "Sleep", url: "resetnow://sleep")
                    QuickActionButton(icon: "bubble.left.fill", label: "Chat", url: "resetnow://chat")
                }
            }
            .padding()
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let label: String
    let url: String
    
    var body: some View {
        Link(destination: URL(string: url)!) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(label)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(Color(hex: "8BA888"))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
            )
        }
    }
}

// Lock Screen Widget (accessoryRectangular)
struct LockScreenWidgetView: View {
    let entry: AffirmationEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 10))
                Text("ResetNow")
                    .font(.system(size: 10, weight: .medium))
            }
            
            Text(entry.affirmation)
                .font(.system(size: 12, weight: .medium))
                .lineLimit(2)
        }
        .widgetURL(URL(string: "resetnow://affirm"))
    }
}

// MARK: - Main Widget
@main
struct ResetNowWidget: Widget {
    let kind: String = "ResetNowWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AffirmationProvider()) { entry in
            WidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Daily Affirmation")
        .description("See today's affirmation and quick access to ResetNow tools.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}

struct WidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: AffirmationEntry
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .accessoryRectangular:
            LockScreenWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Color Extension for Widget
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Previews
#Preview(as: .systemSmall) {
    ResetNowWidget()
} timeline: {
    AffirmationEntry(date: .now, affirmation: "I am enough, exactly as I am right now.", category: "Self Worth")
}

#Preview(as: .systemMedium) {
    ResetNowWidget()
} timeline: {
    AffirmationEntry(date: .now, affirmation: "This feeling will pass. I am safe.", category: "Calm")
}

#Preview(as: .accessoryRectangular) {
    ResetNowWidget()
} timeline: {
    AffirmationEntry(date: .now, affirmation: "I have overcome challenges before.", category: "Strength")
}

