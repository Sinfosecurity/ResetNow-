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
            .navigationTitle("Settings")
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
                    title: "Daily Affirmation"
                )
            }
            .tint(.calmSage)
            
            Toggle(isOn: $dailyResetReminderEnabled) {
                SettingsRow(
                    icon: "bell.fill",
                    iconColor: .warmPeach,
                    title: "Daily Reset Reminder"
                )
            }
            .tint(.calmSage)
        } header: {
            Text("Notifications")
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
                    title: "Sounds"
                )
            }
            .tint(.calmSage)
            
            Toggle(isOn: $hapticsEnabled) {
                SettingsRow(
                    icon: "iphone.radiowaves.left.and.right",
                    iconColor: .softLavender,
                    title: "Haptic Feedback"
                )
            }
            .tint(.calmSage)
            
            Picker(selection: $selectedAppearance) {
                ForEach(AppearanceMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            } label: {
                SettingsRow(
                    icon: "moon.stars.fill",
                    iconColor: .sleepColor,
                    title: "Appearance"
                )
            }
            .onChange(of: selectedAppearance) { oldValue, newValue in
                updateAppearance(newValue)
            }
        } header: {
            Text("Experience")
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
                    title: "Crisis Resources",
                    showChevron: true
                )
            }
        } header: {
            Text("Safety")
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
                    title: "Medical Sources & Citations"
                )
            }
            
            NavigationLink {
                ResearchReferencesView()
            } label: {
                SettingsRow(
                    icon: "doc.text.fill",
                    iconColor: .learnColor,
                    title: "Research References"
                )
            }
        } header: {
            Text("Evidence & Sources")
                .font(ResetTypography.caption(12))
        } footer: {
            Text("ResetNow's techniques are based on evidence-based research from reputable medical and academic sources.")
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
                    title: "Privacy Policy",
                    showChevron: true
                )
            }
            
            Button(action: openTermsOfUse) {
                SettingsRow(
                    icon: "doc.text.fill",
                    iconColor: .warmGray,
                    title: "Terms of Use",
                    showChevron: true
                )
            }
        } header: {
            Text("Legal")
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
                    title: "Support & Contact"
                )
            }
            
            NavigationLink {
                AboutView()
            } label: {
                SettingsRow(
                    icon: "info.circle.fill",
                    iconColor: .learnColor,
                    title: "About ResetNow"
                )
            }
        } header: {
            Text("Help & About")
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
                
                Text("Made with 💚 for your wellbeing")
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
                    title: "Replay Onboarding"
                )
            }
            .confirmationDialog("Reset App?", isPresented: $showResetConfirmation) {
                Button("Reset & Show Onboarding", role: .destructive) {
                    appState.resetForTesting()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will reset the app and show the onboarding again.")
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
    let title: String
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
                    
                    Text("Your companion for calm")
                        .font(ResetTypography.body(16))
                        .foregroundColor(.secondary)
                }
                .padding(.top, ResetSpacing.xl)
                
                // Mission
                VStack(alignment: .leading, spacing: ResetSpacing.md) {
                    Text("Our Mission")
                        .font(ResetTypography.heading(20))
                        .foregroundColor(.primary)
                    
                    Text("ResetNow helps you de-escalate anxiety in 1-5 minutes with simple, gentle tools. We believe everyone deserves access to calm, and that small moments of self-care can transform your relationship with stress.")
                        .font(ResetTypography.body(15))
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, ResetSpacing.md)
                
                // Values
                VStack(alignment: .leading, spacing: ResetSpacing.md) {
                    Text("Our Values")
                        .font(ResetTypography.heading(20))
                        .foregroundColor(.primary)
                    
                    ValueRow(icon: "heart.fill", color: .softRose, text: "Compassion over judgment")
                    ValueRow(icon: "lock.shield.fill", color: .calmSage, text: "Privacy by design")
                    ValueRow(icon: "accessibility", color: .gentleSky, text: "Accessible to all")
                    ValueRow(icon: "sparkles", color: .warmPeach, text: "Simplicity in everything")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, ResetSpacing.md)
                
                // Disclaimer
                VStack(spacing: ResetSpacing.md) {
                    Text("Important Note")
                        .font(ResetTypography.heading(16))
                        .foregroundColor(.primary)
                    
                    Text("ResetNow provides general wellbeing and educational information only and is not a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of a qualified health provider with any questions you may have regarding a medical condition. If you're experiencing a mental health crisis, please contact emergency services or a crisis helpline.")
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
    let text: String
    
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

