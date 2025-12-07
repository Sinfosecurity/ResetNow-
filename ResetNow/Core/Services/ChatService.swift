//
//  ChatService.swift
//  ResetNow
//
//  AI Chat service protocol and mock implementation
//

import Foundation

// MARK: - Chat Service Protocol
protocol ChatService {
    /// Send a message and receive a response
    /// - Parameters:
    ///   - message: The user's message
    ///   - history: Previous messages in the conversation for context
    /// - Returns: Rae's response message
    func send(message: String, history: [ChatMessage]) async throws -> ChatMessage
}

// MARK: - Chat Response
struct ChatResponse {
    let text: String
    let safetyFlag: String?
    let suggestedTool: ResetToolKind?
}

// MARK: - Mock Chat Service
/// Mock implementation that returns supportive canned responses
/// TODO: Replace with real LLM API integration in future version
/// DO NOT hard-code any API keys or external endpoints
final class MockChatService: ChatService {
    
    // Crisis keywords that trigger safety response
    private let crisisKeywords = [
        "kill myself", "suicide", "suicidal", "end my life", "want to die",
        "hurt myself", "self harm", "self-harm", "cutting", "overdose",
        "jump off", "hang myself", "don't want to live", "no reason to live",
        "better off dead", "can't go on", "end it all"
    ]
    
    func send(message: String, history: [ChatMessage]) async throws -> ChatMessage {
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64.random(in: 800_000_000...1_500_000_000))
        
        let lowercased = message.lowercased()
        
        // Check for crisis keywords first - SAFETY PRIORITY
        if containsCrisisKeywords(lowercased) {
            return createCrisisResponse(chatSessionId: history.first?.chatSessionId ?? UUID())
        }
        
        // Generate supportive response based on content
        let response = generateResponse(for: lowercased, history: history)
        
