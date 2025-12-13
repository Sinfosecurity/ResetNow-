//
//  JourneysView.swift
//  ResetNow
//
//  Multi-step guided programs for deeper healing
//

import SwiftUI

struct JourneysView: View {
    @State private var selectedJourney: Journey?
    @State private var journeyProgress: [UUID: Int] = [:]
    @State private var showPaywall = false
    @EnvironmentObject var storeManager: StoreManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: ResetSpacing.lg) {
                // Header
                headerSection
                
                // In progress journeys
                if let activeJourney = Journey.samples.first(where: { journeyProgress[$0.id] != nil && journeyProgress[$0.id]! < $0.totalSteps }) {
                    ActiveJourneyCard(
                        journey: activeJourney,
                        currentStep: journeyProgress[activeJourney.id] ?? 0
                    ) {
                        selectedJourney = activeJourney
                    }
                }
                
                // All journeys
                allJourneysSection
            }
            .padding(.horizontal, ResetSpacing.md)
            .padding(.bottom, ResetSpacing.xxl)
        }
        .background(backgroundGradient.ignoresSafeArea())
        .navigationTitle("Journeys")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedJourney) { journey in
            JourneyDetailView(
                journey: journey,
                currentStep: journeyProgress[journey.id] ?? 0
            ) { completedStep in
                journeyProgress[journey.id] = completedStep + 1
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: ResetSpacing.sm) {
            Text("Guided programs for growth")
                .font(ResetTypography.body(16))
                .foregroundColor(.secondary)
            
            Text("Multi-day journeys combining lessons, exercises, and reflection.")
                .font(ResetTypography.body(14))
                .foregroundColor(.warmGray.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, ResetSpacing.sm)
    }
    
    private var allJourneysSection: some View {
        VStack(alignment: .leading, spacing: ResetSpacing.md) {
            Text("Available Journeys")
                .font(ResetTypography.heading(18))
                .foregroundColor(.primary)
            
            ForEach(Journey.samples) { journey in
                JourneyCard(
                    journey: journey,
                    progress: journeyProgress[journey.id]
                ) {
                    if journey.isPremium && !storeManager.hasPremiumAccess {
                        showPaywall = true
                    } else {
                        selectedJourney = journey
                    }
                }
            }
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.creamWhite,
                Color.journeysColor.opacity(0.1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Active Journey Card
struct ActiveJourneyCard: View {
    let journey: Journey
    let currentStep: Int
    let action: () -> Void
    
    var progress: CGFloat {
        guard journey.totalSteps > 0 else { return 0 }
        return CGFloat(currentStep) / CGFloat(journey.totalSteps)
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.journeysColor.opacity(0.7),
                                Color.calmSage.opacity(0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Decorative path
                GeometryReader { geometry in
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: geometry.size.height * 0.7))
                        path.addCurve(
                            to: CGPoint(x: geometry.size.width, y: geometry.size.height * 0.3),
                            control1: CGPoint(x: geometry.size.width * 0.3, y: geometry.size.height),
                            control2: CGPoint(x: geometry.size.width * 0.7, y: 0)
                        )
                    }
                    .stroke(Color.white.opacity(0.2), lineWidth: 3)
                }
                
                VStack(alignment: .leading, spacing: ResetSpacing.md) {
                    HStack {
                        Text("Continue Journey")
                            .font(ResetTypography.caption(12))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Spacer()
                        
                        Text("Step \(currentStep + 1) of \(journey.totalSteps)")
                            .font(ResetTypography.caption(12))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Text(journey.name)
                        .font(ResetTypography.display(24))
                        .foregroundColor(.white)
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.3))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.secondarySystemGroupedBackground))
                                .frame(width: geometry.size.width * progress, height: 8)
                        }
                    }
                    .frame(height: 8)
                    
                    Spacer()
                    
                    // Current step preview
                    if currentStep < journey.steps.count {
                        let step = journey.steps[currentStep]
                        HStack(spacing: ResetSpacing.sm) {
                            Image(systemName: step.iconName)
                                .font(.system(size: 14))
                            Text(step.title)
                                .font(ResetTypography.body(14))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, ResetSpacing.md)
                        .padding(.vertical, ResetSpacing.sm)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                        )
                    }
                }
                .padding(ResetSpacing.lg)
            }
            .frame(height: 200)
        }
    }
}

// MARK: - Journey Card
struct JourneyCard: View {
    let journey: Journey
    let progress: Int?
    let action: () -> Void
    
