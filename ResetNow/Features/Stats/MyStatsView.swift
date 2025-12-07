//
//  MyStatsView.swift
//  ResetNow
//
//  Progress tracking with streaks and usage stats
//

import SwiftUI

struct MyStatsView: View {
    @EnvironmentObject var persistence: PersistenceController
    @Environment(\.colorScheme) var colorScheme
    @State private var animateStats = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ResetSpacing.lg) {
                    streakCard
                    weeklyOverviewCard
                    toolUsageSection
                    encouragementSection
                }
                .padding(.horizontal, ResetSpacing.md)
                .padding(.bottom, ResetSpacing.xxl)
            }
            .scrollContentBackground(.hidden)
            .background(Color(.systemBackground).ignoresSafeArea())
            .toolbarBackground(Color(.systemBackground), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationTitle("My Stats")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6)) {
                animateStats = true
            }
        }
    }
    
    // MARK: - Streak Card
    private var streakCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [Color.warmPeach.opacity(0.7), Color.warmPeach.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Decorative elements
            HStack {
                Spacer()
                VStack {
                    ForEach(0..<3, id: \.self) { i in
                        Image(systemName: "flame.fill")
                            .font(.system(size: 30 - CGFloat(i * 8)))
                            .foregroundColor(.white.opacity(0.2 - Double(i) * 0.05))
                            .offset(x: CGFloat(i * 10), y: CGFloat(i * -5))
                    }
                    Spacer()
                }
                .padding(.top, ResetSpacing.md)
                .padding(.trailing, ResetSpacing.lg)
            }
            
            HStack(spacing: ResetSpacing.lg) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(persistence.currentStreak)")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("day streak")
                        .font(ResetTypography.heading(18))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                    .opacity(animateStats ? 1 : 0)
                    .scaleEffect(animateStats ? 1 : 0.5)
            }
            .padding(ResetSpacing.lg)
        }
        .frame(height: 160)
        .opacity(animateStats ? 1 : 0)
        .offset(y: animateStats ? 0 : 20)
    }
    
    // MARK: - Weekly Overview
    private var weeklyOverviewCard: some View {
        VStack(alignment: .leading, spacing: ResetSpacing.md) {
            Text("This Week")
                .font(ResetTypography.heading(18))
                .foregroundColor(.primary)
            
            let weekData = getWeekData()
            
            HStack(spacing: ResetSpacing.sm) {
                ForEach(weekData, id: \.day) { data in
                    VStack(spacing: ResetSpacing.sm) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(data.count > 0 ? Color.calmSage : Color.warmGray.opacity(0.2))
                            .frame(width: 36, height: CGFloat(min(data.count * 20 + 20, 80)))
                            .overlay(
                                Text("\(data.count)")
                                    .font(ResetTypography.caption(11))
                                    .foregroundColor(data.count > 0 ? .white : .clear)
                            )
                        
                        Text(data.day)
                            .font(ResetTypography.caption(11))
                            .foregroundColor(data.isToday ? .calmSage : .warmGray)
                            .fontWeight(data.isToday ? .semibold : .regular)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(ResetSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.cardBackground(for: colorScheme))
                    .resetShadow(radius: 6, opacity: colorScheme == .dark ? 0 : 0.06)
            )
        }
        .opacity(animateStats ? 1 : 0)
        .animation(ResetAnimations.staggered(index: 1), value: animateStats)
    }
    
    struct DayData {
        let day: String
        let count: Int
        let isToday: Bool
    }
    
    private func getWeekData() -> [DayData] {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let startOfWeek = calendar.date(byAdding: .day, value: -(weekday - 1), to: today)!
        
        let days = ["S", "M", "T", "W", "T", "F", "S"]
        let sessions = persistence.getSessionsThisWeek()
        
        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: offset, to: startOfWeek)!
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
            
            let count = sessions.filter { session in
                session.startedAt >= dayStart && session.startedAt < dayEnd
            }.count
            
            return DayData(day: days[offset], count: count, isToday: calendar.isDateInToday(date))
        }
    }
    
    // MARK: - Tool Usage
    private var toolUsageSection: some View {
        VStack(alignment: .leading, spacing: ResetSpacing.md) {
            Text("Your Favorite Tools")
                .font(ResetTypography.heading(18))
                .foregroundColor(.primary)
            
            let toolCounts = persistence.getToolUsageCounts()
            let sortedTools = toolCounts.sorted { $0.value > $1.value }.prefix(4)
            
            if sortedTools.isEmpty {
                EmptyToolUsageView()
            } else {
                ForEach(Array(sortedTools.enumerated()), id: \.element.key) { index, item in
                    ToolUsageRow(tool: item.key, count: item.value, rank: index + 1)
                        .opacity(animateStats ? 1 : 0)
                        .animation(ResetAnimations.staggered(index: index + 2), value: animateStats)
                }
            }
        }
    }
    
    // MARK: - Encouragement
    private var encouragementSection: some View {
        VStack(spacing: ResetSpacing.md) {
            HStack(spacing: ResetSpacing.md) {
                StatCard(title: "Total Resets", value: "\(persistence.totalResets)", icon: "sparkles", color: .calmSage)
                StatCard(title: "Best Streak", value: "\(persistence.currentStreak)", icon: "flame.fill", color: .warmPeach)
            }
            
            VStack(spacing: ResetSpacing.sm) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.softRose)
                
                Text(encouragementMessage)
                    .font(ResetTypography.body(14))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(ResetSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.softRose.opacity(0.1))
            )
        }
        .opacity(animateStats ? 1 : 0)
        .animation(ResetAnimations.staggered(index: 6), value: animateStats)
    }
    
    private var encouragementMessage: String {
        if persistence.totalResets == 0 {
            return "Start your first reset today. Every journey begins with a single step."
        } else if persistence.currentStreak >= 7 {
            return "Amazing! A week-long streak shows real commitment to your wellbeing."
        } else if persistence.currentStreak >= 3 {
            return "You're building a great habit! Three days of self-care is something to celebrate."
        } else {
            return "Every reset counts. You're doing great by taking time for yourself."
        }
    }
}

