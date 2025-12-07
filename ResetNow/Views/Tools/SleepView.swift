//
//  SleepView.swift
//  ResetNow
//
//  Sleep sounds and calming audio for rest
//

import SwiftUI
import AVFoundation

struct SleepView: View {
    @State private var selectedTrack: SleepTrack?
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: ResetSpacing.lg) {
                // Header
                headerSection
                
                // Featured track
                if let featured = SleepTrack.samples.first {
                    FeaturedSleepCard(track: featured) {
                        selectedTrack = featured
                    }
                }
                
                // All tracks
                tracksListSection
            }
            .padding(.horizontal, ResetSpacing.md)
            .padding(.bottom, ResetSpacing.xxl)
        }
        .background(
            ZStack {
                AnimatedGradientBackground(colors: [Color.twilightGradientStart, Color.deepSlate, Color.black])
                FloatingParticles(colors: [.white.opacity(0.5), .softLavender.opacity(0.3)])
                    .opacity(0.3)
            }
        )
        .navigationTitle("Sleep")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedTrack) { track in
            SleepPlayerView(track: track)
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: ResetSpacing.sm) {
            Text("Drift into peaceful rest")
                .font(ResetTypography.body(16))
                .foregroundColor(.white.opacity(0.8))
            
            Text("Long-playing sounds to help you fall asleep and stay asleep.")
                .font(ResetTypography.body(14))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, ResetSpacing.sm)
    }
    
    private var tracksListSection: some View {
        VStack(alignment: .leading, spacing: ResetSpacing.md) {
            Text("All Sounds")
                .font(ResetTypography.heading(18))
                .foregroundColor(.white)
            
            ForEach(SleepTrack.samples) { track in
                SleepTrackRow(track: track) {
                    selectedTrack = track
                }
            }
        }
    }
    
    private var backgroundGradient: some View {
        AdaptiveColors.gradient(for: colorScheme)
    }
}

// MARK: - Featured Sleep Card
struct FeaturedSleepCard: View {
    let track: SleepTrack
    let action: () -> Void
    
    @State private var animateStars = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.twilightGradientStart,
                                Color.twilightGradientEnd
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Stars decoration
                StarsOverlay()
                    .opacity(animateStars ? 0.8 : 0.4)
                    .animation(
                        Animation.easeInOut(duration: 2).repeatForever(autoreverses: true),
                        value: animateStars
                    )
                
                // Content
                VStack(alignment: .leading, spacing: ResetSpacing.md) {
                    HStack {
                        Image(systemName: track.iconName)
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Spacer()
                        
                        Text(formatDuration(track.durationMinutes))
                            .font(ResetTypography.caption(12))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.2))
                            )
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Featured Tonight")
                            .font(ResetTypography.caption(12))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text(track.name)
                            .font(ResetTypography.display(24))
                            .foregroundColor(.white)
                        
                        Text(track.description)
                            .font(ResetTypography.body(14))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    // Play button
                    HStack {
                        Spacer()
                        
                        HStack(spacing: ResetSpacing.sm) {
                            Image(systemName: "play.fill")
                            Text("Play")
                        }
                        .font(ResetTypography.heading(14))
                        .foregroundColor(.twilightGradientStart)
                        .padding(.horizontal, ResetSpacing.lg)
                        .padding(.vertical, ResetSpacing.sm + 2)
                        .background(
                            Capsule()
                                .fill(Color(.secondarySystemGroupedBackground))
                        )
                    }
                }
                .padding(ResetSpacing.lg)
            }
            .frame(height: 220)
        }
        .onAppear {
            animateStars = true
        }
        .accessibilityLabel("Featured: \(track.name)")
        .accessibilityHint("Double tap to play")
    }
    
    private func formatDuration(_ minutes: Int) -> String {
        let hours = minutes / 60
        if hours >= 1 {
            return "\(hours)h"
        }
        return "\(minutes)m"
    }
}

// MARK: - Stars Overlay
struct StarsOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<20, id: \.self) { i in
                Circle()
                    .fill(Color(.secondarySystemGroupedBackground))
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: CGFloat.random(in: 0...geometry.size.height)
                    )
            }
        }
    }
}

// MARK: - Sleep Track Row
struct SleepTrackRow: View {
    let track: SleepTrack
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: ResetSpacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.sleepColor.opacity(0.6), Color.sleepColor.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: track.iconName)
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(track.name)
                            .font(ResetTypography.heading(16))
                            .foregroundColor(.white)
                        

                    }
                    
                    Text(track.description)
                        .font(ResetTypography.caption(13))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(formatDuration(track.durationMinutes))
                        .font(ResetTypography.caption(12))
                        .foregroundColor(.white.opacity(0.7))
                    
                    // Tags
                    HStack(spacing: 4) {
                        ForEach(track.tags.prefix(2), id: \.self) { tag in
                            Text(tag)
                                .font(ResetTypography.caption(10))
                                .foregroundColor(.sleepColor)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(Color.sleepColor.opacity(0.15))
                                )
                        }
                    }
                }
            }
            .padding(ResetSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .accessibilityLabel("\(track.name), \(formatDuration(track.durationMinutes))")
        .accessibilityHint("Double tap to play")
    }
    
    private func formatDuration(_ minutes: Int) -> String {
        let hours = minutes / 60
        if hours >= 1 {
            return "\(hours)h"
        }
        return "\(minutes)m"
    }
}