    var isCompleted: Bool {
        if let p = progress, p >= journey.totalSteps { return true }
        return false
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: ResetSpacing.md) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.journeysColor.opacity(journey.isPremium ? 0.3 : 0.6),
                                    Color.journeysColor.opacity(journey.isPremium ? 0.15 : 0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    if journey.isPremium {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.6))
                    } else if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "map.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(journey.name)
                            .font(ResetTypography.heading(16))
                            .foregroundColor(journey.isPremium ? .warmGray : .deepSlate)
                        
                        if journey.isPremium {
                            Text("Premium")
                                .font(ResetTypography.caption(10))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(Color.warmGray.opacity(0.15))
                                )
                        }
                    }
                    
                    Text(journey.description)
                        .font(ResetTypography.caption(13))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack(spacing: ResetSpacing.md) {
                        Label("\(journey.estimatedDays) days", systemImage: "calendar")
                        Label("\(journey.totalSteps) steps", systemImage: "list.bullet")
                    }
                    .font(ResetTypography.caption(11))
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.warmGray.opacity(0.5))
            }
            .padding(ResetSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .resetShadow(radius: 6, opacity: 0.06)
            )
            .opacity(journey.isPremium ? 0.7 : 1)
        }
        //.disabled(journey.isPremium) // Remove this so we can tap to see paywall
    }
}

// MARK: - Journey Detail View
struct JourneyDetailView: View {
    let journey: Journey
    let currentStep: Int
    let onCompleteStep: (Int) -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var showStep = false
    @State private var activeStepIndex: Int?
    @State private var viewMode: ViewMode = .daily // Default to daily view
    @State private var activeWeekDisplay: Int = 1
    
    // Derived properties
    var maxUnlockedWeek: Int {
        // Find the week of the furthest unlocked step
        // We unlocked everything for testing, so let's simulate progression
        // If currentStep is 7 (Day 7 end), we unlock week 2.
        
        let lastCompletedDay = journey.steps.prefix(currentStep).last?.day ?? 1
        let unlockedWeek = (lastCompletedDay - 1) / 7 + 1
        
        // If we finished the last day of week 1 (Day 7), we are technically ready for Week 2
        // So if lastCompletedDay is 7, unlockedWeek is 1. But if we are ON step 8 (Day 8), it is Week 2.
        
        // For simpler testing logic:
        return 2 // Always allow seeing up to week 2 for testing
    }
    
    var totalWeeks: Int {
        let maxDay = journey.steps.last?.day ?? 1
        return (maxDay - 1) / 7 + 1
    }
    
    var isCurrentWeekCompleted: Bool {
        // Check if all steps in the current activeWeekDisplay are completed
        let stepsInWeek = journey.steps.filter { ($0.day - 1) / 7 + 1 == activeWeekDisplay }
        guard let lastStepInWeek = stepsInWeek.last else { return false }
        
        // Find index of this last step
        if let index = journey.steps.firstIndex(where: { $0.id == lastStepInWeek.id }) {
            return index < currentStep
        }
        return false
    }
    
    enum ViewMode: String, CaseIterable {
        case daily = "Daily Plan"
        case weekly = "Weekly Plan"
    }
    
    var dailySteps: [(key: Int, value: [JourneyStep])] {
        let grouped = Dictionary(grouping: journey.steps, by: { $0.day })
        return grouped.sorted(by: { $0.key < $1.key })
    }
    
