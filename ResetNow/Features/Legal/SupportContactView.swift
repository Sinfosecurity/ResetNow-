//
//  SupportContactView.swift
//  ResetNow
//
//  Support & Contact screen for App Store Guideline 1.5 compliance
//

import SwiftUI

struct SupportContactView: View {
    @Environment(\.openURL) var openURL
    
    var body: some View {
        ScrollView {
            VStack(spacing: ResetSpacing.lg) {
                // Header
                headerSection
                
                // How we can help
                helpTopicsSection
                
                // Contact options
                contactOptionsSection
                
                // Additional info
                additionalInfoSection
            }
            .padding(.horizontal, ResetSpacing.md)
            .padding(.bottom, ResetSpacing.xxl)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationTitle("Support & Contact")
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: ResetSpacing.md) {
            ZStack {
                Circle()
                    .fill(Color.calmSage.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.calmSage)
            }
            
            Text("ResetNow Support")
                .font(ResetTypography.display(24))
                .foregroundColor(.primary)
            
            Text("We're here to help you get the most out of ResetNow. Whether you have questions about features, need technical assistance, or want to share feedback—we'd love to hear from you.")
                .font(ResetTypography.body(15))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, ResetSpacing.lg)
    }
    
    // MARK: - Help Topics
    private var helpTopicsSection: some View {
        VStack(alignment: .leading, spacing: ResetSpacing.md) {
            Text("How We Can Help")
                .font(ResetTypography.heading(18))
                .foregroundColor(.primary)
            
            VStack(spacing: ResetSpacing.sm) {
                HelpTopicRow(icon: "gearshape.fill", title: "Technical Issues", description: "App crashes, audio problems, or display issues")
                HelpTopicRow(icon: "questionmark.circle.fill", title: "Feature Questions", description: "How to use breathing exercises, sleep sounds, or other tools")
                HelpTopicRow(icon: "lightbulb.fill", title: "Feature Requests", description: "Suggestions for new features or improvements")
                HelpTopicRow(icon: "exclamationmark.triangle.fill", title: "Bug Reports", description: "Report issues you've encountered")
                HelpTopicRow(icon: "star.fill", title: "General Feedback", description: "Share your experience with ResetNow")
            }
        }
    }
    
    // MARK: - Contact Options
    private var contactOptionsSection: some View {
        VStack(alignment: .leading, spacing: ResetSpacing.md) {
            Text("Contact Us")
                .font(ResetTypography.heading(18))
                .foregroundColor(.primary)
            
            // Email support
            Button(action: openEmail) {
                HStack(spacing: ResetSpacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.calmSage.opacity(0.2))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.calmSage)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Email Support")
                            .font(ResetTypography.heading(16))
                            .foregroundColor(.primary)
                        
                        Text(AppConstants.supportEmail)
                            .font(ResetTypography.caption(13))
                            .foregroundColor(.calmSage)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding(ResetSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemGroupedBackground))
                        .resetShadow(radius: 6, opacity: 0.06)
                )
            }
            
            // Support website
            Button(action: openSupportWebsite) {
                HStack(spacing: ResetSpacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gentleSky.opacity(0.2))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "globe")
                            .font(.system(size: 22))
                            .foregroundColor(.gentleSky)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Support Website")
                            .font(ResetTypography.heading(16))
                            .foregroundColor(.primary)
                        
                        Text("Visit our help center")
                            .font(ResetTypography.caption(13))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding(ResetSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemGroupedBackground))
                        .resetShadow(radius: 6, opacity: 0.06)
                )
            }
        }
    }
    
    // MARK: - Additional Info
    private var additionalInfoSection: some View {
        VStack(alignment: .leading, spacing: ResetSpacing.md) {
            Text("Response Time")
                .font(ResetTypography.heading(16))
                .foregroundColor(.primary)
            
            Text("We typically respond to support inquiries within 24-48 hours during business days. For urgent issues, please include \"URGENT\" in your email subject line.")
                .font(ResetTypography.body(14))
                .foregroundColor(.secondary)
            
            Divider()
                .padding(.vertical, ResetSpacing.sm)
            
            Text("Before contacting support, please include:")
                .font(ResetTypography.caption(13))
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: ResetSpacing.xs) {
                BulletItem(text: "Your device model (e.g., iPhone 14)")
                BulletItem(text: "iOS version (e.g., iOS 17.0)")
                BulletItem(text: "ResetNow app version")
                BulletItem(text: "A description of the issue")
                BulletItem(text: "Steps to reproduce the problem")
            }
        }
        .padding(ResetSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.warmGray.opacity(0.08))
        )
    }
    
    // MARK: - Actions
    private func openEmail() {
        let subject = "ResetNow Support Request"
        let body = """
        
        ---
        Device: \(UIDevice.current.model)
        iOS Version: \(UIDevice.current.systemVersion)
        App Version: \(AppConstants.appVersion)
        """
        
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let url = URL(string: "mailto:\(AppConstants.supportEmail)?subject=\(encodedSubject)&body=\(encodedBody)") {
            openURL(url)
        }
    }
    
    private func openSupportWebsite() {
        if let url = URL(string: AppConstants.supportURL) {
            openURL(url)
        }
    }
}

// MARK: - Help Topic Row
struct HelpTopicRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: ResetSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.calmSage)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(ResetTypography.heading(14))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(ResetTypography.caption(12))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, ResetSpacing.xs)
    }
}

// MARK: - Bullet Item
struct BulletItem: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: ResetSpacing.sm) {
            Text("•")
                .foregroundColor(.secondary)
            Text(text)
                .font(ResetTypography.caption(12))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview
struct SupportContactView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SupportContactView()
        }
    }
}

/*
 IMPORTANT: App Store Connect Configuration
 
 Before submitting to App Store:
 
 1. Support URL:
    - Go to App Store Connect → Your App → App Information
    - Set "Support URL" to the same URL as AppConstants.supportURL
    - Ensure this URL leads to a functional support page
    - DO NOT use a Notion editing URL or other non-public links
 
 2. The support page should:
    - Be accessible without login
    - Clearly explain how users can get help
    - Include contact information (email, form, etc.)
    - Be available in the same language(s) as the app
 
 3. Test the support URL before submission:
    - Open it in Safari on iOS
    - Verify it loads correctly
    - Test any contact forms or email links
 */

