//
//  BreatheView.swift
//  ResetNow
//
//  Guided breathing exercises with beautiful animations
//

import SwiftUI

struct BreatheView: View {
    @State private var selectedExercise: BreathingExercise?
    @State private var showExerciseDetail = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: ResetSpacing.lg) {
                // Header
                headerSection
                
                // Exercise list
                exerciseListSection
            }
            .padding(.horizontal, ResetSpacing.md)
            .padding(.bottom, ResetSpacing.xxl)
        }
        .background(backgroundGradient.ignoresSafeArea())
        .navigationTitle("Breathe")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedExercise) { exercise in
            BreathingSessionView(exercise: exercise)
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: ResetSpacing.sm) {
            Text("Calm your nervous system")
                .font(ResetTypography.body(16))
                .foregroundColor(.secondary)
            
            Text("Choose a breathing technique and let your body find its calm.")
                .font(ResetTypography.body(14))
                .foregroundColor(.warmGray.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, ResetSpacing.sm)
    }
    
    private var exerciseListSection: some View {
        VStack(spacing: ResetSpacing.md) {
            ForEach(BreathingExercise.presets) { exercise in
                BreathingExerciseCard(exercise: exercise) {
                    selectedExercise = exercise
                }
            }
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.creamWhite,
                Color.calmSage.opacity(0.15)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Breathing Exercise Card
struct BreathingExerciseCard: View {
    let exercise: BreathingExercise
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: ResetSpacing.md) {
                // Animated indicator
                BreathingIndicator()
                    .frame(width: 50, height: 50)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(ResetTypography.heading(16))
                        .foregroundColor(.primary)
                    
                    Text(exercise.description)
                        .font(ResetTypography.caption(13))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    // Timing info
                    HStack(spacing: ResetSpacing.sm) {
                        TimingPill(label: "In", seconds: exercise.inhaleSeconds)
                        if exercise.holdTopSeconds > 0 {
                            TimingPill(label: "Hold", seconds: exercise.holdTopSeconds)
                        }
                        TimingPill(label: "Out", seconds: exercise.exhaleSeconds)
                        if exercise.holdBottomSeconds > 0 {
                            TimingPill(label: "Hold", seconds: exercise.holdBottomSeconds)
                        }
                    }
                    .padding(.top, 4)
                }
                
                Spacer()
                
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.calmSage)
            }
            .padding(ResetSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .resetShadow(radius: 8, opacity: 0.08)
            )
        }
    }
}

// MARK: - Timing Pill
struct TimingPill: View {
    let label: String
    let seconds: Int
    
    var body: some View {
        HStack(spacing: 2) {
            Text(label)
                .font(ResetTypography.caption(10))
            Text("\(seconds)s")
                .font(ResetTypography.caption(10))
                .fontWeight(.semibold)
        }
        .foregroundColor(.calmSage)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(Color.calmSage.opacity(0.15))
        )
    }
}

// MARK: - Breathing Indicator (animated preview)
struct BreathingIndicator: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.calmSage.opacity(0.2))
            
            Circle()
                .fill(Color.calmSage.opacity(0.4))
                .scaleEffect(isAnimating ? 0.8 : 0.5)
            
            Circle()
                .fill(Color.calmSage)
                .scaleEffect(isAnimating ? 0.5 : 0.3)
        }
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 2)
                    .repeatForever(autoreverses: true)
            ) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Breathing Session View
struct BreathingSessionView: View {
    let exercise: BreathingExercise
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    
    @State private var isActive = false
    @State private var phase: BreathPhase = .ready
    @State private var progress: CGFloat = 0
    @State private var cyclesCompleted = 0
    @State private var selectedDuration: Int = 60 // seconds
    @State private var timeRemaining: Int = 60
    @State private var showMoodCheck = false
    @State private var moodBefore: Int = 5
    @State private var moodAfter: Int = 5
    @State private var sessionComplete = false
    
    enum BreathPhase: String {
        case ready = "Ready"
        case inhale = "Breathe In"
        case holdTop = "Hold... "
        case exhale = "Breathe Out"
        case holdBottom = "Hold"
        case complete = "Complete"
    }
    
    let durationOptions = [60, 120, 180, 300]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                backgroundGradient
                    .ignoresSafeArea()
                