    var weeklySteps: [(key: Int, value: [JourneyStep])] {
        let grouped = Dictionary(grouping: journey.steps, by: { ($0.day - 1) / 7 + 1 })
        return grouped.sorted(by: { $0.key < $1.key })
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ResetSpacing.lg) {
                    // Header
                    VStack(spacing: ResetSpacing.md) {
                        Text(journey.name)
                            .font(ResetTypography.display(28))
                            .foregroundColor(.primary)
                        
                        Text(journey.description)
                            .font(ResetTypography.body(16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        // Progress
                        HStack(spacing: ResetSpacing.lg) {
                            ProgressIndicator(
                                icon: "checkmark.circle.fill",
                                value: "\(currentStep)",
                                label: "Completed"
                            )
                            
                            ProgressIndicator(
                                icon: "list.bullet",
                                value: "\(journey.totalSteps - currentStep)",
                                label: "Remaining"
                            )
                            
                            ProgressIndicator(
                                icon: "calendar",
                                value: "\(journey.estimatedDays)",
                                label: "Days"
                            )
                        }
                        .padding(.top, ResetSpacing.sm)
                    }
                    .padding(.horizontal, ResetSpacing.lg)
                    
                    // View Mode Toggle
                    Picker("View Mode", selection: $viewMode) {
                        ForEach(ViewMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, ResetSpacing.lg)
                    
                    Divider()
                        .padding(.vertical, ResetSpacing.sm)
                    
                    // Week Navigator
                    HStack {
                        Button(action: {
                            if activeWeekDisplay > 1 { activeWeekDisplay -= 1 }
                        }) {
                            Image(systemName: "chevron.left")
                                .padding()
                                .background(Color.secondary.opacity(0.1))
                                .clipShape(Circle())
                        }
                        .disabled(activeWeekDisplay <= 1)
                        
                        Text("Week \(activeWeekDisplay)")
                            .font(ResetTypography.heading(20))
                            .frame(maxWidth: .infinity)
                        
                        Button(action: {
                            if activeWeekDisplay < maxUnlockedWeek { activeWeekDisplay += 1 }
                        }) {
                            Image(systemName: "chevron.right")
                                .padding()
                                .background(Color.secondary.opacity(0.1))
                                .clipShape(Circle())
                        }
                        .disabled(activeWeekDisplay >= maxUnlockedWeek)
                    }
                    .padding(.horizontal)
                    
                    // Steps
                    VStack(alignment: .leading, spacing: ResetSpacing.lg) {
                        if viewMode == .daily {
                            ForEach(dailySteps.filter { ($0.key - 1) / 7 + 1 == activeWeekDisplay }, id: \.key) { day, steps in
                                VStack(alignment: .leading, spacing: ResetSpacing.sm) {
                                    Text("Day \(day)")
                                        .font(ResetTypography.heading(18))
                                        .foregroundColor(.primary)
                                        .padding(.horizontal, ResetSpacing.md)
                                    
                                    ForEach(steps) { step in
                                        if let index = journey.steps.firstIndex(where: { $0.id == step.id }) {
                                            StepRow(
                                                step: step,
                                                index: index,
                                                status: stepStatus(for: index),
                                                isLast: index == journey.steps.count - 1
                                            ) {
                                                activeStepIndex = index
                                                showStep = true
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            // Weekly View - Only show current week logic
                            // But since we are filtering by week globally now, this just lists the steps for the week
                            ForEach(weeklySteps.filter { $0.key == activeWeekDisplay }, id: \.key) { week, steps in
                                VStack(alignment: .leading, spacing: ResetSpacing.sm) {
                                    ForEach(steps) { step in
                                        if let index = journey.steps.firstIndex(where: { $0.id == step.id }) {
                                            StepRow(
                                                step: step,
                                                index: index,
                                                status: stepStatus(for: index),
                                                isLast: index == journey.steps.count - 1
                                            ) {
                                                activeStepIndex = index
                                                showStep = true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // "Next Week" Unlocking Logic
                        if isCurrentWeekCompleted && activeWeekDisplay < totalWeeks {
                            Button(action: {
                                withAnimation {
                                    activeWeekDisplay += 1
                                }
                            }) {
                                HStack {
                                    Text("Start Week \(activeWeekDisplay + 1)")
                                    Image(systemName: "arrow.right")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.journeysColor)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .padding()
                        }
                    }
                }
                .padding(.vertical, ResetSpacing.lg)
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.calmSage)
                }
            }
            .sheet(isPresented: $showStep) {
                if let index = activeStepIndex, index < journey.steps.count {
                    StepSessionView(step: journey.steps[index]) {
                        onCompleteStep(index)
                        showStep = false
                    }
                }
            }
        }
    }
    
    private func stepStatus(for index: Int) -> StepStatus {
        if index < currentStep { return .completed }
        return .current // Unlocked for testing
    }
    
    enum StepStatus {
        case completed, current, locked
    }
}

// MARK: - Progress Indicator
struct ProgressIndicator: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(value)
                    .font(ResetTypography.heading(18))
            }
            .foregroundColor(.journeysColor)
            
            Text(label)
                .font(ResetTypography.caption(11))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Step Row
struct StepRow: View {
    let step: JourneyStep
    let index: Int
    let status: JourneyDetailView.StepStatus
    let isLast: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: ResetSpacing.md) {
                // Timeline
                VStack(spacing: 0) {
                    // Top line
                    if index > 0 {
                        Rectangle()
                            .fill(status == .locked ? Color.warmGray.opacity(0.2) : Color.journeysColor)
                            .frame(width: 2, height: 20)
                    } else {
                        Spacer().frame(height: 20)
                    }
                    
                    // Circle
                    ZStack {
                        Circle()
                            .fill(circleColor)
                            .frame(width: 32, height: 32)
                        
                        if status == .completed {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        } else {
                            Text("\(index + 1)")
                                .font(ResetTypography.caption(14))
                                .foregroundColor(status == .locked ? .warmGray : .white)
                        }
                    }
                    
                    // Bottom line
                    if !isLast {
                        Rectangle()
                            .fill(status == .completed ? Color.journeysColor : Color.warmGray.opacity(0.2))
                            .frame(width: 2, height: 30)
                    }
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: step.iconName)
                            .font(.system(size: 14))
                            .foregroundColor(status == .locked ? .warmGray : stepTypeColor)
                        
                        Text(step.title)
                            .font(ResetTypography.heading(15))
                            .foregroundColor(status == .locked ? .warmGray : .deepSlate)
                    }
                    
                    Text(step.instructions)
                        .font(ResetTypography.caption(13))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                if status == .current {
                    Text("Start")
                        .font(ResetTypography.caption(13))
                        .foregroundColor(.white)
                        .padding(.horizontal, ResetSpacing.md)
                        .padding(.vertical, ResetSpacing.sm)
                        .background(
                            Capsule()
                                .fill(Color.journeysColor)
                        )
                } else if status == .locked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.warmGray.opacity(0.5))
                }
            }
            .padding(.horizontal, ResetSpacing.md)
        }
        .disabled(status != .current)
    }
    
    private var circleColor: Color {
        switch status {
        case .completed: return .journeysColor
        case .current: return .journeysColor
        case .locked: return .warmGray.opacity(0.2)
        }
    }
    
    private var stepTypeColor: Color {
        switch step.type {
        case .lesson: return .learnColor
        case .breathe: return .breatheColor
        case .visualization: return .visualizeColor
        case .affirmation: return .affirmColor
        case .journal: return .journalColor
        case .game: return .gamesColor
        }
    }
}

// MARK: - Step Session View
struct StepSessionView: View {
    let step: JourneyStep
    let onComplete: () -> Void
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                switch step.type {
                case .breathe:
                    BreatheWrapper(step: step, onComplete: onComplete)
                case .affirmation:
                    AffirmationWrapper(step: step, onComplete: onComplete)
                case .visualization:
                    VisualizationWrapper(step: step, onComplete: onComplete)
                case .lesson:
                    LessonWrapper(step: step, onComplete: onComplete)
                case .journal:
                    JournalWrapper(step: step, onComplete: onComplete)
                case .game:
                    GameWrapper(step: step, onComplete: onComplete)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Wrappers for Journey Steps

struct BreatheWrapper: View {
    let step: JourneyStep
    let onComplete: () -> Void
    
    @State private var scale: CGFloat = 1.0
    @State private var phaseText: String = "Get Ready"
    @State private var isComplete = false
    @State private var circleColor: Color = .calmSage
    @State private var isActive = false
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0.5
    
    // Dynamic Configuration
    var isBoxBreathing: Bool {
        step.title.localizedCaseInsensitiveContains("Box")
    }
    
    var is478: Bool {
        step.title.localizedCaseInsensitiveContains("4-7-8")
    }
    
    // Timings
    var inhaleTime: Double { 
        if is478 { return 4 }
        return isBoxBreathing ? 4 : 4 
    }
    
    var holdTopTime: Double { 
        if is478 { return 7 }
        return isBoxBreathing ? 4 : 2 
    }
    
    var exhaleTime: Double { 
        if is478 { return 8 }
        return isBoxBreathing ? 4 : 4 
    }
    
    var holdBottomTime: Double { 
        // 4-7-8 usually has no hold at bottom, cycle restarts immediately
        if is478 { return 0 }
        return isBoxBreathing ? 4 : 0 
    }
    
    let cycles: Int = 3
    
    var body: some View {
        VStack(spacing: 40) {
            // Header
            VStack(spacing: 12) {
                Text(step.title)
                    .font(ResetTypography.heading(28))
                    .foregroundColor(.primary)
                
                Text(step.instructions)
                    .font(ResetTypography.body(18))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            .padding(.top, 40)
            
            // Animation Center
            ZStack {
                // Outer Glow
                Circle()
                    .fill(circleColor.opacity(0.2))
                    .frame(width: 250, height: 250)
                    .scaleEffect(scale * 1.2)
                    .blur(radius: 30)
                
                // Flower Pattern
                ForEach(0..<6) { i in
                    Circle()
                        .stroke(circleColor.opacity(0.4), lineWidth: 2)
                        .frame(width: 120, height: 120)
                        .offset(x: 0, y: -60)
                        .rotationEffect(.degrees(Double(i) * 60))
                        .rotationEffect(.degrees(rotation))
                        .scaleEffect(scale)
                }
                
                // Core Circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [circleColor.opacity(0.6), circleColor.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                    .scaleEffect(scale)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            .scaleEffect(scale)
                    )
                
                // Text
                Text(phaseText)
                    .font(ResetTypography.heading(24))
                    .foregroundColor(.primary)
                    .contentTransition(.numericText()) // Smooth transition if supported, otherwise normal
                    .animation(.easeInOut, value: phaseText)
            }
            .frame(height: 350)
            .onAppear {
                withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
            
            Spacer()
            
            // Action Button
            Button(action: onComplete) {
                Text(isComplete ? "Complete Session" : "Stop Session")
            }
            .buttonStyle(ResetPrimaryButtonStyle())
            .opacity(isComplete ? 1.0 : 0.6)
            .padding()
        }
        .onAppear {
            startBreathingSession()
        }
        .onDisappear {
            isActive = false
        }
    }
    
    private func startBreathingSession() {
        isActive = true
        runBreathingCycle(cycle: 0)
    }
    
    private func runBreathingCycle(cycle: Int) {
        guard isActive else { return }
        
        if cycle >= cycles {
            completeSession()
            return
        }
        
        // Inhale
        animatePhase(text: "Breathe In", scaleTarget: 1.5, color: .calmSage, duration: inhaleTime)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + inhaleTime) {
            guard self.isActive else { return }
            
            // Hold Top
            self.animatePhase(text: "Hold", scaleTarget: 1.55, color: .softLavender, duration: self.holdTopTime)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + self.holdTopTime) {
                guard self.isActive else { return }
                
                // Exhale
                self.animatePhase(text: "Breathe Out", scaleTarget: 1.0, color: .gentleSky, duration: self.exhaleTime)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + self.exhaleTime) {
                    guard self.isActive else { return }
                    
                    if self.holdBottomTime > 0 {
                        // Hold Bottom (for Box Breathing)
                        self.animatePhase(text: "Hold", scaleTarget: 1.0, color: .softLavender, duration: self.holdBottomTime)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + self.holdBottomTime) {
                            guard self.isActive else { return }
                            self.runBreathingCycle(cycle: cycle + 1)
                        }
                    } else {
                        self.runBreathingCycle(cycle: cycle + 1)
                    }
                }
            }
        }
    }
    
    private func animatePhase(text: String, scaleTarget: CGFloat, color: Color, duration: Double) {
        withAnimation(.easeInOut(duration: duration)) {
            self.phaseText = text
            self.scale = scaleTarget
            self.circleColor = color
        }
    }
    
    private func completeSession() {
        withAnimation {
            isComplete = true
            phaseText = "Well Done"
            scale = 1.0
            circleColor = .calmSage
        }
    }
}

struct AffirmationWrapper: View {
    let step: JourneyStep
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Reusing the nice premium card styling concepts
            VStack(spacing: 24) {
                Image(systemName: "quote.opening")
                    .font(.system(size: 40))
                    .foregroundColor(.softRose.opacity(0.5))
                
                Text(step.instructions) // Using instructions as the affirmation text for now
                    .font(ResetTypography.display(24))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                
                Image(systemName: "quote.closing")
                    .font(.system(size: 40))
                    .foregroundColor(.softRose.opacity(0.5))
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 20)
            )
            .padding()
            
            Spacer()
            
            Button("I Affirm This", action: onComplete)
                .buttonStyle(ResetPrimaryButtonStyle())
                .padding()
        }
        .background(Color.softRose.opacity(0.1).ignoresSafeArea())
    }
}

