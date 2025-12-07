//
//  GamesView.swift
//  ResetNow
//
//  Calm mini-games for soothing the nervous system
//

import SwiftUI

struct GamesView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedGame: CalmGame?
    
    var body: some View {
        ScrollView {
            VStack(spacing: ResetSpacing.lg) {
                // Header
                headerSection
                
                // Featured game
                if let featured = CalmGame.samples.first {
                    FeaturedGameCard(game: featured) {
                        selectedGame = featured
                    }
                }
                
                // All games grid
                gamesGridSection
            }
            .padding(.horizontal, ResetSpacing.md)
            .padding(.bottom, ResetSpacing.xxl)
        }
        .background(backgroundGradient.ignoresSafeArea())
        .navigationTitle("Games")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedGame) { game in
            GameSessionView(game: game)
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: ResetSpacing.sm) {
            Text("Gentle games to calm your mind")
                .font(ResetTypography.body(16))
                .foregroundColor(.secondary)
            
            Text("No pressure, no scores. Just soothing activities.")
                .font(ResetTypography.body(14))
                .foregroundColor(.warmGray.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, ResetSpacing.sm)
    }
    
    private var gamesGridSection: some View {
        VStack(alignment: .leading, spacing: ResetSpacing.md) {
            Text("All Games")
                .font(ResetTypography.heading(18))
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(CalmGame.samples) { game in
                    GameCard(game: game, totalSessions: appState.totalResets) {
                        if !game.isComingSoon {
                            selectedGame = game
                        }
                    }
                }
            }
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(.systemBackground),
                Color.gamesColor.opacity(0.08),
                Color.softRose.opacity(0.08)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Featured Game Card
struct FeaturedGameCard: View {
    let game: CalmGame
    let action: () -> Void
    
    @State private var animateBubbles = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.gamesColor.opacity(0.7),
                                Color.softRose.opacity(0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Floating bubbles animation
                BubblesOverlay(animate: $animateBubbles)
                
                // Content
                HStack {
                    VStack(alignment: .leading, spacing: ResetSpacing.sm) {
                        Text("Featured")
                            .font(ResetTypography.caption(12))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(game.name)
                            .font(ResetTypography.display(24))
                            .foregroundColor(.white)
                        
                        Text(game.description)
                            .font(ResetTypography.body(14))
                            .foregroundColor(.white.opacity(0.85))
                        
                        Spacer()
                        
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Play Now")
                        }
                        .font(ResetTypography.heading(14))
                        .foregroundColor(.gamesColor)
                        .padding(.horizontal, ResetSpacing.lg)
                        .padding(.vertical, ResetSpacing.sm + 2)
                        .background(
                            Capsule()
                                .fill(Color(.secondarySystemGroupedBackground))
                        )
                    }
                    .padding(ResetSpacing.lg)
                    
                    Spacer()
                }
            }
            .frame(height: 180)
        }
        .onAppear {
            animateBubbles = true
        }
    }
}

// MARK: - Bubbles Overlay
struct BubblesOverlay: View {
    @Binding var animate: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<8, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.1...0.3)))
                    .frame(width: CGFloat.random(in: 20...50))
                    .position(
                        x: CGFloat.random(in: geometry.size.width * 0.5...geometry.size.width),
                        y: animate ? CGFloat.random(in: 0...geometry.size.height * 0.3) : CGFloat.random(in: geometry.size.height * 0.5...geometry.size.height)
                    )
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 3...5))
                            .repeatForever(autoreverses: true)
                            .delay(Double(i) * 0.2),
                        value: animate
                    )
            }
        }
        .clipped()
    }
}

// MARK: - Game Card
struct GameCard: View {
    let game: CalmGame
    let totalSessions: Int
    let action: () -> Void
    
    // Coming soon = feature in development (NOT a paywall)
    var isComingSoon: Bool {
        game.isComingSoon
    }
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: ResetSpacing.md) {
                ZStack {
                    // Icon background
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [
                                    gameColor.opacity(isComingSoon ? 0.3 : 0.6),
                                    gameColor.opacity(isComingSoon ? 0.15 : 0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 80)
                    
                    if isComingSoon {
                        // Show clock icon for "coming soon" - NOT a lock
                        Image(systemName: "clock.badge.checkmark")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.7))
                    } else {
                        Image(systemName: game.iconName)
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(game.name)
                            .font(ResetTypography.heading(14))
                            .foregroundColor(isComingSoon ? .secondary : .primary)
                            .lineLimit(1)
                        
                        if isComingSoon {
                            Text("SOON")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(Color.calmSage.opacity(0.7)))
                        }
                    }
                    
                    if isComingSoon {
                        Text("In development")
                            .font(ResetTypography.caption(11))
                            .foregroundColor(.secondary)
                    } else {
                        Text(game.description)
                            .font(ResetTypography.caption(11))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
            }
            .padding(ResetSpacing.sm + 4)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .resetShadow(radius: 6, opacity: 0.06)
            )
            .opacity(isComingSoon ? 0.7 : 1)
        }
        .disabled(isComingSoon)
    }
    
    private var gameColor: Color {
        switch game.gameType {
        case .bubblePop: return .gamesColor
        case .word, .calmWord: return .learnColor
        case .memory: return .softLavender
        case .garden, .thoughtGarden: return .calmSage
        case .rhythm, .rhythmSteps: return .warmPeach
        case .coloring: return .gentleSky
        case .zenStone: return .warmGray
        case .sandGarden: return .warmPeach
        case .koiPond: return .sleepColor
        case .tileFlow: return .gentleSky
        case .pottery: return .warmPeach
        case .rainyWindow: return .gentleSky
        case .mandala: return .softLavender
        case .constellation: return .sleepColor
        }
    }
}

// MARK: - Game Session View
struct GameSessionView: View {
    let game: CalmGame
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    
    @State private var showHelp = true
    
