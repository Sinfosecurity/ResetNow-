//
//  ResetTool.swift
//  ResetNow
//
//  All data models and type definitions
//

import SwiftUI

// MARK: - App Constants
enum AppConstants {
    static let appName = "ResetNow"
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    // Support
    static let supportEmail = "ashobal@sinfosecurity.com"
    static let supportURL = "https://sinfosecurity.github.io/ResetNow-support/index.html"
    
    // Legal URLs - Live on GitHub Pages
    static let privacyPolicyURL = "https://sinfosecurity.github.io/ResetNow-support/privacy.html"
    static let termsOfServiceURL = "https://sinfosecurity.github.io/ResetNow-support/terms.html"
    static let termsOfUseURL = termsOfServiceURL // alias
    
    // App Store
    // ⚠️ TODO: Replace with real App Store ID after first submission approval
    // Format: "id" followed by numbers, e.g., "id1234567890"
    static let appStoreID = "id0000000000"
    static let appStoreURL = "https://apps.apple.com/app/\(appStoreID)"
}

// MARK: - Type Aliases
typealias ResetToolKind = ResetTool

// MARK: - Reset Tool Enum
enum ResetTool: String, CaseIterable, Identifiable, Codable {
    case learn
    case breathe
    case games
    case journal
    case visualize
    case sleep
    case affirm
    case journeys
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .learn: return "Learn"
        case .breathe: return "Breathe"
        case .games: return "Games"
        case .journal: return "Journal"
        case .visualize: return "Visualize"
        case .sleep: return "Sleep"
        case .affirm: return "Affirm"
        case .journeys: return "Journeys"
        }
    }
    
    var description: String {
        switch self {
        case .learn: return "Understand anxiety and calm your mind with simple lessons"
        case .breathe: return "Guided breathing exercises to reduce anxiety quickly"
        case .games: return "Gentle mini-games that steady your nervous system"
        case .journal: return "Express your thoughts with prompts and free writing"
        case .visualize: return "Guided body scans and safe-place scenes"
        case .sleep: return "Calming sounds and stories for restful sleep"
        case .affirm: return "Daily affirmations to build self-worth and calm"
        case .journeys: return "Multi-step guided programs for deeper healing"
        }
    }
    
    var iconName: String {
        switch self {
        case .learn: return "book.fill"
        case .breathe: return "wind"
        case .games: return "gamecontroller.fill"
        case .journal: return "pencil.and.scribble"
        case .visualize: return "eye.fill"
        case .sleep: return "moon.stars.fill"
        case .affirm: return "heart.fill"
        case .journeys: return "map.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .learn: return .learnColor
        case .breathe: return .breatheColor
        case .games: return .gamesColor
        case .journal: return .journalColor
        case .visualize: return .visualizeColor
        case .sleep: return .sleepColor
        case .affirm: return .affirmColor
        case .journeys: return .journeysColor
        }
    }
    
    var sortOrder: Int {
        switch self {
        case .learn: return 0
        case .breathe: return 1
        case .games: return 2
        case .journal: return 3
        case .visualize: return 4
        case .sleep: return 5
        case .affirm: return 6
        case .journeys: return 7
        }
    }
}

// MARK: - Onboarding Enums
enum MoodLevel: String, CaseIterable, Codable {
    case veryLow = "Very Low"
    case low = "Low"
    case neutral = "Neutral"
    case good = "Good"
    case great = "Great"
    
    var emoji: String {
        switch self {
        case .veryLow: return "😰"
        case .low: return "😔"
        case .neutral: return "😐"
        case .good: return "🙂"
        case .great: return "😊"
        }
    }
    
    var color: Color {
        switch self {
        case .veryLow: return .sosRed
        case .low: return .warmPeach
        case .neutral: return .warmGray
        case .good: return .calmSage
        case .great: return .journeysColor
        }
    }
}

enum AgeGroup: String, CaseIterable, Codable {
    case teen = "13-17"
    case youngAdult = "18-25"
    case adult = "26-45"
    case matureAdult = "46-65"
    case senior = "65+"
    
    var displayName: String {
        switch self {
        case .teen: return "Teen (13-17)"
        case .youngAdult: return "Young Adult (18-25)"
        case .adult: return "Adult (26-45)"
        case .matureAdult: return "Mature Adult (46-65)"
        case .senior: return "Senior (65+)"
        }
    }
}

enum Concern: String, CaseIterable, Codable {
    case generalAnxiety = "General Anxiety"
    case workStress = "Work/School Stress"
    case sleepIssues = "Sleep Issues"
    case relationshipStress = "Relationship Stress"
    case healthAnxiety = "Health Anxiety"
    case socialAnxiety = "Social Anxiety"
    case justExploring = "Just Exploring"
    
    var icon: String {
        switch self {
        case .generalAnxiety: return "brain.head.profile"
        case .workStress: return "briefcase.fill"
        case .sleepIssues: return "moon.zzz.fill"
        case .relationshipStress: return "heart.fill"
        case .healthAnxiety: return "cross.case.fill"
        case .socialAnxiety: return "person.3.fill"
        case .justExploring: return "sparkles"
        }
    }
}

enum ExperienceLevel: String, CaseIterable, Codable {
    case beginner = "New to this"
    case some = "Some experience"
    case regular = "Regular practice"
    
    var icon: String {
        switch self {
        case .beginner: return "🌱"
        case .some: return "🌿"
        case .regular: return "🌳"
        }
    }
    
    var description: String {
        switch self {
        case .beginner: return "I'm just starting my wellness journey"
        case .some: return "I've tried meditation or breathing before"
        case .regular: return "I practice mindfulness regularly"
        }
    }
}

enum Goal: String, CaseIterable, Codable {
    case reduceAnxiety = "Reduce daily anxiety"
    case sleepBetter = "Sleep better"
    case manageStress = "Manage stress"
    case buildResilience = "Build resilience"
    case findCalm = "Find moments of calm"
    
    var icon: String {
        switch self {
        case .reduceAnxiety: return "heart.circle.fill"
        case .sleepBetter: return "moon.stars.fill"
        case .manageStress: return "leaf.fill"
        case .buildResilience: return "shield.fill"
        case .findCalm: return "sparkles"
        }
    }
}

enum PreferredTheme: String, CaseIterable, Codable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
    
    var icon: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .system: return "circle.lefthalf.filled"
        }
    }
}

// MARK: - User Profile
struct UserProfile: Identifiable, Codable {
    var id: UUID
    var displayName: String?
    var createdAt: Date
    var acceptedDisclaimerAt: Date?
    var prefersDarkMode: Bool
    var enabledNotifications: Bool
    var completedOnboarding: Bool
    var dailyReminderTime: Date?
    var streakDays: Int
    var lastActiveDate: Date?
    var totalMinutesUsed: Int
    var favoriteTool: ResetTool?
    var dailyAffirmationEnabled: Bool
    var resetsReminderEnabled: Bool
    
    // New Onboarding Fields
    var ageGroup: AgeGroup?
    var concerns: Set<Concern>
    var experienceLevel: ExperienceLevel?
    var goals: Set<Goal>
    var preferredTheme: PreferredTheme
    
    static let `default` = UserProfile(
        id: UUID(),
        displayName: nil,
        createdAt: Date(),
        acceptedDisclaimerAt: nil,
        prefersDarkMode: false,
        enabledNotifications: false,
        completedOnboarding: false,
        dailyReminderTime: nil,
        streakDays: 0,
        lastActiveDate: nil,
        totalMinutesUsed: 0,
        favoriteTool: nil,
        dailyAffirmationEnabled: false,
        resetsReminderEnabled: false,
        ageGroup: nil,
        concerns: [],
        experienceLevel: nil,
        goals: [],
        preferredTheme: .system
    )
}

// MARK: - Session Model
struct ResetSession: Identifiable, Codable {
    let id: UUID
    let startedAt: Date
    var endedAt: Date?
    let sourceToolKind: ResetTool
    let subtypeId: UUID?
    var notes: String?
    
    var durationMinutes: Int? {
        guard let endedAt = endedAt else { return nil }
        return Int(endedAt.timeIntervalSince(startedAt) / 60)
    }
}

// MARK: - Message Sender
enum MessageSender: String, Codable {
    case user
    case rae
}

// MARK: - Chat Message
struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let chatSessionId: UUID
    let sender: MessageSender
    let createdAt: Date
    let text: String
    var safetyFlag: String?
    
    // Nested type alias for backwards compatibility
    typealias MessageSender = ResetNow.MessageSender
    
    init(
        id: UUID = UUID(),
        chatSessionId: UUID,
        sender: MessageSender,
        createdAt: Date = Date(),
        text: String,
        safetyFlag: String? = nil
    ) {
        self.id = id
        self.chatSessionId = chatSessionId
        self.sender = sender
        self.createdAt = createdAt
        self.text = text
        self.safetyFlag = safetyFlag
    }
}

// MARK: - Chat Session
struct ChatSession: Identifiable, Codable {
    let id: UUID
    let startedAt: Date
    var endedAt: Date?
    var isCrisisFlagged: Bool
    var crisisFlagReason: String?
    
    init(
        id: UUID = UUID(),
        startedAt: Date = Date(),
        endedAt: Date? = nil,
        isCrisisFlagged: Bool = false,
        crisisFlagReason: String? = nil
    ) {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.isCrisisFlagged = isCrisisFlagged
        self.crisisFlagReason = crisisFlagReason
    }
}

// MARK: - Mood Checkin
struct MoodCheckin: Identifiable, Codable {
    let id: UUID
    let sessionId: UUID?
    let createdAt: Date
    let moodType: MoodType
    var valueBefore: Int?
    var valueAfter: Int?
    
    enum MoodType: String, Codable {
        case anxiety
        case stress
        case mood
    }
}

// MARK: - Journal Entry
struct JournalEntry: Identifiable, Codable {
    let id: UUID
    let createdAt: Date
    let promptText: String?
    let entryText: String
    let moodTag: String?
    
    static let prompts: [String] = [
        "What's on your mind right now?",
        "What are three things you're grateful for today?",
        "Describe a moment when you felt calm recently.",
        "What would you tell a friend who felt this way?",
        "What do you need most right now?",
        "Write about something that made you smile today.",
        "What can you let go of today?",
        "Describe your ideal peaceful moment.",
        "What strength got you through a hard time?",
        "Write a kind note to yourself."
    ]
}