                if !isActive && !sessionComplete {
                    // Setup view
                    setupView
                } else if sessionComplete {
                    // Completion view
                    completionView
                } else {
                    // Active breathing view
                    activeBreathingView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - Setup View
    private var setupView: some View {
        VStack(spacing: ResetSpacing.xl) {
            Spacer()
            
            // Exercise info
            VStack(spacing: ResetSpacing.md) {
                Text(exercise.name)
                    .font(ResetTypography.display(28))
                    .foregroundColor(.primary)
                
                Text(exercise.description)
                    .font(ResetTypography.body(16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, ResetSpacing.lg)
            }
            
            // Duration picker
            VStack(spacing: ResetSpacing.md) {
                Text("Duration")
                    .font(ResetTypography.caption(14))
                    .foregroundColor(.secondary)
                
                HStack(spacing: ResetSpacing.md) {
                    ForEach(durationOptions, id: \.self) { duration in
                        DurationButton(
                            duration: duration,
                            isSelected: selectedDuration == duration
                        ) {
                            selectedDuration = duration
                            timeRemaining = duration
                        }
                    }
                }
            }
            
            // Mood check before
            VStack(spacing: ResetSpacing.md) {
                Text("How are you feeling?")
                    .font(ResetTypography.body(16))
                    .foregroundColor(.primary)
                
                MoodSlider(value: $moodBefore, label: "Anxiety Level")
            }
            .padding(.horizontal, ResetSpacing.lg)
            
            Spacer()
            
            // Start button
            Button(action: startSession) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Begin")
                }
            }
            .buttonStyle(ResetPrimaryButtonStyle())
            .padding(.horizontal, ResetSpacing.xl)
            .padding(.bottom, ResetSpacing.xl)
        }
    }
    
