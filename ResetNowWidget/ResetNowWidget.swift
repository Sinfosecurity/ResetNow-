//
//  ResetNowWidget.swift
//  ResetNowWidget
//
//  Daily affirmations widget for ResetNow
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Provider (Simple version for reliability)
struct Provider: TimelineProvider {
    
    private let affirmations = [
        "You are worthy of peace and calm.",
        "Take a deep breath. You've got this.",
        "Progress, not perfection.",
        "Your feelings are valid.",
        "One moment at a time.",
        "You are stronger than you know.",
        "Be gentle with yourself today.",
        "You deserve moments of stillness.",
        "Every small step counts.",
        "You are doing better than you think.",
        "This moment is a fresh start.",
        "Your calm is your superpower.",
        "You are capable of handling today.",
        "Peace begins with a single breath.",
        "You are enough, just as you are."
    ]
    
    func placeholder(in context: Context) -> AffirmationEntry {
        AffirmationEntry(date: Date(), affirmation: "You are worthy of peace and calm.")
    }

    func getSnapshot(in context: Context, completion: @escaping (AffirmationEntry) -> Void) {
        let entry = AffirmationEntry(date: Date(), affirmation: affirmations.randomElement() ?? affirmations[0])
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<AffirmationEntry>) -> Void) {
        var entries: [AffirmationEntry] = []
        let currentDate = Date()
        
        // Update every 4 hours with new affirmation
        for hourOffset in stride(from: 0, to: 24, by: 4) {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = AffirmationEntry(
                date: entryDate,
                affirmation: affirmations[hourOffset / 4 % affirmations.count]
            )
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

// MARK: - Timeline Entry
struct AffirmationEntry: TimelineEntry {
    let date: Date
    let affirmation: String
}

// MARK: - Widget Views
struct ResetNowWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Small Widget
struct SmallWidgetView: View {
    var entry: AffirmationEntry
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [Color(hex: "4B2E83"), Color(hex: "1E1B4B")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(alignment: .leading, spacing: 10) {
                // Header
                HStack {
                    Image(systemName: "leaf.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "2DD4BF"))
                    
                    Spacer()
                }
                
                Spacer()
                
                // Affirmation - LARGER FONT
                Text(entry.affirmation)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(4)
                    .minimumScaleFactor(0.75)
            }
            .padding(16)
        }
    }
}

// MARK: - Medium Widget
struct MediumWidgetView: View {
    var entry: AffirmationEntry
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "4B2E83"), Color(hex: "1E1B4B")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            HStack(spacing: 16) {
                // Affirmation side
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "leaf.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Color(hex: "2DD4BF"))
                        
                        Text("ResetNow")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text(entry.affirmation)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Quick actions
                VStack(spacing: 10) {
                    QuickActionButton(icon: "wind", label: "Breathe", color: Color(hex: "0D9488"))
                    QuickActionButton(icon: "moon.stars.fill", label: "Sleep", color: Color(hex: "4F46E5"))
                    QuickActionButton(icon: "heart.fill", label: "SOS", color: Color(hex: "EF4444"))
                }
                .frame(width: 95)
            }
            .padding(16)
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let label: String
    let color: Color
    
    var destination: URL {
        switch label {
        case "Breathe": return URL(string: "resetnow://breathe")!
        case "Sleep": return URL(string: "resetnow://sleep")!
        case "SOS": return URL(string: "resetnow://sos")!
        default: return URL(string: "resetnow://home")!
        }
    }
    
    var body: some View {
        Link(destination: destination) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(color.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

// MARK: - Large Widget
struct LargeWidgetView: View {
    var entry: AffirmationEntry
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "4B2E83"), Color(hex: "312E81"), Color(hex: "1E1B4B")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Image(systemName: "leaf.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(Color(hex: "2DD4BF"))
                    
                    Text("ResetNow")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                
                // Affirmation card
                VStack(spacing: 12) {
                    Image(systemName: "quote.opening")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "2DD4BF").opacity(0.8))
                    
                    Text(entry.affirmation)
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(Color.white.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Spacer()
                
                // Quick action grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    LargeQuickAction(icon: "wind", label: "Breathe", color: Color(hex: "0D9488"))
                    LargeQuickAction(icon: "gamecontroller.fill", label: "Games", color: Color(hex: "DB2777"))
                    LargeQuickAction(icon: "moon.stars.fill", label: "Sleep", color: Color(hex: "4F46E5"))
                    LargeQuickAction(icon: "sun.max.fill", label: "Affirm", color: Color(hex: "D97706"))
                    LargeQuickAction(icon: "message.fill", label: "Chat", color: Color(hex: "2563EB"))
                    LargeQuickAction(icon: "heart.fill", label: "SOS", color: Color(hex: "EF4444"))
                }
            }
            .padding(18)
        }
    }
}

struct LargeQuickAction: View {
    let icon: String
    let label: String
    let color: Color
    
    var destination: URL {
        switch label {
        case "Breathe": return URL(string: "resetnow://breathe")!
        case "Games": return URL(string: "resetnow://games")!
        case "Sleep": return URL(string: "resetnow://sleep")!
        case "Affirm": return URL(string: "resetnow://affirm")!
        case "Chat": return URL(string: "resetnow://chat")!
        case "SOS": return URL(string: "resetnow://sos")!
        default: return URL(string: "resetnow://home")!
        }
    }
    
    var body: some View {
        Link(destination: destination) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(color.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

// MARK: - Widget Configuration
struct ResetNowWidget: Widget {
    let kind: String = "ResetNowWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ResetNowWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    LinearGradient(
                        colors: [Color(hex: "4B2E83"), Color(hex: "1E1B4B")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
        }
        .configurationDisplayName("ResetNow")
        .description("Daily affirmations and quick access to calm.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Color Extension
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
            (a, r, g, b) = (255, 128, 128, 128)
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

// MARK: - Preview
#Preview(as: .systemSmall) {
    ResetNowWidget()
} timeline: {
    AffirmationEntry(date: .now, affirmation: "You are worthy of peace and calm.")
}

#Preview(as: .systemMedium) {
    ResetNowWidget()
} timeline: {
    AffirmationEntry(date: .now, affirmation: "Take a deep breath. You've got this.")
}

#Preview(as: .systemLarge) {
    ResetNowWidget()
} timeline: {
    AffirmationEntry(date: .now, affirmation: "Every small step counts. Be gentle with yourself.")
}