// MARK: - Affirmation Favorite (for persistence)
struct AffirmationFavorite: Identifiable, Codable {
    let id: UUID
    let affirmationId: UUID
    let createdAt: Date
}

// MARK: - Lesson Progress
struct LessonProgress: Identifiable, Codable {
    let id: UUID
    let lessonId: UUID
    var completedAt: Date?
    var progress: Double
    
    init(id: UUID = UUID(), lessonId: UUID, completedAt: Date? = nil, progress: Double = 0) {
        self.id = id
        self.lessonId = lessonId
        self.completedAt = completedAt
        self.progress = progress
    }
}

// MARK: - Journey Progress
struct JourneyProgress: Identifiable, Codable {
    let id: UUID
    let journeyId: UUID
    var currentStepIndex: Int
    var completedStepIds: [UUID]
    var startedAt: Date
    var completedAt: Date?
    
    init(
        id: UUID = UUID(),
        journeyId: UUID,
        currentStepIndex: Int = 0,
        completedStepIds: [UUID] = [],
        startedAt: Date = Date(),
        completedAt: Date? = nil
    ) {
        self.id = id
        self.journeyId = journeyId
        self.currentStepIndex = currentStepIndex
        self.completedStepIds = completedStepIds
        self.startedAt = startedAt
        self.completedAt = completedAt
    }
}

// MARK: - Lesson
struct Lesson: Identifiable, Codable {
    let id: UUID
    let title: String
    let iconName: String
    let summary: String
    let body: String
    let estimatedMinutes: Int
    let category: LessonCategory
    let isComingSoon: Bool
    let sources: [String]
    let keyPoints: [String]
    let tryThis: String
    
    // Backwards compatibility
    var isPremium: Bool { false }
    
    enum LessonCategory: String, Codable, CaseIterable {
        case foundations = "Understanding Anxiety"
        case shortTerm = "Short-Term Relief Skills"
        case longTerm = "Long-Term Transformation"
    }
    
