//
//  SettingsView.swift
//  ResetNow
//
//  App settings with legal links for App Store compliance
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var persistence: PersistenceController
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    
    @State private var dailyAffirmationEnabled = true
    @State private var dailyResetReminderEnabled = true
    @State private var soundEnabled = true
    @State private var hapticsEnabled = true
    @State private var selectedAppearance: AppearanceMode = .system
    @State private var showSOSResources = false
    @State private var showResetConfirmation = false
    
    @Environment(\.openURL) var openURL
    
    enum AppearanceMode: String, CaseIterable {
        case system = "System"
        case light = "Light"
        case dark = "Dark"
        
        var localizedName: LocalizedStringKey {
            switch self {
            case .system: return "settings_appearance_system"
            case .light: return "settings_appearance_light"
            case .dark: return "settings_appearance_dark"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Notifications
                notificationsSection
                
                // Experience
                experienceSection
                
                // Safety
                safetySection
                
                // Sources & Research (Guideline 1.4.1)
                sourcesSection
                
                // Legal (Guideline 3.1.2)
                legalSection
                
                // Support (Guideline 1.5)
                supportSection
                
                // App info
                appInfoSection
            }
            .listStyle(.insetGrouped)
            .background(SemanticColors.background(colorScheme).ignoresSafeArea())
            .scrollContentBackground(.hidden)
            .navigationTitle("settings_title")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showSOSResources) {
            SOSResourcesView()
        }
        .onAppear {
            loadSettings()
        }
    }
    
    // MARK: - Notifications Section
    private var notificationsSection: some View {
        Section {
            Toggle(isOn: $dailyAffirmationEnabled) {
                SettingsRow(
                    icon: "heart.fill",
                    iconColor: .affirmColor,
                    title: "settings_daily_affirmation"
                )
            }
            .tint(.calmSage)
            
            Toggle(isOn: $dailyResetReminderEnabled) {
                SettingsRow(
                    icon: "bell.fill",
                    iconColor: .warmPeach,
                    title: "settings_daily_reminder"
                )
            }
            .tint(.calmSage)
        } header: {
            Text("settings_notifications")
                .font(ResetTypography.caption(12))
        }
    }
    
    // MARK: - Experience Section
    private var experienceSection: some View {
        Section {
            Toggle(isOn: $soundEnabled) {
                SettingsRow(
                    icon: "speaker.wave.2.fill",
                    iconColor: .gentleSky,
                    title: "settings_sounds"
                )
            }
            .tint(.calmSage)
            
            Toggle(isOn: $hapticsEnabled) {
                SettingsRow(
                    icon: "iphone.radiowaves.left.and.right",
                    iconColor: .softLavender,
                    title: "settings_haptics"
                )
            }
            .tint(.calmSage)
            
            Picker(selection: $selectedAppearance) {
                ForEach(AppearanceMode.allCases, id: \.self) { mode in
                    Text(mode.localizedName).tag(mode)
                }
            } label: {
                SettingsRow(
                    icon: "moon.stars.fill",
                    iconColor: .sleepColor,
                    title: "settings_appearance"
                )
            }
            .onChange(of: selectedAppearance) { oldValue, newValue in
                updateAppearance(newValue)
            }
        } header: {
            Text("settings_experience")
                .font(ResetTypography.caption(12))
        }
    }
    
    // MARK: - Safety Section
    private var safetySection: some View {
        Section {
            Button(action: { showSOSResources = true }) {
                SettingsRow(
                    icon: "heart.circle.fill",
                    iconColor: .sosRed,
                    title: "settings_crisis_resources",
                    showChevron: true
                )
            }
        } header: {
            Text("settings_safety")
                .font(ResetTypography.caption(12))
        }
    }
    
    // MARK: - Sources Section (Guideline 1.4.1)
    private var sourcesSection: some View {
        Section {
            NavigationLink {
                MedicalSourcesView()
            } label: {
                SettingsRow(
                    icon: "cross.case.fill",
                    iconColor: .calmSage,
                    title: "settings_medical_sources"
                )
            }
            
            NavigationLink {
                ResearchReferencesView()
            } label: {
                SettingsRow(
                    icon: "doc.text.fill",
                    iconColor: .learnColor,
                    title: "settings_research"
                )
            }
        } header: {
            Text("settings_evidence")
                .font(ResetTypography.caption(12))
        } footer: {
            Text("settings_evidence_footer")
                .font(ResetTypography.caption(11))
        }
    }
    
    // MARK: - Legal Section (Guideline 3.1.2)
    private var legalSection: some View {
        Section {
            Button(action: openPrivacyPolicy) {
                SettingsRow(
                    icon: "lock.shield.fill",
                    iconColor: .calmSage,
                    title: "settings_privacy",
                    showChevron: true
                )
            }
            
            Button(action: openTermsOfUse) {
                SettingsRow(
                    icon: "doc.text.fill",
                    iconColor: .warmGray,
                    title: "settings_terms",
                    showChevron: true
                )
            }
        } header: {
            Text("settings_legal")
                .font(ResetTypography.caption(12))
        }
    }
    
    // MARK: - Support Section (Guideline 1.5)
    private var supportSection: some View {
        Section {
            NavigationLink {
                SupportContactView()
            } label: {
                SettingsRow(
                    icon: "questionmark.circle.fill",
                    iconColor: .gentleSky,
                    title: "settings_support"
                )
            }
            
            NavigationLink {
                AboutView()
            } label: {
                SettingsRow(
                    icon: "info.circle.fill",
                    iconColor: .learnColor,
                    title: "settings_about"
                )
            }
        } header: {
            Text("settings_help")
                .font(ResetTypography.caption(12))
        }
    }
    
    // MARK: - App Info Section
    private var appInfoSection: some View {
        Section {
            VStack(spacing: ResetSpacing.sm) {
                Text(AppConstants.appName)
                    .font(ResetTypography.heading(16))
                    .foregroundColor(.primary)
                
                Text("Version \(AppConstants.appVersion) (\(AppConstants.buildNumber))")
                    .font(ResetTypography.caption(12))
                    .foregroundColor(.secondary)
                
                Text("settings_made_with_love")
                    .font(ResetTypography.caption(12))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, ResetSpacing.md)
            .listRowBackground(Color.clear)
            
            // Developer/Testing option
            Button(action: { showResetConfirmation = true }) {
                SettingsRow(
                    icon: "arrow.counterclockwise",
                    iconColor: .warmPeach,
                    title: "settings_replay_onboarding"
                )
            }
            .confirmationDialog("settings_reset_confirm_title", isPresented: $showResetConfirmation) {
                Button("settings_reset_confirm_action", role: .destructive) {
                    appState.resetForTesting()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("settings_reset_confirm_message")
            }
        }
    }
    
    // MARK: - Actions
    private func loadSettings() {
        dailyAffirmationEnabled = persistence.userProfile.dailyAffirmationEnabled
        dailyResetReminderEnabled = persistence.userProfile.resetsReminderEnabled
        
        let colorSchemeValue = UserDefaults.standard.integer(forKey: "colorScheme")
        switch colorSchemeValue {
        case 1: selectedAppearance = .light
        case 2: selectedAppearance = .dark
        default: selectedAppearance = .system
        }
    }
    
    private func updateAppearance(_ mode: AppearanceMode) {
        switch mode {
        case .system: UserDefaults.standard.set(0, forKey: "colorScheme")
        case .light: UserDefaults.standard.set(1, forKey: "colorScheme")
        case .dark: UserDefaults.standard.set(2, forKey: "colorScheme")
        }
    }
    
    private func openPrivacyPolicy() {
        if let url = URL(string: AppConstants.privacyPolicyURL) {
            openURL(url)
        }
    }
    
    private func openTermsOfUse() {
        if let url = URL(string: AppConstants.termsOfUseURL) {
            openURL(url)
        }
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    @Environment(\.colorScheme) var colorScheme
    let icon: String
    let iconColor: Color
    let title: LocalizedStringKey
    var showChevron: Bool = false
    
    var body: some View {
        HStack(spacing: ResetSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(iconColor)
                )
            
            Text(title)
                .font(ResetTypography.body(16))
                .foregroundColor(SemanticColors.textPrimary(colorScheme))
            
            if showChevron {
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(SemanticColors.textSecondary(colorScheme))
            }
        }
    }
}