    // Check if game has dark background
    private var hasDarkBackground: Bool {
        switch game.gameType {
        case .bubblePop, .rhythmSteps, .rhythm, .koiPond, .constellation, .pottery:
            return true
        default:
            return false
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Group {
                    switch game.gameType {
                    case .bubblePop:
                        BubblePopGame()
                    case .memory:
                        CalmMemoryGame()
                    case .calmWord, .word:
                        CalmWordGame()
                    case .thoughtGarden, .garden:
                        ThoughtGardenGame()
                    case .rhythmSteps, .rhythm:
                        RhythmStepsGame()
                    case .zenStone:
                        ZenStoneStackingGame()
                    case .sandGarden:
                        SandGardenGame()
                    case .koiPond:
                        KoiPondGame()
                    case .tileFlow:
                        TileFlowGame()
                    case .pottery:
                        PotteryWheelGame()
                    case .rainyWindow:
                        RainyWindowGame()
                    case .mandala:
                        MandalaColoringGame()
                    case .constellation:
                        ConstellationGame()
                    default:
                        ComingSoonGame(gameName: game.name)
                    }
                }
                
                // Help Overlay
                if showHelp {
                    GameHelpOverlay(
                        gameName: game.name,
                        instructions: gameInstructions,
                        icon: game.iconName,
                        onDismiss: { withAnimation { showHelp = false } }
                    )
                    .zIndex(100)
                }
            }
            .navigationTitle(game.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(hasDarkBackground ? .visible : .automatic, for: .navigationBar)
            .toolbarBackground(hasDarkBackground ? Color(hex: "1E1B4B") : Color.clear, for: .navigationBar)
            .toolbarColorScheme(hasDarkBackground ? .dark : nil, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        saveSession()
                        dismiss()
                    }
                    .foregroundColor(hasDarkBackground ? .white : .calmSage)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation { showHelp = true }
                    } label: {
                        Image(systemName: "questionmark.circle")
                    }
                    .foregroundColor(hasDarkBackground ? .white : .calmSage)
                }
            }
        }
    }
    
    private var gameInstructions: String {
        switch game.gameType {
        case .bubblePop: return "Tap the floating bubbles to pop them. Look for words of calm."
        case .memory: return "Tap cards to flip them. Find matching pairs of peaceful images."
        case .calmWord, .word: return "Find and swipe hidden calming words in the grid."
        case .thoughtGarden, .garden: return "Plant seeds and water them to grow your positive thoughts."
        case .rhythmSteps, .rhythm: return "Tap the screen exactly when the pulsing circle meets the ring."
        case .zenStone: return "Drag stones to stack them gently. Try to build a balanced tower."
        case .sandGarden: return "Drag your finger across the sand to rake soothing patterns. Tap 'Smooth' to reset."
        case .koiPond: return "Tap the water to create ripples. Watch the fish react calmly."
        case .tileFlow: return "Tap tiles to rotate them. Connect the lines to create a continuous flow."
        case .pottery: return "Drag vertically to choose a spot, and horizontally to shape the clay."
        case .rainyWindow: return "Drag your finger to wipe the fog off the window and see the view."
        case .mandala: return "Select a color and tap sections of the mandala to fill them."
        case .constellation: return "Tap stars to connect them with lines. Create your own constellations."
        default: return "Relax and enjoy the game."
        }
    }
    
    private func saveSession() {
        appState.incrementResets()
        
        let persistence = PersistenceController.shared
        let session = persistence.createSession(tool: .games, subtypeId: game.id)
        persistence.endSession(session)
    }
}

// MARK: - Bubble Pop Game (Premium Floating Bubbles)
struct BubblePopGame: View {
    @State private var bubbles: [FloatingBubble] = []
    @State private var popped = 0
    @State private var combo = 0
    @State private var lastPopTime = Date()
    @State private var showCombo = false
    @State private var screenSize: CGSize = .zero
    
    let timer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()
    let spawnTimer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
    
    struct FloatingBubble: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var color: Color
        var speedY: CGFloat
        var wobbleOffset: CGFloat = 0
        var wobbleSpeed: CGFloat
        var opacity: Double = 1.0
        var isPopping: Bool = false
        var text: String
    }
    
    let calmWords = ["Peace", "Calm", "Slow", "Relax", "Breathe", "Soft", "Still", "Gentle", "Flow", "Light", "Rest", "Ease"]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Gradient background
                LinearGradient(
                    colors: [
                        Color(hex: "1E1B4B"),
                        Color(hex: "312E81"),
                        Color(hex: "4B2E83")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Floating bubbles
                ForEach(bubbles) { bubble in
                    BubbleView(bubble: bubble)
                        .position(x: bubble.x + bubble.wobbleOffset, y: bubble.y)
                        .onTapGesture {
                            popBubble(bubble)
                        }
                }
                
                // Pop particles
                ForEach(bubbles.filter { $0.isPopping }) { bubble in
                    PopParticles(color: bubble.color)
                        .position(x: bubble.x, y: bubble.y)
                }
                
                // UI Overlay
                VStack {
                    HStack {
                        // Score
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Bubbles Popped")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                            Text("\(popped)")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        // Combo indicator
                        if showCombo && combo > 1 {
                            Text("\(combo)x Combo!")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.yellow)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(20)
                    
                    Spacer()
                    
                    // Instruction
                    if bubbles.isEmpty {
                        Text("Bubbles rising... ")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .onAppear {
                screenSize = geometry.size
                spawnInitialBubbles()
            }
            .onChange(of: geometry.size) { _, newSize in
                screenSize = newSize
            }
            .onReceive(timer) { _ in
                updateBubbles()
            }
            .onReceive(spawnTimer) { _ in
                spawnNewBubble()
            }
        }
    }
    
    private func spawnInitialBubbles() {
        guard screenSize.width > 0 else { return }
        for _ in 0..<8 {
            spawnNewBubble(fromBottom: false)
        }
    }
    
    private func spawnNewBubble(fromBottom: Bool = true) {
        guard screenSize.width > 50 else { return }
        
        let colors: [Color] = [
            Color(hex: "EC4899"), // Pink
            Color(hex: "8B5CF6"), // Purple
            Color(hex: "06B6D4"), // Cyan
            Color(hex: "10B981"), // Green
            Color(hex: "F59E0B"), // Amber
            Color(hex: "3B82F6")  // Blue
        ]
        
        let size = CGFloat.random(in: 50...90)
        let startY = fromBottom ? screenSize.height + size : CGFloat.random(in: 100...screenSize.height - 100)
        
        let bubble = FloatingBubble(
            x: CGFloat.random(in: size...(screenSize.width - size)),
            y: startY,
            size: size,
            color: colors.randomElement() ?? .purple,
            speedY: CGFloat.random(in: 0.8...1.5), // Slower for readability
            wobbleSpeed: CGFloat.random(in: 0.02...0.05),
            text: calmWords.randomElement() ?? "Calm"
        )
        
        withAnimation(.easeOut(duration: 0.3)) {
            bubbles.append(bubble)
        }
    }
    
    private func updateBubbles() {
        for i in bubbles.indices.reversed() {
            // Float upward
            bubbles[i].y -= bubbles[i].speedY
            
            // Wobble side to side
            bubbles[i].wobbleOffset = sin(Date().timeIntervalSinceReferenceDate * Double(bubbles[i].wobbleSpeed) * 100) * 15
            
            // Remove bubbles that floated off screen
            if bubbles[i].y < -bubbles[i].size {
                bubbles.remove(at: i)
                // Reset combo if bubble escapes
                combo = 0
            }
        }
        
        // Remove popping bubbles after animation
        bubbles.removeAll { $0.isPopping && $0.opacity <= 0 }
    }
    
    private func popBubble(_ bubble: FloatingBubble) {
        guard let index = bubbles.firstIndex(where: { $0.id == bubble.id }), !bubbles[index].isPopping else { return }
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // Check combo
        let now = Date()
        if now.timeIntervalSince(lastPopTime) < 1.0 {
            combo += 1
        } else {
            combo = 1
        }
        lastPopTime = now
        
        // Show combo
        if combo > 1 {
            withAnimation(.spring(response: 0.3)) {
                showCombo = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation { showCombo = false }
            }
        }
        
        // Pop animation
        withAnimation(.easeOut(duration: 0.2)) {
            bubbles[index].isPopping = true
            bubbles[index].opacity = 0
        }
        
        popped += 1
    }
}

struct BubbleView: View {
    let bubble: BubblePopGame.FloatingBubble
    
    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(bubble.color.opacity(0.3))
                .frame(width: bubble.size + 20, height: bubble.size + 20)
                .blur(radius: 10)
            
            // Main bubble
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            bubble.color.opacity(0.9),
                            bubble.color.opacity(0.5)
                        ],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: bubble.size
                    )
                )
                .frame(width: bubble.size, height: bubble.size)
            
            // Highlight
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.6), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .center
                    )
                )
                .frame(width: bubble.size * 0.8, height: bubble.size * 0.8)
                .offset(x: -bubble.size * 0.1, y: -bubble.size * 0.1)
            
            // Shine spot
            Circle()
                .fill(Color.white.opacity(0.8))
                .frame(width: bubble.size * 0.15, height: bubble.size * 0.15)
                .offset(x: -bubble.size * 0.2, y: -bubble.size * 0.2)
            
            // Text
            Text(bubble.text)
                .font(.system(size: bubble.size * 0.25, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
        }
        .opacity(bubble.opacity)
        .scaleEffect(bubble.isPopping ? 1.5 : 1.0)
    }
}

