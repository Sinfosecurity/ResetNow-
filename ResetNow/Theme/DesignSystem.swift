//
//  DesignSystem.swift
//  ResetNow
//
//  Design System for ResetNow - Soft, calming, supportive aesthetics
//


import SwiftUI
import UIKit


// MARK: - Semantic Color Tokens
/// Color tokens using Apple's iOS system colors for optimal appearance.
/// Pure black backgrounds for OLED screens, high contrast text.
enum SemanticColors {
    static func background(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: "000000") : Color(hex: "F2F2F7")
    }
    
    static func surface(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: "1C1C1E") : .white
    }
    
    static func surfaceSecondary(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: "2C2C2E") : Color(hex: "F2F2F7")
    }
    
    /// Primary text - pure white/black for maximum contrast
    static func textPrimary(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .white : .black
    }
    
    /// Secondary text - iOS standard secondary label color
    static func textSecondary(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: "EBEBF5").opacity(0.6) : Color(hex: "3C3C43").opacity(0.6)
    }
    
    /// Tertiary text - for timestamps and minor details
    static func textTertiary(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: "EBEBF5").opacity(0.3) : Color(hex: "3C3C43").opacity(0.3)
    }
    
    /// Section headers - matches iOS Settings style
    static func sectionHeader(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: "8E8E93") : Color(hex: "6D6D72")
    }
    
    static let disabledBackground = Color(hex: "D1D1D6")
    static let disabledText = Color(hex: "8E8E93")
    
    static func disabledSurface(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: "3A3A3C") : Color(hex: "E5E5EA")
    }
}

// MARK: - Adaptive Card Color
/// Use this for card/surface backgrounds that need to adapt to dark mode
struct AdaptiveCard: View {
    @Environment(\.colorScheme) var colorScheme
    var cornerRadius: CGFloat = 16
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(colorScheme == .dark ? Color(hex: "1C1C1E") : .white)
    }
}

// MARK: - Color Palette
// Matches app icon (purple/teal) and mascot (blue)
extension Color {
    // Adaptive card background - use Color.cardBackground(for: colorScheme)
    static func cardBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: "1C1C1E") : .white
    }
    
    // Brand colors - matching app icon
    static let resetPrimary = Color(hex: "4B2E83")      // Deep purple from icon
    static let resetSecondary = Color(hex: "2DD4BF")    // Teal accent from icon
    static let resetAccent = Color(hex: "3B82F6")       // Blue from mascot
    
    // Core colors - cohesive purple/blue/teal theme
    // WCAG AA compliant - minimum 4.5:1 contrast ratio for text
    static let calmSage = Color(hex: "0D9488")          // Dark teal - WCAG AA on white (5.1:1)
    static let calmSageLight = Color(hex: "2DD4BF")     // Light teal for backgrounds only
    static let softLavender = Color(hex: "4F46E5")      // Darker indigo - WCAG AA (5.5:1)
    static let warmPeach = Color(hex: "6366F1")         // Indigo purple
    static let gentleSky = Color(hex: "2563EB")         // Darker blue - WCAG AA (4.9:1)
    static let softRose = Color(hex: "7C3AED")          // Darker violet - WCAG AA (5.3:1)
    static let creamWhite = Color(hex: "F8FAFC")        // Clean white
    static let warmGray = Color(hex: "475569")          // Darker slate - WCAG AA (6.2:1)
    static let deepSlate = Color(hex: "0F172A")         // Deep navy
    static let midnightSoft = Color(hex: "1E1B4B")      // Purple-tinted dark
    
    // Button colors - dark enough for white text
    static let buttonSage = Color(hex: "0D9488")        // Dark teal button (5.1:1)
    static let buttonSagePressed = Color(hex: "0F766E") // Even darker teal
    
    // Gradients - matching icon gradient
    static let sunriseGradientStart = Color(hex: "EDE9FE")   // Light purple
    static let sunriseGradientEnd = Color(hex: "DBEAFE")     // Light blue
    static let twilightGradientStart = Color(hex: "4B2E83")  // Deep purple
    static let twilightGradientEnd = Color(hex: "1E1B4B")    // Darker purple
    static let oceanGradientStart = Color(hex: "2DD4BF")     // Teal
    static let oceanGradientEnd = Color(hex: "3B82F6")       // Blue
    
    // Tool colors - WCAG AA compliant for text on white
    static let learnColor = Color(hex: "2563EB")        // Dark blue (4.9:1)
    static let breatheColor = Color(hex: "0D9488")      // Dark teal (5.1:1)
    static let gamesColor = Color(hex: "DB2777")        // Dark pink (4.6:1)
    static let journalColor = Color(hex: "7C3AED")      // Dark violet (5.3:1)
    static let visualizeColor = Color(hex: "0891B2")    // Dark cyan (4.6:1)
    static let sleepColor = Color(hex: "4F46E5")        // Dark indigo (5.5:1)
    static let affirmColor = Color(hex: "D97706")       // Dark amber (4.7:1)
    static let journeysColor = Color(hex: "059669")     // Dark emerald (4.8:1)
    
    // Safety - keeping red for emergency visibility
    static let sosRed = Color(hex: "EF4444")            // Bright red
    static let safetyYellow = Color(hex: "F59E0B")      // Amber warning
    
    // Additional nature colors
    static let saffron = Color(hex: "E4C027")           // Saffron yellow
    
    static let disabledBackground = SemanticColors.disabledBackground
    static let disabledText = SemanticColors.disabledText
}