// MARK: - About View
struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: ResetSpacing.xl) {
                // Logo
                VStack(spacing: ResetSpacing.md) {
                    Image("AppLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .cornerRadius(28)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    Text(AppConstants.appName)
                        .font(ResetTypography.display(28))
                        .foregroundColor(.primary)
                    
                    Text("about_tagline")
                        .font(ResetTypography.body(16))
                        .foregroundColor(.secondary)
                }
                .padding(.top, ResetSpacing.xl)
                
                // Mission
                VStack(alignment: .leading, spacing: ResetSpacing.md) {
                    Text("about_mission_title")
                        .font(ResetTypography.heading(20))
                        .foregroundColor(.primary)
                    
                    Text("about_mission_text")
                        .font(ResetTypography.body(15))
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, ResetSpacing.md)
                
                // Values
                VStack(alignment: .leading, spacing: ResetSpacing.md) {
                    Text("about_values_title")
                        .font(ResetTypography.heading(20))
                        .foregroundColor(.primary)
                    
                    ValueRow(icon: "heart.fill", color: .softRose, text: "about_value_compassion")
                    ValueRow(icon: "lock.shield.fill", color: .calmSage, text: "about_value_privacy")
                    ValueRow(icon: "accessibility", color: .gentleSky, text: "about_value_access")
                    ValueRow(icon: "sparkles", color: .warmPeach, text: "about_value_simplicity")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, ResetSpacing.md)
                
                // Disclaimer
                VStack(spacing: ResetSpacing.md) {
                    Text("about_important_note")
                        .font(ResetTypography.heading(16))
                        .foregroundColor(.primary)
                    
                    Text("about_disclaimer")
                        .font(ResetTypography.caption(13))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(ResetSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.warmGray.opacity(0.1))
                )
                .padding(.horizontal, ResetSpacing.md)
                
                Spacer(minLength: ResetSpacing.xxl)
            }
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ValueRow: View {
    let icon: String
    let color: Color
    let text: LocalizedStringKey
    
    var body: some View {
        HStack(spacing: ResetSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(text)
                .font(ResetTypography.body(15))
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(PersistenceController.shared)
            .environmentObject(AppState())
    }
}

/*
 IMPORTANT: App Store Connect Legal URLs
 
 Before submitting to App Store:
 
 1. Privacy Policy URL:
    - Update AppConstants.privacyPolicyURL with your real URL
    - Set the same URL in App Store Connect → App Information → Privacy Policy URL
    - The page must be live and accessible
 
 2. Terms of Use URL:
    - Update AppConstants.termsOfUseURL with your real URL
    - You can either:
      a) Provide a custom Terms of Use URL in App Store Connect
      b) Use Apple's standard EULA (no custom URL needed)
 
 3. Both pages should:
    - Be accessible without login
    - Be available in the same language(s) as the app
    - Load correctly on mobile devices
    - Not require any app or account to view
 */