    // MARK: - Active Breathing View
    private var activeBreathingView: some View {
        VStack(spacing: ResetSpacing.xl) {
            // Header with Exercise Name & Time
            VStack(spacing: 8) {
                Text(exercise.name.uppercased())
                    .font(ResetTypography.caption(12))
                    .fontWeight(.bold)
                    .tracking(2)
                    .foregroundColor(.secondary)
                    .opacity(0.8)
                
                Text(formatTime(timeRemaining))
                    .font(ResetTypography.heading(32))
                    .monospacedDigit()
                    .foregroundColor(.primary)
            }
            .padding(.top, ResetSpacing.xl)
            
            Spacer()
            
            // Main breathing display
            ZStack {
                // Progress ring background
                Circle()
                    .stroke(Color.calmSage.opacity(0.1), lineWidth: 4)
                    .frame(width: 300, height: 300)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [.calmSage, .softLavender],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 300, height: 300)
                    .rotationEffect(.degrees(-90))
                    .opacity(0.6)
                
                // Professional Animation
                ProfessionalBreathingAnimation(phase: phase, duration: phaseDuration)
                    .frame(width: 250, height: 250)
                
                // Phase text
                if phase != .ready {
                    VStack(spacing: 8) {
                        Text(phase.rawValue)
                            .font(ResetTypography.display(24))
                            .foregroundColor(.primary)
                            .transition(.opacity.combined(with: .scale(scale: 0.9)))
                            .id(phase) // Force transition on change
                        
                        Text("\(cyclesCompleted) cycles")
                            .font(ResetTypography.caption(14))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Controls
            HStack(spacing: ResetSpacing.xl) {
                Button(action: stopSession) {
                    Image(systemName: "stop.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.secondary)
                    .frame(width: 60, height: 60)
                    .background(Circle().fill(Color.white.opacity(0.8)).resetShadow())
                }
                
                Button(action: { isActive.toggle() }) {
                    Image(systemName: isActive ? "pause.fill" : "play.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.calmSage, .calmSage.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .resetShadow(radius: 8)
                    )
                }
            }
            .padding(.bottom, ResetSpacing.xxl)
        }
        .onAppear {
            startBreathingCycle()
        }
    }
    
    // MARK: - Completion View
    private var completionView: some View {
        VStack(spacing: ResetSpacing.xl) {
            Spacer()
            
            // Success animation
            ZStack {
                Circle()
                    .fill(Color.calmSage.opacity(0.2))
                    .frame(width: 150, height: 150)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.calmSage)
            }
            
            Text("Well done!")
                .font(ResetTypography.display(28))
                .foregroundColor(.primary)
            
            Text("You completed \(cyclesCompleted) breathing cycles")
                .font(ResetTypography.body(16))
                .foregroundColor(.secondary)
            
            // Mood check after
            VStack(spacing: ResetSpacing.md) {
                Text("How do you feel now?")
                    .font(ResetTypography.body(16))
                    .foregroundColor(.primary)
                
                MoodSlider(value: $moodAfter, label: "Anxiety Level")
            }
            .padding(.horizontal, ResetSpacing.lg)
            
            // Mood change indicator
            if moodBefore > moodAfter {
                HStack(spacing: ResetSpacing.sm) {
                    Image(systemName: "arrow.down")
                    Text("Your anxiety decreased by \(moodBefore - moodAfter) points")
                }
                .font(ResetTypography.caption(14))
                .foregroundColor(.calmSage)
                .padding(.horizontal, ResetSpacing.md)
                .padding(.vertical, ResetSpacing.sm)
                .background(
                    Capsule()
                        .fill(Color.calmSage.opacity(0.15))
                )
            }
            
            Spacer()
            
            Button("Done") {
                saveSession()
                dismiss()
            }
            .buttonStyle(ResetPrimaryButtonStyle())
            .padding(.horizontal, ResetSpacing.xl)
            .padding(.bottom, ResetSpacing.xl)
        }
    }
    
    // MARK: - Helpers
    private var circleSize: CGFloat {
        switch phase {
        case .ready: return 80
        case .inhale: return 180
        case .holdTop: return 180
        case .exhale: return 80
        case .holdBottom: return 80
        case .complete: return 120
        }
    }
    
    private var phaseDuration: Double {
        switch phase {
        case .ready: return 0.5
        case .inhale: return Double(exercise.inhaleSeconds)
        case .holdTop: return Double(exercise.holdTopSeconds)
        case .exhale: return Double(exercise.exhaleSeconds)
        case .holdBottom: return Double(exercise.holdBottomSeconds)
        case .complete: return 0.5
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.creamWhite,
                Color.calmSage.opacity(0.1),
                Color.softLavender.opacity(0.1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
    
    private func startSession() {
        isActive = true
        timeRemaining = selectedDuration
        startBreathingCycle()
        startTimer()
    }
    
    private func stopSession() {
        isActive = false
        sessionComplete = true
    }
    
    private var totalDuration: Double {
        Double(exercise.inhaleSeconds + exercise.holdTopSeconds + exercise.exhaleSeconds + exercise.holdBottomSeconds)
    }

    private func startBreathingCycle() {
        guard isActive else { return }
        
        // Inhale
        phase = .inhale
        let inhaleEnd = Double(exercise.inhaleSeconds) / totalDuration
        
        withAnimation(.linear(duration: phaseDuration)) {
            progress = inhaleEnd
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + phaseDuration) {
            guard self.isActive else { return }
            
            // Hold top
            if self.exercise.holdTopSeconds > 0 {
                self.phase = .holdTop
                let holdTopEnd = Double(self.exercise.inhaleSeconds + self.exercise.holdTopSeconds) / self.totalDuration
                
                withAnimation(.linear(duration: self.phaseDuration)) {
                    self.progress = holdTopEnd
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + self.phaseDuration) {
                    self.continueToExhale()
                }
            } else {
                self.continueToExhale()
            }
        }
    }
    
    private func continueToExhale() {
        guard isActive else { return }
        
        // Exhale
        phase = .exhale
        let timeSoFar = Double(exercise.inhaleSeconds + exercise.holdTopSeconds)
        let exhaleEnd = (timeSoFar + Double(exercise.exhaleSeconds)) / totalDuration
        
        withAnimation(.linear(duration: phaseDuration)) {
            progress = exhaleEnd
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + phaseDuration) {
            guard self.isActive else { return }
            
            // Hold bottom
            if self.exercise.holdBottomSeconds > 0 {
                self.phase = .holdBottom
                withAnimation(.linear(duration: self.phaseDuration)) {
                    self.progress = 1.0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + self.phaseDuration) {
                    self.completeCycle()
                }
            } else {
                self.completeCycle()
            }
        }
    }
    
    private func completeCycle() {
        guard isActive else { return }
        cyclesCompleted += 1
        progress = 0
        startBreathingCycle()
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if !isActive || timeRemaining <= 0 {
                timer.invalidate()
                if timeRemaining <= 0 {
                    sessionComplete = true
                    isActive = false
                }
                return
            }
            timeRemaining -= 1
        }
    }
    
    private func saveSession() {
        appState.incrementResets()
        
        let persistence = PersistenceController.shared
        let session = persistence.createSession(tool: .breathe, subtypeId: exercise.id)
        persistence.endSession(session)
        _ = persistence.createMoodCheck(
            session: session,
            type: .anxiety,
            before: moodBefore,
            after: moodAfter
        )
    }
}

// MARK: - Duration Button
struct DurationButton: View {
    let duration: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(formatDuration(duration))
                .font(ResetTypography.caption(14))
                .foregroundColor(isSelected ? .white : .deepSlate)
                .padding(.horizontal, ResetSpacing.md)
                .padding(.vertical, ResetSpacing.sm)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.calmSage : Color.white.opacity(0.8))
                )
        }
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let mins = seconds / 60
        return "\(mins) min"
    }
}

