//
//  ChatView.swift
//  ResetNow
//
//  AI companion chat with Rae - includes safety features
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var persistence: PersistenceController
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    @State private var messages: [ChatMessage] = []
    @State private var inputText = ""
    @State private var isTyping = false
    @State private var showSafetyResources = false
    @State private var currentSession: ChatSession?
    @FocusState private var isInputFocused: Bool
    
    // Uses real OpenAI if API key is configured, otherwise falls back to mock
    private let chatService: ChatService = OpenAIChatService()
    
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                colorScheme == .dark ? Color(hex: "0F172A") : Color.creamWhite,
                colorScheme == .dark ? Color(hex: "1A2F23") : Color.calmSage.opacity(0.1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var inputFieldFill: Color {
        colorScheme == .dark ? Color(hex: "2C2C2E") : Color.white.opacity(0.5)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Subtle calming background
                backgroundGradient
                .ignoresSafeArea()
                .onTapGesture {
                    isInputFocused = false
                }
                
                VStack(spacing: 0) {
                    // Safety banner (Guideline 1.4.1 compliance)
                    safetyBanner
                    
                    // Messages
                    messagesScrollView
                    
                    // Input area
                    inputArea
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .navigationTitle("Chat with Rae")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: goToHome) {
                        HStack(spacing: 4) {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                        .font(ResetTypography.caption(14))
                        .foregroundColor(.calmSage)
                        .frame(minWidth: 44, minHeight: 44)
                        .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Home")
                    .accessibilityHint("Returns to the main screen")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showSafetyResources = true }) {
                        Label("Safety", systemImage: "heart.circle.fill")
                            .labelStyle(.titleAndIcon)
                            .font(ResetTypography.caption(12))
                            .foregroundColor(.sosRed)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.sosRed.opacity(0.1)))
                            .frame(minWidth: 44, minHeight: 44)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Safety Resources")
                    .accessibilityHint("Opens emergency contact information")
                }
                
                // Keyboard Dismissal
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isInputFocused = false
                    }
                    .foregroundColor(.calmSage)
                }
            }
            .sheet(isPresented: $showSafetyResources) {
                SOSResourcesView()
            }
        }
        .onAppear {
            setupChat()
        }
    }
    
    private func goToHome() {
        // Switch to the home/journey tab
        appState.selectedTab = 0
    }
    
    // MARK: - Safety Banner
    private var safetyBanner: some View {
        HStack(spacing: ResetSpacing.sm) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 14))
            
            Text("Rae is a wellbeing companion, not a doctor, therapist, or emergency service.")
                .font(ResetTypography.caption(11))
        }
        .foregroundColor(.secondary)
        .padding(.horizontal, ResetSpacing.md)
        .padding(.vertical, ResetSpacing.sm)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Messages Scroll View
    private var messagesScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: ResetSpacing.md) {
                    ForEach(messages) { message in
                        ChatBubble(message: message)
                            .id(message.id)
                    }
                    
                    if isTyping {
                        TypingIndicator()
                            .id("typing")
                    }
                    
                    // Show quick actions if Rae just spoke (e.g. greeting) or if chat is empty
                    if !isTyping && (messages.isEmpty || messages.last?.sender == .rae) {
                        quickActionsView
                            .padding(.top, ResetSpacing.sm)
                    }
                }
                .padding(.horizontal, ResetSpacing.md)
                .padding(.vertical, ResetSpacing.md)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: messages.count) {
                withAnimation {
                    if let lastId = messages.last?.id {
                        proxy.scrollTo(lastId, anchor: .bottom)
                    } else {
                        proxy.scrollTo("typing", anchor: .bottom)
                    }
                }
            }
        }
    }
    
    // MARK: - Quick Actions
    private var quickActionsView: some View {
        VStack(spacing: ResetSpacing.sm) {
            Text("How can I help right now?")
                .font(ResetTypography.caption(13))
                .foregroundColor(.secondary)
                .padding(.bottom, 4)
            
            SuggestedPromptButton(text: "I'm feeling anxious") {
                sendMessage("I'm feeling anxious")
            }
            SuggestedPromptButton(text: "I can't sleep") {
                sendMessage("I can't sleep")
            }
            SuggestedPromptButton(text: "I need to calm down") {
                sendMessage("I need to calm down")
            }
        }
        .padding(.vertical, ResetSpacing.md)
        .padding(.horizontal, ResetSpacing.lg)
    }
    
    // MARK: - Input Area
    private var inputArea: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: ResetSpacing.sm) {
                TextField("Type a message... ", text: $inputText, axis: .vertical)
                    .font(ResetTypography.body(16))
                    .padding(.horizontal, ResetSpacing.md)
                    .padding(.vertical, ResetSpacing.sm + 4)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(inputFieldFill)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.calmSage.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .focused($isInputFocused)
                    .lineLimit(1...4)
                
                Button(action: { sendMessage(inputText) }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(inputText.isEmpty ? .warmGray.opacity(0.3) : .calmSage)
                        .frame(minWidth: 44, minHeight: 44)
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityLabel("Send Message")
                .accessibilityHint("Sends your message to Rae")
            }
            .padding(.horizontal, ResetSpacing.md)
            .padding(.vertical, ResetSpacing.sm)
            .background(.ultraThinMaterial)
        }
    }
    
    // MARK: - Setup & Actions
    private func setupChat() {
        currentSession = persistence.getActiveOrNewChatSession()
        if let session = currentSession {
            // Check if we need to add a greeting
            if persistence.shouldTriggerGreeting(for: session.id) {
                let greeting = generateGreeting()
                persistence.addGreetingMessage(sessionId: session.id, text: greeting)
            }
            
            // Load messages
            messages = persistence.getMessages(for: session.id)
        }
    }
    
    private func generateGreeting() -> String {
        let greetings = [
            "Hi, I’m Rae, your wellbeing companion. 💚\nI’m here to listen and support you, but I’m not a doctor or therapist.\nWhat’s on your mind today?",
            "Hey, I’m Rae. Thanks for stopping by. I’m here to help you cope with stress, worry, or tough feelings, but I can’t provide medical or emergency help.\nHow are you feeling right now?",
            "Hi, I’m Rae, your companion in ResetNow. 🌱\nI can offer gentle support and ideas for calming down or coping, but I’m not an emergency service.\nWould you like to tell me what you’re going through, or tap one of the buttons below to start?"
        ]
        return greetings.randomElement() ?? greetings[0]
    }
    
    private func sendMessage(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard let session = currentSession else { return }
        
        // Add user message
        persistence.addChatMessage(sessionId: session.id, sender: .user, text: text)
        
        let userMessage = ChatMessage(
            id: UUID(),
            chatSessionId: session.id,
            sender: .user,
            createdAt: Date(),
            text: text
        )
        messages.append(userMessage)
        inputText = ""
        
        // Show typing indicator
        isTyping = true
        
        // Get AI response
        Task {
            do {
                let response = try await chatService.send(message: text, history: messages)
                
                await MainActor.run {
                    isTyping = false
                    messages.append(response)
                    persistence.addChatMessage(
                        sessionId: session.id,
                        sender: .rae,
                        text: response.text,
                        safetyFlag: response.safetyFlag
                    )
                    
                    // Show safety resources if crisis detected
                    if response.safetyFlag == "crisis_detected" {
                        showSafetyResources = true
                    }
                }
            } catch {
                await MainActor.run {
                    isTyping = false
                    // Show empathetic error message
                    let errorMessage = ChatMessage(
                        id: UUID(),
                        chatSessionId: session.id,
                        sender: .rae,
                        createdAt: Date(),
                        text: "I'm having trouble responding right now, but I'm still here with you. Could you try sending that again? If you're in crisis, please reach out to 988 or 741741."
                    )
                    messages.append(errorMessage)
                }
            }
        }
    }
}