        return ChatMessage(
            id: UUID(),
            chatSessionId: history.first?.chatSessionId ?? UUID(),
            sender: .rae,
            createdAt: Date(),
            text: response.text,
            safetyFlag: response.safetyFlag
        )
    }
    
    private func containsCrisisKeywords(_ message: String) -> Bool {
        crisisKeywords.contains { message.contains($0) }
    }
    
    private func createCrisisResponse(chatSessionId: UUID) -> ChatMessage {
        let crisisText = """
        I hear that you're going through something really difficult right now, and I want you to know that what you're feeling matters.
        
        I'm not able to provide the kind of support you need in this moment, but there are people trained to help who are available right now.
        
        Please reach out to:
        • 988 Suicide & Crisis Lifeline (call or text 988)
        • Crisis Text Line (text HOME to 741741)
        • Your local emergency services (911)
        
        You deserve support from people who can truly help. You're not alone in this. 💚
        
        If you're in immediate danger, please call emergency services right away.
        """
        
        return ChatMessage(
            id: UUID(),
            chatSessionId: chatSessionId,
            sender: .rae,
            createdAt: Date(),
            text: crisisText,
            safetyFlag: "crisis_detected"
        )
    }
    
    private func generateResponse(for message: String, history: [ChatMessage]) -> ChatResponse {
        // Anxiety-related keywords
        if message.contains("anxious") || message.contains("anxiety") || message.contains("worried") || message.contains("panic") {
            let responses = [
                ChatResponse(
                    text: "I hear you. Anxiety can feel overwhelming, but you're not alone in this. Would you like to try a quick breathing exercise? It can help calm your nervous system in just a few minutes.",
                    safetyFlag: nil,
                    suggestedTool: .breathe
                ),
                ChatResponse(
                    text: "Thank you for sharing that with me. Anxiety is something many people experience, and it's okay to feel this way. Sometimes grounding yourself helps—try noticing 5 things you can see around you right now. Would you like to try a guided grounding exercise?",
                    safetyFlag: nil,
                    suggestedTool: .visualize
                ),
                ChatResponse(
                    text: "That sounds really tough, and I appreciate you opening up. Remember, this feeling will pass. Would you like me to suggest a calming visualization or a simple breathing technique?",
                    safetyFlag: nil,
                    suggestedTool: .breathe
                )
            ]
            return responses.randomElement()!
        }
        
        // Sleep-related
        if message.contains("sleep") || message.contains("tired") || message.contains("insomnia") || message.contains("can't rest") {
            let responses = [
                ChatResponse(
                    text: "Sleep troubles can be so frustrating. Have you tried our Sleep sounds? Gentle rain or ocean waves can really help. Would you like to try the 4-7-8 breathing technique? It's designed specifically for relaxation and sleep.",
                    safetyFlag: nil,
                    suggestedTool: .sleep
                ),
                ChatResponse(
                    text: "I understand how hard it is when sleep doesn't come easily. Sometimes a body scan before bed can help release tension you didn't know you were holding. Want me to guide you through one?",
                    safetyFlag: nil,
                    suggestedTool: .visualize
                )
            ]
            return responses.randomElement()!
        }
        
        // Stress/overwhelm
        if message.contains("stress") || message.contains("overwhelm") || message.contains("too much") {
            let responses = [
                ChatResponse(
                    text: "When everything feels like too much, sometimes the simplest thing helps most: one deep breath. Let's try together—breathe in slowly for 4 counts, then out for 6. You're doing great just by being here.",
                    safetyFlag: nil,
                    suggestedTool: .breathe
                ),
                ChatResponse(
                    text: "I'm here with you. It's okay to feel overwhelmed—life can be a lot sometimes. Would you like to try a calming game to give your mind a gentle break? Or we could do some breathing together.",
                    safetyFlag: nil,
                    suggestedTool: .games
                )
            ]
            return responses.randomElement()!
        }
        
        // Sad/down
        if message.contains("sad") || message.contains("down") || message.contains("depressed") || message.contains("lonely") {
            let responses = [
                ChatResponse(
                    text: "I'm sorry you're feeling this way. It takes courage to share that. Would it help to read some gentle affirmations, or would you prefer to just talk? I'm here to listen.",
                    safetyFlag: nil,
                    suggestedTool: .affirm
                ),
                ChatResponse(
                    text: "Thank you for trusting me with how you're feeling. Sadness is a part of being human, and it's okay to feel it. Sometimes writing down our thoughts in a journal can help process difficult feelings. Would you like to try that?",
                    safetyFlag: nil,
                    suggestedTool: .journal
                )
            ]
            return responses.randomElement()!
        }
        
        // Greetings
        if message.contains("hello") || message.contains("hi") || message.contains("hey") {
            return ChatResponse(
                text: "Hello! I'm Rae, your wellbeing companion. How are you feeling today? I'm here to listen and help however I can.",
                safetyFlag: nil,
                suggestedTool: nil
            )
        }
        
        // Gratitude/positive
        if message.contains("thank") || message.contains("grateful") || message.contains("better") {
            return ChatResponse(
                text: "I'm so glad to hear that. Remember, taking time for yourself is important, and you're doing great. Is there anything else on your mind?",
                safetyFlag: nil,
                suggestedTool: nil
            )
        }
        
        // Work/School stress
        if message.contains("work") || message.contains("job") || message.contains("school") || message.contains("study") || message.contains("boss") {
            let responses = [
                ChatResponse(
                    text: "It sounds like there's a lot of pressure on you right now. Remember, your worth isn't defined by your productivity. Have you taken a small break today?",
                    safetyFlag: nil,
                    suggestedTool: .breathe
                ),
                ChatResponse(
                    text: "Work and school can be so draining. It's important to set boundaries for your own well-being. How does your body feel when you think about these tasks?",
                    safetyFlag: nil,
                    suggestedTool: nil
                )
            ]
            return responses.randomElement()!
        }

        // Relationships/Family
        if message.contains("family") || message.contains("friend") || message.contains("partner") || message.contains("fight") || message.contains("argument") {
            let responses = [
                ChatResponse(
                    text: "Relationships can be really complicated. It's okay to feel hurt or confused. I'm here to listen if you want to vent more about what happened.",
                    safetyFlag: nil,
                    suggestedTool: nil
                ),
                ChatResponse(
                    text: "That sounds difficult. Connection is important, but so is your peace. What do you think you need most right now—space or support?",
                    safetyFlag: nil,
                    suggestedTool: .affirm
                )
            ]
            return responses.randomElement()!
        }

        // Default supportive responses - Expanded for variety
        let defaultResponses = [
            ChatResponse(
                text: "I'm listening. Please go on.",
                safetyFlag: nil,
                suggestedTool: nil
            ),
            ChatResponse(
                text: "That makes sense. How long have you been feeling this way?",
                safetyFlag: nil,
                suggestedTool: nil
            ),
            ChatResponse(
                text: "I appreciate you sharing that. It sounds like a lot to carry.",
                safetyFlag: nil,
                suggestedTool: nil
            ),
            ChatResponse(
                text: "I'm here with you. Take your time.",
                safetyFlag: nil,
                suggestedTool: nil
            ),
            ChatResponse(
                text: "It's okay to not have all the answers right now. Just breathing through it is enough.",
                safetyFlag: nil,
                suggestedTool: .breathe
            ),
            ChatResponse(
                text: "Thank you for trusting me. I want to support you—what would be most helpful right now?",
                safetyFlag: nil,
                suggestedTool: nil
            ),
            ChatResponse(
                text: "I hear you. Sometimes just saying it out loud (or typing it) helps a little. How does it feel to share that?",
                safetyFlag: nil,
                suggestedTool: nil
            ),
            ChatResponse(
                text: "You're doing the best you can, and that is enough. Is there a specific part of this that feels hardest?",
                safetyFlag: nil,
                suggestedTool: nil
            ),
            ChatResponse(
                text: "I'm here. You don't have to go through this alone.",
                safetyFlag: nil,
                suggestedTool: nil
            ),
            ChatResponse(
                text: "That sounds really valid. Be gentle with yourself today.",
                safetyFlag: nil,
                suggestedTool: .affirm
            )
        ]
        
        return defaultResponses.randomElement()!
    }
}