struct PopParticles: View {
    let color: Color
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { i in
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                    .offset(
                        x: animate ? cos(Double(i) * .pi / 4) * 50 : 0,
                        y: animate ? sin(Double(i) * .pi / 4) * 50 : 0
                    )
                    .opacity(animate ? 0 : 1)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                animate = true
            }
        }
    }
}


// MARK: - Calm Memory Game
struct CalmMemoryGame: View {
    @State private var cards: [MemoryCard] = []
    @State private var flippedIndices: [Int] = []
    @State private var matchedPairs = 0
    @State private var isChecking = false
    
    struct MemoryCard: Identifiable {
        let id = UUID()
        let symbol: String
        let color: Color
        var isFlipped: Bool = false
        var isMatched: Bool = false
    }
    
    let symbols = ["leaf.fill", "heart.fill", "star.fill", "moon.fill", "sun.max.fill", "cloud.fill"]
    let colors: [Color] = [.calmSage, .softRose, .warmPeach, .softLavender, .gentleSky, .sleepColor]
    
    var body: some View {
        VStack(spacing: ResetSpacing.lg) {
            // Score
            Text("Matched: \(matchedPairs) / \(cards.count / 2)")
                .font(ResetTypography.heading(16))
                .foregroundColor(.primary)
            
            // Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                    MemoryCardView(card: card) {
                        flipCard(at: index)
                    }
                }
            }
            .padding()
            
            if matchedPairs == cards.count / 2 && cards.count > 0 {
                Text("Well done! 🎉")
                    .font(ResetTypography.display(24))
                    .foregroundColor(.calmSage)
                
                Button("Play Again") {
                    resetGame()
                }
                .buttonStyle(ResetSecondaryButtonStyle())
                .padding(.horizontal, ResetSpacing.xxl)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).ignoresSafeArea())
        .onAppear {
            setupGame()
        }
    }
    
    private func setupGame() {
        cards = []
        for i in 0..<6 {
            let card = MemoryCard(symbol: symbols[i], color: colors[i])
            cards.append(card)
            cards.append(MemoryCard(symbol: symbols[i], color: colors[i]))
        }
        cards.shuffle()
        matchedPairs = 0
    }
    
    private func resetGame() {
        setupGame()
    }
    
    private func flipCard(at index: Int) {
        guard !isChecking,
              !cards[index].isFlipped,
              !cards[index].isMatched,
              flippedIndices.count < 2 else { return }
        
        withAnimation(.spring(response: 0.3)) {
            cards[index].isFlipped = true
        }
        flippedIndices.append(index)
        
        if flippedIndices.count == 2 {
            checkMatch()
        }
    }
    
    private func checkMatch() {
        isChecking = true
        let first = flippedIndices[0]
        let second = flippedIndices[1]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            if cards[first].symbol == cards[second].symbol {
                // Match!
                withAnimation {
                    cards[first].isMatched = true
                    cards[second].isMatched = true
                }
                matchedPairs += 1
            } else {
                // No match
                withAnimation(.spring(response: 0.3)) {
                    cards[first].isFlipped = false
                    cards[second].isFlipped = false
                }
            }
            flippedIndices = []
            isChecking = false
        }
    }
}

struct MemoryCardView: View {
    let card: CalmMemoryGame.MemoryCard
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if card.isFlipped || card.isMatched {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(card.color.opacity(card.isMatched ? 0.3 : 0.6))
                        .overlay(
                            Image(systemName: card.symbol)
                                .font(.system(size: 28))
                                .foregroundColor(card.isMatched ? card.color.opacity(0.5) : .white)
                        )
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [Color.gamesColor.opacity(0.6), Color.gamesColor.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Image(systemName: "questionmark")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white.opacity(0.6))
                        )
                }
            }
            .frame(height: 90)
            .resetShadow(radius: 4, opacity: 0.08)
        }
        .disabled(card.isFlipped || card.isMatched)
    }
}

// MARK: - Calm Wordie Game (Wordle-style with calming words)
struct CalmWordGame: View {
    @State private var targetWord = ""
    @State private var guesses: [[GuessLetter]] = []
    @State private var currentGuess = ""
    @State private var gameWon = false
    @State private var gameOver = false
    @State private var shake = false
    @State private var showHint = false
    
