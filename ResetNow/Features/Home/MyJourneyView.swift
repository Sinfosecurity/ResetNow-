//
//  MyJourneyView.swift
//  ResetNow
//
//  Home hub with reset tools grid and SOS button
//

import SwiftUI

struct MyJourneyView: View {
    @EnvironmentObject var persistence: PersistenceController
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    @State private var showSOSSheet = false
    @State private var animateCards = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ResetSpacing.lg) {
                    // Header with greeting
                    headerSection
                    
                    // Quick stats row
                    quickStatsRow
                    
                    // SOS Button
                    sosButton
                    
                    // Tools grid
                    toolsGridSection
                    
                    // Recent activity
                    recentActivitySection
                }
                .padding(.horizontal, ResetSpacing.md)
                .padding(.top, ResetSpacing.md)
                .padding(.bottom, ResetSpacing.xxl)
            }
            .scrollContentBackground(.hidden)
            .scrollContentBackground(.hidden)
            .background(
                ZStack {
                    AnimatedGradientBackground()
                    FloatingParticles()
                        .opacity(0.6)
                }
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(AppConstants.appName)
                        .font(ResetTypography.heading(20))
                        .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showSOSSheet) {
            SOSResourcesView()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animateCards = true
            }
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: ResetSpacing.sm) {
            Text(greetingMessage)
                .font(ResetTypography.display(28))
                .foregroundColor(.white)
                .accessibilityLabel(greetingMessage)
            
            Text("What would help you today?")
                .font(ResetTypography.body(16))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, ResetSpacing.sm)
    }
    
    private var greetingMessage: String {
        appState.personalizedGreeting()
    }
    
    // MARK: - Quick Stats
    private var quickStatsRow: some View {
        HStack(spacing: ResetSpacing.md) {
            QuickStatPill(
                icon: "flame.fill",
                value: "\(persistence.currentStreak)",
                label: "day streak",
                color: .warmPeach
            )
            
            QuickStatPill(
                icon: "sparkles",
                value: "\(persistence.totalResets)",
                label: "resets",
                color: .softLavender
            )
        }
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 20)
        .animation(ResetAnimations.staggered(index: 0), value: animateCards)
    }
    
    // MARK: - SOS / Panic Button
    private var sosButton: some View {
        Button(action: { showSOSSheet = true }) {
            VStack(spacing: 8) {
                // Centered heart icon
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Centered text
                VStack(spacing: 4) {
                    Text("PANIC BUTTON SOS")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Tap for immediate support & resources")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
                .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color.sosRed, Color.sosRed.opacity(0.85)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: Color.sosRed.opacity(0.4), radius: 12, x: 0, y: 6)
            )
        }
        .accessibleButton(
            label: "PANIC BUTTON SOS",
            hint: "Double tap for emergency resources"
        )
        .simultaneousGesture(TapGesture().onEnded {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        })
        .opacity(animateCards ? 1 : 0)
        .animation(ResetAnimations.staggered(index: 1), value: animateCards)
    }
    
    // MARK: - Tools Grid
    private var toolsGridSection: some View {
        VStack(alignment: .leading, spacing: ResetSpacing.md) {
            Text("Reset Tools")
                .font(ResetTypography.heading(18))
                .foregroundColor(.white)
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(Array(ResetToolKind.allCases.sorted(by: { $0.sortOrder < $1.sortOrder }).enumerated()), id: \.element.id) { index, tool in
                    NavigationLink(destination: destinationView(for: tool)) {
                        ToolCard(tool: tool)
                    }
                    .buttonStyle(ResetToolButtonStyle(color: tool.color))
                    .opacity(animateCards ? 1 : 0)
                    .offset(y: animateCards ? 0 : 30)
                    .animation(ResetAnimations.staggered(index: index + 2), value: animateCards)
                }
            }
        }
    }
    
    @ViewBuilder
    private func destinationView(for tool: ResetToolKind) -> some View {
        switch tool {
        case .learn: LearnView()
        case .breathe: BreatheView()
        case .games: GamesView()
        case .journal: JournalView()
        case .visualize: VisualizeView()
        case .sleep: SleepView()
        case .affirm: AffirmView()
        case .journeys: JourneysView()
        }
    }
    
    // MARK: - Recent Activity
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: ResetSpacing.md) {
            Text("Recent Activity")
                .font(ResetTypography.heading(18))
                .foregroundColor(.white)
            
            if persistence.sessions.isEmpty {
                EmptyRecentActivity()
            } else {
                RecentActivityList(sessions: persistence.getRecentSessions(limit: 5))
            }
        }
        .opacity(animateCards ? 1 : 0)
        .animation(ResetAnimations.staggered(index: 10), value: animateCards)
    }
    
}

