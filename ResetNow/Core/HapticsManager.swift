//
//  HapticsManager.swift
//  ResetNow
//
//  Centralized management for haptic feedback
//

import UIKit
import SwiftUI

class HapticsManager: ObservableObject {
    static let shared = HapticsManager()
    
    private init() {}
    
    // MARK: - Impact Feedback
    
    /// Triggers a light impact feedback (e.g., for button taps)
    func playLight() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Triggers a medium impact feedback (e.g., for toggle switches)
    func playMedium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Triggers a heavy impact feedback (e.g., for significant actions)
    func playHeavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Triggers a rigid impact feedback
    func playRigid() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Triggers a soft impact feedback
    func playSoft() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // MARK: - Notification Feedback
    
    /// Triggers a success notification feedback
    func playSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    
    /// Triggers a warning notification feedback
    func playWarning() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }
    
    /// Triggers an error notification feedback
    func playError() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
    
    // MARK: - Selection Feedback
    
    /// Triggers a selection change feedback (e.g., scrolling through a picker)
    func playSelection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}

// MARK: - View Extension
extension View {
    func hapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .light, trigger: Bool) -> some View {
        self.onChange(of: trigger) { newValue in
            if newValue {
                let generator = UIImpactFeedbackGenerator(style: style)
                generator.impactOccurred()
            }
        }
    }
}
