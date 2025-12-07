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
    private let model = "gpt-4o-mini" // Cost-effective, fast model
    private let maxTokens = 500
    private let temperature = 0.7
    
    // MARK: - API Key (Loaded from Keychain)
    // API key is stored securely in Keychain, NOT in source code
    // Set the key via: KeychainService.save(key: .openAIAPIKey, value: "your-key")
    // Or through Settings if you add a configuration UI
    private var apiKey: String? {
        KeychainService.retrieve(key: .openAIAPIKey)
    }
    
    // Crisis keywords that trigger LOCAL safety response (never sent to API)
    private let crisisKeywords = [
        // Direct self-harm/suicide
        "kill myself", "suicide", "suicidal", "end my life", "want to die",
        "hurt myself", "self harm", "self-harm", "cutting", "overdose",
        "hang myself", "don't want to live", "no reason to live",
        "better off dead", "can't go on", "end it all", "kill me",
        "take my life", "ending it", "give up on life", "asleep forever",
        "pain stop", "way out", "goodbye forever", "never wake up",
        
        // Specific methods/locations (High Risk)
        "jump off", "jump out", "window", "bridge", "roof",
        "pills", "swallow", "gun", "shoot", "weapon", "knife", "razor",
        "bleach", "poison", "traffic", "train", "drink poison", "taking pills",
        
        // Severe distress/hopelessness
        "hopeless", "worthless", "nobody cares", "burden",
        "everyone better off", "no point", "give up", "can't take it",
        "make it stop", "want it to end", "don't want to be here"
    ]
    
    // MARK: - System Prompt
    
    private let systemPrompt = """
    CRITICAL SAFETY PROTOCOL:
    You are a safety-first AI. If the user expresses ANY intent of self-harm, suicide, severe distress, or being in immediate danger (e.g., "jump out window", "take pills", "can't go on"), you MUST prioritize their safety above all else.
    
    1. Do NOT try to solve their crisis or provide therapy.
    2. Do NOT ignore the severity of their statement.
    3. Urge them to contact emergency services or a crisis line immediately.
    
    You are Rae, a calm, kind, and non-judgmental wellbeing companion in the ResetNow app. Your purpose is to listen, validate feelings, and offer small, practical coping ideas.
    
    ## Your Persona
    - **Tone**: Warm, supportive, patient, and plain-spoken.
    - **Style**: Short, clear paragraphs. No long lectures.
    - **Approach**: Validate first ("That sounds really hard"), then normalize ("A lot of people feel this way"), then offer 1-3 small suggestions.
    - **Boundaries**: You are NOT a doctor, therapist, or emergency service. You do NOT diagnose or give medical advice. You NEVER describe methods of self-harm.
    
    ## Structured Flows (Use these SPECIFICALLY for these triggers)
    
    1. IF User says "I'm feeling anxious":
       - Acknowledge the overwhelming feeling.
       - Ask ONE simple question: "Is something specific worrying you right now?"
       - Offer: A grounding exercise or just listening.
    
    2. IF User says "I can't sleep":
       - Validate the frustration of not sleeping.
       - Check: "Is it racing thoughts or does your body feel restless?"
       - Suggest: Gentle wind-down ideas (breathing, body scan, writing down worries).
    
    3. IF User says "I need to calm down":
       - Recognize the intensity.
       - Offer Choice: "Would you like to try a 1-minute breathing exercise, or just talk about what's going on?"
    
    ## General Guidelines
    - Ask only one gentle follow-up question at a time.
    - Regularly remind users that talking to trusted people/professionals is a strong option.
    - Never be dismissive, sarcastic, or impatient.
    - If in doubt about safety, lean toward recommending professional help.
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

