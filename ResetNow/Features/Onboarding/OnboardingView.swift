//
//  OnboardingView.swift
//  ResetNow
//
//  Professional onboarding with mood check and personalization
//

import SwiftUI

// MARK: - Main Onboarding View
struct OnboardingView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var persistence: PersistenceController
    
    // Onboarding Data
    @State private var displayName = ""
    @State private var selectedMood: MoodLevel = .neutral
    @State private var selectedAge: AgeGroup = .youngAdult
    @State private var selectedConcerns: Set<Concern> = []
    @State private var selectedGoals: Set<Goal> = []
    @State private var selectedExperience: ExperienceLevel = .beginner
    @State private var selectedTheme: PreferredTheme = .system
    @State private var notificationsEnabled: Bool = false
    
    // Animation states
    @State private var step = 1
    @State private var isNameFocused = false
    
    var body: some View {
        ZStack {
            // Background
            OnboardingBackground(step: step)
                .ignoresSafeArea()
            
            // Content
            VStack {
                // Progress bar
                ProgressBar(currentStep: step, totalSteps: 9)
                    .padding(.top, 20)
                    .padding(.horizontal, 24)
                
                TabView(selection: $step) {
                    WelcomeStep(onNext: nextStep)
                        .tag(1)
                    
                    NameStep(displayName: $displayName, onNext: nextStep)
                        .tag(2)
                    
                    MoodCheckStep(selectedMood: $selectedMood, onNext: nextStep)
                        .tag(3)
                    
                    AgeGroupStep(selectedAge: $selectedAge, onNext: nextStep)
                        .tag(4)
                    
                    ConcernsStep(selectedConcerns: $selectedConcerns, onNext: nextStep)
                        .tag(5)
                    
                    GoalsStep(selectedGoals: $selectedGoals, onNext: nextStep)
                        .tag(6)
                        
                    ExperienceLevelStep(selectedExperience: $selectedExperience, onNext: nextStep)
                        .tag(7)
                        
                    ThemeStep(selectedTheme: $selectedTheme, onNext: nextStep)
                        .tag(8)
                    
                    NotificationStep(isEnabled: $notificationsEnabled, onNext: nextStep)
                        .tag(9)
                    
                    DisclaimerStep(onComplete: completeOnboarding)
                        .tag(10)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.5), value: step)
            }
        }
        .interactiveDismissDisabled()
    }
    
    private func nextStep() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            step += 1
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        }
    }
    
    private func completeOnboarding() {
        // Save onboarding data
        appState.hasAcceptedDisclaimer = true
        appState.hasCompletedOnboarding = true
        
        // Save user's display name
        let name = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !name.isEmpty {
            appState.userDisplayName = name
        }
        
        // Save initial mood as a mood checkin
        let moodValue = moodToValue(selectedMood)
        persistence.createMoodCheckin(sessionId: nil, type: .mood, before: moodValue, after: nil)
        
        // Save full profile
        var profile = persistence.userProfile
        profile.displayName = name.isEmpty ? nil : name
        profile.ageGroup = selectedAge
        profile.concerns = selectedConcerns
        profile.experienceLevel = selectedExperience
        profile.goals = selectedGoals
        profile.preferredTheme = selectedTheme
        profile.enabledNotifications = notificationsEnabled
        profile.completedOnboarding = true
        profile.acceptedDisclaimerAt = Date()
        
        persistence.updateProfile(profile)
        
        // Close onboarding
        withAnimation(.spring(response: 0.5)) {
            isPresented = false
        }
    }
    
    private func moodToValue(_ mood: MoodLevel) -> Int {
        switch mood {
        case .veryLow: return 1
        case .low: return 2
        case .neutral: return 3
        case .good: return 4
        case .great: return 5
        }
    }
}

