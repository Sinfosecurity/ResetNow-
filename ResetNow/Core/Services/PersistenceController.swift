//
//  PersistenceController.swift
//  ResetNow
//
//  Local data persistence using JSON files and UserDefaults
//

import Foundation

@MainActor
final class PersistenceController: ObservableObject {
    static let shared = PersistenceController()
    
    // MARK: - Published State
    @Published private(set) var userProfile: UserProfile
    @Published private(set) var sessions: [ResetSession] = []
    @Published private(set) var journalEntries: [JournalEntry] = []
    @Published private(set) var affirmationFavorites: Set<UUID> = []
    @Published private(set) var lessonProgress: [UUID: LessonProgress] = [:]
    @Published private(set) var journeyProgress: [UUID: JourneyProgress] = [:]
    @Published private(set) var chatSessions: [ChatSession] = []
    @Published private(set) var chatMessages: [ChatMessage] = []
    @Published private(set) var moodCheckins: [MoodCheckin] = []
    
    // MARK: - Catalog Data (loaded from bundled JSON)
    @Published private(set) var lessons: [Lesson] = []
    @Published private(set) var breathingExercises: [BreathingExercise] = []
    @Published private(set) var games: [CalmGame] = []
    @Published private(set) var sleepTracks: [SleepTrack] = []
    @Published private(set) var visualizations: [Visualization] = []
    @Published private(set) var affirmations: [Affirmation] = []
    @Published private(set) var journeys: [Journey] = []
    
    // MARK: - Computed Stats
    var currentStreak: Int {
        calculateStreak()
    }
    
    var totalResets: Int {
        sessions.count
    }
    
    // MARK: - File URLs
    private let documentsDirectory: URL
    private let userProfileURL: URL
    private let sessionsURL: URL
    private let journalURL: URL
    private let favoritesURL: URL
    private let lessonProgressURL: URL
    private let journeyProgressURL: URL
    private let chatSessionsURL: URL
    private let chatMessagesURL: URL
    private let moodCheckinsURL: URL
    
    // MARK: - Init
    private init() {
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        userProfileURL = documentsDirectory.appendingPathComponent("user_profile.json")
        sessionsURL = documentsDirectory.appendingPathComponent("sessions.json")
        journalURL = documentsDirectory.appendingPathComponent("journal.json")
        favoritesURL = documentsDirectory.appendingPathComponent("favorites.json")
        lessonProgressURL = documentsDirectory.appendingPathComponent("lesson_progress.json")
        journeyProgressURL = documentsDirectory.appendingPathComponent("journey_progress.json")
        chatSessionsURL = documentsDirectory.appendingPathComponent("chat_sessions.json")
        chatMessagesURL = documentsDirectory.appendingPathComponent("chat_messages.json")
        moodCheckinsURL = documentsDirectory.appendingPathComponent("mood_checkins.json")
        
        // Load or create default user profile
        userProfile = Self.loadJSON(from: userProfileURL) ?? UserProfile.default
        
        // Load user data
        sessions = Self.loadJSON(from: sessionsURL) ?? []
        journalEntries = Self.loadJSON(from: journalURL) ?? []
        let favoritesList: [AffirmationFavorite] = Self.loadJSON(from: favoritesURL) ?? []
        affirmationFavorites = Set(favoritesList.map { $0.affirmationId })
        
        let lessonProgressList: [LessonProgress] = Self.loadJSON(from: lessonProgressURL) ?? []
        lessonProgress = Dictionary(uniqueKeysWithValues: lessonProgressList.map { ($0.lessonId, $0) })
        
        let journeyProgressList: [JourneyProgress] = Self.loadJSON(from: journeyProgressURL) ?? []
        journeyProgress = Dictionary(uniqueKeysWithValues: journeyProgressList.map { ($0.journeyId, $0) })
        
        chatSessions = Self.loadJSON(from: chatSessionsURL) ?? []
        chatMessages = Self.loadJSON(from: chatMessagesURL) ?? []
        moodCheckins = Self.loadJSON(from: moodCheckinsURL) ?? []
        
        // Load catalog data from bundle
        loadCatalogData()
    }
    
