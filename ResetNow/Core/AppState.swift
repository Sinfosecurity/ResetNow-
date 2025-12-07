//
//  AppState.swift
//  ResetNow
//
//  Global app state management
//

import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    // MARK: - Published State
    @Published var hasAcceptedDisclaimer: Bool
    @Published var selectedTab: Int = 0
    @Published var isOnboardingComplete: Bool
    @Published var totalResets: Int
    @Published var userDisplayName: String {
        didSet {
            UserDefaults.standard.set(userDisplayName, forKey: Keys.userDisplayName)
            // Also update persistence controller if available
            Task { @MainActor in
                var profile = PersistenceController.shared.userProfile
                if profile.displayName != userDisplayName {
                    profile.displayName = userDisplayName
                    PersistenceController.shared.updateProfile(profile)
                }
            }
        }
    }
    
    // MARK: - UserDefaults Keys
    private enum Keys {
        static let hasAcceptedDisclaimer = "hasAcceptedDisclaimer"
        static let isOnboardingComplete = "isOnboardingComplete"
        static let totalResets = "totalResets"
        static let userDisplayName = "userDisplayName"
    }
    
    // MARK: - Init
    init() {
        self.hasAcceptedDisclaimer = UserDefaults.standard.bool(forKey: Keys.hasAcceptedDisclaimer)
        self.isOnboardingComplete = UserDefaults.standard.bool(forKey: Keys.isOnboardingComplete)
        self.totalResets = UserDefaults.standard.integer(forKey: Keys.totalResets)
        self.userDisplayName = UserDefaults.standard.string(forKey: Keys.userDisplayName) ?? ""
    }
    
    // Computed property for backward compatibility
    var hasCompletedOnboarding: Bool {
        get { isOnboardingComplete }
        set {
            isOnboardingComplete = newValue
            UserDefaults.standard.set(newValue, forKey: Keys.isOnboardingComplete)
        }
    }
    
    // MARK: - Actions
    func acceptDisclaimer() {
        hasAcceptedDisclaimer = true
        UserDefaults.standard.set(true, forKey: Keys.hasAcceptedDisclaimer)
    }
    
    func completeOnboarding() {
        isOnboardingComplete = true
        hasAcceptedDisclaimer = true
        UserDefaults.standard.set(true, forKey: Keys.isOnboardingComplete)
        UserDefaults.standard.set(true, forKey: Keys.hasAcceptedDisclaimer)
    }
    
    func incrementResets() {
        totalResets += 1
        UserDefaults.standard.set(totalResets, forKey: Keys.totalResets)
    }
    
    func resetForTesting() {
        hasAcceptedDisclaimer = false
        isOnboardingComplete = false
        totalResets = 0
        userDisplayName = ""
        UserDefaults.standard.set(false, forKey: Keys.hasAcceptedDisclaimer)
        UserDefaults.standard.set(false, forKey: Keys.isOnboardingComplete)
        UserDefaults.standard.set(0, forKey: Keys.totalResets)
        UserDefaults.standard.set("", forKey: Keys.userDisplayName)
    }
    
    /// Returns personalized greeting with user's name
    func personalizedGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        let timeGreeting: String
        
        switch hour {
        case 5..<12:
            timeGreeting = "Good morning"
        case 12..<17:
            timeGreeting = "Good afternoon"
        case 17..<21:
            timeGreeting = "Good evening"
        default:
            timeGreeting = "Hello"
        }
        
        if userDisplayName.isEmpty {
            return timeGreeting
        } else {
            return "\(timeGreeting), \(userDisplayName)"
        }
    }
}

