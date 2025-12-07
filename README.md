# ResetNow v1.0 (MVP)

**A gentle companion for anxiety and stress support**

ResetNow is an iOS app that gives people quick, gentle tools to calm their nervous system: breathing exercises, visualizations, sleep sounds, mini-games, affirmations, and an AI companion called Rae.

## ✨ Features

### Reset Tools
- **Learn** - Evidence-based lessons about anxiety (with medical citations)
- **Breathe** - Guided breathing exercises with animated visuals
- **Games** - Calm mini-games (Bubble Pop, Memory)
- **Journal** - Lightweight journaling with prompts
- **Visualize** - Guided body scans and grounding exercises
- **Sleep** - Long-playing ambient sounds with background audio support
- **Affirm** - Daily affirmations with favorites
- **Journeys** - Multi-step guided programs

### AI Companion - Rae
- Supportive, non-judgmental chat interface
- Crisis keyword detection with automatic safety response
- Suggests tools based on user's feelings
- Clear disclaimers about limitations

### Safety Features
- SOS button with 988, Crisis Text Line, and more
- Crisis detection in AI chat
- Prominent safety disclaimers throughout

### Widgets
- Home Screen widget (small/medium)
- Lock Screen widget (accessoryRectangular)
- Deep links to app features

## 📱 Platforms

- iOS 16.0+
- iPhone (primary)
- iPad (universal build)

## 🛠 Technical Stack

- **SwiftUI** - Declarative UI
- **MVVM Architecture** - Clean separation of concerns
- **Swift Concurrency** - async/await patterns
- **JSON Persistence** - Local data storage
- **AVFoundation** - Background audio with Now Playing integration
- **WidgetKit** - Home Screen and Lock Screen widgets

## 📁 Project Structure

```
ResetNow/
├── ResetNowApp.swift
├── ContentView.swift
├── Core/
│   ├── Models/
│   │   └── Models.swift
│   ├── Services/
│   │   ├── PersistenceController.swift
│   │   ├── ChatService.swift
│   │   └── AudioService.swift
│   └── Theme/
│       └── Theme.swift
├── Features/
│   ├── Home/
│   │   ├── MyJourneyView.swift
│   │   └── SOSResourcesView.swift
│   ├── Chat/
│   │   └── ChatView.swift
│   ├── Stats/
│   │   └── MyStatsView.swift
│   ├── Settings/
│   │   └── SettingsView.swift
│   ├── Tools/
│   │   └── ToolViews.swift
│   └── Legal/
│       ├── MedicalSourcesView.swift
│       ├── ResearchReferencesView.swift
│       └── SupportContactView.swift
└── ResetNowWidgetExtension/
    └── ResetNowWidget.swift
```

## 📋 App Store Compliance

This app has been designed to address previous App Store review feedback:

### Guideline 1.4.1 - Medical Citations
- ✅ Evidence-based sources listed in Learn hub
- ✅ Medical Sources & Citations screen with 12+ authoritative sources
- ✅ Research References screen with peer-reviewed citations
- ✅ Disclaimers throughout the app

### Guideline 1.5 - Support URL
- ✅ Support & Contact screen in Settings
- ✅ Email support link with device info
- ✅ Support website link (configure URL before submission)

### Guidelines 2.1, 3.1.2 - No In-App Purchases
- ✅ Completely FREE app with NO active IAP/subscriptions
- ✅ Locked features show "Coming Soon" (not tied to payment)
- ✅ No StoreKit, paywalls, or price labels

### Guideline 3.1.2 - Privacy & Terms
- ✅ Privacy Policy link in Settings
- ✅ Terms of Use link in Settings
- ✅ URLs configurable in Theme.swift

### Guideline 2.3.3 - Screenshots
- ✅ Adaptive layouts for iPhone and iPad
- ✅ Native UI on all device sizes

## ⚠️ Before App Store Submission

### 1. Configure URLs
Update these in `Core/Theme/Theme.swift`:
```swift
static let privacyPolicyURL = "https://your-domain.com/privacy"
static let termsOfUseURL = "https://your-domain.com/terms"
static let supportURL = "https://your-domain.com/support"
static let supportEmail = "your-email@domain.com"
```

### 2. App Store Connect Settings
- **Support URL**: Must match `supportURL` constant (must be functional, NOT a Notion editing URL)
- **Privacy Policy URL**: Must match `privacyPolicyURL` constant
- **Marketing URL**: Optional but recommended

### 3. Enable Background Audio
In Xcode:
1. Select target → Signing & Capabilities
2. Add "Background Modes"
3. Check "Audio, AirPlay, and Picture in Picture"

### 4. Screenshot Guidelines
- **iPhone**: Use iPhone simulator, capture native UI
- **iPad 13"**: Use 13" iPad simulator, capture native iPad UI
- **DO NOT**: Embed iPhone frames inside iPad screenshots
- **Required screens**: Home, Breathe, Learn (with citations), SOS, Journal, Sleep

## 🚀 Getting Started

1. Open `ResetNow.xcodeproj` in Xcode 15+
2. Select your target device/simulator
3. Build and run (⌘R)

### Requirements
- Xcode 15.0+
- iOS 16.0+ deployment target
- Swift 5.9+

## 🔮 Future Enhancements

### In-App Purchases (Future Version)
To add IAP/subscriptions later:
1. Import StoreKit
2. Create StoreKitManager class
3. Configure products in App Store Connect
4. Add paywall UI
5. Implement receipt validation
6. Add "Restore Purchases" in Settings
7. Test with sandbox accounts

### LLM Integration (Future Version)
The ChatService protocol is ready for real LLM integration:
1. Create new class implementing ChatService
2. Store API keys securely (Keychain, not source code)
3. Always check crisis keywords locally first
4. Include safety instructions in system prompt

## 📄 License

Copyright © 2024 ResetNow. All rights reserved.

## ⚠️ Disclaimer

ResetNow is a wellbeing companion app and is NOT a substitute for:
- Professional medical advice
- Therapy or counseling
- Emergency services

If you're in crisis, contact:
- **988 Suicide & Crisis Lifeline** (US): Call or text 988
- **Crisis Text Line**: Text HOME to 741741
- Your local emergency services

---

Made with 💚 for your wellbeing