    // MARK: - Catalog Loading
    private func loadCatalogData() {
        // Try loading from bundled JSON, fall back to hardcoded defaults
        lessons = loadBundledJSON("lessons") ?? Lesson.samples
        breathingExercises = loadBundledJSON("breathing_exercises") ?? Self.defaultBreathingExercises
        games = loadBundledJSON("games") ?? Self.defaultGames
        sleepTracks = loadBundledJSON("sleep_tracks") ?? Self.defaultSleepTracks
        visualizations = loadBundledJSON("visualizations") ?? Visualization.samples
        affirmations = loadBundledJSON("affirmations") ?? Self.defaultAffirmations
        journeys = loadBundledJSON("journeys") ?? Self.defaultJourneys
    }
    
    private func loadBundledJSON<T: Decodable>(_ filename: String) -> T? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    // MARK: - User Profile
    func acceptDisclaimer() {
        userProfile.acceptedDisclaimerAt = Date()
        saveUserProfile()
    }
    
    func updateProfile(_ profile: UserProfile) {
        userProfile = profile
        saveUserProfile()
    }
    
    private func saveUserProfile() {
        Self.saveJSON(userProfile, to: userProfileURL)
    }
    
    // MARK: - Sessions
    func createSession(tool: ResetToolKind, subtypeId: UUID?) -> ResetSession {
        let session = ResetSession(
            id: UUID(),
            startedAt: Date(),
            endedAt: nil,
            sourceToolKind: tool,
            subtypeId: subtypeId,
            notes: nil
        )
        sessions.append(session)
        saveSessions()
        updateStreak()
        return session
    }
    