    static let samples: [Lesson] = [
        // CATEGORY 1: Understanding Anxiety (Foundations)
        Lesson(
            id: UUID(),
            title: "What Is Anxiety?",
            iconName: "brain.head.profile",
            summary: "Understanding your body's natural alarm system",
            body: "Anxiety is your body's natural response... ",
            estimatedMinutes: 3,
            category: .foundations,
            isComingSoon: false,
            sources: ["NIMH", "APA"],
            keyPoints: [
                "Anxiety is a normal biological response, not a defect.",
                "It evolved to keep early humans safe from predators.",
                "Your brain is trying to protect you, even if it feels scary.",
                "The physical symptoms are your body preparing for action.",
                "Understanding this mechanism reduces the fear of fear."
            ],
            tryThis: "Next time you feel anxious, say to yourself: \"Thank you brain for trying to protect me, but I am safe right now.\""
        ),
        Lesson(
            id: UUID(),
            title: "Panic vs Anxiety",
            iconName: "exclamationmark.triangle",
            summary: "Knowing the difference helps you respond",
            body: "While anxiety and panic attacks share similarities... ",
            estimatedMinutes: 3,
            category: .foundations,
            isComingSoon: false,
            sources: ["ADAA", "Mayo Clinic"],
            keyPoints: [
                "Anxiety is often related to a specific stressor or worry.",
                "Panic attacks can happen out of the blue with no trigger.",
                "Panic peaks within minutes; anxiety can linger for hours.",
                "Panic feels physical and intense; anxiety feels mental and worried.",
                "Both are treatable and temporary states."
            ],
            tryThis: "Create a \"Panic Plan\" note on your phone listing 3 people to call and 3 soothing songs to play if panic strikes."
        ),

        Lesson(
            id: UUID(),
            title: "Your Nervous System",
            iconName: "waveform.path.ecg",
            summary: "Meet your fight, flight, and rest responses",
            body: "Your autonomic nervous system has two main branches... ",
            estimatedMinutes: 3,
            category: .foundations,
            isComingSoon: false,
            sources: ["Harvard", "Cleveland Clinic"],
            keyPoints: [
                "The Sympathetic system is your \"gas pedal\" (Fight/Flight).",
                "The Parasympathetic system is your \"brake\" (Rest/Digest).",
                "Anxiety happens when the gas pedal gets stuck.",
                "You can manually engage the brake using your breath.",
                "Your body cannot be in both states at the exact same time."
            ],
            tryThis: "Splash cold water on your face to trigger the \"Mammalian Dive Reflex\", which instantly activates your parasympathetic nervous system."
        ),
        Lesson(
            id: UUID(),
            title: "Why Breathing Helps",
            iconName: "wind",
            summary: "The science behind calm breathing",
            body: "Slow, deep breathing is one of the most powerful tools... ",
            estimatedMinutes: 2,
            category: .foundations,
            isComingSoon: false,
            sources: ["Harvard Medical School"],
            keyPoints: [
                "Short, shallow breaths signal danger to your brain.",
                "Long, slow exhales signal safety and relaxation.",
                "Breathing is the only autonomic function you can control.",
                "Slowing your breath directly slows your heart rate.",
                "Consistency matters more than perfect technique."
            ],
            tryThis: "Place one hand on your chest and one on your belly. Breathe so only the belly hand moves."
        ),
        Lesson(
            id: UUID(),
            title: "Physical Effects",
            iconName: "figure.walk",
            summary: "How anxiety manifests in your body",
            body: "Anxiety isn't just in your head... ",
            estimatedMinutes: 4,
            category: .foundations,
            isComingSoon: false,
            sources: ["Mayo Clinic"],
            keyPoints: [
                "Adrenaline causes your heart to race to pump blood to muscles.",
                "Digestion slows down, causing \"butterflies\" or nausea.",
                "Muscles tense up to prepare for fighting or fleeing.",
                "Vision might blur or tunnel as pupils dilate.",
                "These are survival mechanisms, not signs of illness."
            ],
            tryThis: "Do a quick body scan. Squeeze your fists tight for 5 seconds, then release. Notice the difference between tension and relaxation."
        ),
        Lesson(
            id: UUID(),
            title: "Mental Effects",
            iconName: "bubble.left.and.bubble.right",
            summary: "Racing thoughts and cognitive patterns",
            body: "Anxiety affects how we think and perceive... ",
            estimatedMinutes: 4,
            category: .foundations,
            isComingSoon: false,
            sources: ["APA"],
            keyPoints: [
                "Anxiety makes you overestimate danger.",
                "It makes you underestimate your ability to cope.",
                "\"Catastrophizing\" is jumping to the worst-case scenario.",
                "Racing thoughts are the brain searching for a solution.",
                "Worry gives a false sense of control over the future."
            ],
            tryThis: "Write down your worry. Then write down the \"Best Case\", \"Worst Case\", and \"Most Likely\" outcomes."
        ),
        Lesson(
            id: UUID(),
            title: "Causes & Theories",
            iconName: "questionmark.circle",
            summary: "Where does anxiety come from?",
            body: "Anxiety is a complex mix of genetics and environment... ",
            estimatedMinutes: 5,
            category: .foundations,
            isComingSoon: false,
            sources: ["NIMH"],
            keyPoints: [
                "Genetics play a role; some nervous systems are more sensitive.",
                "Life experiences and trauma shape your alarm system.",
                "Chronic stress can keep cortisol levels elevated.",
                "Personality traits like perfectionism can contribute.",
                "It is not a sign of weakness or failure."
            ],
            tryThis: "Draw a simple timeline of your life. Mark when your anxiety felt highest and lowest. Look for patterns."
        ),
        Lesson(
            id: UUID(),
            title: "First Steps",
            iconName: "shoeprints.fill",
            summary: "Beginning your journey to recovery",
            body: "Recovery starts with small, manageable steps... ",
            estimatedMinutes: 3,
            category: .foundations,
            isComingSoon: false,
            sources: ["ADAA"],
            keyPoints: [
                "Acceptance is the first step, not resistance.",
                "Recovery is non-linear; setbacks are normal.",
                "Small daily habits compound over time.",
                "You don't have to do this alone.",
                "Patience with yourself is crucial."
            ],
            tryThis: "Set one tiny, achievable goal for today (e.g., \"Drink one glass of water\", \"Walk for 5 minutes\")."
        ),
        Lesson(
            id: UUID(),
            title: "Panic Attacks 101",
            iconName: "bolt.heart.fill",
            summary: "Demystifying the panic experience",
            body: "A panic attack is an intense surge of fear... ",
            estimatedMinutes: 4,
            category: .foundations,
            isComingSoon: false,
            sources: ["APA"],
            keyPoints: [
                "A panic attack cannot kill you or make you go crazy.",
                "It is an adrenaline surge that will naturally pass.",
                "Most attacks peak within 10 minutes.",
                "Fighting the panic often prolongs it.",
                "Riding the wave is scary but effective."
            ],
            tryThis: "Visualize the panic as a wave. Instead of trying to stop the wave, imagine surfing over it until it reaches the shore."
        ),
        Lesson(
            id: UUID(),
            title: "Why It Feels Real",
            iconName: "eye.fill",
            summary: "The biology of false alarms",
            body: "Your brain can't always distinguish real danger from perceived... ",
            estimatedMinutes: 3,
            category: .foundations,
            isComingSoon: false,
            sources: ["Harvard"],
            keyPoints: [
                "The Amygdala is your brain's smoke detector.",
                "It can't tell the difference between a tiger and a scary thought.",
                "It triggers the alarm before your logical brain can check it.",
                "Physical symptoms reinforce the belief that danger is real.",
                "You can retrain this alarm system over time."
            ],
            tryThis: "Name the false alarm. When you feel a symptom, say out loud: \"This is just adrenaline. It is uncomfortable, but not dangerous.\""
        ),
        Lesson(
            id: UUID(),
            title: "Myths vs Facts",
            iconName: "info.circle",
            summary: "Clearing up common misconceptions",
            body: "Let's debunk common myths about anxiety... ",
            estimatedMinutes: 3,
            category: .foundations,
            isComingSoon: false,
            sources: ["NAMI"],
            keyPoints: [
                "Myth: Anxiety means you are weak. Fact: It takes strength to endure it.",
                "Myth: You should just \"calm down\". Fact: It's a physiological state.",
                "Myth: Medication is the only fix. Fact: Therapy and lifestyle help too.",
                "Myth: You will always feel this way. Fact: Anxiety is highly treatable.",
                "Myth: Avoiding triggers cures anxiety. Fact: Avoidance feeds anxiety."
            ],
            tryThis: "Identify one myth you've believed about your own anxiety. Write down the counter-fact."
        ),

        // CATEGORY 2: Short-Term Relief Skills (Immediate Calm)
        Lesson(
            id: UUID(),
            title: "Grounding Techniques",
            iconName: "leaf.fill",
            summary: "Simple ways to feel present and safe",
            body: "Grounding techniques help anchor you in the present... ",
            estimatedMinutes: 2,
            category: .shortTerm,
            isComingSoon: false,
            sources: ["APA", "ADAA"],
            keyPoints: [
                "Grounding reconnects you with reality.",
                "It pulls focus away from internal worry to external safety.",
                "Physical touch is a powerful grounding tool.",
                "Mental games can distract the amygdala.",
                "It works best when practiced before high anxiety hits."
            ],
            tryThis: "Hold an ice cube in your hand. Focus entirely on the sensation of cold and melting water."
        ),
        Lesson(
            id: UUID(),
            title: "Breathing Tools",
            iconName: "lungs.fill",
            summary: "Quick access to calming breathwork",
            body: "Explore our dedicated breathing tools... ",
            estimatedMinutes: 1,
            category: .shortTerm,
            isComingSoon: false,
            sources: ["ResetNow"],
            keyPoints: [
                "Box Breathing resets rhythm.",
                "4-7-8 Breathing induces sleepiness.",
                "Lengthening the exhale triggers relaxation.",
                "Breathe through your nose, not your mouth.",
                "Use the \"Breathe\" tab for guided pacing."
            ],
            tryThis: "Go to the \"Breathe\" tab and complete one 2-minute session of \"Simple Calm\"."
        ),
        Lesson(
            id: UUID(),
            title: "Quick Reframes",
            iconName: "arrow.triangle.2.circlepath",
            summary: "Shift your perspective instantly",
            body: "Cognitive reframing helps change negative thought patterns... ",
            estimatedMinutes: 3,
            category: .shortTerm,
            isComingSoon: false,
            sources: ["CBT Basics"],
            keyPoints: [
                "Thoughts are not facts.",
                "Ask: \"Is this thought helpful?\"",
                "Ask: \"What is the evidence for this thought?\"",
                "Replace \"What if\" with \"Even if\".",
                "View the situation as a challenge, not a threat."
            ],
            tryThis: "Change \"I can't handle this\" to \"This is hard, but I have handled hard things before.\""
        ),
        Lesson(
            id: UUID(),
            title: "Safe-Spot Vis.",
            iconName: "photo.fill",
            summary: "Mental vacation to a safe place",
            body: "Visualization can trick your brain into calmness... ",
            estimatedMinutes: 4,
            category: .shortTerm,
            isComingSoon: true,
            sources: ["Guided Imagery"],
            keyPoints: [
                "Your brain reacts to imagined safety like real safety.",
                "Detail is key: see, hear, smell, and feel the place.",
                "It can be a real place or an imaginary one.",
                "Return to this spot whenever you feel overwhelmed.",
                "Practice visiting it when you are calm first."
            ],
            tryThis: "Close your eyes for 1 minute. Imagine sitting on a warm beach. Feel the sun on your skin and hear the waves."
        ),
        Lesson(
            id: UUID(),
            title: "Social Media",
            iconName: "iphone",
            summary: "Managing digital anxiety triggers",
            body: "Social media can be a major source of anxiety... ",
            estimatedMinutes: 3,
            category: .shortTerm,
            isComingSoon: true,
            sources: ["Cyberpsychology"],
            keyPoints: [
                "Comparison is the thief of joy.",
                "Doomscrolling keeps your nervous system agitated.",
                "Curate your feed to be supportive, not stressful.",
                "Blue light disrupts sleep and mood.",
                "Real connection happens offline."
            ],
            tryThis: "Unfollow 3 accounts that make you feel inadequate or anxious. Follow 3 that make you feel calm or inspired."
        ),
        Lesson(
            id: UUID(),
            title: "Diet & Anxiety",
            iconName: "fork.knife",
            summary: "Foods that help and harm",
            body: "What you eat affects how you feel... ",
            estimatedMinutes: 4,
            category: .shortTerm,
            isComingSoon: true,
            sources: ["Nutritional Psychiatry"],
            keyPoints: [
                "Caffeine mimics anxiety symptoms (racing heart).",
                "Sugar crashes can feel like panic.",
                "Gut health is linked to brain health (serotonin).",
                "Hydration is essential for clear thinking.",
                "Magnesium-rich foods can support relaxation."
            ],
            tryThis: "Swap your second cup of coffee for herbal tea or water today and notice if your jitteriness decreases."
        ),
        Lesson(
            id: UUID(),
            title: "Exercise & Mood",
            iconName: "figure.run",
            summary: "Moving to release tension",
            body: "Exercise is a natural anti-anxiety treatment... ",
            estimatedMinutes: 3,
            category: .shortTerm,
            isComingSoon: false,
            sources: ["Mayo Clinic"],
            keyPoints: [
                "Exercise burns off excess adrenaline.",
                "It releases endorphins, natural painkillers.",
                "Rhythmic movement is soothing to the brain.",
                "It improves sleep quality.",
                "You don't need a gym; walking works wonders."
            ],
            tryThis: "Put on your favorite upbeat song and dance or shake your body for the entire duration of the track."
        ),
        Lesson(
            id: UUID(),
            title: "Sleep Basics",
            iconName: "bed.double.fill",
            summary: "Quick tips for better rest",
            body: "Sleep and anxiety are closely linked... ",
            estimatedMinutes: 3,
            category: .shortTerm,
            isComingSoon: false,
            sources: ["Sleep Foundation"],
            keyPoints: [
                "A cool, dark room promotes deep sleep.",
                "Stick to a consistent wake-up time.",
                "Avoid screens 1 hour before bed.",
                "If you can't sleep, get up and do something boring.",
                "Your bed is for sleep, not worrying."
            ],
            tryThis: "Tonight, charge your phone in another room (or across the room) so it's not the last thing you see."
        ),
        Lesson(
            id: UUID(),
            title: "5-4-3-2-1 Method",
            iconName: "hand.raised.fingers.spread.fill",
            summary: "The ultimate emergency grounding tool",
            body: "Use your five senses to ground yourself... ",
            estimatedMinutes: 2,
            category: .shortTerm,
            isComingSoon: false,
            sources: ["Trauma Informed Care"],
            keyPoints: [
                "5 things you can SEE.",
                "4 things you can TOUCH.",
                "3 things you can HEAR.",
                "2 things you can SMELL.",
                "1 thing you can TASTE.",
                "Say them out loud if possible."
            ],
            tryThis: "Look around right now. Find 5 blue objects in your environment."
        ),
        Lesson(
            id: UUID(),
            title: "Sensory Reset",
            iconName: "snowflake",
            summary: "Using cold and heat to calm down",
            body: "Temperature changes can reset your nervous system... ",
            estimatedMinutes: 2,
            category: .shortTerm,
            isComingSoon: true,
            sources: ["DBT Skills"],
            keyPoints: [
                "Intense cold activates the dive reflex.",
                "Warmth promotes muscle relaxation.",
                "Weighted blankets provide proprioceptive input.",
                "Soothing scents bypass the thinking brain.",
                "Shocking the senses snaps you out of loops."
            ],
            tryThis: "Run your wrists under very cold water for 30 seconds."
        ),

        // CATEGORY 3: Long-Term Transformation Skills (Deep Work)
        Lesson(
            id: UUID(),
            title: "Resistance vs Trust",
            iconName: "water.waves",
            summary: "Learning to float past fear",
            body: "Fighting anxiety often makes it stronger... ",
            estimatedMinutes: 5,
            category: .longTerm,
            isComingSoon: true,
            sources: ["Claire Weekes"],
            keyPoints: [
                "What you resist, persists.",
                "Floating means moving with the tension, not against it.",
                "Acceptance doesn't mean liking it; it means allowing it.",
                "Trust your body knows how to handle this.",
                "The struggle is often worse than the anxiety itself."
            ],
            tryThis: "Visualize yourself floating on a river. The anxiety is the current. Don't swim against it; let it carry you until it slows down."
        ),
        Lesson(
            id: UUID(),
            title: "Learn To Sleep",
            iconName: "moon.stars.fill",
            summary: "Rebuilding your relationship with rest",
            body: "Insomnia often comes from trying too hard to sleep... ",
            estimatedMinutes: 6,
            category: .longTerm,
            isComingSoon: true,
            sources: ["CBT-I"],
            keyPoints: [
                "Sleep drive builds up the longer you are awake.",
                "Trying to force sleep pushes it away.",
                "Resting your body is valuable even without sleep.",
                "Let go of the fear of being tired tomorrow.",
                "Your body will sleep when it needs to."
            ],
            tryThis: "If you wake up at night, tell yourself: \"I am just resting my body. That is enough.\""
        ),
        Lesson(
            id: UUID(),
            title: "Self-Labelling",
            iconName: "tag.fill",
            summary: "You are not your anxiety",
            body: "Labels can limit our growth... ",
            estimatedMinutes: 4,
            category: .longTerm,
            isComingSoon: true,
            sources: ["Narrative Therapy"],
            keyPoints: [
                "You HAVE anxiety; you are NOT anxiety.",
                "Language shapes your reality.",
                "Avoid saying \"My anxiety\" (ownership).",
                "Say \"The anxiety\" (separation).",
                "You are a person experiencing a temporary state."
            ],
            tryThis: "Catch yourself saying \"I am anxious\". Correct it to \"I am feeling anxiety right now\"."
        ),
        Lesson(
            id: UUID(),
            title: "Writing to Heal",
            iconName: "pencil.and.scribble",
            summary: "Journaling for clarity and release",
            body: "Writing helps process complex emotions... ",
            estimatedMinutes: 4,
            category: .longTerm,
            isComingSoon: true,
            sources: ["Expressive Writing"],
            keyPoints: [
                "Writing gets thoughts out of your head.",
                "It helps identify hidden triggers.",
                "It creates a record of your survival and growth.",
                "Don't worry about grammar or spelling.",
                "Write to express, not to impress."
            ],
            tryThis: "Set a timer for 3 minutes. Write continuously without lifting your pen. Don't think, just flow."
        ),
        Lesson(
            id: UUID(),
            title: "Mindfulness 101",
            iconName: "drop.fill",
            summary: "Living in the present moment",
            body: "Mindfulness is simple, but not easy... ",
            estimatedMinutes: 5,
            category: .longTerm,
            isComingSoon: false,
            sources: ["MBSR"],
            keyPoints: [
                "Mindfulness is paying attention on purpose.",
                "It is observing without judgment.",
                "It is returning to the present when the mind wanders.",
                "You cannot stop thoughts, but you can watch them.",
                "The present moment is the only place life happens."
            ],
            tryThis: "Pick one daily activity (brushing teeth, drinking coffee). Do it with 100% attention on the sensations."
        ),
        Lesson(
            id: UUID(),
            title: "Self-Compassion",
            iconName: "heart.fill",
            summary: "Being kind to yourself",
            body: "Treat yourself like you would a friend... ",
            estimatedMinutes: 4,
            category: .longTerm,
            isComingSoon: true,
            sources: ["Neff"],
            keyPoints: [
                "Self-criticism activates the threat system.",
                "Self-compassion activates the soothing system.",
                "You deserve kindness simply because you exist.",
                "Suffering is part of the shared human experience.",
                "Be a coach, not a critic."
            ],
            tryThis: "Place a hand on your heart. Say: \"This is a moment of suffering. Suffering is part of life. May I be kind to myself.\""
        ),
        Lesson(
            id: UUID(),
            title: "Rewiring Habits",
            iconName: "arrow.triangle.branch",
            summary: "Changing your brain's pathways",
            body: "Neuroplasticity means you can change... ",
            estimatedMinutes: 5,
            category: .longTerm,
            isComingSoon: true,
            sources: ["Neuroscience"],
            keyPoints: [
                "Neurons that fire together, wire together.",
                "Anxiety is often a well-worn neural path.",
                "New habits forge new paths.",
                "Repetition is the key to rewiring.",
                "It takes time to overgrow the old trails."
            ],
            tryThis: "Identify one \"anxiety habit\" (e.g., checking the news). Replace it with one \"calm habit\" (e.g., checking your breath) for 3 days."
        ),
        Lesson(
            id: UUID(),
            title: "Building Resilience",
            iconName: "shield.fill",
            summary: "Bouncing back stronger",
            body: "Resilience is a muscle you can build... ",
            estimatedMinutes: 4,
            category: .longTerm,
            isComingSoon: true,
            sources: ["APA"],
            keyPoints: [
                "Resilience is not the absence of distress.",
                "It is the ability to adapt to adversity.",
                "Meaning and purpose fuel resilience.",
                "Social connection is a pillar of strength.",
                "Every challenge you survive makes you stronger."
            ],
            tryThis: "List 3 difficult things you have overcome in the past. Remind yourself of the strength you used then."
        ),
        Lesson(
            id: UUID(),
            title: "Body Awareness",
            iconName: "figure.arms.open",
            summary: "Somatic experiencing basics",
            body: "Listening to your body's subtle signals... ",
            estimatedMinutes: 4,
            category: .longTerm,
            isComingSoon: true,
            sources: ["Somatic Therapy"],
            keyPoints: [
                "Trauma and stress live in the body.",
                "Noticing sensations without story helps release them.",
                "Tracking \"pleasant\" sensations builds capacity.",
                "Movement completes the stress cycle.",
                "Your body is your ally, not your enemy."
            ],
            tryThis: "Scan your body for a place that feels \"neutral\" or \"okay\" (e.g., your earlobe, your big toe). Rest your attention there."
        ),
        Lesson(
            id: UUID(),
            title: "Hormones & Mood",
            iconName: "drop.triangle.fill",
            summary: "Understanding biological cycles",
            body: "Hormones play a huge role in anxiety... ",
            estimatedMinutes: 4,
            category: .longTerm,
            isComingSoon: true,
            sources: ["Endocrinology"],
            keyPoints: [
                "Cortisol is the stress hormone.",
                "Serotonin and Dopamine regulate mood.",
                "Menstrual cycles can amplify anxiety (PMS/PMDD).",
                "Blood sugar fluctuations mimic panic.",
                "Tracking cycles helps you predict and prepare."
            ],
            tryThis: "Start a simple log. Note your anxiety level (1-10) and the time of day/month. Look for biological rhythms."
        ),
        Lesson(
            id: UUID(),
            title: "Breath Practice",
            iconName: "nose.fill",
            summary: "Deepening your breathwork",
            body: "Advanced breathing techniques for long-term calm... ",
            estimatedMinutes: 5,
            category: .longTerm,
            isComingSoon: true,
            sources: ["Pranayama"],
            keyPoints: [
                "Breath is the bridge between mind and body.",
                "Diaphragmatic breathing massages the Vagus nerve.",
                "Breath retention builds CO2 tolerance.",
                "Alternate nostril breathing balances hemispheres.",
                "Daily practice lowers baseline stress."
            ],
            tryThis: "Practice \"Alternate Nostril Breathing\" (Nadi Shodhana) for 2 minutes to balance your energy."
        ),
        Lesson(
            id: UUID(),
            title: "Visualization Mastery",
            iconName: "sparkles",
            summary: "Advanced mental imagery",
            body: "Using your imagination to create your reality... ",
            estimatedMinutes: 6,
            category: .longTerm,
            isComingSoon: true,
            sources: ["Sports Psychology"],
            keyPoints: [
                "Athletes use visualization to improve performance.",
                "You can visualize yourself coping calmly.",
                "Engage all senses for maximum effect.",
                "Visualize the process, not just the outcome.",
                "Your brain practices the success before it happens."
            ],
            tryThis: "Visualize your upcoming day going smoothly. See yourself handling a challenge with calm confidence."
        )
    ]
}