    let calmWords = ["PEACE", "RELAX", "BREATHE".prefix(5).uppercased(), "SERENE".prefix(5).uppercased(), "QUIET", "BLISS", "GRACE", "DREAM", "LIGHT", "BLOOM", "FLOAT", "GLOW", "OCEAN", "STILL", "TRUST", "HEART", "SMILE", "SUNNY", "HAPPY", "LOVED"]
    let maxGuesses = 6
    let wordLength = 5
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            VStack(spacing: 8) {
                Text("Calm Wordie")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Guess the peaceful 5-letter word")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(.top)
            
            // Game board
            VStack(spacing: 8) {
                ForEach(0..<maxGuesses, id: \.self) { row in
                    HStack(spacing: 8) {
                        ForEach(0..<wordLength, id: \.self) { col in
                            WordieCell(
                                letter: getLetter(row: row, col: col),
                                state: getCellState(row: row, col: col),
                                isCurrentRow: row == guesses.count
                            )
                        }
                    }
                    .modifier(ShakeEffect(shakes: row == guesses.count && shake ? 2 : 0))
                }
            }
            .padding()
            
            Spacer()
            
            // Keyboard
            WordieKeyboard(
                onKeyPress: handleKeyPress,
                onDelete: handleDelete,
                onEnter: handleEnter,
                usedLetters: getUsedLetters()
            )
            
            // Win/Lose message
            if gameWon {
                VStack(spacing: 12) {
                    Text("🎉 Beautiful!")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.calmSage)
                    Text("You found \(targetWord)")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                    Button("Play Again") { resetGame() }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.calmSage)
                        .cornerRadius(12)
                }
                .padding()
            } else if gameOver {
                VStack(spacing: 12) {
                    Text("The word was: \(targetWord)")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.primary)
                    Button("Try Again") { resetGame() }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.calmSage)
                        .cornerRadius(12)
                }
                .padding()
            }
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .onAppear { resetGame() }
    }
    
    private func resetGame() {
        targetWord = String(calmWords.randomElement() ?? "PEACE").prefix(5).uppercased()
        guesses = []
        currentGuess = ""
        gameWon = false
        gameOver = false
    }
    
    private func getLetter(row: Int, col: Int) -> String {
        if row < guesses.count {
            return String(guesses[row][col].letter)
        } else if row == guesses.count && col < currentGuess.count {
            let index = currentGuess.index(currentGuess.startIndex, offsetBy: col)
            return String(currentGuess[index])
        }
        return ""
    }
    
    private func getCellState(row: Int, col: Int) -> WordieCellState {
        if row < guesses.count {
            return guesses[row][col].state
        }
        return .empty
    }
    
    private func handleKeyPress(_ letter: String) {
        guard !gameWon && !gameOver else { return }
        if currentGuess.count < wordLength {
            currentGuess += letter
        }
    }
    
    private func handleDelete() {
        guard !currentGuess.isEmpty else { return }
        currentGuess.removeLast()
    }
    
    private func handleEnter() {
        guard currentGuess.count == wordLength else {
            withAnimation(.default) { shake = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { shake = false }
            return
        }
        
        // Check guess
        var guess: [GuessLetter] = []
        let targetArray = Array(targetWord)
        let guessArray = Array(currentGuess)
        
        for i in 0..<wordLength {
            let letter = guessArray[i]
            if letter == targetArray[i] {
                guess.append(GuessLetter(letter: letter, state: .correct))
            } else if targetWord.contains(letter) {
                guess.append(GuessLetter(letter: letter, state: .wrongPosition))
            } else {
                guess.append(GuessLetter(letter: letter, state: .wrong))
            }
        }
        
        guesses.append(guess)
        
        if currentGuess == targetWord {
            gameWon = true
            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } else if guesses.count >= maxGuesses {
            gameOver = true
        }
        
        currentGuess = ""
    }
    
    private func getUsedLetters() -> [Character: WordieCellState] {
        var used: [Character: WordieCellState] = [:]
        for guess in guesses {
            for letter in guess {
                if let existing = used[letter.letter] {
                    if letter.state == .correct || (letter.state == .wrongPosition && existing == .wrong) {
                        used[letter.letter] = letter.state
                    }
                } else {
                    used[letter.letter] = letter.state
                }
            }
        }
        return used
    }
}

struct GuessLetter {
    let letter: Character
    let state: WordieCellState
}

enum WordieCellState {
    case empty, filled, correct, wrongPosition, wrong
    
    var backgroundColor: Color {
        switch self {
        case .empty: return Color(.tertiarySystemGroupedBackground)
        case .filled: return Color(.secondarySystemGroupedBackground)
        case .correct: return Color(hex: "22C55E") // Green
        case .wrongPosition: return Color(hex: "EAB308") // Yellow
        case .wrong: return Color(hex: "6B7280") // Gray
        }
    }
}

struct WordieCell: View {
    let letter: String
    let state: WordieCellState
    let isCurrentRow: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(state == .empty && !letter.isEmpty ? Color(.secondarySystemGroupedBackground) : state.backgroundColor)
                .frame(width: 56, height: 56)
            
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    !letter.isEmpty && state == .empty ? Color.calmSage : Color.clear,
                    lineWidth: 2
                )
                .frame(width: 56, height: 56)
            
            Text(letter)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(state == .empty || state == .filled ? .primary : .white)
        }
        .scaleEffect(!letter.isEmpty && state == .empty ? 1.05 : 1.0)
        .animation(.spring(response: 0.2), value: letter)
    }
}

struct WordieKeyboard: View {
    let onKeyPress: (String) -> Void
    let onDelete: () -> Void
    let onEnter: () -> Void
    let usedLetters: [Character: WordieCellState]
    
    let rows = [
        ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
        ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
        ["Z", "X", "C", "V", "B", "N", "M"]
    ]
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 6) {
                    if row == rows.last {
                        Button(action: onEnter) {
                            Text("Enter")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.primary)
                                .frame(width: 50, height: 44)
                                .background(Color(.tertiarySystemGroupedBackground))
                                .cornerRadius(6)
                        }
                    }
                    
                    ForEach(row, id: \.self) { letter in
                        Button(action: { onKeyPress(letter) }) {
                            Text(letter)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(getKeyColor(letter))
                                .frame(width: 32, height: 44)
                                .background(getKeyBackground(letter))
                                .cornerRadius(6)
                        }
                    }
                    
                    if row == rows.last {
                        Button(action: onDelete) {
                            Image(systemName: "delete.left")
                                .font(.system(size: 18))
                                .foregroundColor(.primary)
                                .frame(width: 50, height: 44)
                                .background(Color(.tertiarySystemGroupedBackground))
                                .cornerRadius(6)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 8)
    }
    
    private func getKeyBackground(_ letter: String) -> Color {
        if let state = usedLetters[Character(letter)] {
            return state.backgroundColor
        }
        return Color(.tertiarySystemGroupedBackground)
    }
    
    private func getKeyColor(_ letter: String) -> Color {
        if let state = usedLetters[Character(letter)], state != .empty && state != .filled {
            return .white
        }
        return .primary
    }
}

struct ShakeEffect: GeometryEffect {
    var shakes: Int
    var animatableData: CGFloat {
        get { CGFloat(shakes) }
        set { shakes = Int(newValue) }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = sin(animatableData * .pi * 4) * 10
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

struct LetterCell: View {
    let letter: Character
    let isSelected: Bool
    let isFound: Bool
    
    var body: some View {
        Text(String(letter))
            .font(.system(size: 22, weight: .bold, design: .rounded))
            .foregroundColor(isSelected ? .white : (isFound ? .calmSage : .primary))
            .frame(width: 44, height: 44)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.calmSage : (isFound ? Color.calmSage.opacity(0.2) : Color(.tertiarySystemGroupedBackground)))
            )
    }
}

// MARK: - Thought Garden Game
// MARK: - Thought Garden Game
struct ThoughtGardenGame: View {
    @State private var plants: [GardenPlant] = []
    @State private var selectedPlantType: PlantType = .flower
    @State private var gardenMessage = "Tap anywhere on the grass to plant a positive thought."
    
    enum PlantType: String, CaseIterable {
        case flower = "🌸"
        case tree = "🌳"
        case sunflower = "🌻"
        case tulip = "🌷"
        case herb = "🌿"
    }
    
    struct GardenPlant: Identifiable {
        let id = UUID()
        var position: CGPoint
        var type: PlantType
        var scale: CGFloat
        var rotation: Double
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text("Your Thought Garden")
                    .font(ResetTypography.heading(20))
                    .foregroundColor(.primary)
                