    func endSession(_ session: ResetSession, notes: String? = nil) {
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index].endedAt = Date()
            sessions[index].notes = notes
            saveSessions()
        }
    }
    
    func getRecentSessions(limit: Int = 10) -> [ResetSession] {
        Array(sessions.sorted { $0.startedAt > $1.startedAt }.prefix(limit))
    }
    
    private func saveSessions() {
        Self.saveJSON(sessions, to: sessionsURL)
    }
    
    // MARK: - Mood Checkins
    func createMoodCheckin(sessionId: UUID?, type: MoodCheckin.MoodType, before: Int?, after: Int?) {
        let checkin = MoodCheckin(
            id: UUID(),
            sessionId: sessionId,
            createdAt: Date(),
            moodType: type,
            valueBefore: before,
            valueAfter: after
        )
        moodCheckins.append(checkin)
        Self.saveJSON(moodCheckins, to: moodCheckinsURL)
    }
    
    // Convenience method matching view usage
    func createMoodCheck(session: ResetSession, type: MoodCheckin.MoodType, before: Int, after: Int) -> MoodCheckin {
        let checkin = MoodCheckin(
            id: UUID(),
            sessionId: session.id,
            createdAt: Date(),
            moodType: type,
            valueBefore: before,
            valueAfter: after
        )
        moodCheckins.append(checkin)
        Self.saveJSON(moodCheckins, to: moodCheckinsURL)
        return checkin
    }
    
    // MARK: - Journal
    func createJournalEntry(prompt: String?, text: String, moodTag: String?) {
        let entry = JournalEntry(
            id: UUID(),
            createdAt: Date(),
            promptText: prompt,
            entryText: text,
            moodTag: moodTag
        )
        journalEntries.insert(entry, at: 0)
        Self.saveJSON(journalEntries, to: journalURL)
    }
    
    func getJournalEntries() -> [JournalEntry] {
        journalEntries
    }
    
    // MARK: - Favorites
    func toggleFavorite(affirmationId: UUID) -> Bool {
        if affirmationFavorites.contains(affirmationId) {
            affirmationFavorites.remove(affirmationId)
            saveFavorites()
            return false
        } else {
            affirmationFavorites.insert(affirmationId)
            saveFavorites()
            return true
        }
    }
    
    func isFavorite(affirmationId: UUID) -> Bool {
        affirmationFavorites.contains(affirmationId)
    }
    
    func getFavoriteIds() -> Set<UUID> {
        affirmationFavorites
    }
    
    private func saveFavorites() {
        let list = affirmationFavorites.map { AffirmationFavorite(id: UUID(), affirmationId: $0, createdAt: Date()) }
        Self.saveJSON(list, to: favoritesURL)
    }
    
    // MARK: - Lesson Progress
    func markLessonComplete(_ lessonId: UUID) {
        let progress = LessonProgress(id: UUID(), lessonId: lessonId, completedAt: Date())
        lessonProgress[lessonId] = progress
        let list = Array(lessonProgress.values)
        Self.saveJSON(list, to: lessonProgressURL)
    }
    
    func isLessonComplete(_ lessonId: UUID) -> Bool {
        lessonProgress[lessonId]?.completedAt != nil
    }
    
    // MARK: - Journey Progress
    func startJourney(_ journeyId: UUID) {
        let progress = JourneyProgress(
            id: UUID(),
            journeyId: journeyId,
            currentStepIndex: 0,
            startedAt: Date(),
            completedAt: nil
        )
        journeyProgress[journeyId] = progress
        saveJourneyProgress()
    }
    
    func advanceJourneyStep(_ journeyId: UUID) {
        guard var progress = journeyProgress[journeyId] else { return }
        progress.currentStepIndex += 1
        
        if let journey = journeys.first(where: { $0.id == journeyId }),
           progress.currentStepIndex >= journey.totalSteps {
            progress.completedAt = Date()
        }
        
        journeyProgress[journeyId] = progress
        saveJourneyProgress()
    }
    
    private func saveJourneyProgress() {
        let list = Array(journeyProgress.values)
        Self.saveJSON(list, to: journeyProgressURL)
    }
    
    // MARK: - Chat
    func createChatSession() -> ChatSession {
        let session = ChatSession(
            id: UUID(),
            startedAt: Date(),
            endedAt: nil,
            isCrisisFlagged: false,
            crisisFlagReason: nil
        )
        chatSessions.append(session)
        Self.saveJSON(chatSessions, to: chatSessionsURL)
        return session
    }
    
    func addChatMessage(sessionId: UUID, sender: ChatMessage.MessageSender, text: String, safetyFlag: String? = nil) {
        let message = ChatMessage(
            id: UUID(),
            chatSessionId: sessionId,
            sender: sender,
            createdAt: Date(),
            text: text,
            safetyFlag: safetyFlag
        )
        chatMessages.append(message)
        Self.saveJSON(chatMessages, to: chatMessagesURL)
        
        // Update session if crisis flagged
        if safetyFlag != nil, let index = chatSessions.firstIndex(where: { $0.id == sessionId }) {
            chatSessions[index].isCrisisFlagged = true
            chatSessions[index].crisisFlagReason = safetyFlag
            Self.saveJSON(chatSessions, to: chatSessionsURL)
        }
    }
    
    func getMessages(for sessionId: UUID) -> [ChatMessage] {
        chatMessages.filter { $0.chatSessionId == sessionId }.sorted { $0.createdAt < $1.createdAt }
    }
    
    func getActiveOrNewChatSession() -> ChatSession {
        if let active = chatSessions.first(where: { $0.endedAt == nil }) {
            return active
        }
        return createChatSession()
    }
    
    // MARK: - Greeting Logic
    
    func shouldTriggerGreeting(for sessionId: UUID) -> Bool {
        let sessionMessages = getMessages(for: sessionId)
        
        // 1. First time ever (no messages)
        if sessionMessages.isEmpty {
            return true
        }
        
        // Get last message
        guard let lastMessage = sessionMessages.last else { return true }
        
        // 2. First time today
        let calendar = Calendar.current
        if !calendar.isDateInToday(lastMessage.createdAt) {
            return true
        }
        
        // 3. Long inactivity (e.g., 6 hours)
        let hoursElapsed = Date().timeIntervalSince(lastMessage.createdAt) / 3600
        if hoursElapsed > 6 {
            return true
        }
        
        return false
    }
    
    func addGreetingMessage(sessionId: UUID, text: String) {
        addChatMessage(sessionId: sessionId, sender: .rae, text: text)
    }
    
    // MARK: - Stats
    func getToolUsageCounts() -> [ResetToolKind: Int] {
        var counts: [ResetToolKind: Int] = [:]
        for session in sessions {
            counts[session.sourceToolKind, default: 0] += 1
        }
        return counts
    }
    
    func getSessionsThisWeek() -> [ResetSession] {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        return sessions.filter { $0.startedAt >= startOfWeek }
    }
    
    private func calculateStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())
        
        let sessionDates = Set(sessions.map { calendar.startOfDay(for: $0.startedAt) })
        
        while sessionDates.contains(checkDate) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = previousDay
        }
        
        return streak
    }
    
    private func updateStreak() {
        UserDefaults.standard.set(currentStreak, forKey: "currentStreak")
        UserDefaults.standard.set(Date(), forKey: "lastResetDate")
    }
    
    // MARK: - JSON Helpers
    private static func loadJSON<T: Decodable>(from url: URL) -> T? {
        guard FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    private static func saveJSON<T: Encodable>(_ value: T, to url: URL) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        try? data.write(to: url)
    }
}