// MARK: - Sleep Player View
struct SleepPlayerView: View {
    let track: SleepTrack
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @StateObject private var audioService = AudioService.shared
    
    @State private var fadeOutTimer: Int = 0 // 0 means no timer
    @State private var showTimerPicker = false
    @State private var animatePulse = false
    
    // Timer options in minutes: Off, 15min to 9 hours
    let timerOptions = [0, 15, 30, 45, 60, 90, 120, 180, 240, 300, 360, 420, 480, 540]
    
    private var isPlaying: Bool { audioService.isPlaying }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                backgroundGradient
                    .ignoresSafeArea()
                
                // Stars
                StarsOverlay()
                    .opacity(0.6)
                
                VStack(spacing: ResetSpacing.xl) {
                    Spacer()
                    
                    // Main visual
                    ZStack {
                        // Pulsing circles
                        ForEach(0..<3, id: \.self) { i in
                            Circle()
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                .frame(width: 200 + CGFloat(i * 50), height: 200 + CGFloat(i * 50))
                                .scaleEffect(animatePulse ? 1.1 : 1.0)
                                .animation(
                                    Animation.easeInOut(duration: 3)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(i) * 0.3),
                                    value: animatePulse
                                )
                        }
                        
                        // Icon
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 160, height: 160)
                            
                            Image(systemName: track.iconName)
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Track info
                    VStack(spacing: ResetSpacing.sm) {
                        Text(track.name)
                            .font(ResetTypography.display(28))
                            .foregroundColor(.white)
                        
                        Text(track.description)
                            .font(ResetTypography.body(16))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, ResetSpacing.xl)
                    }
                    
                    Spacer()
                    
                    // Timer button
                    Button(action: { showTimerPicker = true }) {
                        HStack(spacing: ResetSpacing.sm) {
                            Image(systemName: "timer")
                            Text(fadeOutTimer == 0 ? "Set sleep timer" : "Timer: \(formatTimer(fadeOutTimer))")
                        }
                        .font(ResetTypography.body(14))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, ResetSpacing.lg)
                        .padding(.vertical, ResetSpacing.sm + 2)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.1))
                        )
                    }
                    .accessibilityLabel(fadeOutTimer == 0 ? "Set sleep timer" : "Timer set for \(formatTimer(fadeOutTimer))")
                    .accessibilityHint("Double tap to change timer duration")
                    
                    // Play controls
                    HStack(spacing: ResetSpacing.xxl) {
                        // Volume/mute
                        Button(action: {}) {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .frame(minWidth: 44, minHeight: 44)
                        .accessibilityLabel("Volume Controls")
                        
                        // Play/Pause
                        Button(action: { togglePlayback() }) {
                            ZStack {
                                Circle()
                                    .fill(Color(.secondarySystemGroupedBackground))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.twilightGradientStart)
                            }
                        }
                        .accessibilityLabel(isPlaying ? "Pause" : "Play")
                        .accessibilityHint("Double tap to toggle playback")
                        
                        // Loop indicator
                        Button(action: {}) {
                            Image(systemName: "repeat")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, ResetSpacing.xxl)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
                    .accessibilityLabel("Close Player")
                }
            }
        }
        .onAppear {
            animatePulse = true
            // Auto-start playback only if not already playing this track
            if audioService.currentTrack?.id != track.id {
                audioService.play(track: track)
            }
        }
        .onDisappear {
            // DON'T stop audio when sheet closes - let it play in background!
            // Audio continues for sleep sounds feature
            // Only save session if we actually played something
            if audioService.currentTrack?.id == track.id {
                saveSession()
            }
        }
        .onChange(of: fadeOutTimer) { _, newValue in
            audioService.setSleepTimer(minutes: newValue)
        }
        .confirmationDialog("Sleep Timer", isPresented: $showTimerPicker) {
            ForEach(timerOptions, id: \.self) { time in
                Button(time == 0 ? "Off" : formatTimer(time)) {
                    fadeOutTimer = time
                }
            }
        } message: {
            Text("Sound will fade out and stop after the selected time")
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.twilightGradientStart,
                Color.twilightGradientEnd,
                Color.black.opacity(0.3)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private func togglePlayback() {
        if isPlaying {
            audioService.pause()
        } else {
            audioService.play(track: track)
        }
    }
    
    private func formatTimer(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let mins = minutes % 60
            if mins == 0 {
                return hours == 1 ? "1 hour" : "\(hours) hours"
            } else {
                return "\(hours)h \(mins)m"
            }
        }
    }
    
    private func saveSession() {
        appState.incrementResets()
        
        let persistence = PersistenceController.shared
        let session = persistence.createSession(tool: .sleep, subtypeId: track.id)
        persistence.endSession(session)
    }
}

// MARK: - Preview
struct SleepView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationStack {
                SleepView()
                    .environmentObject(AppState())
            }
            .previewDisplayName("Light Mode")
            
            NavigationStack {
                SleepView()
                    .environmentObject(AppState())
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}