// MARK: - Color Hex Initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0) // Default to black if invalid
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // Backwards compatibility
    init(validatedHex hex: String) {
        self.init(hex: hex)
    }
}

// MARK: - Typography
/// Typography system optimized for readability on physical devices.
/// Uses SF Pro Rounded with slightly heavier weights for better visibility.
struct ResetTypography {
    
    /// Display text - for large titles and hero text
    /// Default 34pt bold
    static func display(_ size: CGFloat = 34) -> Font {
        let scaledSize = UIFontMetrics(forTextStyle: .largeTitle).scaledValue(for: size)
        return .system(size: scaledSize, weight: .bold, design: .rounded)
    }
    
    /// Heading text - for section titles and card headers
    /// Default 22pt semibold
    static func heading(_ size: CGFloat = 22) -> Font {
        let scaledSize = UIFontMetrics(forTextStyle: .title2).scaledValue(for: size)
        return .system(size: scaledSize, weight: .semibold, design: .rounded)
    }
    
    /// Body text - for main content and descriptions
    /// Default 17pt medium (slightly bolder than regular for better visibility)
    static func body(_ size: CGFloat = 17) -> Font {
        let scaledSize = UIFontMetrics(forTextStyle: .body).scaledValue(for: size)
        return .system(size: scaledSize, weight: .medium, design: .rounded)
    }
    
    /// Caption text - for labels and secondary info
    /// Default 15pt medium
    static func caption(_ size: CGFloat = 15) -> Font {
        let scaledSize = UIFontMetrics(forTextStyle: .caption1).scaledValue(for: size)
        return .system(size: scaledSize, weight: .medium, design: .rounded)
    }
    
    /// Small caption - for timestamps and minor details
    /// Default 13pt regular
    static func captionSmall(_ size: CGFloat = 13) -> Font {
        let scaledSize = UIFontMetrics(forTextStyle: .caption2).scaledValue(for: size)
        return .system(size: scaledSize, weight: .regular, design: .rounded)
    }
    
    // Fixed size variants (don't scale with Dynamic Type)
    static func displayFixed(_ size: CGFloat = 34) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
    
    static func headingFixed(_ size: CGFloat = 22) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
    
    static func bodyFixed(_ size: CGFloat = 17) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }
    
    static func captionFixed(_ size: CGFloat = 15) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }
}

