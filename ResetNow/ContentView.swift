//
//  ContentView.swift
//  ResetNow
//
//  Main app content with tab navigation
//

import SwiftUI

// MARK: - App Tab Enum
enum AppTab: Int, CaseIterable {
    case journey = 0
    case stats = 1
    case chat = 2
    case settings = 3
    
    var title: String {
        switch self {
        case .journey: return "My Journey"
        case .stats: return "My Stats"
        case .chat: return "Chat"
        case .settings: return "Settings"
        }
    }
    
    var iconName: String {
        switch self {
        case .journey: return "house.fill"
        case .stats: return "chart.bar.fill"
        case .chat: return "bubble.left.and.bubble.right.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var persistence: PersistenceController
    @Environment(\.colorScheme) var colorScheme
    @State private var showDisclaimer = false
    
    // Computed binding that syncs with appState
    private var selectedTab: Binding<AppTab> {
        Binding(
            get: { AppTab(rawValue: appState.selectedTab) ?? .journey },
            set: { appState.selectedTab = $0.rawValue }
        )
    }
    
    var body: some View {
        ZStack {
            // Adaptive Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            // Tab View
            TabView(selection: selectedTab) {
                MyJourneyView()
                    .tabItem {
                        Label(AppTab.journey.title, systemImage: AppTab.journey.iconName)
                    }
                    .tag(AppTab.journey)
                
                MyStatsView()
                    .tabItem {
                        Label(AppTab.stats.title, systemImage: AppTab.stats.iconName)
                    }
                    .tag(AppTab.stats)
                
                ChatView()
                    .tabItem {
                        Label(AppTab.chat.title, systemImage: AppTab.chat.iconName)
                    }
                    .tag(AppTab.chat)
                
                SettingsView()
                    .tabItem {
                        Label(AppTab.settings.title, systemImage: AppTab.settings.iconName)
                    }
                    .tag(AppTab.settings)
            }
            .tint(.calmSage)
        }
        .onAppear {
            configureTabBarAppearance()
            checkOnboarding()
        }
        .fullScreenCover(isPresented: $showDisclaimer) {
            OnboardingView(isPresented: $showDisclaimer)
                .environmentObject(appState)
                .environmentObject(persistence)
        }
        .sheet(item: $appState.activeTool) { tool in
            NavigationStack {
                toolView(for: tool)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Close") {
                                appState.activeTool = nil
                            }
                        }
                    }
            }
        }
    }
    
    @ViewBuilder
    private func toolView(for tool: ResetToolKind) -> some View {
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
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        appearance.shadowImage = nil
        appearance.shadowColor = UIColor.black.withAlphaComponent(0.05)
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    private func checkOnboarding() {
        // Show onboarding if user hasn't completed it
        if !appState.isOnboardingComplete {
            showDisclaimer = true
        }
    }
}

// MARK: - Disclaimer View
struct DisclaimerView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var appState: AppState
    @State private var showCrisisResources = false
    
    var body: some View {
        ZStack {
            ResetGradients.calm
                .ignoresSafeArea()
            
            VStack(spacing: ResetSpacing.lg) {
                Spacer()
                
                // Icon
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.calmSage, .softLavender],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Title
                Text("Welcome to ResetNow")
                    .font(ResetTypography.display(28))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("A gentle space for calm")
                    .font(ResetTypography.body(18))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Disclaimer points
                VStack(alignment: .leading, spacing: ResetSpacing.md) {
                    DisclaimerBullet(
                        icon: "info.circle.fill",
                        text: "ResetNow is a wellbeing companion, not a medical service."
                    )
                    DisclaimerBullet(
                        icon: "person.2.fill",
                        text: "We're not doctors, therapists, or emergency responders."
                    )
                    DisclaimerBullet(
                        icon: "phone.circle.fill",
                        text: "If you're in crisis, please contact emergency services or a crisis hotline."
                    )
                }
                .padding(.horizontal, ResetSpacing.lg)
                
                Spacer()
                
                // Accept button
                Button(action: acceptDisclaimer) {
                    Text("I Understand")
                }
                .buttonStyle(ResetPrimaryButtonStyle())
                .padding(.horizontal, ResetSpacing.xl)
                
                // Crisis resources link
                Button(action: { showCrisisResources = true }) {
                    Text("View Crisis Resources")
                        .font(ResetTypography.caption())
                        .foregroundColor(.calmSage)
                        .underline()
                }
                .padding(.bottom, ResetSpacing.xl)
            }
            .padding()
        }
        .interactiveDismissDisabled()
        .sheet(isPresented: $showCrisisResources) {
            SOSResourcesView()
        }
    }
    
    private func acceptDisclaimer() {
        appState.acceptDisclaimer()
        isPresented = false
    }
}

struct DisclaimerBullet: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: ResetSpacing.md) {
            Image(systemName: icon)
                .foregroundColor(.calmSage)
                .font(.system(size: 20))
                .frame(width: 24)
            
            Text(text)
                .font(ResetTypography.body(15))
                .foregroundColor(.deepSlate.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
            .environmentObject(PersistenceController.shared)
            .environmentObject(AudioService.shared)
    }
}
