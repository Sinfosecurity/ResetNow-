//
//  OpenAIChatService.swift
//  ResetNow
//
//  Real AI chat service using OpenAI GPT API
//  API key loaded securely from Keychain - NEVER hardcode secrets
//

import Foundation

/// OpenAI Chat Service - Real AI-powered responses from GPT
final class OpenAIChatService: ChatService {
    
    // MARK: - Configuration
    
    private let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")!
    private let model = "gpt-4o" // Most capable model for nuanced conversations
    private let maxTokens = 500
    private let temperature = 0.4 // Lower for consistent, careful responses in mental health context
    
    // MARK: - API Key (Loaded from Keychain)
    // API key is stored securely in Keychain, NOT in source code
    // Set the key via: KeychainService.save(key: .openAIAPIKey, value: "your-key")
    // Or through Settings if you add a configuration UI
    private var apiKey: String? {
        KeychainService.retrieve(key: .openAIAPIKey)
    }
    
    // Crisis keywords that trigger LOCAL safety response (never sent to API)
    // CRITICAL: This list must be comprehensive - lives depend on it
    private let crisisKeywords = [
        // Direct self-harm/suicide - explicit
        "kill myself", "suicide", "suicidal", "end my life", "want to die",
        "hurt myself", "self harm", "self-harm", "cutting", "overdose",
        "hang myself", "don't want to live", "no reason to live",
        "better off dead", "can't go on", "end it all", "kill me",
        "take my life", "ending it", "give up on life", "asleep forever",
        "pain stop", "way out", "goodbye forever", "never wake up",
        
        // Cutting/self-injury variations - CRITICAL
        "cut myself", "cut my wrist", "cut my arm", "cut my leg", "cut my skin",
        "cut me", "cutting myself", "slit my wrist", "slit my", "slice my",
        "scratch myself", "burn myself", "burning myself", "hurting myself",
        "harm myself", "harming myself", "injure myself", "injuring myself",
        
        // Coded/slang terms users actually use
        "unalive", "unaliving", "kms", "kys", "ctb", "catch the bus",
        "final exit", "peaceful pill", "end myself", "off myself",
        "do it tonight", "won't be here tomorrow", "last day",
        "say goodbye", "writing notes", "goodbye letter", "final letter",
        
        // Specific methods/locations (High Risk) - Use phrases to avoid false positives
        "jump off a", "jump off the", "jump out the", "jump from", "jumping off",
        "off a bridge", "off the bridge", "off a building", "off the roof",
        "take pills", "take all my pills", "swallow pills", "overdose on",
        "use a gun", "shoot myself", "get a gun",
        "use a knife", "with a knife", "stab myself",
        "drink bleach", "drink poison", "poison myself",
        "step into traffic", "walk into traffic", "in front of a train",
        "tie a noose", "hang myself", "with a rope",
        "drown myself", "drown in",
        
        // Severe distress/hopelessness
        "hopeless", "worthless", "nobody cares", "burden", "i'm a burden",
        "everyone better off", "better off without me", "no point", "give up", "can't take it",
        "make it stop", "want it to end", "don't want to be here",
        "can't do this anymore", "can't live like this", "tired of living",
        "no way out", "trapped", "no escape", "suffering too much",
        "no one would care", "no one would miss me", "disappear forever",
        "want to disappear", "wish i was dead", "wish i wasn't born",
        "shouldn't be alive", "don't deserve to live", "hate being alive"
    ]
    
    // MARK: - System Prompt
    
    private let systemPrompt = """
    You are Rae, a warm, emotionally intelligent companion inside the ResetNow app.

    Your voice blends five qualities seamlessly:

    1) Professional
    - Clear, grounded, steady presence
    - Acknowledge serious events directly (job loss, breakup, fear, shame, panic)
    - Maintain emotional safety

    2) Friendly
    - Warm, inviting tone
    - Make the user feel cared for and understood
    - Never cold or generic

    3) Light Spiritual
    - Uplifting, gentle, universal (not religious)
    - Reference breath, inner calm, grounding, clarity, presence

    4) Therapist-like
    - Reflective, validating language
    - Ask gentle, open-ended questions
    - Help the user explore their feelings, not fix them
    - Never diagnose or label
    - Use grounding techniques when needed

    5) Calm Best Friend
    - Supportive, steady, comforting
    - Speak with genuine empathy
    - Encourage small steps and self-kindness

    -----------------------------------

    CORE BEHAVIOR

    A) ALWAYS acknowledge major events directly.
    If user says: "I was fired"
    You say:
    "I'm really sorry you're going through that. Losing a job is a heavy moment. I'm here with you — how are you feeling right now?"

    B) NEVER minimize the user's emotions.

    C) Use short, warm responses (2–5 sentences).

    D) End with a gentle question that helps them reflect:
    - "What part feels the heaviest right now?"
    - "Where do you feel this in your body?"
    - "Would grounding together help?"

    E) Follow the user's emotional pace — don't rush, don't shift topics too quickly.

    F) If distress increases, offer grounding:
    - "Let's take one slow breath together."
    - "Notice your shoulders and let them soften."

    G) Crisis Safety:
    If user expresses self-harm → respond with compassion and encourage immediate real-world help (988, 741741, 911).

    -----------------------------------

    Your purpose:
    Help the user feel seen, calmer, supported, and understood — never judged or dismissed.
    """
    