// MARK: - Step 1: Welcome
struct WelcomeStep: View {
    let onNext: () -> Void
    @State private var animateLogo = false
    @State private var animateText = false
    @State private var animateButton = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Animated mascot with bounce and float effect
            ZStack {
                // Outer glow pulse
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.calmSage.opacity(0.5), Color.clear],
                            center: .center,
                            startRadius: 50,
                            endRadius: 180
                        )
                    )
                    .frame(width: 320, height: 320)
                    .scaleEffect(animateLogo ? 1.15 : 0.85)
                    .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: animateLogo)
                
                // Inner glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.softLavender.opacity(0.4), Color.clear],
                            center: .center,
                            startRadius: 30,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                    .scaleEffect(animateLogo ? 1.0 : 1.2)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true).delay(0.3), value: animateLogo)
                
                // Mascot with floating animation
                Image("MascotBlue")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 250)
                    .offset(y: animateLogo ? -10 : 10)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animateLogo)
                    .shadow(color: Color.calmSage.opacity(0.3), radius: 20, x: 0, y: 10)
            }
            .scaleEffect(animateLogo ? 1 : 0.3)
            .opacity(animateLogo ? 1 : 0)
            .animation(.spring(response: 0.8, dampingFraction: 0.6), value: animateLogo)
            
            // Welcome text
            VStack(spacing: 16) {
                Text("Welcome to")
                    .font(ResetTypography.heading(18))
                    .foregroundColor(.white.opacity(0.8))
                
                Text("ResetNow")
                    .font(ResetTypography.display(42))
                    .foregroundColor(.white)
                
                Text("Your pocket companion for calm")
                    .font(ResetTypography.body(16))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .opacity(animateText ? 1 : 0)
            .offset(y: animateText ? 0 : 20)
            
            Spacer()
            
            // Get started button
            Button(action: {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                onNext()
            }) {
                HStack(spacing: 12) {
                    Text("Let's Begin")
                        .font(ResetTypography.heading(18))
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .font(ResetTypography.heading(22))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        colors: [Color.calmSage, Color.calmSage.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.calmSage.opacity(0.4), radius: 12, y: 6)
            }
            .accessibilityLabel("Let's Begin")
            .accessibilityHint("Starts the onboarding process")
            .padding(.horizontal, 24)
            .opacity(animateButton ? 1 : 0)
            .offset(y: animateButton ? 0 : 30)
            
            Spacer().frame(height: 40)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                animateLogo = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
                animateText = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.8)) {
                animateButton = true
            }
        }
    }
}

// MARK: - Step 2: Name
struct NameStep: View {
    @Binding var displayName: String
    let onNext: () -> Void
    @State private var animate = false
    @FocusState private var isNameFocused: Bool
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Friendly icon
            ZStack {
                Circle()
                    .fill(Color.calmSage.opacity(0.2))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "person.crop.circle.fill")
                    .font(ResetTypography.display(50))
                    .foregroundColor(.calmSage)
            }
            
            // Title
            VStack(spacing: 12) {
                Text("What should I call you?")
                    .font(ResetTypography.display(28))
                    .foregroundColor(.white)
                
                Text("We'll use this to personalize your experience")
                    .font(ResetTypography.body(15))
                    .foregroundColor(.white.opacity(0.7))
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
            
            // Name input
            VStack(spacing: 16) {
                TextField("Your first name", text: $displayName)
                    .font(ResetTypography.body(20))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .focused($isNameFocused)
                    .submitLabel(.continue)
                    .onSubmit {
                        if !displayName.isEmpty {
                            onNext()
                        }
                    }
                
                Text("Or skip if you prefer")
                    .font(ResetTypography.caption(14))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Continue button
            Button(action: {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                isNameFocused = false // Dismiss keyboard
                // Small delay to allow keyboard to start dismissing before transition
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    onNext()
                }
            }) {
                HStack(spacing: 8) {
                    Text(displayName.isEmpty ? "Skip for now" : "Continue")
                        .font(ResetTypography.heading(17))
                    
                    Image(systemName: "arrow.right")
                        .font(ResetTypography.heading(15))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.calmSage)
                )
                .shadow(color: Color.calmSage.opacity(0.3), radius: 8, y: 4)
            }
            .accessibilityLabel(displayName.isEmpty ? "Skip name entry" : "Continue with name \(displayName)")
            .accessibilityHint("Proceeds to the next step")
            .padding(.horizontal, 24)
            
            Spacer().frame(height: 40)
        }
        .opacity(animate ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animate = true
            }
            // Auto-focus the text field
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isNameFocused = true
            }
        }
    }
}