// MARK: - Tool Usage Row
struct ToolUsageRow: View {
    let tool: ResetToolKind
    let count: Int
    let rank: Int
    
    var body: some View {
        HStack(spacing: ResetSpacing.md) {
            Text("#\(rank)")
                .font(ResetTypography.heading(16))
                .foregroundColor(.secondary)
                .frame(width: 30)
            
            ZStack {
                Circle()
                    .fill(tool.color.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: tool.iconName)
                    .font(.system(size: 18))
                    .foregroundColor(tool.color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(tool.displayName)
                    .font(ResetTypography.heading(15))
                    .foregroundColor(.primary)
                
                Text("\(count) sessions")
                    .font(ResetTypography.caption(12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if rank == 1 {
                Image(systemName: "medal.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.warmPeach)
            }
        }
        .padding(ResetSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemGroupedBackground))
                .resetShadow(radius: 4, opacity: 0.04)
        )
    }
}

// MARK: - Empty Tool Usage
struct EmptyToolUsageView: View {
    var body: some View {
        VStack(spacing: ResetSpacing.md) {
            Image(systemName: "chart.bar")
                .font(.system(size: 32))
                .foregroundColor(.warmGray.opacity(0.5))
            
            Text("No activity yet")
                .font(ResetTypography.body(14))
                .foregroundColor(.secondary)
            
            Text("Use some tools to see your favorites here")
                .font(ResetTypography.caption(12))
                .foregroundColor(.warmGray.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, ResetSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground).opacity(0.8))
        )
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: ResetSpacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(ResetTypography.display(28))
                .foregroundColor(.primary)
            
            Text(title)
                .font(ResetTypography.caption(12))
                .foregroundColor(.secondary)
        }
        .padding(ResetSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
                .resetShadow(radius: 6, opacity: 0.06)
        )
    }
}

// MARK: - Preview
struct MyStatsView_Previews: PreviewProvider {
    static var previews: some View {
        MyStatsView()
            .environmentObject(PersistenceController.shared)
    }
}