struct VisualizationWrapper: View {
    let step: JourneyStep
    let onComplete: () -> Void
    
    var body: some View {
        VStack {
            // Background Header
            ZStack {
                // Fallback Gradient
                LinearGradient(
                    colors: [Color.journeysColor.opacity(0.8), Color.calmSage],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Image if available
                Image("nature_bg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            .frame(height: 300)
            .clipped()
            .overlay(
                LinearGradient(colors: [.black.opacity(0.3), .clear], startPoint: .bottom, endPoint: .top)
            )
            
            ScrollView {
                VStack(spacing: 24) {
                    Text(step.title)
                        .font(ResetTypography.heading(24))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(step.instructions)
                        .font(ResetTypography.body(18))
                        .lineSpacing(8)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                    
                    Button("Complete Visualization", action: onComplete)
                        .buttonStyle(ResetPrimaryButtonStyle())
                        .padding(.top, 20)
                }
                .padding()
            }
        }
        .background(Color(.systemBackground)) // Ensure not transparent
        .ignoresSafeArea(edges: .top)
    }
}

struct JournalWrapper: View {
    let step: JourneyStep
    let onComplete: () -> Void
    @State private var text = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text(step.title)
                .font(ResetTypography.heading(24))
                .padding(.top)
            
            Text(step.instructions)
                .font(ResetTypography.body(16))
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            TextEditor(text: $text)
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(16)
                .padding()
            
            Button("Save Entry", action: onComplete)
                .buttonStyle(ResetPrimaryButtonStyle())
                .disabled(text.isEmpty)
                .opacity(text.isEmpty ? 0.5 : 1)
                .padding()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

struct GameWrapper: View {
    let step: JourneyStep
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color.warmPeach.opacity(0.2))
                    .frame(width: 200, height: 200)
                
                Image(systemName: "gamecontroller.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.warmPeach)
            }
            
            Text("Relaxing Game Time")
                .font(ResetTypography.heading(24))
            
            Text(step.instructions)
                .font(ResetTypography.body(16))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Spacer()
            
            Button("Play & Complete", action: onComplete)
                .buttonStyle(ResetPrimaryButtonStyle())
                .padding()
        }
    }
}

// MARK: - Lesson Wrapper
struct LessonWrapper: View {
    let step: JourneyStep
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            ZStack(alignment: .bottomLeading) {
                LinearGradient(
                    colors: [Color.learnColor.opacity(0.9), Color.learnColor.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Lesson")
                        .font(ResetTypography.caption(14))
                        .textCase(.uppercase)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text(step.title)
                        .font(ResetTypography.heading(28))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                }
                .padding(ResetSpacing.lg)
                .padding(.bottom, ResetSpacing.sm)
            }
            .frame(height: 180)
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: ResetSpacing.lg) {
                    Text(step.instructions)
                        .font(ResetTypography.body(18))
                        .foregroundColor(.primary)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Fallback content for key lessons to prevent empty feeling
                    if step.title == "What Is Anxiety?" {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("The Alarm System")
                                .font(ResetTypography.heading(20))
                                .foregroundColor(.primary)
                            
                            Text("Anxiety is not your enemy. It is your body's attempt to keep you safe. Like a smoke alarm, it is designed to be loud and impossible to ignore.")
                                .font(ResetTypography.body(18))
                                .foregroundColor(.primary)
                                .lineSpacing(6)
                            
                            Text("When you perceive a threat, your amygdala (the brain's fear center) sounds the alarm, flooding your body with adrenaline. This is the 'Fight or Flight' response.")
                                .font(ResetTypography.body(18))
                                .foregroundColor(.primary)
                                .lineSpacing(6)
                        }
                    } else if step.title == "Your Nervous System" {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("The Vagus Nerve")
                                .font(ResetTypography.heading(20))
                                .foregroundColor(.primary)
                            
                            Text("Your autonomic nervous system has two main branches: the Sympathetic (gas pedal) and Parasympathetic (brake pedal).")
                                .font(ResetTypography.body(18))
                                .foregroundColor(.primary)
                                .lineSpacing(6)
                            
                            Text("Anxiety means the gas pedal is stuck. Our goal isn't to break the car, but to learn how to use the brakes again.")
                                .font(ResetTypography.body(18))
                                .foregroundColor(.primary)
                                .lineSpacing(6)
                        }
                    }
                    
                    Button("Complete Lesson", action: onComplete)
                        .buttonStyle(ResetPrimaryButtonStyle())
                        .padding(.top, ResetSpacing.xl)
                }
                .padding(ResetSpacing.lg)
            }
        }
        .background(Color(.systemBackground))
        .ignoresSafeArea(edges: .top)
    }
}

// MARK: - Preview
struct JourneysView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            JourneysView()
        }
    }
}