// Eye component for mascot
struct Eye: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 28, height: 28)
            Circle()
                .fill(Color(hex: "1E3A5F"))
                .frame(width: 14, height: 14)
        }
    }
}

// MARK: - Step 2: Mood Check
struct MoodCheckStep: View {
    @Binding var selectedMood: MoodLevel
    let onNext: () -> Void
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Title
            VStack(spacing: 12) {
                Text("How are you feeling?")
                    .font(ResetTypography.display(28))
                    .foregroundColor(.white)
                
                Text("This helps us personalize your experience")
                    .font(ResetTypography.body(15))
                    .foregroundColor(.white.opacity(0.7))
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
            
            // Mood options
            HStack(spacing: 12) {
                ForEach(MoodLevel.allCases, id: \.self) { mood in
                    MoodButton(
                        mood: mood,
                        isSelected: selectedMood == mood,
                        action: {
                            let generator = UISelectionFeedbackGenerator()
                            generator.selectionChanged()
                            selectedMood = mood
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            
            // Selected mood feedback
            Text(selectedMood.rawValue)
                .font(ResetTypography.heading(20))
                .foregroundColor(selectedMood.color)
                .padding(.top, 8)
            
            Spacer()
            
            // Continue button
            ContinueButton(action: onNext)
                .padding(.horizontal, 24)
            
            Spacer().frame(height: 40)
        }
        .opacity(animate ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animate = true
            }
        }
    }
}

struct MoodButton: View {
    let mood: MoodLevel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(mood.emoji)
                    .font(ResetTypography.display(isSelected ? 44 : 36))
            }
            .frame(width: 60, height: 70)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? mood.color.opacity(0.3) : Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? mood.color : Color.clear, lineWidth: 2)
                    )
            )
            .scaleEffect(isSelected ? 1.1 : 1.0)
            .animation(.spring(response: 0.3), value: isSelected)
        }
        .accessibilityLabel(mood.rawValue)
        .accessibilityHint("Double tap to select this mood")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : [.isButton])
    }
}

// MARK: - Step 3: Age Group
struct AgeGroupStep: View {
    @Binding var selectedAge: AgeGroup
    let onNext: () -> Void
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Title
            VStack(spacing: 12) {
                Text("What's your age group?")
                    .font(ResetTypography.display(28))
                    .foregroundColor(.white)
                
                Text("We'll tailor the experience for you")
                    .font(ResetTypography.body(15))
                    .foregroundColor(.white.opacity(0.7))
            }
            .multilineTextAlignment(.center)
            
            // Age options
            VStack(spacing: 12) {
                ForEach(AgeGroup.allCases, id: \.self) { age in
                    SelectionRow(
                        title: age.displayName,
                        isSelected: selectedAge == age,
                        action: {
                            let generator = UISelectionFeedbackGenerator()
                            generator.selectionChanged()
                            selectedAge = age
                        }
                    )
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            ContinueButton(action: onNext)
                .padding(.horizontal, 24)
            
            Spacer().frame(height: 40)
        }
        .opacity(animate ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animate = true
            }
        }
    }
}

