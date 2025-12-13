//
//  VisualizeView.swift
//  ResetNow
//
//  Guided body scans and visualization exercises
//

import SwiftUI

struct VisualizeView: View {
    @State private var selectedVisualization: Visualization?
    @State private var showPaywall = false
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var storeManager: StoreManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: ResetSpacing.lg) {
                // Header
                headerSection
                
                // Quick grounding exercise
                quickGroundingCard
                
                // Visualizations list
                visualizationsListSection
            }
            .padding(.horizontal, ResetSpacing.md)
            .padding(.bottom, ResetSpacing.xxl)
        }
        .background(
            ZStack {
                AnimatedGradientBackground(colors: [Color.visualizeColor.opacity(0.3), Color.gentleSky.opacity(0.2), Color.creamWhite])
                FloatingParticles(colors: [.visualizeColor, .gentleSky])
                    .opacity(0.4)
            }
        )
        .navigationTitle("Visualize")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedVisualization) { visualization in
            VisualizationSessionView(visualization: visualization)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: ResetSpacing.sm) {
            Text("Ground yourself in the present")
                .font(ResetTypography.body(16))
                .foregroundColor(.primary.opacity(0.8))
            
            Text("Guided exercises to help you feel safe, calm, and connected to your body.")
                .font(ResetTypography.body(14))
                .foregroundColor(.primary.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, ResetSpacing.sm)
    }
    
    private var quickGroundingCard: some View {
        Button(action: { startQuickGrounding() }) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.visualizeColor,
                                Color.visualizeColor.opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color.visualizeColor.opacity(0.3), radius: 12, y: 6)
                
                // Decorative circles
                HStack {
                    Spacer()
                    VStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 80, height: 80)
                            .offset(x: 20, y: -10)
                        Spacer()
                    }
                }
                
                HStack(spacing: ResetSpacing.lg) {
                    VStack(alignment: .leading, spacing: ResetSpacing.sm) {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Quick Grounding")
                        }
                        .font(ResetTypography.caption(12))
                        .foregroundColor(.white.opacity(0.8))
                        
                        Text("5-4-3-2-1")
                            .font(ResetTypography.display(28))
                            .foregroundColor(.white)
                        
                        Text("A 2-minute sensory grounding exercise")
                            .font(ResetTypography.body(14))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.white)
                }
                .padding(ResetSpacing.lg)
            }
            .frame(height: 140)
        }
        .accessibilityLabel("Start Quick Grounding")
        .accessibilityHint("Begins a 2-minute 5-4-3-2-1 grounding exercise")
    }
    
    private var visualizationsListSection: some View {
        VStack(alignment: .leading, spacing: ResetSpacing.xl) {
            ForEach(Visualization.VisualizationCategory.allCases, id: \.self) { category in
                VStack(alignment: .leading, spacing: ResetSpacing.md) {
                    Text(category.rawValue)
                        .font(ResetTypography.heading(20))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 4)
                    
                    ForEach(Visualization.samples.filter { $0.category == category }) { visualization in
                        VisualizationCard(visualization: visualization, isLocked: visualization.isPremium && !storeManager.hasPremiumAccess) {
                            if visualization.isPremium && !storeManager.hasPremiumAccess {
                                showPaywall = true
                            } else {
                                selectedVisualization = visualization
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var backgroundGradient: some View {
        AdaptiveColors.gradient(for: colorScheme)
    }
    
    private func startQuickGrounding() {
        if let grounding = Visualization.samples.first(where: { $0.title == "5-4-3-2-1" }) {
            selectedVisualization = grounding
        }
    }
}

// MARK: - Visualization Card
struct VisualizationCard: View {
    let visualization: Visualization
    let isLocked: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: ResetSpacing.md) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(categoryColor.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: visualization.iconName)
                        .font(.system(size: 20))
                        .foregroundColor(categoryColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(visualization.title)
                            .font(ResetTypography.heading(16))
                            .foregroundColor(.primary)
                        
                        if isLocked {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Text(visualization.description)
                        .font(ResetTypography.caption(13))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack(spacing: ResetSpacing.sm) {
                        // Duration
                        HStack(spacing: 2) {
                            Image(systemName: "clock")
                                .font(.system(size: 10))
                            Text("\(visualization.durationMinutes) min")
                                .font(ResetTypography.caption(11))
                        }
                        .foregroundColor(.secondary)
                        
                        // Category badge
                        Text(visualization.category.rawValue)
                            .font(ResetTypography.caption(10))
                            .foregroundColor(categoryColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(categoryColor.opacity(0.15))
                            )
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(ResetSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    )
                    .shadow(color: categoryColor.opacity(0.15), radius: 8, y: 4)
            )
        }
        .accessibilityLabel("\(visualization.title), \(visualization.durationMinutes) minutes")
        .accessibilityHint("Double tap to start this visualization")
    }
    
    private var categoryColor: Color {
        switch visualization.category {
        case .quickGrounding: return .warmPeach
        case .bodyScans: return .calmSage
        case .guidedScenes: return .softLavender
        case .emotionalSupport: return .gentleSky
        }
    }
}

import AVFoundation

// ... (VisualizeView and VisualizationCard remain unchanged)

// MARK: - Visualization Session View
struct VisualizationSessionView: View {
    let visualization: Visualization
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    
    @State private var currentStep = 0
    @State private var sessionComplete = false
    @State private var animatePulse = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isMuted = false
    
    private var steps: [String] {
        visualization.steps
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                backgroundGradient
                    .ignoresSafeArea()
                
                if !sessionComplete {
                    activeSessionView
                } else {
                    completionView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        stopAudio()
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
                    .accessibilityLabel("Close Session")
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    if visualization.audioFileName != nil {
                        Button(action: toggleMute) {
                            Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                .foregroundColor(.secondary)
                        }
                        .frame(minWidth: 44, minHeight: 44)
                        .contentShape(Rectangle())
                        .accessibilityLabel(isMuted ? "Unmute Audio" : "Mute Audio")
                    }
                }
            }
        }
        .onAppear {
            animatePulse = true
            playAudio()
        }
        .onDisappear {
            stopAudio()
        }
    }
    
    // MARK: - Active Session View
    private var activeSessionView: some View {
        VStack(spacing: ResetSpacing.xl) {
            Text(visualization.title)
                .font(ResetTypography.heading(24))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, ResetSpacing.lg)
                .padding(.top, ResetSpacing.md)
            
            // Progress indicator
            ProgressView(value: Double(currentStep), total: Double(steps.count))
                .tint(.visualizeColor)
                .padding(.horizontal, ResetSpacing.xl)
            
            Text("Step \(currentStep + 1) of \(steps.count)")
                .font(ResetTypography.caption(13))
                .foregroundColor(.secondary)
            
            Spacer()
            
            // Animated visual
            ZStack {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(Color.visualizeColor.opacity(0.2), lineWidth: 2)
                        .frame(width: 160 + CGFloat(i * 40), height: 160 + CGFloat(i * 40))
                        .scaleEffect(animatePulse ? 1.05 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 2.5)
                                .repeatForever(autoreverses: true)
                                .delay(Double(i) * 0.2),
                            value: animatePulse
                        )
                }
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.visualizeColor.opacity(0.6),
                                Color.visualizeColor.opacity(0.2)
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 70
                        )
                    )
                    .frame(width: 140, height: 140)
                
                Image(systemName: visualization.iconName)
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Current instruction
            Text(steps[currentStep])
                .font(ResetTypography.heading(20))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, ResetSpacing.xl)
                .animation(.easeInOut, value: currentStep)
            
            Spacer()
            
            // Navigation
            HStack(spacing: ResetSpacing.xl) {
                Button(action: previousStep) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(currentStep > 0 ? .deepSlate : .warmGray.opacity(0.3))
                        .frame(width: 50, height: 50)
                        .background(Circle().fill(Color.white.opacity(0.8)))
                }
                .disabled(currentStep == 0)
                .accessibilityLabel("Previous Step")
                .accessibilityHint("Go back to the previous instruction")
                
                Button(action: nextStep) {
                    HStack(spacing: ResetSpacing.sm) {
                        Text(currentStep == steps.count - 1 ? "Complete" : "Next")
                        Image(systemName: currentStep == steps.count - 1 ? "checkmark" : "chevron.right")
                    }
                    .font(ResetTypography.heading(16))
                    .foregroundColor(.white)
                    .padding(.horizontal, ResetSpacing.xl)
                    .padding(.vertical, ResetSpacing.md)
                    .background(
                        Capsule()
                            .fill(Color.visualizeColor)
                    )
                }
                .accessibilityLabel(currentStep == steps.count - 1 ? "Complete Session" : "Next Step")
                .accessibilityHint("Proceed to the next instruction")
            }
            .padding(.bottom, ResetSpacing.xl)
        }
    }
    
    // MARK: - Completion View
    private var completionView: some View {
        VStack(spacing: ResetSpacing.xl) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.visualizeColor.opacity(0.2))
                    .frame(width: 150, height: 150)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.visualizeColor)
            }
            
            Text("Beautiful!")
                .font(ResetTypography.display(28))
                .foregroundColor(.primary)
            
            Text("You've completed \(visualization.title)")
                .font(ResetTypography.body(16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text("Take a moment to notice how you feel.")
                .font(ResetTypography.body(14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button("Done") {
                saveSession()
                stopAudio()
                dismiss()
            }
            .buttonStyle(ResetPrimaryButtonStyle())
            .padding(.horizontal, ResetSpacing.xl)
            .padding(.bottom, ResetSpacing.xl)
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.creamWhite,
                Color.visualizeColor.opacity(0.1),
                Color.gentleSky.opacity(0.1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private func previousStep() {
        if currentStep > 0 {
            withAnimation {
                currentStep -= 1
            }
        }
    }
    
    private func nextStep() {
        if currentStep < steps.count - 1 {
            withAnimation {
                currentStep += 1
            }
        } else {
            sessionComplete = true
        }
    }
    
    private func saveSession() {
        appState.incrementResets()
        
        let persistence = PersistenceController.shared
        // Note: subtypeId is now just the visualization ID
        let session = persistence.createSession(tool: .visualize, subtypeId: visualization.id)
        persistence.endSession(session)
    }
    
    // MARK: - Audio Methods
    private func playAudio() {
        guard let fileName = visualization.audioFileName else { return }
        
        // Try to find the file in the bundle
        // We look for mp3 extension
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            print("Audio file not found: \(fileName)")
            return
        }
        
        do {
            // Configure audio session
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.volume = isMuted ? 0 : 0.5 // Start at 50% volume
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Failed to play audio: \(error)")
        }
    }
    
    private func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    private func toggleMute() {
        isMuted.toggle()
        if let player = audioPlayer {
            player.setVolume(isMuted ? 0 : 0.5, fadeDuration: 0.5)
        }
    }
}

// MARK: - Preview
struct VisualizeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationStack {
                VisualizeView()
                    .environmentObject(AppState())
            }
            .previewDisplayName("Light Mode")
            
            NavigationStack {
                VisualizeView()
                    .environmentObject(AppState())
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}