// MARK: - Professional Breathing Animation
struct ProfessionalBreathingAnimation: View {
    let phase: BreathingSessionView.BreathPhase
    let duration: Double
    
    // Derived state for animation scaling
    private var scale: CGFloat {
        switch phase {
        case .ready: return 0.3
        case .inhale: return 1.0
        case .holdTop: return 1.05 // Slight pulse at top
        case .exhale: return 0.3
        case .holdBottom: return 0.3
        case .complete: return 0.0
        }
    }
    
    // Rotation logic
    private var rotation: Double {
        switch phase {
        case .inhale: return 45
        case .exhale: return 0
        default: return 0
        }
    }
    
    var body: some View {
        ZStack {
            // Layer 1: Ambient Glow (Expands most)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.calmSage.opacity(0.3),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 150
                    )
                )
                .scaleEffect(scale * 1.2)
                .opacity(phase == .holdTop ? 0.6 : 0.4)
                .animation(.easeInOut(duration: duration), value: phase)
            
            // Layer 2: Flower Petals
            ForEach(0..<6) { i in
                Circle()
                    .fill(Color.calmSage.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .offset(y: -60) // Offset from center
                    .rotationEffect(.degrees(Double(i) * 60))
                    .rotationEffect(.degrees(rotation)) // Spin slightly while breathing
                    .scaleEffect(scale)
                    .animation(
                        .easeInOut(duration: duration),
                        value: phase
                    )
            }
            
            // Layer 3: Inner Core
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.9), .calmSage.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)
                .scaleEffect(scale * 0.8)
                .shadow(color: .calmSage.opacity(0.3), radius: 10)
                .animation(.easeInOut(duration: duration), value: phase)
        }
    }
}

// MARK: - Mood Slider
struct MoodSlider: View {
    @Binding var value: Int
    let label: String
    
    var body: some View {
        VStack(spacing: ResetSpacing.sm) {
            HStack {
                Text("Low")
                    .font(ResetTypography.caption(12))
                    .foregroundColor(.secondary)
                Spacer()
                Text("High")
                    .font(ResetTypography.caption(12))
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: ResetSpacing.sm) {
                ForEach(0..<11) { i in
                    Button(action: { value = i }) {
                        Circle()
                            .fill(i <= value ? moodColor(for: i) : Color.warmGray.opacity(0.2))
                            .frame(width: 24, height: 24)
                    }
                }
            }
            
            Text(moodLabel(for: value))
                .font(ResetTypography.caption(12))
                .foregroundColor(moodColor(for: value))
        }
    }
    
    private func moodColor(for value: Int) -> Color {
        switch value {
        case 0...2: return .calmSage
        case 3...4: return .gentleSky
        case 5...6: return .warmPeach
        case 7...8: return .softRose
        default: return .sosRed.opacity(0.8)
        }
    }
    
    private func moodLabel(for value: Int) -> String {
        switch value {
        case 0...2: return "Very calm"
        case 3...4: return "Slightly uneasy"
        case 5...6: return "Moderate anxiety"
        case 7...8: return "High anxiety"
        default: return "Very anxious"
        }
    }
}

// MARK: - Preview
struct BreatheView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BreatheView()
                .environmentObject(AppState())
        }
    }
}