// MARK: - Breathing Exercise
struct BreathingExercise: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let inhaleSeconds: Int
    let holdTopSeconds: Int
    let exhaleSeconds: Int
    let holdBottomSeconds: Int
    let defaultDurationSeconds: Int
    let isComingSoon: Bool
    
    var totalCycleSeconds: Int {
        inhaleSeconds + holdTopSeconds + exhaleSeconds + holdBottomSeconds
    }
    
    // Backwards compatibility with views
    var isPremium: Bool { false }
    
    static let presets: [BreathingExercise] = [
        BreathingExercise(id: UUID(), name: "Box Breathing", description: "Equal inhale, hold, exhale, hold. Used for calm under pressure.", inhaleSeconds: 4, holdTopSeconds: 4, exhaleSeconds: 4, holdBottomSeconds: 4, defaultDurationSeconds: 180, isComingSoon: false),
        BreathingExercise(id: UUID(), name: "4-7-8 Relaxation", description: "Dr. Weil's technique for sleep and anxiety.", inhaleSeconds: 4, holdTopSeconds: 7, exhaleSeconds: 8, holdBottomSeconds: 0, defaultDurationSeconds: 180, isComingSoon: false),
        BreathingExercise(id: UUID(), name: "Simple Calm", description: "Gentle inhale and exhale. Perfect for beginners.", inhaleSeconds: 4, holdTopSeconds: 0, exhaleSeconds: 6, holdBottomSeconds: 0, defaultDurationSeconds: 120, isComingSoon: false),
        BreathingExercise(id: UUID(), name: "Energizing Breath", description: "Quick cycles to boost energy and alertness.", inhaleSeconds: 3, holdTopSeconds: 0, exhaleSeconds: 3, holdBottomSeconds: 0, defaultDurationSeconds: 60, isComingSoon: false),
        BreathingExercise(id: UUID(), name: "Deep Sleep Breath", description: "Extended exhale pattern for rest.", inhaleSeconds: 4, holdTopSeconds: 4, exhaleSeconds: 10, holdBottomSeconds: 2, defaultDurationSeconds: 300, isComingSoon: false),
        
        // New Techniques
        BreathingExercise(id: UUID(), name: "Resonant Breathing", description: "A steady, balanced rhythm that helps your mind and body return to equilibrium.", inhaleSeconds: 5, holdTopSeconds: 0, exhaleSeconds: 5, holdBottomSeconds: 0, defaultDurationSeconds: 180, isComingSoon: false),
        BreathingExercise(id: UUID(), name: "Slow Release Breath", description: "A calm inhale paired with a long, controlled exhale to settle your nervous system.", inhaleSeconds: 4, holdTopSeconds: 0, exhaleSeconds: 8, holdBottomSeconds: 0, defaultDurationSeconds: 180, isComingSoon: false),
        BreathingExercise(id: UUID(), name: "Focus Booster", description: "A simple pattern designed to sharpen attention and bring clarity.", inhaleSeconds: 3, holdTopSeconds: 3, exhaleSeconds: 3, holdBottomSeconds: 1, defaultDurationSeconds: 120, isComingSoon: false),
        BreathingExercise(id: UUID(), name: "Gentle Wave Breath", description: "Smooth, flowing breaths that mimic the rise and fall of gentle ocean waves.", inhaleSeconds: 4, holdTopSeconds: 0, exhaleSeconds: 6, holdBottomSeconds: 0, defaultDurationSeconds: 180, isComingSoon: false),
        BreathingExercise(id: UUID(), name: "Stress Reset Breath", description: "A grounding technique for breaking the stress cycle and easing tension.", inhaleSeconds: 4, holdTopSeconds: 1, exhaleSeconds: 6, holdBottomSeconds: 0, defaultDurationSeconds: 180, isComingSoon: false),
        BreathingExercise(id: UUID(), name: "Energy Lift Breath", description: "Short active cycles to help you feel more awake and alert.", inhaleSeconds: 2, holdTopSeconds: 0, exhaleSeconds: 2, holdBottomSeconds: 0, defaultDurationSeconds: 60, isComingSoon: false),
        BreathingExercise(id: UUID(), name: "Heart-Calm Rhythm", description: "A soothing pattern that encourages a calmer heartbeat and quieter mind.", inhaleSeconds: 6, holdTopSeconds: 0, exhaleSeconds: 4, holdBottomSeconds: 0, defaultDurationSeconds: 180, isComingSoon: false),
        BreathingExercise(id: UUID(), name: "Nervous System Reset", description: "A balanced breath structure designed to activate your parasympathetic response.", inhaleSeconds: 4, holdTopSeconds: 4, exhaleSeconds: 6, holdBottomSeconds: 0, defaultDurationSeconds: 180, isComingSoon: false),
        BreathingExercise(id: UUID(), name: "Deep Release Breath", description: "A long, gentle exhale that allows the body to release held stress.", inhaleSeconds: 4, holdTopSeconds: 2, exhaleSeconds: 10, holdBottomSeconds: 0, defaultDurationSeconds: 300, isComingSoon: false),
        BreathingExercise(id: UUID(), name: "Quiet Mind Breath", description: "A soft, slowed breath pattern to calm racing thoughts and reduce internal noise.", inhaleSeconds: 3, holdTopSeconds: 3, exhaleSeconds: 6, holdBottomSeconds: 0, defaultDurationSeconds: 180, isComingSoon: false)
    ]
}

