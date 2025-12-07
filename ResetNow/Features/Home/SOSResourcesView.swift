//
//  SOSResourcesView.swift
//  ResetNow
//
//  Crisis resources and emergency support
//

import SwiftUI

struct SOSResourcesView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ResetSpacing.lg) {
                    headerSection
                    importantNoteCard
                    emergencyResourcesSection
                    crisisHotlinesSection
                    selfCareTipsSection
                }
                .padding(.horizontal, ResetSpacing.md)
                .padding(.bottom, ResetSpacing.xxl)
            }
            .background(
                LinearGradient(
                    colors: [Color.creamWhite, Color.softRose.opacity(0.1)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Support Resources")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(ResetTypography.body(16))
                        .foregroundColor(.calmSage)
                }
            }
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: ResetSpacing.md) {
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.sosRed.opacity(0.8), .softRose],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("You're Not Alone")
                .font(ResetTypography.display(24))
                .foregroundColor(.primary)
            
            Text("Help is available 24/7")
                .font(ResetTypography.body(16))
                .foregroundColor(.secondary)
        }
        .padding(.top, ResetSpacing.lg)
    }
    
    // MARK: - Important Note
    private var importantNoteCard: some View {
        VStack(alignment: .leading, spacing: ResetSpacing.md) {
            HStack(spacing: ResetSpacing.sm) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.sosRed)
                Text("Important")
                    .font(ResetTypography.heading(16))
                    .foregroundColor(.sosRed)
            }
            
            Text("If you are in immediate danger or having a medical emergency, please call your local emergency number immediately.")
                .font(ResetTypography.body(14))
                .foregroundColor(.deepSlate.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
            
            Button(action: { callNumber("911") }) {
                HStack {
                    Image(systemName: "phone.fill")
                    Text("Call Emergency Services")
                }
                .font(ResetTypography.heading(16))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, ResetSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.sosRed)
                )
            }
        }
        .padding(ResetSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.sosRed.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.sosRed.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Emergency Resources
    private var emergencyResourcesSection: some View {
        VStack(alignment: .leading, spacing: ResetSpacing.md) {
            Text("Emergency Resources")
                .font(ResetTypography.heading(18))
                .foregroundColor(.primary)
            
            CrisisResourceCard(
                icon: "phone.fill",
                title: "988 Suicide & Crisis Lifeline",
                subtitle: "Call or text 988 (US)",
                description: "Free, confidential support 24/7",
                actionText: "Call 988"
            ) {
                callNumber("988")
            }
            
            CrisisResourceCard(
                icon: "message.fill",
                title: "Crisis Text Line",
                subtitle: "Text HOME to 741741",
                description: "Free 24/7 text support",
                actionText: "Start Text"
            ) {
                textCrisisLine()
            }
            
            CrisisResourceCard(
                icon: "globe",
                title: "International Association",
                subtitle: "Find help worldwide",
                description: "Crisis centers in many countries",
                actionText: "Visit Site"
            ) {
                openURL(URL(string: "https://www.iasp.info/resources/Crisis_Centres/")!)
            }
        }
    }
    
    // MARK: - Crisis Hotlines
    private var crisisHotlinesSection: some View {
        VStack(alignment: .leading, spacing: ResetSpacing.md) {
            Text("Other Helplines")
                .font(ResetTypography.heading(18))
                .foregroundColor(.primary)
            
            VStack(spacing: ResetSpacing.sm) {
                HotlineRow(name: "National Domestic Violence Hotline", number: "1-800-799-7233")
                HotlineRow(name: "SAMHSA National Helpline", number: "1-800-662-4357")
                HotlineRow(name: "Trevor Project (LGBTQ+ Youth)", number: "1-866-488-7386")
                HotlineRow(name: "Veterans Crisis Line", number: "988 (Press 1)")
            }
            .padding(ResetSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .resetShadow(radius: 6, opacity: 0.06)
            )
        }
    }
    
    // MARK: - Self Care Tips
    private var selfCareTipsSection: some View {
        VStack(alignment: .leading, spacing: ResetSpacing.md) {
            Text("While You Wait for Help")
                .font(ResetTypography.heading(18))
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: ResetSpacing.sm) {
                SelfCareTip(icon: "lungs.fill", text: "Take slow, deep breaths")
                SelfCareTip(icon: "person.2.fill", text: "Reach out to someone you trust")
                SelfCareTip(icon: "house.fill", text: "Go to a safe place if possible")
                SelfCareTip(icon: "drop.fill", text: "Drink some water")
                SelfCareTip(icon: "figure.walk", text: "Try gentle movement or stretching")
            }
            .padding(ResetSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.calmSage.opacity(0.1))
            )
        }
    }
    
    // MARK: - Actions
    private func callNumber(_ number: String) {
        let cleaned = number.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        if let url = URL(string: "tel://\(cleaned)") {
            openURL(url)
        }
    }
    
    private func textCrisisLine() {
        if let url = URL(string: "sms:741741&body=HOME") {
            openURL(url)
        }
    }
}

// MARK: - Crisis Resource Card
struct CrisisResourceCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let description: String
    let actionText: String
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: ResetSpacing.md) {
            HStack(spacing: ResetSpacing.md) {
                Circle()
                    .fill(Color.calmSage.opacity(0.2))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.calmSage)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(ResetTypography.heading(15))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(ResetTypography.caption(13))
                        .foregroundColor(.calmSage)
                }
                
                Spacer()
            }
            
            Text(description)
                .font(ResetTypography.body(13))
                .foregroundColor(.secondary)
            
            Button(action: action) {
                Text(actionText)
                    .font(ResetTypography.caption(14))
                    .foregroundColor(.white)
                    .padding(.horizontal, ResetSpacing.lg)
                    .padding(.vertical, ResetSpacing.sm + 2)
                    .background(Capsule().fill(Color.calmSage))
            }
        }
        .padding(ResetSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
                .resetShadow(radius: 6, opacity: 0.06)
        )
    }
}

// MARK: - Hotline Row
struct HotlineRow: View {
    let name: String
    let number: String
    @Environment(\.openURL) var openURL
    
    var body: some View {
        Button(action: callNumber) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(ResetTypography.body(14))
                        .foregroundColor(.primary)
                    
                    Text(number)
                        .font(ResetTypography.caption(13))
                        .foregroundColor(.calmSage)
                }
                
                Spacer()
                
                Image(systemName: "phone.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.calmSage)
            }
            .padding(.vertical, ResetSpacing.sm)
        }
    }
    
    private func callNumber() {
        let cleaned = number.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        if let url = URL(string: "tel://\(cleaned)") {
            openURL(url)
        }
    }
}

// MARK: - Self Care Tip
struct SelfCareTip: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: ResetSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.calmSage)
                .frame(width: 24)
            
            Text(text)
                .font(ResetTypography.body(14))
                .foregroundColor(.deepSlate.opacity(0.8))
        }
    }
}

// MARK: - Preview
struct SOSResourcesView_Previews: PreviewProvider {
    static var previews: some View {
        SOSResourcesView()
    }
}