// MARK: - Chat Bubble
struct ChatBubble: View {
    let message: ChatMessage
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appState: AppState
    
    var isUser: Bool { message.sender == .user }
    var isCrisis: Bool { message.safetyFlag == "crisis_detected" }
    
    private var bubbleGradient: LinearGradient {
        if isUser {
            return LinearGradient(
                colors: [Color.calmSage, Color.calmSage.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if isCrisis {
            return LinearGradient(
                colors: [
                    Color.sosRed.opacity(0.1),
                    Color.sosRed.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [
                    colorScheme == .dark ? Color(hex: "2C2C2E") : Color.white,
                    colorScheme == .dark ? Color(hex: "1C1C1E") : Color.white.opacity(0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    var body: some View {
        HStack {
            if isUser { Spacer() }
            
            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                if !isUser {
                    HStack(spacing: ResetSpacing.sm) {
                        Image("MascotBlue")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 34)
                        Text("Rae")
                            .font(ResetTypography.caption(12))
                            .foregroundColor(.secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    if isCrisis {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.sosRed)
                            Text("Safety Check")
                                .font(ResetTypography.caption(12).weight(.bold))
                                .foregroundColor(.sosRed)
                        }
                        .padding(.bottom, 4)
                    }
                    
                    Text(message.text)
                        .font(ResetTypography.body(15))
                        .foregroundColor(isUser ? .white : .primary)
                }
                .padding(.horizontal, ResetSpacing.md)
                .padding(.vertical, ResetSpacing.sm + 4)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(bubbleGradient)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(isCrisis ? Color.sosRed.opacity(0.8) : Color.clear, lineWidth: 2)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                
                if isCrisis {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.circle.fill")
                        Text("Support resources available")
                    }
                    .font(ResetTypography.caption(11))
                    .foregroundColor(.sosRed)
                    .padding(.leading, 4)
                }
                
                Text(message.createdAt.formatted(date: .omitted, time: .shortened))
                    .font(ResetTypography.caption(10))
                    .foregroundColor(.warmGray.opacity(0.7))
                
                // Tool Suggestion Chip
                if let tool = message.suggestedTool {
                    Button(action: { appState.activeTool = tool }) {
                        HStack(spacing: 4) {
                            Image(systemName: tool.iconName)
                            Text("Try " + tool.displayName)
                        }
                        .font(ResetTypography.caption(12).weight(.medium))
                        .foregroundColor(isUser ? .calmSage : .white)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(
                            Capsule()
                                .fill(isUser ? Color.white : Color.calmSage)
                                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                        )
                    }
                    .padding(.top, 2)
                    .accessibilityLabel("Open \(tool.displayName)")
                }
            }
            .frame(maxWidth: 280, alignment: isUser ? .trailing : .leading)
            
            if !isUser { Spacer() }
        }
    }
}

// MARK: - Typing Indicator
struct TypingIndicator: View {
    @State private var animating = false
    
    var body: some View {
        HStack {
            HStack(spacing: ResetSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(Color.calmSage.opacity(0.2))
                        .frame(width: 28, height: 28)
                    Text("R")
                        .font(ResetTypography.caption(14))
                        .foregroundColor(.calmSage)
                }
                
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(Color.warmGray.opacity(0.5))
                            .frame(width: 8, height: 8)
                            .offset(y: animating ? -4 : 0)
                            .animation(
                                Animation.easeInOut(duration: 0.4)
                                    .repeatForever()
                                    .delay(Double(index) * 0.15),
                                value: animating
                            )
                    }
                }
                .padding(.horizontal, ResetSpacing.md)
                .padding(.vertical, ResetSpacing.sm + 4)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
            }
            Spacer()
        }
        .onAppear { animating = true }
    }
}

// MARK: - Suggested Prompt Button
struct SuggestedPromptButton: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(ResetTypography.body(14))
                .foregroundColor(.calmSage)
                .padding(.horizontal, ResetSpacing.lg)
                .padding(.vertical, ResetSpacing.sm + 2)
                .background(
                    Capsule()
                        .stroke(Color.calmSage, lineWidth: 1.5)
                )
        }
        .accessibilityLabel("Suggestion: \(text)")
        .accessibilityHint("Sends this message to Rae")
    }
}

// MARK: - Preview
struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
            .environmentObject(PersistenceController.shared)
            .environmentObject(AppState())
    }
}