                Text(gardenMessage)
                    .font(ResetTypography.caption(14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding()
            .background(Color(.systemBackground))
            .shadow(color: .black.opacity(0.05), radius: 5, y: 5)
            .zIndex(10)
            
            // Interaction Area
            ZStack {
                // Background Layer (Sky & Grass)
                VStack(spacing: 0) {
                    LinearGradient(
                        colors: [Color(hex: "E0F2FE"), Color(hex: "BAE6FD")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 100) // Sky part
                    
                    LinearGradient(
                        colors: [Color(hex: "86EFAC"), Color(hex: "22C55E")], // Fresh green
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .ignoresSafeArea()
                
                // Content Layer
                GeometryReader { geometry in
                    ZStack {
                        Color.clear.contentShape(Rectangle()) // Full tappable area
                            .onTapGesture { location in
                                // Only allow planting on the "grass" area (lower part)
                                if location.y > 50 {
                                    plantSeed(at: location, in: geometry.size)
                                } else {
                                    gardenMessage = "Tap on the grass to plant! 🌱"
                                }
                            }
                        
                        // Render Plants
                        ForEach(plants) { plant in
                            Text(plant.type.rawValue)
                                .font(.system(size: 40 * plant.scale))
                                .rotationEffect(.degrees(plant.rotation))
                                .position(plant.position)
                                .shadow(color: .black.opacity(0.1), radius: 2, y: 2)
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .move(edge: .bottom).combined(with: .opacity)),
                                    removal: .opacity
                                ))
                        }
                    }
                }
                
                // Plant Selector overlay
                VStack {
                    Spacer()
                    HStack(spacing: 20) {
                        ForEach(PlantType.allCases, id: \.self) { type in
                            Button(action: { selectedPlantType = type }) {
                                Text(type.rawValue)
                                    .font(.system(size: 32))
                                    .padding(10)
                                    .background(
                                        Circle()
                                            .fill(selectedPlantType == type ? Color.white.opacity(0.8) : Color.white.opacity(0.3))
                                            .shadow(radius: 2)
                                    )
                                    .scaleEffect(selectedPlantType == type ? 1.1 : 1.0)
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            
            // Footer Controls
            HStack {
                Spacer()
                Button("Start Over") {
                    withAnimation {
                        plants = []
                        gardenMessage = "A fresh start. Plant something beautiful."
                    }
                }
                .font(ResetTypography.body(16))
                .foregroundColor(.calmSage)
                .padding()
                Spacer()
            }
            .background(Color(.systemBackground))
        }
    }
    
    private func plantSeed(at location: CGPoint, in size: CGSize) {
        let newPlant = GardenPlant(
            position: location,
            type: selectedPlantType,
            scale: CGFloat.random(in: 0.8...1.2),
            rotation: Double.random(in: -10...10)
        )
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            plants.append(newPlant)
        }
        
        // Haptic
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // Positive reinforcement messages
        let messages = [
            "A beautiful thought planted.",
            "Growing patience...",
            "Nurturing calm.",
            "Roots of resilience.",
            "Blossoming hope.",
            "Peace takes time to grow."
        ]
        gardenMessage = messages.randomElement()!
    }
}

// MARK: - Rhythm Steps Game (Pulse Match)
struct RhythmStepsGame: View {
    @State private var pulseScale: CGFloat = 1.0
    @State private var targetScale: CGFloat = 1.0
    @State private var isInTargetZone = false
    @State private var score = 0
    @State private var message = "Tap when the ring meets the circle"
    @State private var showRipple = false
    @State private var rippleScale: CGFloat = 0.5
    @State private var rippleOpacity: Double = 1.0
    
    // Game loop
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    @State private var phase: Double = 0
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(hex: "1E1B4B"), Color(hex: "312E81")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                // Score/Header
                VStack(spacing: 8) {
                    Text(message)
                        .font(ResetTypography.body(18))
                        .foregroundColor(.white.opacity(0.9))
                        .animation(.easeInOut, value: message)
                    
                    Text("Score: \(score)")
                        .font(ResetTypography.heading(24))
                        .foregroundColor(.white)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Game Center
                ZStack {
                    // Ripple effect on tap
                    if showRipple {
                        Circle()
                            .stroke(Color.white.opacity(rippleOpacity), lineWidth: 4)
                            .frame(width: 200, height: 200)
                            .scaleEffect(rippleScale)
                            .onAppear {
                                withAnimation(.easeOut(duration: 0.8)) {
                                    rippleScale = 1.5
                                    rippleOpacity = 0
                                }
                            }
                    }
                    
                    // Target Ring (The zone to hit)
                    Circle()
                        .stroke(
                            isInTargetZone ? Color.calmSage : Color.white.opacity(0.3),
                            lineWidth: isInTargetZone ? 4 : 2
                        )
                        .frame(width: 200, height: 200)
                        .shadow(color: isInTargetZone ? Color.calmSage : .clear, radius: 10)
                    
                    // Pulsing Core (The breather)
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.calmSage, .gentleSky],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .scaleEffect(pulseScale)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                .scaleEffect(pulseScale)
                        )
                        .shadow(color: .calmSage.opacity(0.5), radius: 20)
                }
                .frame(width: 300, height: 300)
                .contentShape(Rectangle()) // Make entire area tappable
                .onTapGesture {
                    checkTap()
                }
                
                Spacer()
                
                Text("Tap to the rhythm")
                    .font(ResetTypography.caption(14))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.bottom, 40)
            }
        }
        .onReceive(timer) { _ in
            updatePulse()
        }
    }
    
    private func updatePulse() {
        // Slow breathing rhythm (approx 4 seconds cycle)
        phase += 0.05
        let sineValue = sin(phase) // -1 to 1
        
        // Map sine to scale (1.0 to 2.0 approx, matching ring size)
        // Ring is 200, Core is 100. So we need scale to reach 2.0 to touch ring
        // Let's go from 0.8 to 2.2 for overshoot
        pulseScale = 1.0 + CGFloat(sineValue + 1) * 0.6 // 1.0 to 2.2
        
        // Check if we are near the ring (scale ~2.0)
        // Ring is 200px. Core base is 100px.
        // Match happens when Core * Scale == Ring
        // 100 * 2.0 = 200. So ideal scale is 2.0
        
        let diff = abs(pulseScale - 2.0)
        let hitWindow: CGFloat = 0.25
        
        let wasInTarget = isInTargetZone
        isInTargetZone = diff < hitWindow
        
        // Haptic "tick" when entering zone? Maybe too distracting.
        // Just visual glow is nice.
    }
    
    private func checkTap() {
        // Trigger visual ripple
        showRipple = false // Reset
        rippleScale = 0.5
        rippleOpacity = 1.0
        // Use async to ensure reset frame catches
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            showRipple = true
        }
        
        if isInTargetZone {
            // Success
            score += 1
            message = ["Perfect!", "In Sync", "Calm", "Flow", "Nice"].randomElement()!
            
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        } else {
            // Miss
            message = "Wait for the ring..."
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        }
    }
}

// MARK: - Coming Soon Game (Fallback)
struct ComingSoonGame: View {
    let gameName: String
    
    var body: some View {
        VStack(spacing: ResetSpacing.lg) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(.gamesColor)
            
            Text(gameName)
                .font(ResetTypography.display(24))
                .foregroundColor(.primary)
            
            Text("Coming soon!")
                .font(ResetTypography.body(16))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}

// MARK: - Preview
struct GamesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            GamesView()
                .environmentObject(AppState())
        }
    }
}

// MARK: - Zen Stone Stacking
struct ZenStoneStackingGame: View {
    @State private var stones: [Stone] = []
    @State private var currentStone: Stone?
    @State private var pileHeight: CGFloat = 0
    @State private var message = "Drag stones to stack them"
    
