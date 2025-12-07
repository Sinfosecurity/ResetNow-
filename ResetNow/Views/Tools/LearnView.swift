//
//  LearnView.swift
//  ResetNow
//
//  Educational content about anxiety and coping skills
//

import SwiftUI

struct LearnView: View {
    @State private var selectedLesson: Lesson?
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var persistence: PersistenceController
    
    var lessonsByCategory: [Lesson.LessonCategory: [Lesson]] {
        Dictionary(grouping: persistence.lessons, by: { $0.category })
    }
    
    var completedLessonIds: Set<UUID> {
        Set(persistence.lessonProgress.keys.filter { persistence.isLessonComplete($0) })
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: ResetSpacing.lg) {
                // Header
                headerSection
                
                // Progress card
                progressCard
                
                // Lessons by category
                ForEach(Lesson.LessonCategory.allCases, id: \.rawValue) { category in
                    if let lessons = lessonsByCategory[category] {
                        LessonCategorySection(
                            category: category,
                            lessons: lessons,
                            completedIds: completedLessonIds,
                            onSelect: { selectedLesson = $0 }
                        )
                    }
                }
            }
            .padding(.horizontal, ResetSpacing.md)
            .padding(.bottom, ResetSpacing.xxl)
        }
        .background(
            ZStack {
                AnimatedGradientBackground(colors: [Color.learnColor.opacity(0.3), Color.softLavender.opacity(0.2), Color.creamWhite])
                FloatingParticles(colors: [.learnColor, .softLavender])
                    .opacity(0.4)
            }
        )
        .navigationTitle("Learn")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedLesson) { lesson in
            LessonDetailView(lesson: lesson) {
                persistence.markLessonComplete(lesson.id)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: ResetSpacing.sm) {
            Text("Understanding helps healing")
                .font(ResetTypography.body(16))
                .foregroundColor(.primary.opacity(0.8))
            
            Text("Short lessons to help you understand anxiety and build coping skills.")
                .font(ResetTypography.body(14))
                .foregroundColor(.primary.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, ResetSpacing.sm)
    }
    
    private var progressCard: some View {
        HStack(spacing: ResetSpacing.lg) {
            // Progress circle
            ZStack {
                Circle()
                    .stroke(Color.learnColor.opacity(0.2), lineWidth: 6)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.learnColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int(progress * 100))%")
                    .font(ResetTypography.heading(14))
                    .foregroundColor(.learnColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Your Progress")
                    .font(ResetTypography.heading(16))
                    .foregroundColor(.primary)
                
                Text("\(completedLessonIds.count) of \(persistence.lessons.count) lessons completed")
                    .font(ResetTypography.caption(13))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(ResetSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                )
                .shadow(color: Color.learnColor.opacity(0.15), radius: 8, y: 4)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Learning Progress: \(Int(progress * 100))% complete. \(completedLessonIds.count) of \(persistence.lessons.count) lessons finished.")
    }
    
    private var progress: CGFloat {
        let total = persistence.lessons.count
        guard total > 0 else { return 0 }
        
        // Ensure we only count completed lessons that currently exist in the catalog
        let validCompletedCount = persistence.lessons.filter { completedLessonIds.contains($0.id) }.count
        
        return CGFloat(validCompletedCount) / CGFloat(total)
    }
    
    private var backgroundGradient: some View {
        AdaptiveColors.gradient(for: colorScheme)
    }
}

// MARK: - Lesson Category Section
struct LessonCategorySection: View {
    let category: Lesson.LessonCategory
    let lessons: [Lesson]
    let completedIds: Set<UUID>
    let onSelect: (Lesson) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: ResetSpacing.md) {
            Text(category.rawValue)
                .font(ResetTypography.heading(18))
                .foregroundColor(.primary)
            
            ForEach(lessons) { lesson in
                LessonRow(
                    lesson: lesson,
                    isCompleted: completedIds.contains(lesson.id)
                ) {
                    onSelect(lesson)
                }
            }
        }
    }
}