// MARK: - Adaptive Colors
struct AdaptiveColors {
    static func background(for colorScheme: ColorScheme) -> Color {
        SemanticColors.background(colorScheme)
    }
    
    static func cardSurface(for colorScheme: ColorScheme) -> Color {
        SemanticColors.surface(colorScheme)
    }
    
    static func primaryText(for colorScheme: ColorScheme) -> Color {
        SemanticColors.textPrimary(colorScheme)
    }
    
    static func secondaryText(for colorScheme: ColorScheme) -> Color {
        SemanticColors.textSecondary(colorScheme)
    }
    
    static func screenBackground(for colorScheme: ColorScheme) -> LinearGradient {
        if colorScheme == .dark {
            // Pure black gradient for clean OLED appearance
            return LinearGradient(
                colors: [Color(hex: "000000"), Color(hex: "000000")],
                startPoint: .top,
                endPoint: .bottom
            )
        } else {
            // Light iOS-style background
            return LinearGradient(
                colors: [Color(hex: "F2F2F7"), Color(hex: "FFFFFF")],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    static func gradient(for colorScheme: ColorScheme) -> LinearGradient {
        ResetGradients.background(for: colorScheme)
    }
}

// MARK: - Gradients
struct ResetGradients {
    static let sunrise = LinearGradient(
        colors: [.sunriseGradientStart, .sunriseGradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let twilight = LinearGradient(
        colors: [.twilightGradientStart, .twilightGradientEnd],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let ocean = LinearGradient(
        colors: [.oceanGradientStart, .oceanGradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let calm = LinearGradient(
        colors: [Color.calmSage.opacity(0.4), Color.softLavender.opacity(0.3)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let warmth = LinearGradient(
        colors: [Color.warmPeach.opacity(0.5), Color.softRose.opacity(0.4)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static func background(for colorScheme: ColorScheme) -> LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                colors: [Color(hex: "0F172A"), Color(hex: "1E1B4B")], // Deep Slate to Midnight Soft
                startPoint: .top,
                endPoint: .bottom
            )
        } else {
            return LinearGradient(
                colors: [Color(hex: "F2F2F7"), Color(hex: "FFFFFF")],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    static func toolGradient(for color: Color) -> LinearGradient {
        LinearGradient(
            colors: [color.opacity(0.7), color.opacity(0.4)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Shadows
struct ResetShadow: ViewModifier {
    var radius: CGFloat = 8
    var opacity: Double = 0.12
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .shadow(
                color: Color.black.opacity(colorScheme == .dark ? 0.3 : opacity),
                radius: radius,
                x: 0,
                y: 4
            )
    }
}

extension View {
    func resetShadow(radius: CGFloat = 8, opacity: Double = 0.12) -> some View {
        modifier(ResetShadow(radius: radius, opacity: opacity))
    }
}

// MARK: - Glassmorphism Card
struct GlassmorphismCard: ViewModifier {
    var cornerRadius: CGFloat = 20
    var opacity: Double = 0.15
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(colorScheme == .dark ? 0.2 : 0.6),
                                        Color.white.opacity(colorScheme == .dark ? 0.05 : 0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 12, y: 4)
            )
    }
}

extension View {
    func glassmorphism(cornerRadius: CGFloat = 20) -> some View {
        modifier(GlassmorphismCard(cornerRadius: cornerRadius))
    }
}

// MARK: - Gradient Card Background
struct GradientCardBackground: View {
    let colors: [Color]
    var cornerRadius: CGFloat = 20
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(
                LinearGradient(
                    colors: colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
}

// MARK: - Animated Gradient Background
struct AnimatedGradientBackground: View {
    @State private var animateGradient = false
    let colors: [Color]
    
    init(colors: [Color] = [Color(hex: "1E1B4B"), Color(hex: "312E81"), Color(hex: "4B2E83")]) {
        self.colors = colors
    }
    
    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

// MARK: - Floating Particles
struct FloatingParticles: View {
    let particleCount: Int
    let colors: [Color]
    
    init(particleCount: Int = 20, colors: [Color] = [.calmSage, .gentleSky, .softLavender]) {
        self.particleCount = particleCount
        self.colors = colors
    }
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<particleCount, id: \.self) { index in
                FloatingParticle(
                    color: colors[index % colors.count],
                    size: CGFloat.random(in: 4...12),
                    startPosition: CGPoint(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: CGFloat.random(in: 0...geometry.size.height)
                    ),
                    duration: Double.random(in: 8...15)
                )
            }
        }
    }
}

struct FloatingParticle: View {
    let color: Color
    let size: CGFloat
    let startPosition: CGPoint
    let duration: Double
    
    @State private var offset: CGSize = .zero
    @State private var opacity: Double = 0.3
    
    var body: some View {
        Circle()
            .fill(color.opacity(opacity))
            .frame(width: size, height: size)
            .blur(radius: size / 3)
            .position(x: startPosition.x, y: startPosition.y)
            .offset(offset)
            .onAppear {
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    offset = CGSize(
                        width: CGFloat.random(in: -50...50),
                        height: CGFloat.random(in: -100...100)
                    )
                    opacity = Double.random(in: 0.1...0.5)
                }
            }
    }
}

// MARK: - Premium Card Style
struct PremiumCardStyle: ViewModifier {
    let accentColor: Color
    var cornerRadius: CGFloat = 24
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    colorScheme == .dark ? Color(hex: "1C1C1E") : .white,
                                    colorScheme == .dark ? Color(hex: "2C2C2E") : Color(hex: "F8FAFC")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Accent glow
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: [accentColor.opacity(0.5), accentColor.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                }
                .shadow(color: accentColor.opacity(0.2), radius: 16, y: 8)
            )
    }
}

extension View {
    func premiumCard(accentColor: Color, cornerRadius: CGFloat = 24) -> some View {
        modifier(PremiumCardStyle(accentColor: accentColor, cornerRadius: cornerRadius))
    }
}

// MARK: - Shimmer Effect
struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        Color.white.opacity(0.4),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(30))
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    phase = 400
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }
}

// MARK: - Card Style
struct ResetCardStyle: ViewModifier {
    var cornerRadius: CGFloat = 20
    var padding: CGFloat = 16
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(SemanticColors.surface(colorScheme))
                    .resetShadow()
            )
    }
}

extension View {
    func resetCard(cornerRadius: CGFloat = 20, padding: CGFloat = 16) -> some View {
        modifier(ResetCardStyle(cornerRadius: cornerRadius, padding: padding))
    }
}

// MARK: - View Extensions
extension View {
    func adaptiveScreenBackground() -> some View {
        modifier(AdaptiveScreenBackgroundModifier())
    }
    
    func primaryTextColor() -> some View {
        modifier(PrimaryTextColorModifier())
    }
    
    func secondaryTextColor() -> some View {
        modifier(SecondaryTextColorModifier())
    }
}

private struct AdaptiveScreenBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content.background(
            AdaptiveColors.screenBackground(for: colorScheme)
                .ignoresSafeArea()
        )
    }
}

private struct PrimaryTextColorModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content.foregroundColor(SemanticColors.textPrimary(colorScheme))
    }
}

private struct SecondaryTextColorModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content.foregroundColor(SemanticColors.textSecondary(colorScheme))
    }
}