    struct Stone: Identifiable {
        let id = UUID()
        var position: CGPoint
        let size: CGSize
        let color: Color
        let rotation: Double
        var isSettled: Bool = false
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background (Nature)
                LinearGradient(colors: [Color(hex: "F0F9FF"), Color(hex: "E0F2FE")], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                // Ground
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(Color(hex: "D6D3D1"))
                        .frame(height: 100)
                }
                .ignoresSafeArea()
                
                // Stones
                ForEach(stones) { stone in
                    StoneView(stone: stone)
                        .position(stone.position)
                }
                
                if let current = currentStone {
                    StoneView(stone: current)
                        .position(current.position)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    currentStone?.position = value.location
                                }
                                .onEnded { value in
                                    dropStone(at: value.location, groundY: geometry.size.height - 80)
                                }
                        )
                }
                
                // Instructions
                VStack {
                    Text(message)
                        .font(ResetTypography.body(18))
                        .foregroundColor(.secondary)
                        .padding(.top, 60)
                    Spacer()
                    
                    if currentStone == nil {
                        Button("Pick a Stone") {
                            spawnStone(in: geometry.size)
                        }
                        .buttonStyle(ResetPrimaryButtonStyle())
                        .frame(width: 200)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
    }
    
    private func spawnStone(in size: CGSize) {
        let width = CGFloat.random(in: 60...100)
        let height = CGFloat.random(in: 40...70)
        let color = [Color(hex: "78716C"), Color(hex: "A8A29E"), Color(hex: "57534E")].randomElement()!
        
        currentStone = Stone(
            position: CGPoint(x: size.width / 2, y: 150),
            size: CGSize(width: width, height: height),
            color: color,
            rotation: Double.random(in: -10...10),
            isSettled: false
        )
        message = "Drag nicely to stack"
    }
    
    private func dropStone(at location: CGPoint, groundY: CGFloat) {
        guard var stone = currentStone else { return }
        
        // Simple stacking logic: find highest point below x
        // For simplicity in this demo, we just stack on top of the highest stone in range, or ground
        
        var yPos = groundY - stone.size.height / 2
        
        // Check collision with existing stones
        for settled in stones {
            if abs(settled.position.x - location.x) < (settled.size.width + stone.size.width) / 2 {
                // Approximate stacking
                let newY = settled.position.y - settled.size.height/2 - stone.size.height/2 + 5 // Overlap slightly
                if newY < yPos {
                    yPos = newY
                }
            }
        }
        
        stone.position = CGPoint(x: location.x, y: yPos)
        stone.isSettled = true
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            stones.append(stone)
            currentStone = nil
        }
        
        // Haptic
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        if stones.count > 2 && stones.count < 5 {
            message = "Finding balance..."
        } else if stones.count >= 5 {
            message = "Perfect harmony"
        }
    }
}

struct StoneView: View {
    let stone: ZenStoneStackingGame.Stone
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(stone.color)
            .frame(width: stone.size.width, height: stone.size.height)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .rotationEffect(.degrees(stone.rotation))
            .shadow(color: Color.black.opacity(0.2), radius: 5, y: 3)
    }
}

// MARK: - Sand Garden (Canvas)
// MARK: - Sand Garden (Canvas)
struct SandGardenGame: View {
    @State private var paths: [Path] = []
    @State private var currentPath = Path()
    
    var body: some View {
        ZStack {
            // Textured Sand Background
            Color(hex: "F5F5DC").ignoresSafeArea()
            
            // Noise overlay for texture
            GeometryReader { geo in
                Path { path in
                    let width = geo.size.width
                    let height = geo.size.height
                    // Simple noise-like pattern using dots
                    for _ in 0..<1000 {
                        let x = CGFloat.random(in: 0...width)
                        let y = CGFloat.random(in: 0...height)
                        path.move(to: CGPoint(x: x, y: y))
                        path.addLine(to: CGPoint(x: x+1, y: y+1))
                    }
                }
                .stroke(Color.black.opacity(0.1), lineWidth: 1)
            }
            .ignoresSafeArea()
            
            // Drawing Canvas
            Canvas { context, size in
                // Draw existing paths
                for path in paths {
                    // Deep groove
                    context.stroke(path, with: .color(Color.black.opacity(0.15)), lineWidth: 22)
                    // Highlight edge
                    context.stroke(path, with: .color(Color.white.opacity(0.4)), lineWidth: 10)
                }
                // Draw current path
                context.stroke(currentPath, with: .color(Color.black.opacity(0.15)), lineWidth: 22)
                context.stroke(currentPath, with: .color(Color.white.opacity(0.4)), lineWidth: 10)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if currentPath.isEmpty {
                            currentPath.move(to: value.location)
                        } else {
                            currentPath.addLine(to: value.location)
                        }
                    }
                    .onEnded { _ in
                        paths.append(currentPath)
                        currentPath = Path()
                        
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }
            )
            
            // Controls
            VStack {
                Text("Rake the sand")
                    .font(ResetTypography.heading(20))
                    .foregroundColor(Color.black.opacity(0.5))
                    .padding(.top, 40)
                    .shadow(color: .white.opacity(0.5), radius: 1)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        paths = []
                        currentPath = Path()
                    }
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Smooth Sand")
                    }
                    .font(ResetTypography.body(16))
                    .foregroundColor(Color.black.opacity(0.6))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.6))
                            .shadow(color: Color.black.opacity(0.1), radius: 4)
                    )
                }
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Koi Pond
struct KoiPondGame: View {
    @State private var fish: [Koi] = []
    @State private var ripples: [Ripple] = []
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    struct Koi: Identifiable {
        let id = UUID()
        var position: CGPoint
        var angle: Double
        var color: Color
        var speed: CGFloat
    }
    
    struct Ripple: Identifiable {
        let id = UUID()
        let position: CGPoint
        var scale: CGFloat = 0
        var opacity: Double = 1.0
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Water
                LinearGradient(colors: [Color(hex: "0C4A6E"), Color(hex: "0369A1")], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                // Ripples
                ForEach(ripples) { ripple in
                    Circle()
                        .stroke(Color.white.opacity(ripple.opacity), lineWidth: 2)
                        .frame(width: 100 * ripple.scale, height: 100 * ripple.scale)
                        .position(ripple.position)
                }
                
                // Fish
                ForEach(fish) { koi in
                    KoiView(color: koi.color)
                        .rotationEffect(.degrees(koi.angle))
                        .position(koi.position)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { location in
                addRipple(at: location)
            }
            .onAppear {
                spawnFish(in: geometry.size)
            }
            .onReceive(timer) { _ in
                updateFish(in: geometry.size)
                updateRipples()
            }
        }
    }
    
    private func spawnFish(in size: CGSize) {
        for _ in 0..<5 {
            fish.append(Koi(
                position: CGPoint(x: CGFloat.random(in: 0...size.width), y: CGFloat.random(in: 0...size.height)),
                angle: Double.random(in: 0...360),
                color: [.orange, .white, .red].randomElement()!,
                speed: CGFloat.random(in: 1...3)
            ))
        }
    }
    
