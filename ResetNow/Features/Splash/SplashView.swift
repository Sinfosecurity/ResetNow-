//
//  SplashView.swift
//  ResetNow
//
//  Created by ResetNow AI on 12/5/25.
//

import SwiftUI
import AVKit

struct SplashView: View {
    var onFinished: () -> Void
    
    @State private var player: AVPlayer?
    @State private var errorMessage: String?
    @State private var isVideoFinished = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let player = player {
                VideoPlayer(player: player)
                    .disabled(true) // Disable user interaction
                    .ignoresSafeArea()
                    .aspectRatio(contentMode: .fill) // Ensure it fills the screen
                    .onAppear {
                        player.play()
                    }
            } else if let errorMessage = errorMessage {
                // Fallback or Error View
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    
                    Text(errorMessage)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .background(Color.black.opacity(0.8))
            }
        }
        .onAppear {
            setupPlayer()
        }
        .onReceive(NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)) { _ in
            // Video finished playing
            finishSplash()
        }
    }
    
    private func setupPlayer() {
        // 1. Try specific names
        var videoUrl = Bundle.main.url(forResource: "Welcome to resetnow", withExtension: "mp4") ??
                       Bundle.main.url(forResource: "welcome_video", withExtension: "mp4")
        
        // 2. If not found, search for ANY mp4 in the bundle (Robust fallback)
        if videoUrl == nil {
            if let urls = Bundle.main.urls(forResourcesWithExtension: "mp4", subdirectory: nil),
               let firstUrl = urls.first {
                print("Found mp4 at: \(firstUrl)")
                videoUrl = firstUrl
            }
        }

        guard let url = videoUrl else {
            print("Splash video not found")
            self.errorMessage = "Video NOT found in Bundle.\n\nPlease check Xcode:\n1. Open Project Navigator\n2. Find \"Welcome to resetnow.mp4\"\n3. Check \"Target Membership\" in Right Sidebar"
            
            // Delay dismissal so user can see the error
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                onFinished()
            }
            return
        }
        
        let player = AVPlayer(url: url)
        player.actionAtItemEnd = .none // Prevent it from restarting or doing weird things
        self.player = player
    }
    
    private func finishSplash() {
        guard !isVideoFinished else { return }
        isVideoFinished = true
        
        // Small buffer to ensure the video doesn't just cut to black instantly if there's a frame drop
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onFinished()
        }
    }
}