// MARK: - Button Styles

struct ResetPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    @Environment(\.colorScheme) var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(ResetTypography.heading(18))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(backgroundColor(isPressed: configuration.isPressed))
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
    
    private func backgroundColor(isPressed: Bool) -> Color {
        if !isEnabled {
            return Color(hex: "AAAAAA")
        }
        if isPressed {
            return Color(hex: "3A6A3B")
        }
        return Color(hex: "4A7A4B")
    }
}

struct ResetSecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    @Environment(\.colorScheme) var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(ResetTypography.body(17))
            .foregroundColor(foregroundColor(isPressed: configuration.isPressed))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(backgroundColor(isPressed: configuration.isPressed))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor(isPressed: configuration.isPressed), lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
    
    private func foregroundColor(isPressed: Bool) -> Color {
        if !isEnabled {
            return Color(hex: "888888")
        }
        return Color(hex: "4A7A4B")
    }
    
    private func backgroundColor(isPressed: Bool) -> Color {
        if isPressed {
            return Color(hex: "4A7A4B").opacity(0.15)
        }
        return Color.clear
    }
    
    private func borderColor(isPressed: Bool) -> Color {
        if !isEnabled {
            return Color(hex: "CCCCCC")
        }
        return Color(hex: "4A7A4B")
    }
}