// MARK: - Quick Stat Pill
struct QuickStatPill: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: ResetSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
            
            Text(value)
                .font(ResetTypography.heading(18))
                .foregroundColor(.white)
            
            Text(label)
                .font(ResetTypography.caption(13))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal, ResetSpacing.md)
        .padding(.vertical, ResetSpacing.sm + 2)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(value) \(label)")
    }
}

// MARK: - Tool Card
struct ToolCard: View {
    let tool: ResetToolKind
    @Environment(\.colorScheme) var colorScheme
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: ResetSpacing.md) {
            // Icon with glow effect
            ZStack {
                // Glow
                Circle()
                    .fill(tool.color.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .blur(radius: 10)
                
                // Main icon circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [tool.color, tool.color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                
                Image(systemName: tool.iconName)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(tool.displayName)
                    .font(ResetTypography.heading(16))
                    .foregroundColor(.primary)
                
                Text(tool.description)
                    .font(ResetTypography.caption(12))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(ResetSpacing.md)
        .background(
            ZStack {
                // Gradient tint based on tool color
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                tool.color.opacity(colorScheme == .dark ? 0.15 : 0.08),
                                Color(.secondarySystemGroupedBackground)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Glass overlay
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(colorScheme == .dark ? 0.1 : 0.5),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: tool.color.opacity(0.3), radius: 12, y: 6)
        )
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .accessibleButton(
            label: tool.displayName,
            hint: "Double tap to open tool"
        )
    }
}

// MARK: - Empty Recent Activity
struct EmptyRecentActivity: View {
    var body: some View {
        VStack(spacing: ResetSpacing.md) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 32))
                .foregroundColor(.calmSage.opacity(0.5))
            
            Text("Your journey starts here")
                .font(ResetTypography.body(14))
                .foregroundColor(.secondary)
            
            Text("Try a reset tool above to begin")
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

// MARK: - Recent Activity List
struct RecentActivityList: View {
    let sessions: [ResetSession]
    
    var body: some View {
        VStack(spacing: ResetSpacing.sm) {
            ForEach(sessions) { session in
                RecentActivityRow(session: session)
            }
        }
    }
}

struct RecentActivityRow: View {
    let session: ResetSession
    
    var body: some View {
        HStack(spacing: ResetSpacing.md) {
            // Tool icon
            Circle()
                .fill(session.sourceToolKind.color.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: session.sourceToolKind.iconName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(session.sourceToolKind.color)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(session.sourceToolKind.displayName)
                    .font(ResetTypography.body(14))
                    .foregroundColor(.white)
                
                Text(session.startedAt.formatted(.relative(presentation: .named)))
                    .font(ResetTypography.caption(12))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            if let duration = session.durationMinutes {
                Text("\(duration) min")
                    .font(ResetTypography.caption(12))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.horizontal, ResetSpacing.md)
        .padding(.vertical, ResetSpacing.sm + 4)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
    }
}

// MARK: - Preview
struct MyJourneyView_Previews: PreviewProvider {
    static var previews: some View {
        MyJourneyView()
            .environmentObject(PersistenceController.shared)
    }
}