// MARK: - Default Catalog Data
extension PersistenceController {
    

    
    static let defaultBreathingExercises: [BreathingExercise] = [
        BreathingExercise(id: UUID(), name: "Box Breathing", description: "Equal inhale, hold, exhale, hold. Used for calm under pressure.", inhaleSeconds: 4, holdTopSeconds: 4, exhaleSeconds: 4, holdBottomSeconds: 4, defaultDurationSeconds: 180, isComingSoon: false, isPremium: false),
        BreathingExercise(id: UUID(), name: "4-7-8 Relaxation", description: "Dr. Weil's technique for sleep and anxiety.", inhaleSeconds: 4, holdTopSeconds: 7, exhaleSeconds: 8, holdBottomSeconds: 0, defaultDurationSeconds: 180, isComingSoon: false, isPremium: false),
        BreathingExercise(id: UUID(), name: "Simple Calm", description: "Gentle inhale and exhale. Perfect for beginners.", inhaleSeconds: 4, holdTopSeconds: 0, exhaleSeconds: 6, holdBottomSeconds: 0, defaultDurationSeconds: 120, isComingSoon: false, isPremium: false),
        BreathingExercise(id: UUID(), name: "Energizing Breath", description: "Quick cycles to boost energy and alertness.", inhaleSeconds: 3, holdTopSeconds: 0, exhaleSeconds: 3, holdBottomSeconds: 0, defaultDurationSeconds: 60, isComingSoon: false, isPremium: true),
        BreathingExercise(id: UUID(), name: "Deep Sleep Breath", description: "Extended exhale pattern for rest.", inhaleSeconds: 4, holdTopSeconds: 4, exhaleSeconds: 10, holdBottomSeconds: 2, defaultDurationSeconds: 300, isComingSoon: false, isPremium: true)
    ]
    
    static let defaultGames: [CalmGame] = [
        CalmGame(id: UUID(), name: "Bubble Pop Calm", description: "Gently pop floating bubbles at your own pace", gameType: .bubblePop, isComingSoon: false, isLockedByProgress: false, unlockRequirement: nil, isPremium: false),
        CalmGame(id: UUID(), name: "Calm Word", description: "Find peaceful words in letter grids", gameType: .calmWord, isComingSoon: true, isLockedByProgress: false, unlockRequirement: nil, isPremium: true),
        CalmGame(id: UUID(), name: "Calm Memory", description: "Match calming images gently", gameType: .memory, isComingSoon: false, isLockedByProgress: false, unlockRequirement: nil, isPremium: true),
        CalmGame(id: UUID(), name: "Thought Garden", description: "Plant and grow a peaceful digital garden", gameType: .thoughtGarden, isComingSoon: true, isLockedByProgress: true, unlockRequirement: 5, isPremium: true),
        CalmGame(id: UUID(), name: "Rhythm Steps", description: "Tap along to soothing rhythms", gameType: .rhythmSteps, isComingSoon: true, isLockedByProgress: false, unlockRequirement: nil, isPremium: true)
    ]
    
