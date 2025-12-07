//
//  AffirmView.swift
//  ResetNow
//
//  Daily affirmations with categories and favorites
//

import SwiftUI

struct AffirmView: View {
    @State private var selectedCategory: Affirmation.AffirmationCategory? = nil
    @State private var showFavoritesOnly = false
    @State private var favoriteIds: Set<UUID> = []
    @State private var todaysAffirmation: Affirmation?
    @State private var animateCard = false
    
    let persistence = PersistenceController.shared
    
    var filteredAffirmations: [Affirmation] {
        var result = Affirmation.samples
        
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        if showFavoritesOnly {
            result = result.filter { favoriteIds.contains($0.id) }
        }
        
        return result
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: ResetSpacing.lg) {
                // Today's affirmation
                todaysAffirmationSection
                
                // Category filters
                categoryFiltersSection
                
                // Affirmation cards
                affirmationCardsSection
            }
            .padding(.horizontal, ResetSpacing.md)
            .padding(.bottom, ResetSpacing.xxl)
        }
        .scrollContentBackground(.hidden)
        .background(
            ZStack {
                AnimatedGradientBackground()
                FloatingParticles()
                    .opacity(0.6)
            }
            .ignoresSafeArea()
        )
        .navigationTitle("Affirm")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            loadFavorites()
            selectTodaysAffirmation()
            withAnimation(.spring(response: 0.6)) {
                animateCard = true
            }
        }
    }
    
    // MARK: - Today's Affirmation
    private var todaysAffirmationSection: some View {
        VStack(spacing: ResetSpacing.md) {
            if let affirmation = todaysAffirmation {
                PremiumAffirmationCard(
                    affirmation: affirmation,
                    isFavorite: favoriteIds.contains(affirmation.id),
                    onFavorite: { toggleFavorite(affirmation) },
                    onShare: { shareAffirmation(affirmation) },
                    onShuffle: { rotateAffirmation() }
                )
                .opacity(animateCard ? 1 : 0)
                .offset(y: animateCard ? 0 : 20)
            }
        }
    }
    
    // MARK: - Category Filters
    private var categoryFiltersSection: some View {
        VStack(alignment: .leading, spacing: ResetSpacing.md) {
            HStack {
                Text("Categories")
                    .font(ResetTypography.heading(18))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Favorites toggle
                Button(action: { showFavoritesOnly.toggle() }) {
                    HStack(spacing: 4) {
                        Image(systemName: showFavoritesOnly ? "heart.fill" : "heart")
                        Text("Favorites")
                    }
                    .font(ResetTypography.caption(13))
                    .foregroundColor(showFavoritesOnly ? .softRose : .white.opacity(0.7))
                    .padding(.horizontal, ResetSpacing.sm + 4)
                    .padding(.vertical, ResetSpacing.sm)
                    .background(
                        Capsule()
                            .fill(showFavoritesOnly ? Color.softRose.opacity(0.2) : Color.white.opacity(0.1))
                            .overlay(
                                Capsule()
                                    .stroke(showFavoritesOnly ? Color.softRose : Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: ResetSpacing.sm) {
                    CategoryChip(
                        title: "All",
                        isSelected: selectedCategory == nil,
                        color: .calmSage
                    ) {
                        selectedCategory = nil
                    }
                    
                    ForEach(Affirmation.AffirmationCategory.allCases, id: \.rawValue) { category in
                        CategoryChip(
                            title: category.rawValue,
                            isSelected: selectedCategory == category,
                            color: category.color
                        ) {
                            selectedCategory = category
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Affirmation Cards
    private var affirmationCardsSection: some View {
        VStack(spacing: ResetSpacing.md) {
            if filteredAffirmations.isEmpty {
                EmptyFavoritesView()
            } else {
                HStack(alignment: .top, spacing: 16) {
                    // Left Column
                    LazyVStack(spacing: 16) {
                        ForEach(Array(filteredAffirmations.enumerated().filter { $0.offset % 2 == 0 }), id: \.element.id) { index, affirmation in
                            GlassAffirmationCard(
                                affirmation: affirmation,
                                isFavorite: favoriteIds.contains(affirmation.id),
                                onFavorite: { toggleFavorite(affirmation) }
                            )
                            .opacity(animateCard ? 1 : 0)
                            .offset(y: animateCard ? 0 : 20)
                            .animation(ResetAnimations.staggered(index: index, baseDelay: 0.03), value: animateCard)
                        }
                    }
                    
                    // Right Column
                    LazyVStack(spacing: 16) {
                        ForEach(Array(filteredAffirmations.enumerated().filter { $0.offset % 2 != 0 }), id: \.element.id) { index, affirmation in
                            GlassAffirmationCard(
                                affirmation: affirmation,
                                isFavorite: favoriteIds.contains(affirmation.id),
                                onFavorite: { toggleFavorite(affirmation) }
                            )
                            .opacity(animateCard ? 1 : 0)
                            .offset(y: animateCard ? 0 : 20)
                            .animation(ResetAnimations.staggered(index: index, baseDelay: 0.03), value: animateCard)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Helpers
    private func loadFavorites() {
        favoriteIds = persistence.getFavoriteIds()
    }
    
    private func selectTodaysAffirmation() {
        // Use day of year as seed for consistent daily affirmation
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = dayOfYear % Affirmation.samples.count
        todaysAffirmation = Affirmation.samples[index]
    }
    
    private func rotateAffirmation() {
        if let current = todaysAffirmation, let index = Affirmation.samples.firstIndex(where: { $0.id == current.id }) {
            let nextIndex = (index + 1) % Affirmation.samples.count
            withAnimation(.spring(response: 0.5)) {
                todaysAffirmation = Affirmation.samples[nextIndex]
            }
        } else {
            selectTodaysAffirmation()
        }
    }
    
    private func toggleFavorite(_ affirmation: Affirmation) {
        let isFavorite = persistence.toggleFavorite(affirmationId: affirmation.id)
        if isFavorite {
            favoriteIds.insert(affirmation.id)
        } else {
            favoriteIds.remove(affirmation.id)
        }
    }

    @MainActor
    private func shareAffirmation(_ affirmation: Affirmation) {
        let view = ShareableAffirmationView(affirmation: affirmation)
        let renderer = ImageRenderer(content: view)
        renderer.scale = UIScreen.main.scale
        
        if let image = renderer.uiImage {
            let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
        }
    }
// ...
}

// MARK: - Premium Hero Card
struct PremiumAffirmationCard: View {
    let affirmation: Affirmation
    let isFavorite: Bool
    let onFavorite: () -> Void
    let onShare: () -> Void
    let onShuffle: () -> Void
    
    @State private var shimmerOffset: CGFloat = -200
    
    var body: some View {
        ZStack {
            // Glow effect
            RoundedRectangle(cornerRadius: 24)
                .fill(affirmation.category.color.opacity(0.3))
                .blur(radius: 20)
                .offset(y: 10)
            
            // Glass Card
            RoundedRectangle(cornerRadius: 24)
                .fill(Material.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [
                                    affirmation.category.color.opacity(0.2),
                                    affirmation.category.color.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.6),
                                    .white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
            
            // Content
            VStack(spacing: ResetSpacing.lg) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("TODAY'S AFFIRMATION")
                            .font(ResetTypography.caption(10).weight(.bold))
                            .tracking(1.5)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text(affirmation.category.rawValue)
                            .font(ResetTypography.caption(12))
                            .foregroundColor(affirmation.category.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(affirmation.category.color.opacity(0.2))
                            )
                    }
                    
                    Spacer()
                    
                    Button(action: onFavorite) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 22))
                            .foregroundColor(isFavorite ? .softRose : .white.opacity(0.6))
                            .symbolEffect(.bounce, value: isFavorite)
                    }
                }
                
                Text("\"\(affirmation.text)\"")
                    .font(ResetTypography.display(24))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, ResetSpacing.sm)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                
                HStack(spacing: 16) {
                    Button(action: onShare) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
                        }
                        .font(ResetTypography.caption(14).weight(.medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    
                    Button(action: onShuffle) {
                        HStack(spacing: 8) {
                            Image(systemName: "shuffle")
                            Text("New")
                        }
                        .font(ResetTypography.caption(14).weight(.medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                }
            }
            .padding(24)
            
            // Shimmer overlay
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.2), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .rotationEffect(.degrees(45))
                .offset(x: shimmerOffset)
                .mask(RoundedRectangle(cornerRadius: 24))
        }
        .frame(minHeight: 260)
        .onAppear {
            withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false).delay(1)) {
                shimmerOffset = 200
            }
        }
    }
}

// MARK: - Glass Category Chip
struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(ResetTypography.caption(13).weight(.medium))
                .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? AnyShapeStyle(color.opacity(0.8)) : AnyShapeStyle(Material.ultraThinMaterial))
                        .overlay(
                            Capsule()
                                .stroke(isSelected ? color : .white.opacity(0.2), lineWidth: 1)
                        )
                )
                .shadow(color: isSelected ? color.opacity(0.4) : .clear, radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - Glass Affirmation Card
struct GlassAffirmationCard: View {
    let affirmation: Affirmation
    let isFavorite: Bool
    let onFavorite: () -> Void
    
    var body: some View {
        Button(action: onFavorite) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(affirmation.category.rawValue.uppercased())
                        .font(ResetTypography.caption(10).weight(.bold))
                        .foregroundColor(affirmation.category.color)
                        .tracking(1)
                    
                    Spacer()
                    
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 16))
                        .foregroundColor(isFavorite ? .softRose : .white.opacity(0.3))
                }
                
                Text(affirmation.text)
                    .font(ResetTypography.body(14))
                    .foregroundColor(.white)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Material.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.05))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

// MARK: - Empty Favorites View
struct EmptyFavoritesView: View {
    var body: some View {
        VStack(spacing: ResetSpacing.md) {
            Image(systemName: "heart")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.3))
            
            Text("No favorites yet")
                .font(ResetTypography.body(16))
                .foregroundColor(.white.opacity(0.8))
            
            Text("Tap the heart on any affirmation to save it here")
                .font(ResetTypography.caption(13))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, ResetSpacing.xxl)
    }
}

// MARK: - Shareable Affirmation View (For Image Generation)
struct ShareableAffirmationView: View {
    let affirmation: Affirmation
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    affirmation.category.color,
                    affirmation.category.color.opacity(0.7)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Texture/noise overlay
            Color.white.opacity(0.05)
            
            // Decorative circles
            GeometryReader { geo in
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 300, height: 300)
                    .offset(x: -100, y: -100)
                
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .position(x: geo.size.width - 50, y: geo.size.height - 50)
            }
            
            VStack(spacing: 40) {
                // Category
                Text(affirmation.category.rawValue.uppercased())
                    .font(ResetTypography.captionFixed(14))
                    .fontWeight(.bold)
                    .tracking(2)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                            .overlay(Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1))
                    )
                
                // Quote
                Text("\"\(affirmation.text)\"")
                    .font(ResetTypography.displayFixed(32))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                
                // Footer / Branding
                HStack(spacing: 12) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                    
                    Text("ResetNow")
                        .font(ResetTypography.headingFixed(24))
                        .foregroundColor(.white)
                }
                .opacity(0.9)
            }
            .padding(40)
        }
        .frame(width: 400, height: 500)
        .background(Color.black) // Fallback
    }
}

// MARK: - Preview
struct AffirmView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AffirmView()
        }
    }
}