// MARK: - Step 4: Concerns
struct ConcernsStep: View {
    @Binding var selectedConcerns: Set<Concern>
    let onNext: () -> Void
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 20)
            
            // Title
            VStack(spacing: 12) {
                Text("What brings you here?")
                    .font(ResetTypography.display(28))
                    .foregroundColor(.white)
                
                Text("Select all that apply")
                    .font(ResetTypography.body(15))
                    .foregroundColor(.white.opacity(0.7))
            }
            .multilineTextAlignment(.center)
            
            // Concerns grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(Concern.allCases, id: \.self) { concern in
                        MultiSelectCard(
                            title: concern.rawValue,
                            icon: concern.icon,
                            isSelected: selectedConcerns.contains(concern),
                            action: {
                                let generator = UISelectionFeedbackGenerator()
                                generator.selectionChanged()
                                if selectedConcerns.contains(concern) {
                                    selectedConcerns.remove(concern)
                                } else {
                                    selectedConcerns.insert(concern)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 24)
            }
            
            ContinueButton(action: onNext, isEnabled: !selectedConcerns.isEmpty)
                .padding(.horizontal, 24)
            
            Spacer().frame(height: 40)
        }
        .opacity(animate ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animate = true
            }
        }
    }
}

// MARK: - Step 5: Goals
struct GoalsStep: View {
    @Binding var selectedGoals: Set<Goal>
    let onNext: () -> Void
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 20)
            
            // Title
            VStack(spacing: 12) {
                Text("What are your goals?")
                    .font(ResetTypography.display(28))
                    .foregroundColor(.white)
                
                Text("We'll help you track progress")
                    .font(ResetTypography.body(15))
                    .foregroundColor(.white.opacity(0.7))
            }
            .multilineTextAlignment(.center)
            
            // Goals list
            VStack(spacing: 12) {
                ForEach(Goal.allCases, id: \.self) { goal in
                    MultiSelectRow(
                        title: goal.rawValue,
                        icon: goal.icon,
                        isSelected: selectedGoals.contains(goal),
                        action: {
                            let generator = UISelectionFeedbackGenerator()
                            generator.selectionChanged()
                            if selectedGoals.contains(goal) {
                                selectedGoals.remove(goal)
                            } else {
                                selectedGoals.insert(goal)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            ContinueButton(action: onNext, isEnabled: !selectedGoals.isEmpty)
                .padding(.horizontal, 24)
            
            Spacer().frame(height: 40)
        }
        .opacity(animate ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animate = true
            }
        }
    }
}

// MARK: - Step 6: Disclaimer
struct DisclaimerStep: View {
    let onComplete: () -> Void
    @State private var hasAccepted = false
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 20)
                    
                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color.calmSage.opacity(0.2))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "checkmark.shield.fill")
                            .font(ResetTypography.display(36))
                            .foregroundColor(.calmSage)
                    }
                    
                    // Title
                    VStack(spacing: 12) {
                        Text("You're all set!")
                            .font(ResetTypography.display(28))
                            .foregroundColor(.white)
                        
                        Text("Just one more thing... ")
                            .font(ResetTypography.body(15))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    // Disclaimer card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Important")
                            .font(ResetTypography.heading(16))
                            .foregroundColor(.white)
                        
                        Text("ResetNow is a wellness companion, not a medical service. It does not provide medical advice, diagnosis, or treatment.")
                            .font(ResetTypography.body(14))
                            .foregroundColor(.white.opacity(0.8))
                            .lineSpacing(4)
                        
                        Text("If you're experiencing a mental health emergency, please contact emergency services (911) or the 988 Suicide & Crisis Lifeline.")
                            .font(ResetTypography.body(14))
                            .foregroundColor(.white.opacity(0.8))
                            .lineSpacing(4)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.1))
                    )
                    .padding(.horizontal, 24)
                    
                    // Checkbox
                    Button(action: { hasAccepted.toggle() }) {
                        HStack(spacing: 12) {
                            Image(systemName: hasAccepted ? "checkmark.square.fill" : "square")
                                .font(ResetTypography.heading(24))
                                .foregroundColor(hasAccepted ? .calmSage : .white.opacity(0.5))
                            
                            Text("I understand and accept")
                                .font(ResetTypography.body(16))
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
            }
            
            Spacer()
            
            // Start button
            Button(action: onComplete) {
                HStack(spacing: 12) {
                    Text("Start My Journey")
                        .font(ResetTypography.heading(18))
                    
                    Image(systemName: "sparkles")
                        .font(ResetTypography.heading(18))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        colors: hasAccepted ? [Color.calmSage, Color.calmSage.opacity(0.8)] : [Color.gray, Color.gray.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: hasAccepted ? Color.calmSage.opacity(0.4) : Color.clear, radius: 12, y: 6)
            }
            .disabled(!hasAccepted)
            .padding(.horizontal, 24)
            
            Spacer().frame(height: 20)
        }
        .opacity(animate ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animate = true
            }
        }
    }
}