// MARK: - Chat Service Error
enum ChatServiceError: Error {
    case networkError
    case invalidResponse
    case rateLimited
}

/*
 TODO: Future LLM Integration
 
 To integrate a real LLM API:
 
 1. Create a new class implementing ChatService (e.g., OpenAIChatService)
 
 2. Store API keys securely:
    - Use Keychain for local storage
    - Or fetch from a secure backend
    - NEVER hard-code API keys in source code
 
 3. Implement the send() method to:
    - Format messages for the API
    - Send request with proper headers
    - Parse response
    - Always check for crisis keywords locally BEFORE sending to API
    - Always include safety instructions in the system prompt
 
 4. System prompt should include:
    - Identity: \"You are Rae, a supportive wellbeing companion... \"
    - Boundaries: \"You are not a doctor, therapist, or emergency service... \"
    - Safety: \"If user mentions self-harm, always respond with crisis resources... \"
    - Never provide: "Instructions on self-harm, suicide, violence, or harmful content"
 
 5. Update the app to use dependency injection to swap implementations
 
 Example skeleton:
 
 class OpenAIChatService: ChatService {
     private let apiKeyProvider: () -> String?
     
     init(apiKeyProvider: @escaping () -> String?) {
         self.apiKeyProvider = apiKeyProvider
     }
     
     func send(message: String, history: [ChatMessage]) async throws -> ChatMessage {
         // Check crisis keywords locally first
         if containsCrisisKeywords(message) {
             return createLocalCrisisResponse()
         }
         
         guard let apiKey = apiKeyProvider() else {
             throw ChatServiceError.networkError
         }
         
         // Make API request...
     }
 }
 */

