//
//  AudioService.swift
//  ResetNow
//
//  Audio playback service with background audio and Now Playing integration
//

import Foundation
import AVFoundation
import MediaPlayer

@MainActor
final class AudioService: NSObject, ObservableObject {
    static let shared = AudioService()
    
    // MARK: - Published State
    @Published private(set) var isPlaying = false
    @Published private(set) var currentTrack: SleepTrack?
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    
    // MARK: - Audio Player
    private var audioPlayer: AVAudioPlayer?
    private var displayLink: CADisplayLink?
    
    // MARK: - Init
    private override init() {
        super.init()
        setupAudioSession()
        setupRemoteCommandCenter()
    }
    
    // MARK: - Audio Session Setup
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            
            // Set category to playback for background audio AND Lock Screen Now Playing
            // IMPORTANT: Remove .mixWithOthers to show Now Playing on Lock Screen
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            
            // Become the "now playing" app
            UIApplication.shared.beginReceivingRemoteControlEvents()
            
            print("✅ Audio session configured for Lock Screen Now Playing")
            
            /*
             IMPORTANT: For background audio to work, you must:
             1. Enable "Audio, AirPlay, and Picture in Picture" in:
                Target → Signing & Capabilities → + Capability → Background Modes
             2. Or add to Info.plist:
                <key>UIBackgroundModes</key>
                <array>
                    <string>audio</string>
                </array>
             */
            
        } catch {
            print("❌ Failed to set up audio session: \(error)")
        }
    }
    
    // MARK: - Remote Command Center (Lock Screen / Control Center controls)
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Play command
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.resume()
            }
            return .success
        }
        
        // Pause command
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.pause()
            }
            return .success
        }
        
        // Toggle play/pause
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                if self?.isPlaying == true {
                    self?.pause()
                } else {
                    self?.resume()
                }
            }
            return .success
        }
        
        // Stop command
        commandCenter.stopCommand.isEnabled = true
        commandCenter.stopCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.stop()
            }
            return .success
        }
        
        // Disable skip commands (not applicable for ambient audio)
        commandCenter.nextTrackCommand.isEnabled = false
        commandCenter.previousTrackCommand.isEnabled = false
    }
    
    // MARK: - Now Playing Info (Lock Screen & Control Center)
    private func updateNowPlayingInfo() {
        var nowPlayingInfo: [String: Any] = [:]
        
        if let track = currentTrack {
            nowPlayingInfo[MPMediaItemPropertyTitle] = track.name
            nowPlayingInfo[MPMediaItemPropertyArtist] = "ResetNow • Sleep Sounds"
            nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = "Peaceful Rest"
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
            
            // Use mascot as artwork for Lock Screen
            if let mascotImage = UIImage(named: "MascotBlue") {
                let artwork = MPMediaItemArtwork(boundsSize: mascotImage.size) { _ in
                    return mascotImage
                }
                nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
            } else {
                // Fallback: Create a gradient artwork with icon
                let artworkImage = createArtworkImage(for: track)
                let artwork = MPMediaItemArtwork(boundsSize: CGSize(width: 300, height: 300)) { _ in
                    return artworkImage
                }
                nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
            }
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    // Create a nice artwork image for Lock Screen
    private func createArtworkImage(for track: SleepTrack) -> UIImage {
        let size = CGSize(width: 300, height: 300)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Gradient background
            let colors = [
                UIColor(red: 0.29, green: 0.18, blue: 0.51, alpha: 1.0).cgColor, // Purple
                UIColor(red: 0.12, green: 0.11, blue: 0.29, alpha: 1.0).cgColor  // Dark purple
            ]
            
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors as CFArray,
                locations: [0.0, 1.0]
            )!
            
            context.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: size.width, y: size.height),
                options: []
            )
            
            // Draw icon in center
            let iconConfig = UIImage.SymbolConfiguration(pointSize: 80, weight: .medium)
            if let icon = UIImage(systemName: track.iconName, withConfiguration: iconConfig) {
                let iconSize = icon.size
                let iconRect = CGRect(
                    x: (size.width - iconSize.width) / 2,
                    y: (size.height - iconSize.height) / 2,
                    width: iconSize.width,
                    height: iconSize.height
                )
                icon.withTintColor(.white).draw(in: iconRect)
            }
            
            // Draw app name at bottom
            let appName = "ResetNow"
            let font = UIFont.systemFont(ofSize: 24, weight: .bold)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.white.withAlphaComponent(0.8)
            ]
            let textSize = appName.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: size.height - textSize.height - 30,
                width: textSize.width,
                height: textSize.height
            )
            appName.draw(in: textRect, withAttributes: attributes)
        }
    }
    
    // MARK: - Playback Controls
    func play(track: SleepTrack) {
        // Stop current playback
        stop()
        
        currentTrack = track
        
        // Try to load audio file from bundle
        // Support both .mp3 and .wav files
        let extensions = ["mp3", "wav", "m4a"]
        var audioURL: URL?
        
        for ext in extensions {
            if let url = Bundle.main.url(forResource: track.audioAssetName, withExtension: ext) {
                audioURL = url
                break
            }
        }
        
        if let url = audioURL {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.delegate = self
                audioPlayer?.numberOfLoops = -1 // Loop indefinitely
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
                
                isPlaying = true
                duration = audioPlayer?.duration ?? 0
                
                startTimeUpdates()
                updateNowPlayingInfo()
                print("✅ Now playing: \(track.name) from \(url.lastPathComponent)")
            } catch {
                print("❌ Failed to play audio: \(error)")
                // Fall back to simulated playback for demo
                startSimulatedPlayback(track: track)
            }
        } else {
            // Audio file not found - use simulated playback for demo
            print("⚠️ Audio file not found for: \(track.audioAssetName)")
            startSimulatedPlayback(track: track)
        }
    }
    
    private func startSimulatedPlayback(track: SleepTrack) {
        // For demo purposes when audio files aren't available
        isPlaying = true
        duration = Double(track.durationMinutes * 60)
        currentTime = 0
        
        startTimeUpdates()
        updateNowPlayingInfo()
    }
    
    func pause() {
        audioPlayer?.pause()
        isPlaying = false
        updateNowPlayingInfo()
    }
    
    func resume() {
        if audioPlayer != nil {
            audioPlayer?.play()
        }
        isPlaying = true
        updateNowPlayingInfo()
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        
        isPlaying = false
        currentTrack = nil
        currentTime = 0
        duration = 0
        
        stopTimeUpdates()
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
    
    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
        currentTime = time
        updateNowPlayingInfo()
    }
    
    // MARK: - Time Updates
    private var timeUpdateTimer: Timer?
    
    private func startTimeUpdates() {
        stopTimeUpdates()
        
        // Store timer reference so we can cancel it properly
        timeUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            Task { @MainActor [weak self] in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                
                if self.isPlaying {
                    if let player = self.audioPlayer {
                        self.currentTime = player.currentTime
                    } else {
                        // Simulated playback
                        self.currentTime += 1
                        if self.currentTime >= self.duration {
                            self.currentTime = 0 // Loop
                        }
                    }
                    self.updateNowPlayingInfo()
                }
            }
        }
    }
    
    private func stopTimeUpdates() {
        timeUpdateTimer?.invalidate()
        timeUpdateTimer = nil
        displayLink?.invalidate()
        displayLink = nil
    }
    
    // MARK: - Sleep Timer
    private var sleepTimer: Timer?
    
    func setSleepTimer(minutes: Int) {
        cancelSleepTimer()
        
        if minutes > 0 {
            sleepTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(minutes * 60), repeats: false) { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.fadeOutAndStop()
                }
            }
        }
    }
    
    func cancelSleepTimer() {
        sleepTimer?.invalidate()
        sleepTimer = nil
    }
    
    private func fadeOutAndStop() {
        // Gradually reduce volume over 10 seconds
        let fadeSteps = 20
        let fadeInterval = 0.5
        var step = 0
        
        Timer.scheduledTimer(withTimeInterval: fadeInterval, repeats: true) { [weak self] timer in
            Task { @MainActor [weak self] in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                
                step += 1
                let volume = Float(1.0 - (Double(step) / Double(fadeSteps)))
                self.audioPlayer?.volume = max(0, volume)
                
                if step >= fadeSteps {
                    timer.invalidate()
                    self.stop()
                    self.audioPlayer?.volume = 1.0 // Reset for next play
                }
            }
        }
    }
}

// MARK: - AVAudioPlayerDelegate
extension AudioService: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            // Audio finished (shouldn't happen with loop, but handle anyway)
            if flag && audioPlayer?.numberOfLoops != -1 {
                stop()
            }
        }
    }
    
    nonisolated func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        Task { @MainActor in
            print("Audio decode error: \(error?.localizedDescription ?? "Unknown")")
            stop()
        }
    }
}

/*
 IMPORTANT: Background Audio Setup
 
 For sleep sounds to continue playing when:
 - The app is in the background
 - The device is locked
 - The user switches to another app
 
 You MUST enable Background Modes in Xcode:
 
 1. Select your app target
 2. Go to "Signing & Capabilities"
 3. Click "+ Capability"
 4. Add "Background Modes"
 5. Check "Audio, AirPlay, and Picture in Picture"
 
 This adds to Info.plist:
 <key>UIBackgroundModes</key>
 <array>
     <string>audio</string>
 </array>
 
 The audio session category is set to .playback which allows background audio.
 
 The Now Playing integration:
 - Shows track info on Lock Screen
 - Shows in Control Center
 - Provides play/pause controls
 - Integrates with AirPods/Bluetooth headphone controls
 */