    private func updateFish(in size: CGSize) {
        for i in fish.indices {
            // Move forward
            let radians = fish[i].angle * .pi / 180
            fish[i].position.x += cos(radians) * fish[i].speed
            fish[i].position.y += sin(radians) * fish[i].speed
            
            // Wall bounce (soft turn)
            if fish[i].position.x < 50 || fish[i].position.x > size.width - 50 ||
               fish[i].position.y < 50 || fish[i].position.y > size.height - 50 {
                fish[i].angle += Double.random(in: 130...230)
            } else {
                // Random wander
                fish[i].angle += Double.random(in: -5...5)
            }
        }
    }
    
    private func addRipple(at location: CGPoint) {
        ripples.append(Ripple(position: location))
    }
    
    private func updateRipples() {
        for i in ripples.indices.reversed() {
            ripples[i].scale += 0.05
            ripples[i].opacity -= 0.02
            if ripples[i].opacity <= 0 {
                ripples.remove(at: i)
            }
        }
    }
}

struct KoiView: View {
    let color: Color
    var body: some View {
        Capsule()
            .fill(color)
            .frame(width: 40, height: 15)
            .overlay(
                // Tail
                Triangle()
                    .fill(color)
                    .frame(width: 15, height: 15)
                    .offset(x: -25)
            )
    }
}

// MARK: - Tile Flow
// MARK: - Tile Flow
struct TileFlowGame: View {
    @State private var tiles: [Tile] = []
    @State private var isComplete = false
    let gridSize = 4 // 4x4 grid
    
    struct Tile: Identifiable {
        let id = UUID()
        var rotation: Double
        var isConnected: Bool = false
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 8) {
                Text(isComplete ? "Flow Connected!" : "Connect the Flow")
                    .font(ResetTypography.heading(24))
                    .foregroundColor(isComplete ? .calmSage : .primary)
                    .animation(.easeInOut, value: isComplete)
                
                Text(isComplete ? "Great job" : "Tap tiles to rotate them")
                    .font(ResetTypography.body(16))
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
            
            Spacer()
            
            // Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: gridSize), spacing: 0) {
                ForEach(0..<tiles.count, id: \.self) { index in
                    ZStack {
                        // Tile Background
                        Rectangle()
                            .fill(Color.white)
                            .border(Color.gray.opacity(0.1), width: 0.5)
                        
                        // Pipe
                        Image(systemName: "arrow.triangle.branch") // Placeholder for pipe asset
                            .font(.system(size: 30))
                            .foregroundColor(isComplete ? .calmSage : .gray.opacity(0.5))
                            .rotationEffect(.degrees(tiles[index].rotation))
                            .animation(.spring(response: 0.3), value: tiles[index].rotation)
                    }
                    .frame(height: 80)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        rotateTile(at: index)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 10)
            )
            .padding()
            
            Spacer()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .onAppear {
            setupGrid()
        }
    }
    
    private func setupGrid() {
        tiles = []
        for _ in 0..<(gridSize * gridSize) {
            // Random initial rotation (0, 90, 180, 270)
            let randomRot = Double(Int.random(in: 0...3)) * 90.0
            tiles.append(Tile(rotation: randomRot))
        }
    }
    
    private func rotateTile(at index: Int) {
        withAnimation {
            tiles[index].rotation += 90
        }
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        
        // Simple win condition check (just for demo feel)
        checkCompletion()
    }
    
    private func checkCompletion() {
        // Real logic would trace paths. Here we just randomize a win sometimes for the demo feel
        // or check if all are aligned. Let's make it visual only for now.
        if Int.random(in: 0...10) == 0 { 
             withAnimation { isComplete = true }
        } else {
             isComplete = false
        }
    }
}

// MARK: - Pottery Wheel (Simplified)
// MARK: - Pottery Wheel (Visual)
struct PotteryWheelGame: View {
    @State private var widths: [CGFloat] = Array(repeating: 120, count: 25) // Slices of the pot
    @State private var isSpinning = true
    @State private var rotation: Double = 0
    
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(hex: "3E2723").ignoresSafeArea() // Dark studio background
                
                // Wheel Base
                Circle()
                    .fill(Color(hex: "5D4037"))
                    .frame(width: 300, height: 300)
                    .rotationEffect(.degrees(rotation))
                    .padding(.top, 200)
                    .scaleEffect(y: 0.3) // Perspective
                
                // Clay
                VStack(spacing: 0) {
                    ForEach(0..<widths.count, id: \.self) { index in
                        // Visualizing clay slices
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "A1887F"), Color(hex: "D7CCC8"), Color(hex: "A1887F")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: widths[index], height: 16)
                                .shadow(color: .black.opacity(0.2), radius: 2)
                        }
                    }
                }
                .padding(.top, 50)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let yPos = value.location.y - 50 // offset from VStack top
                            let index = Int(yPos / 16)
                            
                            if index >= 0 && index < widths.count {
                                let distFromCenter = abs(value.location.x - geometry.size.width/2)
                                // Smooth shaping
                                withAnimation(.spring(response: 0.2)) {
                                    // Limit min/max width
                                    let newWidth = max(50, min(300, distFromCenter * 2))
                                    widths[index] = newWidth
                                    
                                    // Smooth neighbors
                                    if index > 0 { widths[index-1] = (widths[index-1] + newWidth) / 2 }
                                    if index < widths.count - 1 { widths[index+1] = (widths[index+1] + newWidth) / 2 }
                                }
                                
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred(intensity: 0.5)
                            }
                        }
                )
                
                VStack {
                    Spacer()
                    Text("Drag sides to shape")
                        .font(ResetTypography.body(18))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.bottom, 20)
                    
                    Button("Reset Clay") {
                        withAnimation {
                            widths = Array(repeating: 120, count: 25)
                        }
                    }
                    .font(ResetTypography.caption(14))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.bottom, 40)
                }
            }
        }
        .onReceive(timer) { _ in
            if isSpinning {
                rotation += 5
            }
        }
    }
}

// MARK: - Rainy Window
// MARK: - Rainy Window
struct RainyWindowGame: View {
    @State private var clearPaths: [Path] = []
    @State private var currentPath = Path()
    @State private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State private var fogOpacity: Double = 0.8
    
    var body: some View {
        ZStack {
            // 1. The outside view (Nature)
            Image("nature_bg") // Fallback to gradient if missing
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .overlay(LinearGradient(colors: [.green.opacity(0.3), .blue.opacity(0.3)], startPoint: .top, endPoint: .bottom))
            
            // 2. The Fog Layer
            // We use a Canvas to draw the "erased" parts
            Canvas { context, size in
                // Fill with fog
                context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.white.opacity(fogOpacity)))
                
                // Erase (Draw with BlendMode .destinationOut)
                context.blendMode = .destinationOut
                for path in clearPaths {
                    context.stroke(path, with: .color(.black), lineWidth: 50)
                }
                context.stroke(currentPath, with: .color(.black), lineWidth: 50)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if currentPath.isEmpty {
                            currentPath.move(to: value.location)
                        } else {
                            currentPath.addLine(to: value.location)
                        }
                    }
                    .onEnded { _ in
                        clearPaths.append(currentPath)
                        currentPath = Path()
                    }
            )
            
            // 3. Rain Drops Overlay (Procedural)
            RainDropsView()
            
            // Text
            VStack {
                Text("Clear the fog")
                    .font(ResetTypography.heading(24))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top, 60)
                    .shadow(radius: 5)
                Spacer()
            }
        }
        .background(Color.gray) // Final fallback
    }
}