    // MARK: - Send Message
    
    func send(message: String, history: [ChatMessage]) async throws -> ChatMessage {
        let lowercased = message.lowercased()
        
        // SAFETY FIRST: Check for crisis keywords LOCALLY before sending to API
        // This ensures crisis response even if API fails
        if containsCrisisKeywords(lowercased) {
            return createCrisisResponse(chatSessionId: history.first?.chatSessionId ?? UUID())
        }
        
        // Verify API key is available from Keychain
        guard let key = apiKey, !key.isEmpty else {
            print("⚠️ OpenAI API key not found in Keychain. Using mock response.")
            print("💡 Set key via: KeychainService.save(key: .openAIAPIKey, value: \"your-key\")")
            return try await fallbackToMock(message: message, history: history)
        }
        
        // Build messages array for API
        var messages: [[String: String]] = [
            ["role": "system", "content": systemPrompt]
        ]
        
        // Add conversation history (last 10 messages for context)
        let recentHistory = history.suffix(10)
        for msg in recentHistory {
            let role = msg.sender == .user ? "user" : "assistant"
            messages.append(["role": role, "content": msg.text])
        }
        
        // Add current message
        messages.append(["role": "user", "content": message])
        
        // Build request body
        let requestBody: [String: Any] = [
            "model": model,
            "messages": messages,
            "max_tokens": maxTokens,
            "temperature": temperature
        ]
        
        // Create request
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        request.timeoutInterval = 30
        
        do {
            // Make API call
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Check HTTP status
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ChatServiceError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200:
                break // Success
            case 401:
                print("❌ OpenAI API: Invalid API key")
                throw ChatServiceError.invalidAPIKey
            case 429:
                print("⚠️ OpenAI API: Rate limited")
                throw ChatServiceError.rateLimited
            case 500...599:
                print("❌ OpenAI API: Server error \(httpResponse.statusCode)")
                throw ChatServiceError.serverError
            default:
                print("❌ OpenAI API: Unexpected status \(httpResponse.statusCode)")
                throw ChatServiceError.networkError
            }
            
            // Parse response
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let messageDict = firstChoice["message"] as? [String: Any],
                  let content = messageDict["content"] as? String else {
                throw ChatServiceError.invalidResponse
            }
            
            // Check AI response for any crisis content (safety double-check)
            let safetyFlag: String? = containsCrisisKeywords(content.lowercased()) ? "crisis_mentioned" : nil
            
            return ChatMessage(
                id: UUID(),
                chatSessionId: history.first?.chatSessionId ?? UUID(),
                sender: .rae,
                createdAt: Date(),
                text: content.trimmingCharacters(in: .whitespacesAndNewlines),
                safetyFlag: safetyFlag
            )
            
        } catch let error as ChatServiceError {
            throw error
        } catch {
            print("❌ OpenAI API Error: \(error.localizedDescription)")
            // Fall back to mock on network errors
            return try await fallbackToMock(message: message, history: history)
        }
    }
    
    // MARK: - Crisis Detection (Local)
    
    private func containsCrisisKeywords(_ message: String) -> Bool {
        // Simple keyword matching - in a real app, use NLP or regex for better context
        // e.g. avoid triggering on "I am NOT suicidal" (though safe-side is better)
        crisisKeywords.contains { message.contains($0) }
    }
    
    private func createCrisisResponse(chatSessionId: UUID) -> ChatMessage {
        let crisisText = """
        You’re important, and I want you to be safe. 💚
        
        I am an AI companion, so I cannot provide the crisis care you need right now. Please contact real-world help immediately.
        
        **Support is available 24/7:**
        • **988** - Suicide & Crisis Lifeline
        • **741741** - Crisis Text Line
        • **911** - Emergency Services
        
        Please reach out to them or a trusted friend now.
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
    
    // MARK: - Fallback
    
    private func fallbackToMock(message: String, history: [ChatMessage]) async throws -> ChatMessage {
        // Use mock service as fallback
        let mockService = MockChatService()
        return try await mockService.send(message: message, history: history)
    }
}

// MARK: - Extended Errors

extension ChatServiceError {
    static let invalidAPIKey = ChatServiceError.networkError
    static let serverError = ChatServiceError.networkError
}