    static let defaultSleepTracks: [SleepTrack] = [
        SleepTrack(id: UUID(), name: "All Night Rain", description: "Gentle rainfall to carry you through the night", audioAssetName: "relaxing_rain", durationMinutes: 600, tags: ["rain", "nature"], isComingSoon: false, isPremium: false),
        SleepTrack(id: UUID(), name: "All Night Fireplace", description: "Warm crackling fire sounds", audioAssetName: "fire_crackling", durationMinutes: 600, tags: ["fire", "cozy"], isComingSoon: false, isPremium: true),
        SleepTrack(id: UUID(), name: "Ocean Waves", description: "Rhythmic waves on a peaceful shore", audioAssetName: "ocean_waves", durationMinutes: 600, tags: ["ocean", "nature"], isComingSoon: false, isPremium: true),
        SleepTrack(id: UUID(), name: "Lullaby", description: "Soft instrumental melodies for rest", audioAssetName: "deep_sleep_instant", durationMinutes: 30, tags: ["music", "gentle"], isComingSoon: false, isPremium: false),
        SleepTrack(id: UUID(), name: "Forest Night", description: "Crickets, owls, and gentle forest ambiance", audioAssetName: "night_crickets_owls", durationMinutes: 600, tags: ["nature", "forest"], isComingSoon: false, isPremium: true)
    ]
    
    
    static let defaultAffirmations: [Affirmation] = [
        // Self Worth
        Affirmation(id: UUID(), category: .selfWorth, text: "I am enough, exactly as I am right now.", isComingSoon: false),
        Affirmation(id: UUID(), category: .selfWorth, text: "My worth is not measured by my productivity.", isComingSoon: false),
        Affirmation(id: UUID(), category: .selfWorth, text: "I deserve love and kindness from myself.", isComingSoon: false),
        Affirmation(id: UUID(), category: .selfWorth, text: "I am worthy of rest and peace.", isComingSoon: false),
        // Calm
        Affirmation(id: UUID(), category: .calm, text: "This feeling will pass. I am safe.", isComingSoon: false),
        Affirmation(id: UUID(), category: .calm, text: "I breathe in calm, I breathe out tension.", isComingSoon: false),
        Affirmation(id: UUID(), category: .calm, text: "I am grounded in this present moment.", isComingSoon: false),
        Affirmation(id: UUID(), category: .calm, text: "Peace flows through me with every breath.", isComingSoon: false),
        // Strength
        Affirmation(id: UUID(), category: .strength, text: "I have overcome challenges before. I will again.", isComingSoon: false),
        Affirmation(id: UUID(), category: .strength, text: "I am resilient, even when I don't feel like it.", isComingSoon: false),
        Affirmation(id: UUID(), category: .strength, text: "My struggles do not define my strength.", isComingSoon: false),
        // Hope
        Affirmation(id: UUID(), category: .hope, text: "Tomorrow is a fresh start.", isComingSoon: false),
        Affirmation(id: UUID(), category: .hope, text: "Good things are coming my way.", isComingSoon: false),
        Affirmation(id: UUID(), category: .hope, text: "There is light ahead, even if I can't see it yet.", isComingSoon: false),
        // Self Compassion
        Affirmation(id: UUID(), category: .selfCompassion, text: "I forgive myself for being imperfect.", isComingSoon: false),
        Affirmation(id: UUID(), category: .selfCompassion, text: "It's okay to not be okay sometimes.", isComingSoon: false),
        Affirmation(id: UUID(), category: .selfCompassion, text: "I am doing the best I can with what I have.", isComingSoon: false)
    ]
    