// MARK: - Calm Game
struct CalmGame: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let gameType: GameType
    let isComingSoon: Bool
    let isLockedByProgress: Bool
    let unlockRequirement: Int?
    
    // Backwards compatibility
    var isPremium: Bool { false }
    
    enum GameType: String, Codable {
        case bubblePop = "bubble_pop"
        case calmWord = "calm_word"
        case word = "word" // alias
        case memory = "memory"
        case thoughtGarden = "thought_garden"
        case garden = "garden" // alias
        case rhythmSteps = "rhythm_steps"
        case rhythm = "rhythm" // alias
        case coloring = "coloring"
        case zenStone = "zen_stone"
        case sandGarden = "sand_garden"
        case koiPond = "koi_pond"
        case tileFlow = "tile_flow"
        case pottery = "pottery"
        case rainyWindow = "rainy_window"
        case mandala = "mandala"
        case constellation = "constellation"
    }
    
    var iconName: String {
        switch gameType {
        case .bubblePop: return "circle.grid.3x3.fill"
        case .calmWord, .word: return "textformat.abc"
        case .memory: return "square.grid.3x3.fill"
        case .thoughtGarden, .garden: return "leaf.fill"
        case .rhythmSteps, .rhythm: return "waveform.path"
        case .coloring: return "paintpalette.fill"
        case .zenStone: return "circle.hexagongrid.fill"
        case .sandGarden: return "hand.draw.fill"
        case .koiPond: return "water.waves"
        case .tileFlow: return "arrow.triangle.branch"
        case .pottery: return "cylinder.split.1x2.fill"
        case .rainyWindow: return "cloud.rain.fill"
        case .mandala: return "seal.fill"
        case .constellation: return "star.fill"
        }
    }
    
    static let samples: [CalmGame] = [
        CalmGame(id: UUID(), name: "Bubble Pop Calm", description: "Gently pop floating bubbles at your own pace", gameType: .bubblePop, isComingSoon: false, isLockedByProgress: false, unlockRequirement: nil),
        CalmGame(id: UUID(), name: "Calm Word", description: "Find peaceful words in letter grids", gameType: .calmWord, isComingSoon: false, isLockedByProgress: false, unlockRequirement: nil),
        CalmGame(id: UUID(), name: "Calm Memory", description: "Match calming images gently", gameType: .memory, isComingSoon: false, isLockedByProgress: false, unlockRequirement: nil),
        CalmGame(id: UUID(), name: "Thought Garden", description: "Plant and grow a peaceful digital garden", gameType: .thoughtGarden, isComingSoon: false, isLockedByProgress: false, unlockRequirement: nil),
        CalmGame(id: UUID(), name: "Rhythm Steps", description: "Tap along to soothing rhythms", gameType: .rhythmSteps, isComingSoon: false, isLockedByProgress: false, unlockRequirement: nil),
        CalmGame(id: UUID(), name: "Zen Stone Stacking", description: "Find balance by stacking stones", gameType: .zenStone, isComingSoon: false, isLockedByProgress: false, unlockRequirement: nil),
        CalmGame(id: UUID(), name: "Sand Garden", description: "Draw patterns in the sand", gameType: .sandGarden, isComingSoon: false, isLockedByProgress: false, unlockRequirement: nil),
        CalmGame(id: UUID(), name: "Koi Pond", description: "Interact with peaceful fish", gameType: .koiPond, isComingSoon: false, isLockedByProgress: false, unlockRequirement: nil),
        CalmGame(id: UUID(), name: "Tile Flow", description: "Connect the pipes to flow", gameType: .tileFlow, isComingSoon: false, isLockedByProgress: false, unlockRequirement: nil),
        CalmGame(id: UUID(), name: "Pottery Wheel", description: "Shape clay into beautiful forms", gameType: .pottery, isComingSoon: false, isLockedByProgress: false, unlockRequirement: nil),
        CalmGame(id: UUID(), name: "Rainy Window", description: "Clear the fog from the glass", gameType: .rainyWindow, isComingSoon: false, isLockedByProgress: false, unlockRequirement: nil),
        CalmGame(id: UUID(), name: "Mandala Color", description: "Fill patterns with calming colors", gameType: .mandala, isComingSoon: false, isLockedByProgress: false, unlockRequirement: nil),
        CalmGame(id: UUID(), name: "Constellations", description: "Connect stars to find shapes", gameType: .constellation, isComingSoon: false, isLockedByProgress: false, unlockRequirement: nil)
    ]
}

// MARK: - Sleep Track
struct SleepTrack: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let audioAssetName: String
    let durationMinutes: Int
    let tags: [String]
    let isComingSoon: Bool
    
    // Backwards compatibility
    var isPremium: Bool { false }
    
    var iconName: String {
        if tags.contains("rain") || tags.contains("storm") { return "cloud.rain.fill" }
        if tags.contains("fire") { return "flame.fill" }
        if tags.contains("ocean") { return "water.waves" }
        if tags.contains("forest") { return "leaf.fill" }
        if tags.contains("noise") { return "waveform" }
        if tags.contains("water") { return "drop.fill" }
        if tags.contains("music") || tags.contains("peaceful") { return "music.note" }
        return "speaker.wave.2.fill"
    }
    
    static let samples: [SleepTrack] = [
        SleepTrack(id: UUID(), name: "Midnight Forest", description: "A rich chorus of night crickets and owls", audioAssetName: "night_crickets_owls", durationMinutes: 480, tags: ["nature", "night", "forest"], isComingSoon: false),
        SleepTrack(id: UUID(), name: "Stormy Comfort", description: "Heavy rain and rolling thunder for deep sleep", audioAssetName: "rain_thunderstorm", durationMinutes: 480, tags: ["rain", "storm"], isComingSoon: false),
        SleepTrack(id: UUID(), name: "Deep Sleep Drift", description: "Instant deep sleep frequency", audioAssetName: "deep_sleep_instant", durationMinutes: 480, tags: ["noise", "sleep"], isComingSoon: false),
        SleepTrack(id: UUID(), name: "Hearthside Warmth", description: "Cozy crackling fire", audioAssetName: "fire_crackling", durationMinutes: 480, tags: ["fire", "cozy"], isComingSoon: false),
        SleepTrack(id: UUID(), name: "Summer Night", description: "Gentle crickets on a warm evening", audioAssetName: "nature_crickets", durationMinutes: 480, tags: ["nature", "night"], isComingSoon: false),
        SleepTrack(id: UUID(), name: "Ocean Serenity", description: "Calming waves hitting the shore", audioAssetName: "ocean_waves", durationMinutes: 480, tags: ["ocean", "nature"], isComingSoon: false),
        SleepTrack(id: UUID(), name: "Gentle Rain", description: "Soft, steady rainfall", audioAssetName: "relaxing_rain", durationMinutes: 480, tags: ["rain", "nature"], isComingSoon: false),
        SleepTrack(id: UUID(), name: "Deep Meditation Wave", description: "Soothing waves for deep focus", audioAssetName: "deep_meditation", durationMinutes: 480, tags: ["meditation", "focus"], isComingSoon: false),
        SleepTrack(id: UUID(), name: "Calm Flow", description: "Gentle background ambience", audioAssetName: "calming_sound", durationMinutes: 480, tags: ["music", "calm"], isComingSoon: false),
        SleepTrack(id: UUID(), name: "Stress Relief", description: "Melodic relief for anxious minds", audioAssetName: "stress_relief", durationMinutes: 480, tags: ["music", "relief"], isComingSoon: false),
        SleepTrack(id: UUID(), name: "Meditation Calm", description: "Soft music for quiet moments", audioAssetName: "meditation_calm", durationMinutes: 480, tags: ["music", "meditation"], isComingSoon: false)
    ]
}



// MARK: - Affirmation
struct Affirmation: Identifiable, Codable, Hashable {
    let id: UUID
    let category: AffirmationCategory
    let text: String
    let isComingSoon: Bool
    
    // Backwards compatibility
    var isPremium: Bool { false }
    
    enum AffirmationCategory: String, Codable, CaseIterable {
        case selfWorth = "Self Worth"
        case calm = "Calm"
        case strength = "Strength"
        case hope = "Hope"
        case selfCompassion = "Self Compassion"
        
        var color: Color {
            switch self {
            case .selfWorth: return .warmPeach
            case .calm: return .calmSage
            case .strength: return .softLavender
            case .hope: return .gentleSky
            case .selfCompassion: return .softRose
            }
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Affirmation, rhs: Affirmation) -> Bool {
        lhs.id == rhs.id
    }
    