// MARK: - Lesson Row
struct LessonRow: View {
    let lesson: Lesson
    let isCompleted: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
            action()
        }) {
            HStack(spacing: ResetSpacing.md) {
                // Completion indicator
                ZStack {
                    Circle()
                        .stroke(isCompleted ? Color.calmSage : Color.warmGray.opacity(0.3), lineWidth: 2)
                        .frame(width: 28, height: 28)
                    
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.calmSage)
                    }
                }
                
                // Lesson Icon
                ZStack {
                    Circle()
                        .fill(Color.learnColor.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: lesson.iconName)
                        .font(.system(size: 18))
                        .foregroundColor(.learnColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(lesson.title)
                            .font(ResetTypography.heading(15))
                            .foregroundColor(isCompleted ? .warmGray : .deepSlate)
                        

                    }
                    
                    Text(lesson.summary)
                        .font(ResetTypography.caption(13))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Duration
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 11))
                    Text("\(lesson.estimatedMinutes) min")
                        .font(ResetTypography.caption(12))
                }
                .foregroundColor(.secondary)
            }
            .padding(ResetSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
            )
        }
        .accessibilityLabel("\(lesson.title), \(lesson.estimatedMinutes) minutes")
        .accessibilityHint(isCompleted ? "Lesson completed" : "Double tap to start lesson")
    }
}

// MARK: - Lesson Detail View
struct LessonDetailView: View {
    let lesson: Lesson
    let onComplete: () -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var hasCompleted = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: ResetSpacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: ResetSpacing.sm) {
                        Text(lesson.category.rawValue)
                            .font(ResetTypography.caption(12))
                            .foregroundColor(.learnColor)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.learnColor.opacity(0.15))
                            )
                        
                        Text(lesson.title)
                            .font(ResetTypography.display(28))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: ResetSpacing.md) {
                            Label("\(lesson.estimatedMinutes) min read", systemImage: "clock")
                        }
                        .font(ResetTypography.caption(13))
                        .foregroundColor(.secondary)
                    }
                    
                    Divider()
                        .padding(.vertical, ResetSpacing.sm)
                    
                    // Content
                    Text(lesson.summary)
                        .font(ResetTypography.body(16))
                        .foregroundColor(.deepSlate.opacity(0.9))
                        .lineSpacing(6)
                    
                    // Key Points
                    if !lesson.keyPoints.isEmpty {
                        VStack(alignment: .leading, spacing: ResetSpacing.md) {
                            Text("Key Points")
                                .font(ResetTypography.heading(18))
                                .foregroundColor(.primary)
                            
                            ForEach(lesson.keyPoints, id: \.self) { point in
                                BulletPoint(text: point)
                            }
                        }
                        .padding(.top, ResetSpacing.md)
                    }
                    
                    // Try this section
                    if !lesson.tryThis.isEmpty {
                        VStack(alignment: .leading, spacing: ResetSpacing.md) {
                            Text("Try This")
                                .font(ResetTypography.heading(18))
                                .foregroundColor(.primary)
                            
                            Text(lesson.tryThis)
                                .font(ResetTypography.body(15))
                                .foregroundColor(.secondary)
                                .padding(ResetSpacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.calmSage.opacity(0.1))
                                )
                        }
                        .padding(.top, ResetSpacing.md)
                    }

                }
                .padding(.horizontal, ResetSpacing.md)
                .padding(.bottom, 100) // Space for button
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.calmSage)
                        .frame(minWidth: 44, minHeight: 44)
                        .contentShape(Rectangle())
                        .accessibilityLabel("Close Lesson")
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack {
                    Button(action: markComplete) {
                        HStack {
                            Image(systemName: hasCompleted ? "checkmark.circle.fill" : "checkmark.circle")
                            Text(hasCompleted ? "Completed!" : "Mark as Complete")
                        }
                    }
                    .buttonStyle(ResetPrimaryButtonStyle())
                    .padding(.horizontal, ResetSpacing.lg)
                    .padding(.vertical, ResetSpacing.md)
                    .accessibilityLabel(hasCompleted ? "Lesson Completed" : "Mark Lesson as Complete")
                    .accessibilityHint("Tracks your progress")
                }
                .background(Color(.systemBackground))
            }
        }
    }
    
    private func markComplete() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        hasCompleted = true
        onComplete()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
        }
    }
}

// MARK: - Bullet Point
struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: ResetSpacing.sm) {
            Circle()
                .fill(Color.learnColor)
                .frame(width: 6, height: 6)
                .padding(.top, 8)
            
            Text(text)
                .font(ResetTypography.body(15))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview
struct LearnView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationStack {
                LearnView()
            }
            .previewDisplayName("Light Mode")
            
            NavigationStack {
                LearnView()
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}