    static let defaultJourneys: [Journey] = [
        Journey(
            id: UUID(),
            name: "Anxiety 101",
            description: "A gentle introduction to understanding and managing anxiety",
            estimatedDays: 7,
            steps: [
                JourneyStep(id: UUID(), day: 1, orderIndex: 0, stepType: .lesson, refId: nil, title: "What Is Anxiety?", instructions: "Learn about your body's alarm system"),
                JourneyStep(id: UUID(), day: 1, orderIndex: 1, stepType: .breathe, refId: nil, title: "Simple Calm Breathing", instructions: "Practice your first calming breath"),
                JourneyStep(id: UUID(), day: 2, orderIndex: 2, stepType: .lesson, refId: nil, title: "Your Nervous System", instructions: "Understand how calm happens"),
                JourneyStep(id: UUID(), day: 3, orderIndex: 3, stepType: .visualization, refId: nil, title: "5 Senses Grounding", instructions: "Ground yourself in the present"),
                JourneyStep(id: UUID(), day: 4, orderIndex: 4, stepType: .affirmation, refId: nil, title: "Daily Affirmation", instructions: "Choose an affirmation that speaks to you"),
                JourneyStep(id: UUID(), day: 5, orderIndex: 5, stepType: .journal, refId: nil, title: "Reflection", instructions: "Write about what you've learned"),
                JourneyStep(id: UUID(), day: 6, orderIndex: 6, stepType: .breathe, refId: nil, title: "Box Breathing Mastery", instructions: "Practice a more advanced technique"),
                JourneyStep(id: UUID(), day: 7, orderIndex: 7, stepType: .lesson, refId: nil, title: "Week 1 Review", instructions: "Celebrating your first week"),
                
                // Week 2
                JourneyStep(id: UUID(), day: 8, orderIndex: 8, stepType: .lesson, refId: nil, title: "Understanding Triggers", instructions: "Identifying what sparks your anxiety"),
                JourneyStep(id: UUID(), day: 9, orderIndex: 9, stepType: .breathe, refId: nil, title: "4-7-8 for Sleep", instructions: "Deep relaxation technique"),
                JourneyStep(id: UUID(), day: 10, orderIndex: 10, stepType: .journal, refId: nil, title: "Trigger Log", instructions: "Track patterns in your week"),
                JourneyStep(id: UUID(), day: 11, orderIndex: 11, stepType: .visualization, refId: nil, title: "The River Stream", instructions: "Watching thoughts float by"),
                JourneyStep(id: UUID(), day: 12, orderIndex: 12, stepType: .game, refId: nil, title: "Focus Booster", instructions: "Train your attention muscle"),
                JourneyStep(id: UUID(), day: 13, orderIndex: 13, stepType: .affirmation, refId: nil, title: "I Am Growing", instructions: "Acknowledging your progress"),
                JourneyStep(id: UUID(), day: 14, orderIndex: 14, stepType: .lesson, refId: nil, title: "Neuroplasticity", instructions: "How your brain changes")
            ],
            isComingSoon: false,
            isPremium: false
        ),
        Journey(
            id: UUID(),
            name: "Sleep Reset Week",
            description: "Seven nights of better sleep practices",
            estimatedDays: 7,
            steps: [
                JourneyStep(id: UUID(), day: 1, orderIndex: 0, stepType: .lesson, refId: nil, title: "Sleep Hygiene Basics", instructions: "Set the stage for restful nights"),
                JourneyStep(id: UUID(), day: 1, orderIndex: 1, stepType: .breathe, refId: nil, title: "4-7-8 for Sleep", instructions: "The relaxation breath"),
                JourneyStep(id: UUID(), day: 2, orderIndex: 2, stepType: .visualization, refId: nil, title: "Body Scan", instructions: "Release tension before bed"),
                JourneyStep(id: UUID(), day: 3, orderIndex: 3, stepType: .journal, refId: nil, title: "Worry Dump", instructions: "Clear your mind on paper"),
                JourneyStep(id: UUID(), day: 4, orderIndex: 4, stepType: .affirmation, refId: nil, title: "Bedtime Affirmations", instructions: "Gentle words for rest")
            ],
            isComingSoon: true,
            isPremium: true
        )
    ]
}