    static let samples: [Affirmation] = [
        // Self Worth
        Affirmation(id: UUID(), category: .selfWorth, text: "I am enough, exactly as I am right now.", isComingSoon: false),
        Affirmation(id: UUID(), category: .selfWorth, text: "My worth is not measured by my productivity.", isComingSoon: false),
        Affirmation(id: UUID(), category: .selfWorth, text: "I deserve to take up space.", isComingSoon: false),
        Affirmation(id: UUID(), category: .selfWorth, text: "I honor my need for rest.", isComingSoon: false),
        Affirmation(id: UUID(), category: .selfWorth, text: "I am worthy of love and respect.", isComingSoon: false),
        Affirmation(id: UUID(), category: .selfWorth, text: "My feelings are valid.", isComingSoon: false),
        Affirmation(id: UUID(), category: .selfWorth, text: "I choose to be kind to myself today.", isComingSoon: false),
        
        // Calm
        Affirmation(id: UUID(), category: .calm, text: "This feeling will pass. I am safe.", isComingSoon: false),
        Affirmation(id: UUID(), category: .calm, text: "I breathe in calm, I breathe out tension.", isComingSoon: false),
        Affirmation(id: UUID(), category: .calm, text: "I am grounded in this moment.", isComingSoon: false),
        Affirmation(id: UUID(), category: .calm, text: "Peace begins with a single breath.", isComingSoon: false),
        Affirmation(id: UUID(), category: .calm, text: "I release what I cannot control.", isComingSoon: false),
        Affirmation(id: UUID(), category: .calm, text: "My mind is slowing down.", isComingSoon: false),
        Affirmation(id: UUID(), category: .calm, text: "I am safe in my body.", isComingSoon: false),
        
        // Strength
        Affirmation(id: UUID(), category: .strength, text: "I have overcome challenges before. I will again.", isComingSoon: false),
        Affirmation(id: UUID(), category: .strength, text: "I am stronger than I feel right now.", isComingSoon: false),
        Affirmation(id: UUID(), category: .strength, text: "I trust my ability to handle this.", isComingSoon: false),
        Affirmation(id: UUID(), category: .strength, text: "My resilience is built in small moments.", isComingSoon: false),
        Affirmation(id: UUID(), category: .strength, text: "I can do hard things.", isComingSoon: false),
        Affirmation(id: UUID(), category: .strength, text: "I stand tall in my truth.", isComingSoon: false),
        Affirmation(id: UUID(), category: .strength, text: "My courage grows every day.", isComingSoon: false),
        
        // Hope
        Affirmation(id: UUID(), category: .hope, text: "Today is a fresh start.", isComingSoon: false),
        Affirmation(id: UUID(), category: .hope, text: "Good things are coming my way.", isComingSoon: false),
        Affirmation(id: UUID(), category: .hope, text: "I am open to new possibilities.", isComingSoon: false),
        Affirmation(id: UUID(), category: .hope, text: "Every day is a new opportunity.", isComingSoon: false),
        Affirmation(id: UUID(), category: .hope, text: "I trust the timing of my life.", isComingSoon: false),
        Affirmation(id: UUID(), category: .hope, text: "Light is always present, even in the dark.", isComingSoon: false),
        Affirmation(id: UUID(), category: .hope, text: "My future is bright.", isComingSoon: false),
        
        // Self Compassion
        Affirmation(id: UUID(), category: .selfCompassion, text: "I forgive myself for being imperfect.", isComingSoon: false),
        Affirmation(id: UUID(), category: .selfCompassion, text: "I am doing the best I can.", isComingSoon: false),
        Affirmation(id: UUID(), category: .selfCompassion, text: "It is okay to make mistakes.", isComingSoon: false),
        Affirmation(id: UUID(), category: .selfCompassion, text: "I speak to myself with gentleness.", isComingSoon: false),
        Affirmation(id: UUID(), category: .selfCompassion, text: "My imperfections make me human.", isComingSoon: false),
        Affirmation(id: UUID(), category: .selfCompassion, text: "I embrace my vulnerability.", isComingSoon: false),
        Affirmation(id: UUID(), category: .selfCompassion, text: "I am allowed to ask for help.", isComingSoon: false)
    ]
}

// MARK: - Journey
struct Journey: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let estimatedDays: Int
    let steps: [JourneyStep]
    let isComingSoon: Bool
    
    // Backwards compatibility
    var isPremium: Bool { false }
    
    var totalSteps: Int { steps.count }
    
    static let samples: [Journey] = [
        Journey(
            id: UUID(),
            name: "Anxiety 101",
            description: "A gentle introduction to understanding and managing anxiety",
            estimatedDays: 7,
            steps: [
                JourneyStep(id: UUID(), day: 1, orderIndex: 0, stepType: .lesson, refId: nil, title: "What Is Anxiety?", instructions: "Learn about your body's alarm system"),
                JourneyStep(id: UUID(), day: 1, orderIndex: 1, stepType: .breathe, refId: nil, title: "Simple Calm Breathing", instructions: "Practice your first calming breath"),
                JourneyStep(id: UUID(), day: 2, orderIndex: 2, stepType: .lesson, refId: nil, title: "Your Nervous System", instructions: "Understand how calm happens"),
                JourneyStep(id: UUID(), day: 2, orderIndex: 3, stepType: .visualization, refId: nil, title: "Safe Place", instructions: "Create a mental sanctuary"),
                JourneyStep(id: UUID(), day: 3, orderIndex: 4, stepType: .journal, refId: nil, title: "Anxiety Log", instructions: "Track your triggers today"),
                JourneyStep(id: UUID(), day: 3, orderIndex: 5, stepType: .affirmation, refId: nil, title: "I Am Safe", instructions: "Reinforce your safety"),
                JourneyStep(id: UUID(), day: 4, orderIndex: 6, stepType: .game, refId: nil, title: "Zen Stone Stacking", instructions: "Practice focus and balance"),
                JourneyStep(id: UUID(), day: 5, orderIndex: 7, stepType: .lesson, refId: nil, title: "The Power of Rest", instructions: "Why doing nothing is productive"),
                JourneyStep(id: UUID(), day: 6, orderIndex: 8, stepType: .breathe, refId: nil, title: "Box Breathing", instructions: "Master the navy seal technique"),
                JourneyStep(id: UUID(), day: 7, orderIndex: 9, stepType: .journal, refId: nil, title: "Weekly Reflection", instructions: "Look back on your progress")
            ],
            isComingSoon: false
        ),
        Journey(
            id: UUID(),
            name: "Sleep Reset Week",
            description: "Seven nights of better sleep practices",
            estimatedDays: 7,
            steps: [
                JourneyStep(id: UUID(), day: 1, orderIndex: 0, stepType: .lesson, refId: nil, title: "Sleep Hygiene Basics", instructions: "Set the stage for restful nights"),
                JourneyStep(id: UUID(), day: 1, orderIndex: 1, stepType: .breathe, refId: nil, title: "4-7-8 for Sleep", instructions: "The relaxation breath"),
                JourneyStep(id: UUID(), day: 2, orderIndex: 2, stepType: .visualization, refId: nil, title: "Body Scan", instructions: "Release tension from your muscles"),
                JourneyStep(id: UUID(), day: 3, orderIndex: 3, stepType: .journal, refId: nil, title: "Worry Dump", instructions: "Clear your mind before bed")
            ],
            isComingSoon: false
        )
    ]
}

// MARK: - Journey Step
struct JourneyStep: Identifiable, Codable {
    let id: UUID
    let day: Int // 1-based day index
    let orderIndex: Int
    let stepType: StepType
    let refId: UUID?
    let title: String
    let instructions: String
    
    // Backwards compatibility
    var type: StepType { stepType }
    
    enum StepType: String, Codable {
        case lesson
        case breathe
        case visualization
        case affirmation
        case journal
        case game
    }
    
    var iconName: String {
        switch stepType {
        case .lesson: return "book.fill"
        case .breathe: return "wind"
        case .visualization: return "eye.fill"
        case .affirmation: return "heart.fill"
        case .journal: return "pencil.and.scribble"
        case .game: return "gamecontroller.fill"
        }
    }
}

// MARK: - Medical Source (for compliance screens)
struct MedicalSource: Identifiable, Codable {
    let id: UUID
    let title: String
    let organization: String
    let description: String
    let url: String
    let category: SourceCategory
    
    enum SourceCategory: String, Codable, CaseIterable {
        case mentalHealth = "Mental Health & Anxiety"
        case breathing = "Breathing & Relaxation"
        case sleep = "Sleep & Wellness"
        case therapeutic = "Therapeutic Approaches"
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        organization: String,
        description: String,
        url: String,
        category: SourceCategory
    ) {
        self.id = id
        self.title = title
        self.organization = organization
        self.description = description
        self.url = url
        self.category = category
    }
}

// MARK: - Research Reference (for compliance screens)
struct ResearchReference: Identifiable, Codable {
    let id: UUID
    let authors: String
    let year: String
    let title: String
    let journal: String
    let url: String?
    
    init(
        id: UUID = UUID(),
        authors: String,
        year: String,
        title: String,
        journal: String,
        url: String? = nil
    ) {
        self.id = id
        self.authors = authors
        self.year = year
        self.title = title
        self.journal = journal
        self.url = url
    }
}

// MARK: - App Notification Setting
struct AppNotificationSetting: Identifiable, Codable {
    let id: UUID
    var notificationType: NotificationType
    var isEnabled: Bool
    var scheduledTime: Date?
    
    enum NotificationType: String, Codable, CaseIterable {
        case dailyReminder = "Daily Reminder"
        case weeklyProgress = "Weekly Progress"
        case moodCheckin = "Mood Check-in"
        case affirmation = "Daily Affirmation"
    }
}

