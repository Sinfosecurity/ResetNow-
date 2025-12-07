//
//  ResetNowApp.swift
//  ResetNow
//
//  A gentle companion for anxiety and stress support
//

import SwiftUI

@main
struct ResetNowApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var persistence = PersistenceController.shared
    @StateObject private var audioService = AudioService.shared
    
    init() {
        // OpenAI API key is securely stored in iOS Keychain
        // It was saved on first run and persists until app is uninstalled
    }
    
    @AppStorage("colorScheme") private var storedColorScheme: Int = 0
    
    // App Flow State
    enum AppPhase {
        case splash
        case onboarding
        case main
    }
    
    @State private var appPhase: AppPhase = .splash
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // 1. Main Content (Always present at bottom, but maybe hidden)
                if appPhase == .main {
                    ContentView()
                        .environmentObject(appState)
                        .environmentObject(persistence)
                        .environmentObject(audioService)
                        .preferredColorScheme(colorScheme)
                        .onOpenURL { url in
                            handleDeepLink(url)
                        }
                        .transition(.opacity)
                }
                
                // 2. Onboarding Layer
                if appPhase == .onboarding {
                    OnboardingView(isPresented: Binding(
                        get: { true },
                        set: { if !$0 { transitionToMain() } }
                    ))
                    .environmentObject(appState)
                    .environmentObject(persistence)
                    .transition(.opacity)
                    .zIndex(1)
                }
                
                // 3. Splash Layer (Topmost)
                if appPhase == .splash {
                    SplashView {
                        finishSplash()
                    }
                    .transition(.opacity)
                    .zIndex(2)
                }
            }
            .animation(.easeInOut(duration: 1.0), value: appPhase)
        }
    }
    
    private func finishSplash() {
        if appState.isOnboardingComplete {
            appPhase = .main
        } else {
            appPhase = .onboarding
        }
    }
    
    private func transitionToMain() {
        appPhase = .main
    }
    
    private var colorScheme: ColorScheme? {
        switch storedColorScheme {
        case 1: return .light
        case 2: return .dark
        default: return nil
        }
    }
    
    private func handleDeepLink(_ url: URL) {
        // Handle widget deep links
        guard url.scheme == "resetnow" else { return }
        
        switch url.host {
        case "breathe":
            appState.selectedTab = 0
        case "sleep":
            appState.selectedTab = 0
        case "chat":
            appState.selectedTab = 2
        case "affirm":
            appState.selectedTab = 0
        default:
            break
        }
    }
}

/*
 NOTE: ResetNow v1.0 is a completely FREE app.
 
 There are NO in-app purchases, subscriptions, or "Pro" features in this version.
 All content is available to all users at no cost.
 
 Future versions may add premium features - that implementation would require:
 - StoreKit integration
 - App Store Connect product setup
 - Paywall UI
 - Restore Purchases functionality
 - Receipt validation
 */