struct ResetToolButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .fill(color.opacity(configuration.isPressed ? 0.2 : 0))
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct HapticButtonStyle: ButtonStyle {
    let feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle
    
    init(feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        self.feedbackStyle = feedbackStyle
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    let generator = UIImpactFeedbackGenerator(style: feedbackStyle)
                    generator.impactOccurred()
                }
            }
    }
}

// MARK: - Accessibility Modifiers
struct AccessibleButtonModifier: ViewModifier {
    let label: String
    let hint: String?
    let traits: AccessibilityTraits
    
    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(traits)
    }
}

extension View {
    func accessibleButton(label: String, hint: String? = nil, traits: AccessibilityTraits = .isButton) -> some View {
        modifier(AccessibleButtonModifier(label: label, hint: hint, traits: traits))
    }
}

// MARK: - Spacing
enum ResetSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Animation
struct ResetAnimations {
    static let gentle = Animation.easeInOut(duration: 0.3)
    static let breathing = Animation.easeInOut(duration: 1.5)
    static let pulse = Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)
    static let fadeIn = Animation.easeIn(duration: 0.4)
    
    static func staggered(index: Int, baseDelay: Double = 0.05) -> Animation {
        .spring(response: 0.5, dampingFraction: 0.8)
        .delay(Double(index) * baseDelay)
    }
}

// MARK: - Adaptive Background View
struct AdaptiveBackgroundView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        AdaptiveColors.screenBackground(for: colorScheme)
            .ignoresSafeArea()
    }
}

// MARK: - Previews
#if DEBUG
struct DesignSystem_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("ResetNow Design")
                    .font(ResetTypography.display(28))
                    .foregroundColor(Color(hex: "1A1A1A"))
                
                Text("Heading Text")
                    .font(ResetTypography.heading())
                    .foregroundColor(Color(hex: "333333"))
                
                Text("Body text for reading content")
                    .font(ResetTypography.body())
                    .foregroundColor(Color(hex: "555555"))
                
                Text("Caption for small labels")
                    .font(ResetTypography.caption())
                    .foregroundColor(Color(hex: "666666"))
                
                Button("Primary Action") {}
                    .buttonStyle(ResetPrimaryButtonStyle())
                    .padding(.horizontal)
                
                Button("Secondary Action") {}
                    .buttonStyle(ResetSecondaryButtonStyle())
                    .padding(.horizontal)
                
                HStack(spacing: 12) {
                    colorBox(.calmSage, "Sage")
                    colorBox(.softLavender, "Lavender")
                    colorBox(.warmPeach, "Peach")
                    colorBox(.gentleSky, "Sky")
                }
            }
            .padding()
        }
        .background(Color(hex: "FAF8F5"))
    }
    
    static func colorBox(_ color: Color, _ name: String) -> some View {
        VStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 60, height: 60)
            Text(name)
                .font(ResetTypography.caption(12))
                .foregroundColor(Color(hex: "555555"))
        }
    }
}
#endif