// MARK: - Reusable Components

struct SelectionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(ResetTypography.heading(16))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(ResetTypography.heading(24))
                    .foregroundColor(isSelected ? .calmSage : .white.opacity(0.4))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.calmSage.opacity(0.2) : Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? Color.calmSage : Color.clear, lineWidth: 2)
                    )
            )
        }
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : [.isButton])
    }
}

struct MultiSelectCard: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(ResetTypography.heading(24))
                    .foregroundColor(isSelected ? .calmSage : .white.opacity(0.7))
                
                Text(title)
                    .font(ResetTypography.caption(13))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.calmSage.opacity(0.2) : Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.calmSage : Color.clear, lineWidth: 2)
                    )
            )
        }
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : [.isButton])
    }
}

struct MultiSelectRow: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(ResetTypography.heading(20))
                    .foregroundColor(isSelected ? .calmSage : .white.opacity(0.6))
                    .frame(width: 32)
                
                Text(title)
                    .font(ResetTypography.heading(16))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(ResetTypography.heading(24))
                    .foregroundColor(isSelected ? .calmSage : .white.opacity(0.4))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.calmSage.opacity(0.2) : Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? Color.calmSage : Color.clear, lineWidth: 2)
                    )
            )
        }
    }
}

struct ContinueButton: View {
    let action: () -> Void
    var isEnabled: Bool = true
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text("Continue")
                    .font(ResetTypography.heading(17))
                
                Image(systemName: "arrow.right")
                    .font(ResetTypography.heading(15))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isEnabled ? Color.calmSage : Color.gray.opacity(0.5))
            )
            .shadow(color: isEnabled ? Color.calmSage.opacity(0.3) : Color.clear, radius: 8, y: 4)
        }
        .disabled(!isEnabled)
    }
}

// MARK: - Step 7: Experience Level
struct ExperienceLevelStep: View {
    @Binding var selectedExperience: ExperienceLevel
    let onNext: () -> Void
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Title
            VStack(spacing: 12) {
                Text("Have you meditated before?")
                .font(ResetTypography.display(28))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                
                Text("We'll adjust the guidance level")
                .font(ResetTypography.body(15))
                .foregroundColor(.white.opacity(0.7))
            }
            
            // Options
            VStack(spacing: 12) {
                ForEach(ExperienceLevel.allCases, id: \.self) { level in
                    Button(action: {
                        let generator = UISelectionFeedbackGenerator()
                        generator.selectionChanged()
                        selectedExperience = level
                    }) {
                        HStack(spacing: 16) {
                            Text(level.icon)
                                .font(.system(size: 24))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(level.rawValue)
                                    .font(ResetTypography.heading(16))
                                    .foregroundColor(.white)
                                
                                Text(level.description)
                                    .font(ResetTypography.caption(13))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            Image(systemName: selectedExperience == level ? "checkmark.circle.fill" : "circle")
                                .font(ResetTypography.heading(24))
                                .foregroundColor(selectedExperience == level ? .calmSage : .white.opacity(0.4))
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(selectedExperience == level ? Color.calmSage.opacity(0.2) : Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(selectedExperience == level ? Color.calmSage : Color.clear, lineWidth: 2)
                                )
                        )
                    }
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            ContinueButton(action: onNext)
                .padding(.horizontal, 24)
            
            Spacer().frame(height: 40)
        }
        .opacity(animate ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animate = true
            }
        }
    }
}

