//
//  HapticsManager.swift
//  ResetNow
//
//  Centralized management for haptic feedback
//

import UIKit
import SwiftUI
import CoreHaptics

class HapticsManager: ObservableObject {
    static let shared = HapticsManager()
    
    /// Check if the device supports haptics (iPhone with Taptic Engine)
    /// Mac Mini, Simulator, and older devices don't support haptics
    private let supportsHaptics: Bool
    
    private init() {
        // Check hardware capability once at initialization
        supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        
        #if DEBUG
        if !supportsHaptics {
            print("ℹ️ Haptics: Device does not support haptic feedback (Mac/Simulator/older device)")
        }
        #endif
    }
    
    // MARK: - Impact Feedback
    
    /// Triggers a light impact feedback (e.g., for button taps)
    func playLight() {
        guard supportsHaptics else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Triggers a medium impact feedback (e.g., for toggle switches)
    func playMedium() {
        guard supportsHaptics else { return }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Triggers a heavy impact feedback (e.g., for significant actions)
    func playHeavy() {
        guard supportsHaptics else { return }
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Triggers a rigid impact feedback
    func playRigid() {
        guard supportsHaptics else { return }
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Triggers a soft impact feedback
    func playSoft() {
        guard supportsHaptics else { return }
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // MARK: - Notification Feedback
    
    /// Triggers a success notification feedback
    func playSuccess() {
        guard supportsHaptics else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    
    /// Triggers a warning notification feedback
    func playWarning() {
        guard supportsHaptics else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }
    
    /// Triggers an error notification feedback
    func playError() {
        guard supportsHaptics else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
    
    // MARK: - Selection Feedback
    
    /// Triggers a selection change feedback (e.g., scrolling through a picker)
    func playSelection() {
        guard supportsHaptics else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}

// MARK: - View Extension
extension View {
    func hapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .light, trigger: Bool) -> some View {
        self.onChange(of: trigger) { newValue in
            // Only trigger haptics on devices that support it
            guard newValue, CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.impactOccurred()
        }
    }
}