// MARK: - Visualization
// MARK: - Visualization
struct Visualization: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let iconName: String
    let category: VisualizationCategory
    let durationMinutes: Int
    let steps: [String]
    let audioFileName: String? // New property for audio support
    let isComingSoon: Bool
    
    // Backwards compatibility aliases
    var name: String { title }
    var isPremium: Bool { false }
    
    enum VisualizationCategory: String, Codable, CaseIterable {
        case quickGrounding = "Quick Grounding"
        case bodyScans = "Body Scans"
        case guidedScenes = "Guided Scenes"
        case emotionalSupport = "Emotional Support"
    }
    
    static let samples: [Visualization] = [
        // CATEGORY 1: Quick Grounding
        Visualization(
            id: UUID(),
            title: "5-4-3-2-1",
            description: "The ultimate emergency grounding tool",
            iconName: "hand.raised.fingers.spread.fill",
            category: .quickGrounding,
            durationMinutes: 2,
            steps: [
                "Look around and name 5 things you can see.",
                "Notice 4 things you can physically feel.",
                "Listen for 3 sounds around you.",
                "Identify 2 things you can smell.",
                "Notice 1 thing you can taste.",
                "Take a deep breath. You are here, now, and safe."
            ],
            audioFileName: "grounding_calm", // Mapped to CALMING sound
            isComingSoon: false
        ),
        Visualization(
            id: UUID(),
            title: "5 Senses Grounding",
            description: "Notice 5 things you see, 4 you hear... ",
            iconName: "eye.fill",
            category: .quickGrounding,
            durationMinutes: 3,
            steps: [
                "Look around and name 5 things you can see.",
                "Notice 4 things you can physically feel.",
                "Listen for 3 sounds around you.",
                "Identify 2 things you can smell.",
                "Notice 1 thing you can taste.",
                "Take a deep breath. You are here, now, and safe."
            ],
            audioFileName: "stress_relief_melody", // Mapped to Stress Relieve
            isComingSoon: false
        ),
        
        // CATEGORY 2: Body Scans
        Visualization(
            id: UUID(),
            title: "2 Min Body Scan",
            description: "A quick check-in with your body",
            iconName: "figure.stand",
            category: .bodyScans,
            durationMinutes: 2,
            steps: [
                "Find a comfortable position and close your eyes.",
                "Take three deep breaths, letting your body settle.",
                "Bring your attention to the top of your head.",
                "Notice any sensations in your scalp and forehead.",
                "Move your awareness down to your face and jaw.",
                "Let any tension melt away from your shoulders.",
                "Feel your arms, hands, and fingers relax.",
                "Bring attention to your chest and belly.",
                "Notice your breathing, slow and steady.",
                "Feel your hips, legs, and feet grounded.",
                "Take a moment to feel your whole body at once.",
                "Gently open your eyes when you're ready."
            ],
            audioFileName: "body_scan_bell", // Mapped to Deep Medittation
            isComingSoon: false
        ),
        Visualization(
            id: UUID(),
            title: "5 Min Body Scan",
            description: "A gentle, thorough journey through your body",
            iconName: "figure.stand",
            category: .bodyScans,
            durationMinutes: 5,
            steps: [
                "Find a comfortable position and close your eyes.",
                "Take three deep breaths, letting your body settle.",
                "Bring your attention to the top of your head.",
                "Notice any sensations in your scalp and forehead.",
                "Move your awareness down to your face and jaw.",
                "Let any tension melt away from your shoulders.",
                "Feel your arms, hands, and fingers relax.",
                "Bring attention to your chest and belly.",
                "Notice your breathing, slow and steady.",
                "Feel your hips, legs, and feet grounded.",
                "Take a moment to feel your whole body at once.",
                "Gently open your eyes when you're ready."
            ],
            audioFileName: "deep_sleep_drone", // Mapped to Deep Sound to Fall Instantly
            isComingSoon: false
        ),
        
        // CATEGORY 3: Guided Scenes
        Visualization(
            id: UUID(),
            title: "Safe Place",
            description: "Create and visit your personal sanctuary",
            iconName: "house.fill",
            category: .guidedScenes,
            durationMinutes: 5,
            steps: [
                "Close your eyes and take a deep breath.",
                "Imagine you're in a beautiful, peaceful place.",
                "Notice the colors and light around you.",
                "Feel the temperature on your skin.",
                "What sounds can you hear in this place?",
                "Feel yourself becoming calmer and more at peace.",
                "Know that you can return here whenever you need.",
                "Slowly bring your awareness back to the present."
            ],
            audioFileName: "nature_rain", // Mapped to Relaxing rain sounds
            isComingSoon: false
        ),
        Visualization(
            id: UUID(),
            title: "A Beautiful Beach",
            description: "Walk along a peaceful, sunlit beach",
            iconName: "sun.horizon.fill",
            category: .guidedScenes,
            durationMinutes: 7,
            steps: [
                "Close your eyes and take a deep breath.",
                "Imagine you're in a beautiful, peaceful place.",
                "Notice the colors and light around you.",
                "Feel the temperature on your skin.",
                "What sounds can you hear in this place?",
                "Feel yourself becoming calmer and more at peace.",
                "Know that you can return here whenever you need.",
                "Slowly bring your awareness back to the present."
            ],
            audioFileName: "grounding_calm", // Reusing calming sound
            isComingSoon: true
        ),
        
        // MARK: - NEW EXERCISES (User Provided)
        
        // --- QUICK GROUNDING ---
        Visualization(
            id: UUID(),
            title: "Instant Grounding",
            description: "A quick 1-minute reset for instant grounding",
            iconName: "stopwatch.fill",
            category: .quickGrounding,
            durationMinutes: 1,
            steps: [
                "Take a slow breath in through the nose.",
                "Let your shoulders soften.",
                "Notice one sound around you.",
                "Notice where your body touches the chair or bed.",
                "Feel the weight of your feet.",
                "Take one deeper breath.",
                "Exhale slowly.",
                "Feel one moment of steadiness inside you."
            ],
            audioFileName: "calming_sound",
            isComingSoon: false
        ),
        Visualization(
            id: UUID(),
            title: "Breath of Renewal",
            description: "Two minutes to center your breath and mind",
            iconName: "wind",
            category: .quickGrounding,
            durationMinutes: 2,
            steps: [
                "Bring awareness to your breathing.",
                "Inhale softly through your nose.",
                "Exhale through your mouth.",
                "Notice the coolness of your inhale.",
                "Notice the warmth of your exhale.",
                "Let your shoulders drop naturally.",
                "Allow your breath to slow.",
                "Allow your chest to loosen.",
                "Take one steady breath.",
                "Feel calmer than when you began."
            ],
            audioFileName: "stress_relief",
            isComingSoon: false
        ),
        Visualization(
            id: UUID(),
            title: "Sacred Pause",
            description: "Stop the chaos and observe the present moment",
            iconName: "eye.circle.fill",
            category: .quickGrounding,
            durationMinutes: 3,
            steps: [
                "Pause whatever you’re doing.",
                "Place attention on your breath.",
                "Notice the space above your chest.",
                "Notice the air around you.",
                "Bring awareness to your hands.",
                "Bring awareness to your feet.",
                "Let your jaw relax.",
                "Let your thoughts drift without grabbing them.",
                "Take one slow breath.",
                "Return with a softer mind."
            ],
            audioFileName: "calming_sound",
            isComingSoon: false
        ),
        
        // --- BODY SCANS ---
        Visualization(
            id: UUID(),
            title: "Complete Body Harmony",
            description: "A complete journey through your body for deep relaxation",
            iconName: "figure.stand",
            category: .bodyScans,
            durationMinutes: 8,
            steps: [
                "Close your eyes gently.",
                "Relax your forehead.",
                "Relax your eyes and cheeks.",
                "Soften your jaw.",
                "Release your shoulders.",
                "Let your arms feel heavy.",
                "Feel your chest expand and fall.",
                "Relax your stomach.",
                "Move your awareness down your legs.",
                "Relax your feet and toes.",
                "Sense your whole body as one.",
                "Rest in this calm space."
            ],
            audioFileName: "deep_meditation",
            isComingSoon: false
        ),
        Visualization(
            id: UUID(),
            title: "Nurturing Presence",
            description: "A nurturing scan for comfort and connection",
            iconName: "heart.circle.fill",
            category: .bodyScans,
            durationMinutes: 10,
            steps: [
                "Find a position that supports your body.",
                "Bring awareness to your breath.",
                "Soften your facial muscles.",
                "Relax your shoulders and chest.",
                "Notice your belly without judgment.",
                "Breathe gently into your abdomen.",
                "Bring attention to your lower back.",
                "Soften your hips.",
                "Feel your legs grounding you.",
                "Relax your feet.",
                "Sense your entire body supporting you.",
                "End with one slow, loving breath."
            ],
            audioFileName: "deep_sleep_instant",
            isComingSoon: false
        ),
        Visualization(
            id: UUID(),
            title: "Melting Tension",
            description: "Rapidly release held tension in key areas",
            iconName: "arrow.down.circle.fill",
            category: .bodyScans,
            durationMinutes: 3,
            steps: [
                "Relax your face.",
                "Drop your shoulders.",
                "Loosen your hands.",
                "Unclench your jaw.",
                "Relax your stomach.",
                "Let your legs feel heavy.",
                "Exhale long and slow.",
                "Notice the ease in your body."
            ],
            audioFileName: "meditation_calm",
            isComingSoon: false
        ),
        Visualization(
            id: UUID(),
            title: "Elemental Embrace",
            description: "Connect your body with the elements of nature",
            iconName: "leaf.fill",
            category: .bodyScans,
            durationMinutes: 10,
            steps: [
                "Imagine fresh outdoor air around you.",
                "Relax your forehead.",
                "Relax your cheeks.",
                "Relax your neck.",
                "Let your shoulders fall.",
                "Loosen your arms.",
                "Soften your chest.",
                "Relax your stomach.",
                "Relax your hips.",
                "Relax your legs.",
                "Relax your feet.",
                "Breathe in the calm of nature."
            ],
            audioFileName: "nature_crickets",
            isComingSoon: false
        ),
        Visualization(
            id: UUID(),
            title: "Twilight Unwinding",
            description: "Prepare your body for a restful sleep",
            iconName: "moon.stars.fill",
            category: .bodyScans,
            durationMinutes: 6,
            steps: [
                "Slow your breath.",
                "Relax the muscles around your eyes.",
                "Let your jaw hang loose.",
                "Drop your shoulders completely.",
                "Relax your torso.",
                "Melt into your bed or chair.",
                "Relax your hips and legs.",
                "Relax your feet.",
                "Let your thoughts dim.",
                "Drift toward rest."
            ],
            audioFileName: "deep_sleep_instant",
            isComingSoon: false
        ),
        
        // --- GUIDED SCENES ---
        Visualization(
            id: UUID(),
            title: "Forest Serenity",
            description: "A short walk through a peaceful forest",
            iconName: "tree.fill",
            category: .guidedScenes,
            durationMinutes: 1,
            steps: [
                "Imagine stepping onto a quiet forest path.",
                "Hear gentle rustling in the trees.",
                "Feel cool air around you.",
                "Notice sunlight through leaves.",
                "Walk slowly along the path.",
                "Let your breath match your pace.",
                "Feel grounded.",
                "Take one steady breath."
            ],
            audioFileName: "nature_crickets",
            isComingSoon: false
        ),
        Visualization(
            id: UUID(),
            title: "Waterfall of Peace",
            description: "Relax by a gentle, flowing stream",
            iconName: "drop.fill",
            category: .guidedScenes,
            durationMinutes: 9,
            steps: [
                "Picture clear water flowing down rocks.",
                "Hear the steady rhythm of the stream.",
                "Imagine cool droplets on your skin.",
                "Sit near the gentle water.",
                "Let your breath follow the flow.",
                "Release tension with each exhale.",
                "Feel refreshed energy entering.",
                "Allow your mind to settle.",
                "Rest near the flowing sound.",
                "Breathe in calm.",
                "Breathe out heaviness.",
                "Carry this ease forward."
            ],
            audioFileName: "relaxing_rain",
            isComingSoon: false
        ),
        Visualization(
            id: UUID(),
            title: "Golden Shoreline",
            description: "A warm, soothing walk along the beach",
            iconName: "sun.max.fill",
            category: .guidedScenes,
            durationMinutes: 12,
            steps: [
                "Picture warm sunlight on the ocean surface.",
                "Hear gentle shore waves.",
                "Feel sand under your feet.",
                "Walk along the water’s edge.",
                "Notice the light dancing on the waves.",
                "Let the rhythm calm your body.",
                "Let your breath slow.",
                "Release any tightness.",
                "Feel warmth move through you.",
                "Allow stillness to grow.",
                "Stand with the horizon in view.",
                "End with a slow, mindful breath."
            ],
            audioFileName: "ocean_waves",
            isComingSoon: false
        ),
        Visualization(
            id: UUID(),
            title: "Infinite Horizon",
            description: "Gain perspective from a peaceful hilltop",
            iconName: "mountain.2.fill",
            category: .guidedScenes,
            durationMinutes: 9,
            steps: [
                "Imagine standing on a peaceful hill.",
                "Look out across a wide horizon.",
                "Feel open space around you.",
                "Relax your shoulders.",
                "Slow your breath.",
                "Sense gentle air on your skin.",
                "Let your mind widen.",
                "Let calmness grow.",
                "Feel grounded and steady.",
                "Keep this clarity with you."
            ],
            audioFileName: "stress_relief",
            isComingSoon: false
        ),
        Visualization(
            id: UUID(),
            title: "Sanctuary Within",
            description: "Create and visit your personal safe space",
            iconName: "house.fill",
            category: .guidedScenes,
            durationMinutes: 2,
            steps: [
                "Imagine a private place where you feel secure.",
                "Add colors and textures.",
                "Notice the atmosphere of safety.",
                "Imagine sitting in this space.",
                "Let your breath deepen.",
                "Let your body settle.",
                "Feel supported.",
                "Return to this place anytime."
            ],
            audioFileName: "calming_sound",
            isComingSoon: false
        ),
        Visualization(
            id: UUID(),
            title: "Meadow of Light",
            description: "Rest in a wide, sunlit meadow",
            iconName: "sun.haze.fill",
            category: .guidedScenes,
            durationMinutes: 10,
            steps: [
                "Picture a wide open meadow.",
                "Feel soft grass beneath you.",
                "Hear distant birds.",
                "Feel warm sunlight on your skin.",
                "Let your shoulders drop.",
                "Let your arms relax.",
                "Let your legs feel heavy.",
                "Breathe evenly.",
                "Rest deeply.",
                "Allow stillness to fill you."
            ],
            audioFileName: "meditation_calm",
            isComingSoon: false
        ),
        Visualization(
            id: UUID(),
            title: "Floating Amongst Clouds",
            description: "Float away with the clouds",
            iconName: "cloud.fill",
            category: .guidedScenes,
            durationMinutes: 6,
            steps: [
                "Imagine looking up at slow-moving clouds.",
                "Watch them float effortlessly.",
                "Notice their softness.",
                "Align your breath with their movement.",
                "Let your body loosen.",
                "Release tension.",
                "Drift along in your mind.",
                "Feel spaciousness around you.",
                "Breathe lightly.",
                "Rest in ease."
            ],
            audioFileName: "meditation_calm",
            isComingSoon: false
        ),
        
        // --- EMOTIONAL SUPPORT ---
        Visualization(
            id: UUID(),
            title: "Softening the Edges",
            description: "Soften the sharp edges of anxious feelings",
            iconName: "heart.text.square.fill",
            category: .emotionalSupport,
            durationMinutes: 10,
            steps: [
                "Sit comfortably and breathe softly.",
                "Notice where anxiety touches your body.",
                "Instead of resisting, make room for it.",
                "Relax your shoulders.",
                "Relax your stomach.",
                "Let your breath deepen naturally.",
                "Feel the sensation shift slightly.",
                "Let your body soften more.",
                "Slow your exhale.",
                "Feel steadiness grow.",
                "Sense even the smallest comfort.",
                "Rest in this gentle ease."
            ],
            audioFileName: "stress_relief",
            isComingSoon: false
        ),
        Visualization(
            id: UUID(),
            title: "Inner Strength Rising",
            description: "Reconnect with your inner strength",
            iconName: "star.fill",
            category: .emotionalSupport,
            durationMinutes: 10,
            steps: [
                "Take a slow breath.",
                "Say silently: “I am here.”",
                "Feel your breath stabilizing.",
                "Picture one thing you’ve handled well.",
                "Feel strength rising in your chest.",
                "Repeat: “I can do this.”",
                "Let your shoulders drop.",
                "Let your jaw relax.",
                "Allow calm confidence to settle.",
                "Set one simple intention.",
                "Breathe softly.",
                "Carry this capability forward."
            ],
            audioFileName: "calming_sound",
            isComingSoon: false
        ),
        Visualization(
            id: UUID(),
            title: "Gentle Confidence",
            description: "Build confidence without the weight of perfection",
            iconName: "person.fill.checkmark",
            category: .emotionalSupport,
            durationMinutes: 9,
            steps: [
                "Notice any pressure you’re carrying.",
                "Exhale slowly.",
                "Loosen your shoulders.",
                "Imagine warmth in your chest.",
                "Say: “I don’t need to be perfect.”",
                "Feel the heaviness lift.",
                "Picture yourself succeeding softly.",
                "Relax your hands.",
                "Let tension drain downward.",
                "Breathe with ease.",
                "Feel grounded.",
                "Rest in gentle confidence."
            ],
            audioFileName: "stress_relief",
            isComingSoon: false
        ),
        Visualization(
            id: UUID(),
            title: "Quieting the Mind",
            description: "Let go of racing thoughts",
            iconName: "bubble.left.and.bubble.right.fill",
            category: .emotionalSupport,
            durationMinutes: 7,
            steps: [
                "Notice your mind racing.",
                "Drop attention into your body.",
                "Feel your feet on the ground.",
                "Feel your breath slow.",
                "Imagine your thoughts as floating bubbles.",
                "Let each bubble drift away.",
                "Don’t chase them.",
                "Stay with your breath.",
                "Feel your mind settle.",
                "Rest in clarity."
            ],
            audioFileName: "calming_sound",
            isComingSoon: false
        ),
        Visualization(
            id: UUID(),
            title: "Heartfelt Comfort",
            description: "Find a warm sense of comfort within",
            iconName: "heart.fill",
            category: .emotionalSupport,
            durationMinutes: 9,
            steps: [
                "Place a hand on your chest or stomach.",
                "Feel the warmth beneath your hand.",
                "Breathe softly.",
                "Let your breath soothe you.",
                "Release tension as you exhale.",
                "Notice a sense of comfort building.",
                "Allow this comfort to expand.",
                "Let your body relax deeper.",
                "Sit in this warmth.",
                "End with a gentle breath."
            ],
            audioFileName: "meditation_calm",
            isComingSoon: false
        ),
        Visualization(
            id: UUID(),
            title: "Crystal Clarity",
            description: "Sharpen your mind and clear distractions",
            iconName: "target",
            category: .emotionalSupport,
            durationMinutes: 6,
            steps: [
                "Bring attention to your breathing.",
                "Notice the air entering your nose.",
                "Notice your body sitting here.",
                "Release one long exhale.",
                "Let distractions soften.",
                "Picture a single point of focus.",
                "Hold your attention lightly.",
                "Breathe steadily.",
                "Feel your mind sharpen.",
                "Move forward with clarity."
            ],
            audioFileName: "deep_meditation",
            isComingSoon: false
        ),
        Visualization(
            id: UUID(),
            title: "Dissolving Stress",
            description: "Melt away physical stress",
            iconName: "drop.fill",
            category: .bodyScans,
            durationMinutes: 8,
            steps: [
                "Notice any tight areas.",
                "Breathe gently into them.",
                "Relax your face.",
                "Relax your neck.",
                "Relax your shoulders.",
                "Relax your back.",
                "Relax your legs.",
                "Let tension melt downward.",
                "Sit in ease.",
                "Breathe softly."
            ],
            audioFileName: "deep_meditation",
            isComingSoon: false
        ),
        Visualization(
            id: UUID(),
            title: "Morning Radiance",
            description: "Start your morning with energy and calm",
            iconName: "sun.max.fill",
            category: .emotionalSupport,
            durationMinutes: 9,
            steps: [
                "Sit with your back straight.",
                "Take one energizing breath.",
                "Feel your body waking.",
                "Stretch your shoulders.",
                "Drop into your breath.",
                "Set a calm intention.",
                "Visualize a grounded day.",
                "Feel steady.",
                "Breathe in clarity.",
                "Begin your day with calm confidence."
            ],
            audioFileName: "stress_relief",
            isComingSoon: false
        ),
        Visualization(
            id: UUID(),
            title: "Velvet Night Rest",
            description: "A gentle transition into sleep",
            iconName: "moon.zzz.fill",
            category: .bodyScans,
            durationMinutes: 8,
            steps: [
                "Dim your breath.",
                "Loosen your jaw.",
                "Relax your shoulders.",
                "Relax your back.",
                "Relax your hips.",
                "Relax your legs.",
                "Let your thoughts soften.",
                "Let your body grow heavy.",
                "Sit in the quiet.",
                "Drift toward sleep."
            ],
            audioFileName: "deep_sleep_instant",
            isComingSoon: false
        )
    ]
}