// MARK: - Step 8: Theme
struct ThemeStep: View {
    @Binding var selectedTheme: PreferredTheme
    let onNext: () -> Void
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Title
            VStack(spacing: 12) {
                Text("Choose your vibe")
                .font(ResetTypography.display(28))
                .foregroundColor(.white)
                
                Text("You can change this anytime")
                .font(ResetTypography.body(15))
                .foregroundColor(.white.opacity(0.7))
            }
            
            // Options
            HStack(spacing: 16) {
                ForEach(PreferredTheme.allCases, id: \.self) { theme in
                    Button(action: {
                        let generator = UISelectionFeedbackGenerator()
                        generator.selectionChanged()
                        selectedTheme = theme
                        
                        // Persist immediately for instant feedback
                        let value: Int
                        switch theme {
                        case .light: value = 1
                        case .dark: value = 2
                        case .system: value = 0
                        }
                        UserDefaults.standard.set(value, forKey: "colorScheme")
                    }) {
                        VStack(spacing: 12) {
                            Image(systemName: theme.icon)
                                .font(.system(size: 32))
                                .foregroundColor(selectedTheme == theme ? .calmSage : .white.opacity(0.7))
                            
                            Text(theme.rawValue)
                                .font(ResetTypography.heading(14))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 120)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedTheme == theme ? Color.calmSage.opacity(0.2) : Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedTheme == theme ? Color.calmSage : Color.clear, lineWidth: 2)
                                )
                        )
                    }
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            ContinueButton(action: onNext)
                .padding(.horizontal, 24)
            
            Spacer().frame(height: 40)
        }
        .opacity(animate ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animate = true
            }
        }
    }
}

// MARK: - Step 9: Notifications
struct NotificationStep: View {
    @Binding var isEnabled: Bool
    let onNext: () -> Void
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(Color.calmSage.opacity(0.2))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "bell.badge.fill")
                    .font(ResetTypography.display(40))
                    .foregroundColor(.calmSage)
            }
            
            // Title
            VStack(spacing: 12) {
                Text("Stay on track?")
                .font(ResetTypography.display(28))
                .foregroundColor(.white)
                
                Text("We can send gentle reminders to help you build a habit. No spam, ever.")
                .font(ResetTypography.body(15))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            }
            
            Spacer()
            
            // Buttons
            VStack(spacing: 16) {
                Button(action: {
                    requestNotificationPermission()
                }) {
                    Text("Enable Reminders")
                        .font(ResetTypography.heading(17))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.calmSage)
                        )
                        .shadow(color: Color.calmSage.opacity(0.3), radius: 8, y: 4)
                }
                
                Button(action: {
                    isEnabled = false
                    onNext()
                }) {
                    Text("Maybe Later")
                        .font(ResetTypography.body(16))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.vertical, 8)
                }
            }
            .padding(.horizontal, 24)
            
            Spacer().frame(height: 40)
        }
        .opacity(animate ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animate = true
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                isEnabled = granted
                onNext()
            }
        }
    }
}

// MARK: - Helper Components
struct OnboardingBackground: View {
    let step: Int
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color(hex: "1E1B4B"),  // Deep purple
                    Color(hex: "312E81"),  // Indigo
                    Color(hex: "4B2E83")   // Brand Primary
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated particles or shapes could go here
            FloatingParticles(particleCount: 15, colors: [.calmSage, .softLavender, .gentleSky])
                .opacity(0.3)
        }
    }
}

struct ProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(1...totalSteps, id: \.self) { step in
                Capsule()
                    .fill(step <= currentStep ? Color.calmSage : Color.white.opacity(0.2))
                    .frame(height: 4)
                    .animation(.spring(response: 0.3), value: currentStep)
            }
        }
    }
}



// MARK: - Preview
#if DEBUG
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(isPresented: .constant(true))
            .environmentObject(AppState())
            .environmentObject(PersistenceController.shared)
    }
}
#endif