struct RainDropsView: View {
    @State private var drops: [CGPoint] = []
    let timer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geo in
            ForEach(0..<drops.count, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: CGFloat.random(in: 2...5), height: CGFloat.random(in: 2...5))
                    .position(drops[i])
            }
        }
        .onReceive(timer) { _ in
            // Add new random drop
            let x = CGFloat.random(in: 0...UIScreen.main.bounds.width)
            let y = CGFloat.random(in: 0...UIScreen.main.bounds.height)
            drops.append(CGPoint(x: x, y: y))
            if drops.count > 30 { drops.removeFirst() }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Mandala Coloring
// MARK: - Mandala Coloring
struct MandalaColoringGame: View {
    @State private var sections: [MandalaSection] = []
    @State private var selectedColor: Color = .calmSage
    
    let colors: [Color] = [.calmSage, .softRose, .warmPeach, .softLavender, .gentleSky, .saffron]
    
    struct MandalaSection: Identifiable {
        let id = UUID()
        var color: Color = .white
        
        // Simple circular sections for demo purposes
        // In a real app, these would be complex paths
        var scale: CGFloat
        var rotation: Double
    }
    
    var body: some View {
        VStack {
            Text("Mandala Coloring")
                .font(ResetTypography.heading(24))
                .padding(.top, 40)
            
            Spacer()
            
            ZStack {
                // Interactive Mandala
                ForEach(0..<sections.count, id: \.self) { i in
                    Circle() // Petal
                        .fill(sections[i].color)
                        .frame(width: 80, height: 160)
                        .overlay(Circle().stroke(Color.black.opacity(0.1), lineWidth: 1))
                        .offset(y: -60) // Move out from center
                        .rotationEffect(.degrees(sections[i].rotation))
                        .scaleEffect(sections[i].scale)
                        .onTapGesture {
                            withAnimation {
                                sections[i].color = selectedColor
                            }
                            let generator = UISelectionFeedbackGenerator()
                            generator.selectionChanged()
                        }
                }
                
                // Center
                Circle()
                    .fill(Color.white)
                    .frame(width: 60, height: 60)
                    .shadow(radius: 5)
            }
            .frame(width: 300, height: 300)
            
            Spacer()
            
            // Color Palette
            HStack(spacing: 16) {
                ForEach(colors, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .stroke(Color.primary.opacity(selectedColor == color ? 1 : 0), lineWidth: 3)
                        )
                        .onTapGesture {
                            selectedColor = color
                        }
                }
            }
            .padding(.bottom, 40)
        }
        .onAppear {
            generateMandala()
        }
    }
    
    private func generateMandala() {
        sections = []
        // Generate petals
        for i in 0..<12 {
            sections.append(MandalaSection(scale: 1.0, rotation: Double(i) * 30.0))
        }
        // Generate inner ring
        for i in 0..<8 {
            sections.append(MandalaSection(scale: 0.6, rotation: Double(i) * 45.0 + 22.5))
        }
    }
}

// MARK: - Constellation
// MARK: - Constellation
struct ConstellationGame: View {
    @State private var points: [CGPoint] = [
        CGPoint(x: 100, y: 150), CGPoint(x: 250, y: 100),
        CGPoint(x: 300, y: 300), CGPoint(x: 150, y: 350),
        CGPoint(x: 80, y: 250), CGPoint(x: 200, y: 200)
    ]
    @State private var connections: [(Int, Int)] = []
    @State private var currentStart: Int?
    @State private var isComplete = false
    
    var body: some View {
        ZStack {
            // Night Sky
            LinearGradient(colors: [Color(hex: "0F172A"), Color(hex: "1E293B")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            // Stars (Background)
            ForEach(0..<20, id: \.self) { _ in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.1...0.3)))
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                              y: CGFloat.random(in: 0...UIScreen.main.bounds.height))
            }
            
            // Connected Lines
            Path { path in
                for (from, to) in connections {
                    path.move(to: points[from])
                    path.addLine(to: points[to])
                }
                // Preview line
                if let start = currentStart {
                   // This is harder to do in generic Path without current touch location state.
                   // Omitting preview line for simplicity in this struct structure
                }
            }
            .stroke(Color.white.opacity(0.6), style: StrokeStyle(lineWidth: 2, lineCap: .round))
            
            // Interactive Stars
            ForEach(0..<points.count, id: \.self) { i in
                Circle()
                    .fill(currentStart == i ? Color.yellow : Color.white)
                    .frame(width: 16, height: 16)
                    .shadow(color: .white.opacity(0.5), radius: 5)
                    .position(points[i])
                    .onTapGesture {
                        handleTap(at: i)
                    }
            }
            
            VStack {
                Text(connections.count >= points.count - 1 ? "Starlight Connected" : "Connect the Stars")
                    .font(ResetTypography.heading(20))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.top, 60)
                Spacer()
                
                Button("Reset Sky") {
                    connections = []
                    currentStart = nil
                }
                .foregroundColor(.white.opacity(0.5))
                .padding(.bottom, 40)
            }
        }
    }
    
    private func handleTap(at index: Int) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        if let start = currentStart {
            if start != index {
                // Prevent duplicate connection
                let isDuplicate = connections.contains { ($0 == start && $1 == index) || ($0 == index && $1 == start) }
                if !isDuplicate {
                    withAnimation {
                        connections.append((start, index))
                    }
                }
                currentStart = nil // Deselect after connecting
            } else {
                currentStart = nil // Deselect self
            }
        } else {
            currentStart = index
        }
    }
}

// Helper Shape
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Game Help Overlay
struct GameHelpOverlay: View {
    let gameName: String
    let instructions: String
    let icon: String
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            // Card
            VStack(spacing: 24) {
                // Icon
                if icon.contains(".") {
                    Image(systemName: icon)
                        .font(.system(size: 48))
                        .foregroundColor(.calmSage)
                        .padding()
                        .background(
                            Circle()
                                .fill(Color.calmSage.opacity(0.1))
                                .frame(width: 88, height: 88)
                        )
                } else {
                    // Fallback for asset names if we had them, or just use a generic symbol
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.calmSage)
                        .padding()
                        .background(
                            Circle()
                                .fill(Color.calmSage.opacity(0.1))
                                .frame(width: 88, height: 88)
                        )
                }
                
                VStack(spacing: 8) {
                    Text(gameName)
                        .font(ResetTypography.heading(24))
                        .foregroundColor(.primary)
                    
                    Text("How to Play")
                        .font(ResetTypography.caption(14).smallCaps())
                        .foregroundColor(.secondary)
                }
                
                Text(instructions)
                    .font(ResetTypography.body(16))
                    .foregroundColor(.primary.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .fixedSize(horizontal: false, vertical: true)
                
                Button(action: onDismiss) {
                    Text("Start Playing")
                        .font(ResetTypography.heading(18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.calmSage)
                        )
                }
                .padding(.top, 8)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.2), radius: 20, y: 10)
            )
            .padding(24)
            .transition(.scale.combined(with: .opacity))
        }
    }
}

